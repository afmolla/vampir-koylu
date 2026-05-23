import { getDb } from '../db/database.js';

const BAD_WORDS = [
  'amk',
  'aq',
  'orospu',
  'siktir',
  'sikeyim',
  'pic',
  'piç',
  'got',
  'göt',
  'fuck',
  'shit',
  'bitch',
];

export function filterProfanity(text) {
  let out = String(text);
  for (const w of BAD_WORDS) {
    const re = new RegExp(w.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'gi');
    out = out.replace(re, '*'.repeat(Math.min(w.length, 4)));
  }
  return out;
}

export function submitReport({ reporterId, targetId, targetNick, channel, reason }) {
  const db = getDb();
  db.prepare(
    `INSERT INTO user_reports (reporter_id, target_id, target_nick, channel, reason)
     VALUES (?, ?, ?, ?, ?)`,
  ).run(
    reporterId,
    targetId ?? null,
    targetNick ?? null,
    channel ?? null,
    String(reason ?? 'other').slice(0, 200),
  );
  return { ok: true };
}

export function muteUser(userId, mutedUserId) {
  const db = getDb();
  db.prepare(
    `INSERT OR IGNORE INTO chat_mutes (user_id, muted_user_id) VALUES (?, ?)`,
  ).run(userId, mutedUserId);
  return { ok: true };
}

export function unmuteUser(userId, mutedUserId) {
  const db = getDb();
  db.prepare('DELETE FROM chat_mutes WHERE user_id = ? AND muted_user_id = ?').run(
    userId,
    mutedUserId,
  );
  return { ok: true };
}

export function listMutes(userId) {
  const db = getDb();
  return db
    .prepare(
      `SELECT m.muted_user_id AS userId, u.nick
       FROM chat_mutes m
       LEFT JOIN users u ON u.id = m.muted_user_id
       WHERE m.user_id = ?`,
    )
    .all(userId);
}

export function isMuted(viewerId, authorId) {
  const db = getDb();
  const row = db
    .prepare(
      'SELECT 1 FROM chat_mutes WHERE user_id = ? AND muted_user_id = ?',
    )
    .get(viewerId, authorId);
  return Boolean(row);
}
