import { getDb } from '../db/database.js';

/**
 * Yönetici: kayıtlı üyeler ve misafirler (botlar hariç).
 * @param {'all'|'registered'|'guest'} filter
 */
export function listUsersForAdmin({
  filter = 'all',
  limit = 80,
  offset = 0,
  search = '',
} = {}) {
  const db = getDb();
  const lim = Math.min(200, Math.max(1, Number(limit) || 80));
  const off = Math.max(0, Number(offset) || 0);
  const q = String(search ?? '').trim();

  const where = ["u.id NOT LIKE 'bot:%'"];
  const params = [];

  if (filter === 'registered') where.push('u.is_guest = 0');
  if (filter === 'guest') where.push('u.is_guest = 1');

  if (q.length > 0) {
    where.push('(u.nick LIKE ? COLLATE NOCASE OR u.email LIKE ?)');
    const like = `%${q}%`;
    params.push(like, like);
  }

  const whereSql = where.join(' AND ');

  const totalRow = db
    .prepare(`SELECT COUNT(*) AS n FROM users u WHERE ${whereSql}`)
    .get(...params);

  const rows = db
    .prepare(
      `SELECT u.id, u.nick, u.email, u.is_guest, u.locale, u.created_at,
              COALESCE(p.coins, 0) AS coins,
              COALESCE(p.balance, 0) AS balance,
              COALESCE(p.xp, 0) AS xp
       FROM users u
       LEFT JOIN user_profiles p ON p.user_id = u.id
       WHERE ${whereSql}
       ORDER BY u.created_at DESC
       LIMIT ? OFFSET ?`,
    )
    .all(...params, lim, off);

  return {
    users: rows.map((r) => ({
      id: r.id,
      nick: r.nick,
      email: r.email ?? null,
      isGuest: r.is_guest === 1,
      locale: r.locale,
      createdAt: r.created_at,
      coins: r.coins,
      balance: r.balance,
      xp: r.xp,
    })),
    total: totalRow?.n ?? 0,
    limit: lim,
    offset: off,
  };
}
