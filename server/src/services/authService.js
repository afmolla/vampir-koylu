import bcrypt from 'bcryptjs';
import { OAuth2Client } from 'google-auth-library';
import { v4 as uuidv4 } from 'uuid';
import { config } from '../config.js';
import { getDb } from '../db/database.js';
import { ensureProfile } from './progression.js';
import { isNickOnline } from './liveStats.js';
import { isNickActiveInRooms } from '../rooms/roomStore.js';

export const DEFAULT_AVATAR_URL =
  'https://api.dicebear.com/7.x/avataaars/png?seed=guest';

function rowToUser(row) {
  if (!row) return null;
  return {
    id: row.id,
    nick: row.nick,
    isGuest: row.is_guest === 1,
    locale: row.locale,
    email: row.email ?? null,
    avatarUrl: row.avatar_url || DEFAULT_AVATAR_URL,
  };
}

export function getUserById(id) {
  const db = getDb();
  const row = db.prepare('SELECT * FROM users WHERE id = ?').get(id);
  return rowToUser(row);
}

export function getUserByEmail(email) {
  const db = getDb();
  const row = db.prepare('SELECT * FROM users WHERE email = ?').get(email);
  return rowToUser(row);
}

export function getUserByNick(nick) {
  const name = String(nick ?? '').trim();
  if (name.length < 2) return null;
  const db = getDb();
  const row = db
    .prepare('SELECT * FROM users WHERE nick = ? COLLATE NOCASE')
    .get(name);
  return rowToUser(row);
}

function isNickTaken(nick, excludeUserId = null) {
  const name = String(nick ?? '').trim();
  if (name.length < 2) return false;
  const db = getDb();
  const row = db
    .prepare('SELECT id FROM users WHERE nick = ? COLLATE NOCASE')
    .get(name);
  if (!row) return false;
  if (excludeUserId && row.id === excludeUserId) return false;
  return true;
}

function insertUser({
  id,
  nick,
  isGuest,
  locale,
  email = null,
  passwordHash = null,
  googleId = null,
  facebookId = null,
  avatarUrl = null,
}) {
  const db = getDb();
  db.prepare(
    `INSERT INTO users (
      id, nick, is_guest, locale, email, password_hash,
      google_id, facebook_id, avatar_url, created_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))`,
  ).run(
    id,
    nick,
    isGuest ? 1 : 0,
    locale,
    email,
    passwordHash,
    googleId,
    facebookId,
    avatarUrl ?? DEFAULT_AVATAR_URL,
  );
  ensureProfile(id);
  return getUserById(id);
}

function updateUser(id, fields) {
  const db = getDb();
  const sets = [];
  const vals = [];
  for (const [k, v] of Object.entries(fields)) {
    sets.push(`${k} = ?`);
    vals.push(v);
  }
  if (!sets.length) return getUserById(id);
  vals.push(id);
  db.prepare(`UPDATE users SET ${sets.join(', ')} WHERE id = ?`).run(...vals);
  return getUserById(id);
}

export function registerAccount({ email, password, nick, locale }) {
  const mail = String(email ?? '').trim().toLowerCase();
  const name = String(nick ?? '').trim();
  if (!mail.includes('@') || mail.length < 5) return { error: 'invalid_email' };
  if (String(password ?? '').length < 6) return { error: 'weak_password' };
  if (name.length < 2 || name.length > 24) return { error: 'invalid_nick' };

  if (getUserByEmail(mail)) return { error: 'email_taken' };
  if (isNickTaken(name)) return { error: 'nick_taken' };

  const hash = bcrypt.hashSync(password, 10);
  const avatarUrl = `${DEFAULT_AVATAR_URL}&seed=${encodeURIComponent(mail)}`;
  const user = insertUser({
    id: uuidv4(),
    nick: name,
    isGuest: false,
    locale: locale ?? 'tr',
    email: mail,
    passwordHash: hash,
    avatarUrl,
  });
  return { user };
}

export function loginWithEmail({ email, login, password }) {
  return loginWithCredentials({ login: login ?? email, password });
}

/** E-posta veya kullanıcı adı ile giriş */
export function loginWithCredentials({ login, password }) {
  const raw = String(login ?? '').trim();
  if (raw.length < 2) return { error: 'invalid_credentials' };

  const db = getDb();
  let row;
  if (raw.includes('@')) {
    row = db.prepare('SELECT * FROM users WHERE email = ?').get(raw.toLowerCase());
  } else {
    row = db
      .prepare('SELECT * FROM users WHERE nick = ? COLLATE NOCASE')
      .get(raw);
  }

  if (!row?.password_hash) return { error: 'invalid_credentials' };
  if (!bcrypt.compareSync(String(password ?? ''), row.password_hash)) {
    return { error: 'invalid_credentials' };
  }
  return { user: rowToUser(row) };
}

