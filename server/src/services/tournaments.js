import { randomUUID } from 'crypto';
import { getDb } from '../db/database.js';
import { ensureProfile, syncRankTier } from './progression.js';
import {
  createTournamentRoom,
  getTournamentRoomSnapshot,
} from '../rooms/roomStore.js';

const IAP_PRODUCT_PREFIX = 'tournament_entry_';

export function seedTournamentsIfEmpty() {
  const db = getDb();
  const n = db.prepare('SELECT COUNT(*) AS c FROM tournaments').get().c;
  if (n > 0) return;

  const week = new Date();
  week.setDate(week.getDate() + 7);
  const deadline = week.toISOString();

  const items = [
    {
      id: 'weekly_village_cup',
      title: 'Haftalık Köylü Kupası',
      description: '6–16 oyuncu. Kazanan büyük coin ödülü alır. Coin ile kayıt.',
      entry_fee_coins: 75,
      entry_fee_try: null,
      prize_pool_coins: 800,
      min_players: 6,
      max_players: 16,
    },
    {
      id: 'gold_league_premium',
      title: 'Altın Lig — Premium',
      description: 'Altın rütbe ve üzeri. Coin veya ücretli katılım (Play ödeme yakında).',
      entry_fee_coins: 150,
      entry_fee_try: 29.99,
      prize_pool_coins: 2000,
      min_players: 8,
      max_players: 32,
    },
  ];

  const ins = db.prepare(
    `INSERT INTO tournaments (
      id, title, description, status, entry_fee_coins, entry_fee_try,
      prize_pool_coins, min_players, max_players, registration_deadline
    ) VALUES (?, ?, ?, 'registration', ?, ?, ?, ?, ?, ?)`,
  );

  for (const t of items) {
    ins.run(
      t.id,
      t.title,
      t.description,
      t.entry_fee_coins,
      t.entry_fee_try,
      t.prize_pool_coins,
      t.min_players,
      t.max_players,
      deadline,
    );
  }
}

function mapTournament(row, entryCount = 0) {
  return {
    id: row.id,
    title: row.title,
    description: row.description,
    status: row.status,
    entryFeeCoins: row.entry_fee_coins,
    entryFeeTry: row.entry_fee_try,
    prizePoolCoins: row.prize_pool_coins,
    minPlayers: row.min_players,
    maxPlayers: row.max_players,
    registrationDeadline: row.registration_deadline,
    startsAt: row.starts_at,
    winnerUserId: row.winner_user_id,
    lobbyRoomCode: row.lobby_room_code,
    hostUserId: row.host_user_id,
    entryCount,
    iapProductId: row.entry_fee_try ? `${IAP_PRODUCT_PREFIX}${row.id}` : null,
  };
}

function countPaidEntries(db, tournamentId) {
  return db
    .prepare(
      `SELECT COUNT(*) AS c FROM tournament_entries
       WHERE tournament_id = ? AND payment_status = 'paid'`,
    )
    .get(tournamentId).c;
}

export function listTournaments(userId) {
  const db = getDb();
  seedTournamentsIfEmpty();
  const rows = db
    .prepare(
      `SELECT t.*, (SELECT COUNT(*) FROM tournament_entries e WHERE e.tournament_id = t.id) AS entry_count
       FROM tournaments t
       WHERE t.status IN ('registration', 'lobby', 'live')
       ORDER BY t.registration_deadline ASC`,
    )
    .all();

  const myEntries = userId
    ? db
        .prepare('SELECT tournament_id, payment_status FROM tournament_entries WHERE user_id = ?')
        .all(userId)
    : [];

  return rows.map((r) => ({
    ...mapTournament(r, r.entry_count),
    registered: myEntries.some((e) => e.tournament_id === r.id),
    myPaymentStatus: myEntries.find((e) => e.tournament_id === r.id)?.payment_status ?? null,
  }));
}

export function getTournament(tournamentId, userId) {
  const db = getDb();
  const row = db
    .prepare(
      `SELECT t.*, (SELECT COUNT(*) FROM tournament_entries e WHERE e.tournament_id = t.id) AS entry_count
       FROM tournaments t WHERE t.id = ?`,
    )
    .get(tournamentId);
  if (!row) return null;

  let myEntry = null;
  if (userId) {
    myEntry = db
      .prepare(
        `SELECT payment_method, payment_status, joined_at FROM tournament_entries
         WHERE tournament_id = ? AND user_id = ?`,
      )
      .get(tournamentId, userId);
  }

  const leaderboard = db
    .prepare(
      `SELECT e.user_id, u.nick, e.placement, e.prize_coins, e.payment_status
       FROM tournament_entries e
       JOIN users u ON u.id = e.user_id
       WHERE e.tournament_id = ?
       ORDER BY e.joined_at ASC
       LIMIT 50`,
    )
    .all(tournamentId);

  return {
    ...mapTournament(row, row.entry_count),
    myEntry: myEntry
      ? {
          paymentMethod: myEntry.payment_method,
          paymentStatus: myEntry.payment_status,
          joinedAt: myEntry.joined_at,
        }
      : null,
    entries: leaderboard.map((e) => ({
      userId: e.user_id,
      nick: e.nick,
      placement: e.placement,
      prizeCoins: e.prize_coins,
      paymentStatus: e.payment_status,
    })),
  };
}

