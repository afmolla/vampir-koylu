import { getDb } from '../db/database.js';

export function listFriends(userId) {
  const db = getDb();
  return db
    .prepare(
      `SELECT f.friend_id AS userId, u.nick, u.avatar_url AS avatarUrl
       FROM friends f
       JOIN users u ON u.id = f.friend_id
       WHERE f.user_id = ?
       ORDER BY f.created_at DESC`,
    )
    .all(userId);
}

export function addFriend(userId, friendIdOrNick) {
  const db = getDb();
  let friendId = friendIdOrNick;
  if (!friendId?.includes?.('-') && friendId?.length < 36) {
    const row = db
      .prepare('SELECT id FROM users WHERE nick = ? COLLATE NOCASE')
      .get(String(friendIdOrNick).trim());
    if (!row) return { error: 'user_not_found' };
    friendId = row.id;
  }
  if (friendId === userId) return { error: 'self' };

  const exists = db.prepare('SELECT id FROM users WHERE id = ?').get(friendId);
  if (!exists) return { error: 'user_not_found' };

  db.prepare(
    `INSERT OR IGNORE INTO friends (user_id, friend_id) VALUES (?, ?)`,
  ).run(userId, friendId);
  db.prepare(
    `INSERT OR IGNORE INTO friends (user_id, friend_id) VALUES (?, ?)`,
  ).run(friendId, userId);

  return { ok: true, friends: listFriends(userId) };
}

export function removeFriend(userId, friendId) {
  const db = getDb();
  db.prepare('DELETE FROM friends WHERE user_id = ? AND friend_id = ?').run(
    userId,
    friendId,
  );
  db.prepare('DELETE FROM friends WHERE user_id = ? AND friend_id = ?').run(
    friendId,
    userId,
  );
  return { ok: true, friends: listFriends(userId) };
}
