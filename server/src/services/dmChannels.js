import { getDb } from '../db/database.js';

/** Iki kullanici icin sabit ozel oda kanali (oyundan bagimsiz). */
export function buildDmChannelId(userIdA, userIdB) {
  const a = String(userIdA ?? '').trim();
  const b = String(userIdB ?? '').trim();
  if (!a || !b || a === b) return null;
  const [x, y] = [a, b].sort();
  return `dm:${x}:${y}`;
}

export function isSelfDmChannel(channel) {
  const dm = parseDmChannel(channel);
  return Boolean(dm && dm.peerA === dm.peerB);
}

export function isDmChannel(channel) {
  return typeof channel === 'string' && channel.startsWith('dm:');
}

export function parseDmChannel(channel) {
  if (!isDmChannel(channel)) return null;
  const parts = channel.split(':');
  if (parts.length !== 3) return null;
  return { peerA: parts[1], peerB: parts[2] };
}

export function peerUserId(channel, myUserId) {
  const dm = parseDmChannel(channel);
  if (!dm) return null;
  if (dm.peerA === myUserId) return dm.peerB;
  if (dm.peerB === myUserId) return dm.peerA;
  return null;
}

export function canAccessDmChannel(channel, userId) {
  const dm = parseDmChannel(channel);
  if (!dm) return { ok: false, error: 'invalid_dm' };
  if (dm.peerA === userId || dm.peerB === userId) return { ok: true };
  return { ok: false, error: 'not_dm_participant' };
}

export function upsertDmSession(channel, userA, userB) {
  if (String(userA) === String(userB)) return;
  const db = getDb();
  const [a, b] = [userA, userB].sort();
  db.prepare(
    `INSERT INTO dm_sessions (channel, user_a, user_b, updated_at)
     VALUES (?, ?, ?, datetime('now'))
     ON CONFLICT(channel) DO UPDATE SET updated_at = datetime('now')`,
  ).run(channel, a, b);
}

export function listDmChannelsForUser(userId) {
  const db = getDb();
  const fromSessions = db
    .prepare(
      `SELECT channel FROM dm_sessions WHERE user_a = ? OR user_b = ?`,
    )
    .all(userId, userId)
    .map((r) => r.channel);

  const fromMessages = db
    .prepare(
      `SELECT DISTINCT channel FROM messages WHERE channel LIKE 'dm:%'`,
    )
    .all()
    .map((r) => r.channel)
    .filter((ch) => {
      const dm = parseDmChannel(ch);
      return dm && (dm.peerA === userId || dm.peerB === userId);
    });

  return [...new Set([...fromSessions, ...fromMessages])].filter(
    (ch) => !isSelfDmChannel(ch),
  );
}

export function listDmConversations(userId) {
  const db = getDb();
  const channels = listDmChannelsForUser(userId);
  return channels
    .filter((channel) => !isSelfDmChannel(channel))
    .map((channel) => {
    const otherId = peerUserId(channel, userId);
    if (!otherId || otherId === userId) return null;
    const userRow = otherId
      ? db.prepare('SELECT nick FROM users WHERE id = ?').get(otherId)
      : null;
    const last = db
      .prepare(
        `SELECT content, nick, created_at FROM messages
         WHERE channel = ? ORDER BY id DESC LIMIT 1`,
      )
      .get(channel);
    return {
      channel,
      peerUserId: otherId,
      peerNick: userRow?.nick ?? last?.nick ?? '?',
      lastMessage: last?.content ?? '',
      updatedAt: last?.created_at ?? null,
    };
  })
    .filter(Boolean);
}

export function joinUserToAllDmSockets(socket, userId) {
  const channels = listDmChannelsForUser(userId);
  for (const ch of channels) {
    socket.join(`chat:${ch}`);
  }
  return channels;
}

export function joinSocketsToDmChannel(io, channel, userIdA, userIdB) {
  for (const [, s] of io.sockets.sockets) {
    const uid = s.data?.user?.sub;
    if (uid === userIdA || uid === userIdB) {
      s.join(`chat:${channel}`);
    }
  }
}