export async function loginWithGoogle({ idToken }) {
  if (!config.googleClientId) return { error: 'google_not_configured' };
  const token = String(idToken ?? '').trim();
  if (!token) return { error: 'missing_token' };

  const client = new OAuth2Client(config.googleClientId);
  let payload;
  try {
    const ticket = await client.verifyIdToken({
      idToken: token,
      audience: config.googleClientId,
    });
    payload = ticket.getPayload();
  } catch {
    return { error: 'invalid_google_token' };
  }

  const googleId = payload.sub;
  const email = payload.email?.toLowerCase() ?? null;
  const nick =
    (payload.name ?? email?.split('@')[0] ?? 'Oyuncu').slice(0, 24) || 'Oyuncu';
  const avatarUrl = payload.picture ?? DEFAULT_AVATAR_URL;

  const db = getDb();
  let row = db.prepare('SELECT * FROM users WHERE google_id = ?').get(googleId);
  if (!row && email) {
    row = db.prepare('SELECT * FROM users WHERE email = ?').get(email);
    if (row) {
      updateUser(row.id, {
        google_id: googleId,
        is_guest: 0,
        avatar_url: avatarUrl,
      });
      return { user: getUserById(row.id) };
    }
  }
  if (row) {
    updateUser(row.id, { nick, avatar_url: avatarUrl, is_guest: 0 });
    return { user: getUserById(row.id) };
  }

  const user = insertUser({
    id: uuidv4(),
    nick,
    isGuest: false,
    locale: 'tr',
    email,
    googleId,
    avatarUrl,
  });
  return { user };
}

export async function loginWithFacebook({ accessToken }) {
  if (!config.facebookAppId) return { error: 'facebook_not_configured' };
  const token = String(accessToken ?? '').trim();
  if (!token) return { error: 'missing_token' };

  let profile;
  try {
    const url = new URL('https://graph.facebook.com/me');
    url.searchParams.set('fields', 'id,name,email,picture.type(large)');
    url.searchParams.set('access_token', token);
    const res = await fetch(url);
    if (!res.ok) return { error: 'invalid_facebook_token' };
    profile = await res.json();
  } catch {
    return { error: 'facebook_api_error' };
  }

  const facebookId = profile.id;
  const email = profile.email?.toLowerCase() ?? null;
  const nick = String(profile.name ?? 'Oyuncu').slice(0, 24);
  const avatarUrl =
    profile.picture?.data?.url ?? `${DEFAULT_AVATAR_URL}&seed=fb${facebookId}`;

  const db = getDb();
  let row = db.prepare('SELECT * FROM users WHERE facebook_id = ?').get(facebookId);
  if (!row && email) {
    row = db.prepare('SELECT * FROM users WHERE email = ?').get(email);
    if (row) {
      updateUser(row.id, {
        facebook_id: facebookId,
        is_guest: 0,
        avatar_url: avatarUrl,
      });
      return { user: getUserById(row.id) };
    }
  }
  if (row) {
    updateUser(row.id, { nick, avatar_url: avatarUrl, is_guest: 0 });
    return { user: getUserById(row.id) };
  }

  const user = insertUser({
    id: uuidv4(),
    nick,
    isGuest: false,
    locale: 'tr',
    email,
    facebookId,
    avatarUrl,
  });
  return { user };
}

export function updateAccount(userId, { nick, avatarUrl, password, botDifficulty }) {
  const db = getDb();
  const user = db.prepare('SELECT * FROM users WHERE id = ?').get(userId);
  if (!user) return { error: 'not_found' };

  if (nick != null) {
    const name = String(nick).trim();
    if (name.length < 2 || name.length > 24) return { error: 'invalid_nick' };
    if (isNickTaken(name, userId)) return { error: 'nick_taken' };
    updateUser(userId, { nick: name });
  }
  if (avatarUrl != null) {
    updateUser(userId, { avatar_url: String(avatarUrl).slice(0, 500) });
  }
  if (password != null) {
    if (user.is_guest) return { error: 'guest_cannot_set_password' };
    if (String(password).length < 6) return { error: 'weak_password' };
    const hash = bcrypt.hashSync(password, 10);
    updateUser(userId, { password_hash: hash });
  }
  if (botDifficulty != null) {
    const d = ['easy', 'normal', 'hard'].includes(botDifficulty)
      ? botDifficulty
      : 'normal';
    ensureProfile(userId);
    db.prepare('UPDATE user_profiles SET bot_difficulty = ? WHERE user_id = ?').run(
      d,
      userId,
    );
  }

  return { user: getUserById(userId) };
}

export function guestLogin({ nick, locale }) {
  const name = String(nick ?? '').trim();
  if (name.length < 2 || name.length > 24) return { error: 'invalid_nick' };

  const existing = getUserByNick(name);

  // Kayıtlı üyenin takma adı misafire kapalı
  if (existing && !existing.isGuest) {
    return { error: 'nick_taken' };
  }

  // Çevrimiçi veya lobide bağlı (açık) oyuncu bu adı kullanıyorsa
  const excludeId = existing?.id ?? null;
  if (isNickOnline(name, excludeId) || isNickActiveInRooms(name, excludeId)) {
    return { error: 'nick_in_use' };
  }

  const loc = locale ?? 'tr';

  // Aynı misafir hesabını yeniden kullan (yeni satır oluşturma)
  if (existing?.isGuest) {
    if (loc !== existing.locale) {
      updateUser(existing.id, { locale: loc });
    }
    return { user: getUserById(existing.id) };
  }

  const avatarUrl = `${DEFAULT_AVATAR_URL}&seed=${encodeURIComponent(name)}`;
  try {
    const user = insertUser({
      id: uuidv4(),
      nick: name,
      isGuest: true,
      locale: loc,
      avatarUrl,
    });
    return { user };
  } catch (err) {
    if (err?.code === 'SQLITE_CONSTRAINT_UNIQUE') {
      return { error: 'nick_taken' };
    }
    throw err;
  }
}
