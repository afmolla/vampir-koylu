import { randomBytes } from 'crypto';
import { getDb } from '../db/database.js';
import {
  claimDailyLogin,
  claimQuest,
  ensureProfile,
  getProfileBundle,
} from './progression.js';
import { getLiveSummary, listPublicRooms } from '../rooms/roomStore.js';
import { getOnlinePlayerCount } from './liveStats.js';

export const WEEKLY_QUESTS = [
  { id: 'week_matches_5', metric: 'matches', goal: 5, rewardCoins: 120, rewardXp: 80 },
  { id: 'week_wins_3', metric: 'wins', goal: 3, rewardCoins: 150, rewardXp: 100 },
  { id: 'week_login_5', metric: 'logins', goal: 5, rewardCoins: 100, rewardXp: 60 },
];

export const SEASON_TIERS = [
  { tier: 1, xp: 100, freeCoins: 30, premiumCoins: 80 },
  { tier: 2, xp: 300, freeCoins: 50, premiumCoins: 120 },
  { tier: 3, xp: 600, freeCoins: 80, premiumCoins: 200 },
  { tier: 4, xp: 1000, freeCoins: 120, premiumCoins: 300 },
  { tier: 5, xp: 1500, freeCoins: 200, premiumCoins: 500 },
];

function weekKey() {
  const d = new Date();
  const onejan = new Date(d.getFullYear(), 0, 1);
  const week = Math.ceil(((d - onejan) / 86400000 + onejan.getDay() + 1) / 7);
  return `${d.getFullYear()}-W${week}`;
}

function seasonKey() {
  const d = new Date();
  return `${d.getFullYear()}-M${d.getMonth() + 1}`;
}

function genReferralCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let code = '';
  const bytes = randomBytes(6);
  for (let i = 0; i < 6; i++) code += chars[bytes[i] % chars.length];
  return code;
}

export function ensureReferralCode(userId) {
  const db = getDb();
  const profile = ensureProfile(userId);
  if (profile.referral_code) return profile.referral_code;
  let code;
  for (let i = 0; i < 10; i++) {
    code = genReferralCode();
    const exists = db
      .prepare('SELECT 1 FROM user_profiles WHERE referral_code = ?')
      .get(code);
    if (!exists) break;
  }
  db.prepare('UPDATE user_profiles SET referral_code = ? WHERE user_id = ?').run(
    code,
    userId,
  );
  return code;
}

export function applyReferralCode(userId, code) {
  const db = getDb();
  const profile = ensureProfile(userId);
  if (profile.referred_by_user_id) return { error: 'already_referred' };

  const ref = db
    .prepare('SELECT user_id FROM user_profiles WHERE referral_code = ?')
    .get(String(code ?? '').trim().toUpperCase());
  if (!ref || ref.user_id === userId) return { error: 'invalid_code' };

  db.prepare('UPDATE user_profiles SET referred_by_user_id = ? WHERE user_id = ?').run(
    ref.user_id,
    userId,
  );
  db.prepare('UPDATE user_profiles SET coins = coins + 30 WHERE user_id = ?').run(userId);
  db.prepare('UPDATE user_profiles SET coins = coins + 30 WHERE user_id = ?').run(
    ref.user_id,
  );
  return { ok: true, bundle: getProfileBundle(userId) };
}

export function recordLogin(userId) {
  const db = getDb();
  const profile = ensureProfile(userId);
  const today = new Date().toISOString().slice(0, 10);
  if (profile.last_login_date !== today) {
    db.prepare(
      'UPDATE user_profiles SET login_count = login_count + 1 WHERE user_id = ?',
    ).run(userId);
    incrementWeeklyMetric(userId, 'logins', 1);
  }
  return db
    .prepare('SELECT login_count FROM user_profiles WHERE user_id = ?')
    .get(userId).login_count;
}

