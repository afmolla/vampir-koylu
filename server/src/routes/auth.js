import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { config } from '../config.js';
import { getDb } from '../db/database.js';

export const authRouter = Router();

function signToken(user) {
  return jwt.sign(
    { sub: user.id, isGuest: user.isGuest },
    config.jwtSecret,
    { expiresIn: config.jwtExpiresIn },
  );
}

function upsertUser(payload) {
  const db = getDb();
  const existing = db.prepare('SELECT * FROM users WHERE id = ?').get(payload.id);
  if (existing) return { ...existing, isGuest: existing.is_guest === 1 };

  db.prepare(
    'INSERT INTO users (id, nick, is_guest, locale, created_at) VALUES (?, ?, ?, ?, ?)',
  ).run(payload.id, payload.nick, payload.isGuest ? 1 : 0, payload.locale, payload.createdAt);

  return payload;
}

function getUserById(id) {
  const db = getDb();
  const row = db.prepare('SELECT * FROM users WHERE id = ?').get(id);
  if (!row) return null;
  return { id: row.id, nick: row.nick, isGuest: row.is_guest === 1, locale: row.locale };
}

authRouter.post('/guest', (req, res) => {
  const nick = String(req.body?.nick ?? '').trim();
  if (nick.length < 2 || nick.length > 24) {
    return res.status(400).json({ error: 'invalid_nick' });
  }

  const user = upsertUser({
    id: uuidv4(),
    nick,
    isGuest: true,
    locale: req.body?.locale ?? 'tr',
    createdAt: new Date().toISOString(),
  });

  res.json({
    token: signToken(user),
    user: { id: user.id, nick: user.nick, isGuest: true, locale: user.locale },
  });
});

authRouter.post('/google', (_req, res) => {
  res.status(501).json({
    error: 'not_implemented',
    message: 'Google Sign-In — configure GOOGLE_CLIENT_ID on server',
  });
});

authRouter.post('/facebook', (_req, res) => {
  res.status(501).json({
    error: 'not_implemented',
    message: 'Facebook Login — configure FACEBOOK_APP_ID on server',
  });
});

authRouter.get('/me', (req, res) => {
  const header = req.headers.authorization ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'unauthorized' });

  try {
    const payload = jwt.verify(token, config.jwtSecret);
    const user = getUserById(payload.sub);
    if (!user) return res.status(404).json({ error: 'user_not_found' });
    res.json({
      user: {
        id: user.id,
        nick: user.nick,
        isGuest: user.isGuest,
        locale: user.locale,
      },
    });
  } catch {
    res.status(401).json({ error: 'invalid_token' });
  }
});