function rankAllowsTournament(userId, tournamentId) {
  const db = getDb();
  const profile = ensureProfile(userId);
  const rank = profile.rank_tier ?? 'bronze';
  if (tournamentId === 'gold_league_premium') {
    const order = ['bronze', 'silver', 'gold', 'platinum', 'diamond', 'immortal_vampire'];
    return order.indexOf(rank) >= order.indexOf('gold');
  }
  return true;
}

function discountedCoinFee(baseFee, rankTier) {
  if (rankTier === 'platinum' || rankTier === 'diamond' || rankTier === 'immortal_vampire') {
    return Math.max(1, Math.floor(baseFee * 0.9));
  }
  return baseFee;
}

export function registerForTournament(userId, tournamentId, method = 'coins') {
  const db = getDb();
  seedTournamentsIfEmpty();
  const t = db.prepare('SELECT * FROM tournaments WHERE id = ?').get(tournamentId);
  if (!t) return { error: 'not_found' };
  if (t.status !== 'registration') return { error: 'registration_closed' };

  const existing = db
    .prepare('SELECT 1 FROM tournament_entries WHERE tournament_id = ? AND user_id = ?')
    .get(tournamentId, userId);
  if (existing) return { error: 'already_registered' };

  const count = db
    .prepare('SELECT COUNT(*) AS c FROM tournament_entries WHERE tournament_id = ?')
    .get(tournamentId).c;
  if (count >= t.max_players) return { error: 'tournament_full' };

  if (!rankAllowsTournament(userId, tournamentId)) {
    return { error: 'rank_too_low', requiredRank: 'gold' };
  }

  const profile = ensureProfile(userId);

  if (method === 'balance') {
    const fee = t.entry_fee_try
      ? Math.trunc(Number(t.entry_fee_try))
      : t.entry_fee_coins;
    if ((profile.balance ?? 0) < fee) {
      return { error: 'insufficient_balance', requiredBalance: fee };
    }
    db.prepare('UPDATE user_profiles SET balance = balance - ? WHERE user_id = ?').run(
      fee,
      userId,
    );
    db.prepare(
      `UPDATE tournaments SET prize_pool_coins = prize_pool_coins + ? WHERE id = ?`,
    ).run(Math.floor(fee * 0.8), tournamentId);
    db.prepare(
      `INSERT INTO tournament_entries (tournament_id, user_id, payment_method, payment_status)
       VALUES (?, ?, 'balance', 'paid')`,
    ).run(tournamentId, userId);
    syncRankTier(userId);
    tryAutoOpenLobby(tournamentId);
    return {
      ok: true,
      paidBalance: fee,
      tournament: getTournament(tournamentId, userId),
    };
  }

  if (method === 'iap') {
    if (!t.entry_fee_try) return { error: 'iap_not_available' };
    const ref = randomUUID();
    db.prepare(
      `INSERT INTO tournament_entries (tournament_id, user_id, payment_method, payment_status, payment_ref)
       VALUES (?, ?, 'iap', 'pending', ?)`,
    ).run(tournamentId, userId, ref);

    return {
      ok: true,
      pendingPayment: true,
      paymentRef: ref,
      productId: `${IAP_PRODUCT_PREFIX}${tournamentId}`,
      amountTry: t.entry_fee_try,
      message: 'Play Store ödemesi onaylandığında kayıt tamamlanır.',
      tournament: getTournament(tournamentId, userId),
    };
  }

  const fee = discountedCoinFee(t.entry_fee_coins, profile.rank_tier);
  if (profile.coins < fee) return { error: 'insufficient_coins', requiredCoins: fee };

  db.prepare('UPDATE user_profiles SET coins = coins - ? WHERE user_id = ?').run(fee, userId);
  db.prepare(
    `UPDATE tournaments SET prize_pool_coins = prize_pool_coins + ? WHERE id = ?`,
  ).run(Math.floor(fee * 0.8), tournamentId);

  db.prepare(
    `INSERT INTO tournament_entries (tournament_id, user_id, payment_method, payment_status)
     VALUES (?, ?, 'coins', 'paid')`,
  ).run(tournamentId, userId);

  syncRankTier(userId);
  tryAutoOpenLobby(tournamentId);

  return {
    ok: true,
    paidCoins: fee,
    tournament: getTournament(tournamentId, userId),
  };
}