export function getHomeDashboard(userId) {
  recordLogin(userId);
  const db = getDb();
  const profile = ensureProfile(userId);
  const user = db.prepare('SELECT is_guest FROM users WHERE id = ?').get(userId);
  const today = new Date().toISOString().slice(0, 10);
  const dailyClaimed = profile.last_login_date === today;

  const bundle = getProfileBundle(userId);
  const rooms = listPublicRooms();
  const live = getLiveSummary();

  return {
    live: {
      onlinePlayers: getOnlinePlayerCount(),
      openRooms: rooms.length,
      playersInLobbies: live.playersInLobbies,
    },
    daily: {
      canClaim: !dailyClaimed,
      streak: profile.login_streak ?? 0,
      quests: bundle.dailyQuests,
    },
    weekly: getWeeklyQuests(userId),
    season: getSeasonPass(userId),
    engagement: {
      loginCount: profile.login_count ?? 0,
      isGuest: user?.is_guest === 1,
      showRegisterPrompt:
        user?.is_guest === 1 && (profile.login_count ?? 0) >= 2,
      firstMatchBonusAvailable: profile.first_match_bonus_claimed !== 1,
      referralCode: ensureReferralCode(userId),
    },
    profile: bundle.profile,
  };
}

export function claimFirstMatchBonus(userId) {
  const db = getDb();
  const profile = ensureProfile(userId);
  if (profile.first_match_bonus_claimed === 1) {
    return { error: 'already_claimed', bundle: getProfileBundle(userId) };
  }
  db.prepare(
    `UPDATE user_profiles SET first_match_bonus_claimed = 1, coins = coins + 50, xp = xp + 25 WHERE user_id = ?`,
  ).run(userId);
  return { ok: true, bonusCoins: 50, bundle: getProfileBundle(userId) };
}

export function grantFirstMatchBonusIfNeeded(userId) {
  const db = getDb();
  const profile = ensureProfile(userId);
  if (profile.first_match_bonus_claimed === 1) return;
  db.prepare(
    `UPDATE user_profiles SET first_match_bonus_claimed = 1, coins = coins + 50, xp = xp + 25 WHERE user_id = ?`,
  ).run(userId);
}

function ensureWeeklyQuests(userId) {
  const db = getDb();
  const wk = weekKey();
  for (const q of WEEKLY_QUESTS) {
    db.prepare(
      `INSERT OR IGNORE INTO weekly_quest_progress (user_id, quest_id, progress, goal, week_key, claimed)
       VALUES (?, ?, 0, ?, ?, 0)`,
    ).run(userId, q.id, q.goal, wk);
  }
}

export function incrementWeeklyMetric(userId, metric, amount = 1) {
  ensureWeeklyQuests(userId);
  const db = getDb();
  const wk = weekKey();
  const defs = WEEKLY_QUESTS.filter((q) => q.metric === metric);
  for (const q of defs) {
    db.prepare(
      `UPDATE weekly_quest_progress SET progress = MIN(goal, progress + ?)
       WHERE user_id = ? AND quest_id = ? AND week_key = ? AND claimed = 0`,
    ).run(amount, userId, q.id, wk);
  }
}

export function getWeeklyQuests(userId) {
  ensureWeeklyQuests(userId);
  const db = getDb();
  const wk = weekKey();
  const rows = db
    .prepare(
      `SELECT * FROM weekly_quest_progress WHERE user_id = ? AND week_key = ?`,
    )
    .all(userId, wk);

  return WEEKLY_QUESTS.map((q) => {
    const row = rows.find((r) => r.quest_id === q.id);
    return {
      ...q,
      progress: row?.progress ?? 0,
      claimed: row?.claimed === 1,
    };
  });
}

export function claimWeeklyQuest(userId, questId) {
  const db = getDb();
  const wk = weekKey();
  const def = WEEKLY_QUESTS.find((q) => q.id === questId);
  if (!def) return { error: 'unknown_quest' };

  const row = db
    .prepare(
      `SELECT * FROM weekly_quest_progress WHERE user_id = ? AND quest_id = ? AND week_key = ?`,
    )
    .get(userId, questId, wk);

  if (!row || row.progress < row.goal) return { error: 'not_complete' };
  if (row.claimed === 1) return { error: 'already_claimed' };

  db.prepare(
    `UPDATE weekly_quest_progress SET claimed = 1 WHERE user_id = ? AND quest_id = ? AND week_key = ?`,
  ).run(userId, questId, wk);
  db.prepare(
    `UPDATE user_profiles SET coins = coins + ?, xp = xp + ?, season_xp = season_xp + ? WHERE user_id = ?`,
  ).run(def.rewardCoins, def.rewardXp, Math.floor(def.rewardXp / 2), userId);

  return { ok: true, bundle: getProfileBundle(userId) };
}

export function getSeasonPass(userId) {
  const db = getDb();
  const profile = ensureProfile(userId);
  const sk = seasonKey();
  const claims = db
    .prepare(
      `SELECT tier, track FROM season_pass_claims WHERE user_id = ? AND season_key = ?`,
    )
    .all(userId, sk);

  const seasonXp = profile.season_xp ?? 0;
  const tiers = SEASON_TIERS.map((t) => ({
    ...t,
    unlocked: seasonXp >= t.xp,
    freeClaimed: claims.some((c) => c.tier === t.tier && c.track === 'free'),
    premiumClaimed: claims.some((c) => c.tier === t.tier && c.track === 'premium'),
  }));

  return { seasonKey: sk, seasonXp, tiers };
}

export function claimSeasonTier(userId, tier, track = 'free') {
  const db = getDb();
  const sk = seasonKey();
  const def = SEASON_TIERS.find((t) => t.tier === tier);
  if (!def) return { error: 'invalid_tier' };

  const profile = ensureProfile(userId);
  if ((profile.season_xp ?? 0) < def.xp) return { error: 'not_unlocked' };

  const exists = db
    .prepare(
      `SELECT 1 FROM season_pass_claims WHERE user_id = ? AND tier = ? AND track = ? AND season_key = ?`,
    )
    .get(userId, tier, track, sk);
  if (exists) return { error: 'already_claimed' };

  const coins = track === 'premium' ? def.premiumCoins : def.freeCoins;
  if (track === 'premium' && (profile.balance ?? 0) < 10) {
    return { error: 'premium_requires_balance', hint: 'Premium ödül için bakiye gerekir' };
  }

  if (track === 'premium') {
    db.prepare('UPDATE user_profiles SET balance = balance - 10 WHERE user_id = ?').run(
      userId,
    );
  }

  db.prepare(
    `INSERT INTO season_pass_claims (user_id, tier, track, season_key) VALUES (?, ?, ?, ?)`,
  ).run(userId, tier, track, sk);
  db.prepare('UPDATE user_profiles SET coins = coins + ? WHERE user_id = ?').run(
    coins,
    userId,
  );

  return { ok: true, coins, bundle: getProfileBundle(userId) };
}

export function getLeaderboard({ type = 'xp', limit = 20 } = {}) {
  const db = getDb();
  const cap = Math.min(50, Math.max(5, limit));

  if (type === 'wins') {
    const rows = db
      .prepare(
        `SELECT m.user_id, m.summary_json, u.nick
         FROM match_summaries m
         JOIN users u ON u.id = m.user_id
         ORDER BY m.created_at DESC
         LIMIT 800`,
      )
      .all();
    const wins = new Map();
    for (const row of rows) {
      try {
        const s = JSON.parse(row.summary_json);
        const my = (s.players ?? []).find((p) => p.userId === row.user_id);
        const evil = ['vampire', 'silent_killer', 'double_agent'].includes(my?.role);
        const won =
          (s.winner === 'villager' && !evil) || (s.winner === 'vampire' && evil);
        if (won) {
          const cur = wins.get(row.user_id) ?? { userId: row.user_id, nick: row.nick, wins: 0 };
          cur.wins += 1;
          wins.set(row.user_id, cur);
        }
      } catch {
        /* skip */
      }
    }
    const entries = [...wins.values()]
      .sort((a, b) => b.wins - a.wins)
      .slice(0, cap);
    return { type, entries };
  }

  const rows = db
    .prepare(
      `SELECT u.id AS userId, u.nick, p.xp, p.rank_tier AS rankTier
       FROM user_profiles p
       JOIN users u ON u.id = p.user_id
       WHERE u.is_guest = 0
       ORDER BY p.xp DESC
       LIMIT ?`,
    )
    .all(cap);

  return { type: 'xp', entries: rows };
}

export function registerPushToken(userId, token, platform = 'android') {
  const db = getDb();
  db.prepare(
    `INSERT INTO push_tokens (user_id, token, platform, updated_at)
     VALUES (?, ?, ?, datetime('now'))
     ON CONFLICT(user_id, token) DO UPDATE SET updated_at = datetime('now')`,
  ).run(userId, token, platform);
  return { ok: true };
}

export function onMatchEnd(userId, summary, playerRole) {
  incrementWeeklyMetric(userId, 'matches', 1);
  grantFirstMatchBonusIfNeeded(userId);
  const evil = ['vampire', 'silent_killer', 'double_agent'].includes(playerRole);
  const won =
    (summary.winner === 'villager' && !evil) ||
    (summary.winner === 'vampire' && evil);
  if (won) incrementWeeklyMetric(userId, 'wins', 1);
}

export { claimDailyLogin, claimQuest };