/** Test / admin: pending IAP kaydını onayla */
export function confirmTournamentPayment(userId, tournamentId, paymentRef) {
  const db = getDb();
  const row = db
    .prepare(
      `SELECT * FROM tournament_entries WHERE tournament_id = ? AND user_id = ? AND payment_ref = ?`,
    )
    .get(tournamentId, userId, paymentRef);
  if (!row) return { error: 'not_found' };
  if (row.payment_status === 'paid') return { ok: true, alreadyPaid: true };

  db.prepare(
    `UPDATE tournament_entries SET payment_status = 'paid' WHERE tournament_id = ? AND user_id = ?`,
  ).run(tournamentId, userId);

  tryAutoOpenLobby(tournamentId);
  return { ok: true, tournament: getTournament(tournamentId, userId) };
}

function tryAutoOpenLobby(tournamentId) {
  const db = getDb();
  const t = db.prepare('SELECT * FROM tournaments WHERE id = ?').get(tournamentId);
  if (!t || t.lobby_room_code) return;
  const paid = countPaidEntries(db, tournamentId);
  if (paid < t.min_players) return;
  const first = db
    .prepare(
      `SELECT user_id FROM tournament_entries
       WHERE tournament_id = ? AND payment_status = 'paid' ORDER BY joined_at LIMIT 1`,
    )
    .get(tournamentId);
  if (first) openTournamentLobby(tournamentId, first.user_id);
}

export function openTournamentLobby(tournamentId, userId) {
  const db = getDb();
  const t = db.prepare('SELECT * FROM tournaments WHERE id = ?').get(tournamentId);
  if (!t) return { error: 'not_found' };
  if (t.lobby_room_code) {
    return { ok: true, roomCode: t.lobby_room_code, alreadyOpen: true };
  }

  const paid = countPaidEntries(db, tournamentId);
  if (paid < t.min_players) {
    return { error: 'not_enough_players', required: t.min_players, current: paid };
  }

  const entry = db
    .prepare(
      `SELECT 1 FROM tournament_entries
       WHERE tournament_id = ? AND user_id = ? AND payment_status = 'paid'`,
    )
    .get(tournamentId, userId);
  if (!entry) return { error: 'not_registered' };

  const host = db.prepare('SELECT nick FROM users WHERE id = ?').get(userId);
  const code = createTournamentRoom({
    tournamentId,
    hostId: userId,
    hostNick: host?.nick ?? 'Host',
    maxPlayers: t.max_players,
  });

  db.prepare(
    `UPDATE tournaments SET status = 'lobby', lobby_room_code = ?, host_user_id = ? WHERE id = ?`,
  ).run(code, userId, tournamentId);

  const entrantIds = db
    .prepare(
      `SELECT user_id FROM tournament_entries
       WHERE tournament_id = ? AND payment_status = 'paid'`,
    )
    .all(tournamentId)
    .map((r) => r.user_id);

  import('./pushNotifications.js')
    .then(({ notifyTournamentLobbyOpen }) =>
      notifyTournamentLobbyOpen(tournamentId, t.title, entrantIds),
    )
    .catch(() => {});

  return { ok: true, roomCode: code };
}

export function getTournamentLobby(tournamentId) {
  const db = getDb();
  const t = db.prepare('SELECT * FROM tournaments WHERE id = ?').get(tournamentId);
  if (!t) return { error: 'not_found' };
  if (!t.lobby_room_code) {
    const paid = countPaidEntries(db, tournamentId);
    return {
      open: false,
      paidEntries: paid,
      minPlayers: t.min_players,
      status: t.status,
    };
  }

  const snap = getTournamentRoomSnapshot(t.lobby_room_code);
  const registered = db
    .prepare(
      `SELECT e.user_id, u.nick FROM tournament_entries e
       JOIN users u ON u.id = e.user_id
       WHERE e.tournament_id = ? AND e.payment_status = 'paid'
       ORDER BY e.joined_at`,
    )
    .all(tournamentId);

  return {
    open: true,
    tournamentId,
    roomCode: t.lobby_room_code,
    status: t.status,
    snapshot: snap,
    registered: registered.map((r) => ({ userId: r.user_id, nick: r.nick })),
    minPlayers: t.min_players,
    maxPlayers: t.max_players,
  };
}
