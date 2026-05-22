import { getDb } from '../db/database.js';

export const RANKS = [
  { id: 'bronze', minXp: 0, theme: 'Bronze' },
  { id: 'silver', minXp: 500, theme: 'Silver' },
  { id: 'gold', minXp: 2000, theme: 'Gold' },
  { id: 'immortal_vampire', minXp: 5000, theme: 'Immortal Vampire' },
];

/** Kozmetik — pay-to-win yok, sadece görünüm. */
export const COSMETIC_CATALOG = [
  { id: 'skin_vampire_crimson', type: 'skin', price: 120, cosmeticOnly: true },
  { id: 'skin_vampire_noir', type: 'skin', price: 120, cosmeticOnly: true },
  { id: 'fx_blood_mist', type: 'effect', price: 80, cosmeticOnly: true },
  { id: 'fx_blood_drip', type: 'effect', price: 80, cosmeticOnly: true },
  { id: 'theme_graveyard', type: 'theme', price: 150, cosmeticOnly: true },
  { id: 'frame_gold', type: 'frame', price: 100, cosmeticOnly: true },
  { id: 'frame_immortal', type: 'frame', price: 200, cosmeticOnly: true },
  { id: 'death_skull_burst', type: 'death_anim', price: 90, cosmeticOnly: true },
];

const DAILY_QUESTS = [
  { id: 'win_3', metric: 'wins', goal: 3, rewardCoins: 50, rewardXp: 30 },
  { id: 'trick_2', metric: 'deceptions', goal: 2, rewardCoins: 40, rewardXp: 25 },
  { id: 'doctor_save', metric: 'saves', goal: 1, rewardCoins: 35, rewardXp: 20 },
];

function rankForXp(xp) {
  let rank = RANKS[0];
  for (const r of RANKS) {
    if (xp >= r.minXp) rank = r;
  }
  return rank;
}

export function ensureProfile(userId) {
  const db = getDb();
  let row = db.prepare('SELECT * FROM user_profiles WHERE user_id = ?').get(userId);
  if (row) return row;

  db.prepare(
    `INSERT INTO user_profiles (user_id, xp, coins, rank_tier, login_streak, last_login_date)
     VALUES (?, 0, 100, 'bronze', 0, NULL)`,
  ).run(userId);

  const today = new Date().toISOString().slice(0, 10);
  for (const q of DAILY_QUESTS) {
    db.prepare(
      `INSERT OR IGNORE INTO daily_quest_progress (user_id, quest_id, progress, goal, quest_date, claimed)
       VALUES (?, ?, 0, ?, ?, 0)`,
    ).run(userId, q.id, q.goal, today);
  }

  return db.prepare('SELECT * FROM user_profiles WHERE user_id = ?').get(userId);
}

export function getProfileBundle(userId) {
  const db = getDb();
  const profile = ensureProfile(userId);
  const rank = rankForXp(profile.xp);
  const today = new Date().toISOString().slice(0, 10);

  const quests = db
    .prepare(
      `SELECT * FROM daily_quest_progress WHERE user_id = ? AND quest_date = ?`,
    )
    .all(userId, today);

  const owned = db
    .prepare('SELECT cosmetic_id FROM owned_cosmetics WHERE user_id = ?')
    .all(userId)
    .map((r) => r.cosmetic_id);

  const questDefs = DAILY_QUESTS.map((q) => {
    const row = quests.find((x) => x.quest_id === q.id);
    return {
      ...q,
      progress: row?.progress ?? 0,
      claimed: row?.claimed === 1,
    };
  });

  return {
    profile: {
      userId,
      xp: profile.xp,
      coins: profile.coins,
      rankTier: rank.id,
      rankTheme: rank.theme,
      loginStreak: profile.login_streak,
      lastLoginDate: profile.last_login_date,
      equippedSkin: profile.equipped_skin,
      equippedFrame: profile.equipped_frame,
      equippedTheme: profile.equipped_theme,
      equippedEffect: profile.equipped_effect,
      equippedDeathAnim: profile.equipped_death_anim,
      voiceEffect: profile.voice_effect ?? 'proximity_default',
    },
    dailyQuests: questDefs,
    ownedCosmetics: owned,
    catalog: COSMETIC_CATALOG,
    ranks: RANKS,
  };
}

export function claimDailyLogin(userId) {
  const db = getDb();
  const profile = ensureProfile(userId);
  const today = new Date().toISOString().slice(0, 10);
  if (profile.last_login_date === today) {
    return { alreadyClaimed: true, bundle: getProfileBundle(userId) };
  }

  const yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);
  const yStr = yesterday.toISOString().slice(0, 10);
  let streak = profile.login_streak ?? 0;
  if (profile.last_login_date === yStr) streak += 1;
  else streak = 1;

  const bonusCoins = 20 + Math.min(streak, 7) * 5;
  const bonusXp = 10 + Math.min(streak, 7) * 3;

  db.prepare(
    `UPDATE user_profiles SET coins = coins + ?, xp = xp + ?, login_streak = ?, last_login_date = ? WHERE user_id = ?`,
  ).run(bonusCoins, bonusXp, streak, today, userId);

  return {
    alreadyClaimed: false,
    streak,
    bonusCoins,
    bonusXp,
    bundle: getProfileBundle(userId),
  };
}

export function incrementQuestMetric(userId, metric, amount = 1) {
  const db = getDb();
  ensureProfile(userId);
  const today = new Date().toISOString().slice(0, 10);
  const defs = DAILY_QUESTS.filter((q) => q.metric === metric);

  for (const q of defs) {
    db.prepare(
      `INSERT OR IGNORE INTO daily_quest_progress (user_id, quest_id, progress, goal, quest_date, claimed)
       VALUES (?, ?, 0, ?, ?, 0)`,
    ).run(userId, q.id, q.goal, today);

    db.prepare(
      `UPDATE daily_quest_progress SET progress = MIN(goal, progress + ?)
       WHERE user_id = ? AND quest_id = ? AND quest_date = ? AND claimed = 0`,
    ).run(amount, userId, q.id, today);
  }
}

export function claimQuest(userId, questId) {
  const db = getDb();
  const today = new Date().toISOString().slice(0, 10);
  const def = DAILY_QUESTS.find((q) => q.id === questId);
  if (!def) return { error: 'unknown_quest' };

  const row = db
    .prepare(
      `SELECT * FROM daily_quest_progress WHERE user_id = ? AND quest_id = ? AND quest_date = ?`,
    )
    .get(userId, questId, today);

  if (!row || row.progress < row.goal) return { error: 'not_complete' };
  if (row.claimed === 1) return { error: 'already_claimed' };

  db.prepare(
    `UPDATE daily_quest_progress SET claimed = 1 WHERE user_id = ? AND quest_id = ? AND quest_date = ?`,
  ).run(userId, questId, today);

  db.prepare(
    `UPDATE user_profiles SET coins = coins + ?, xp = xp + ? WHERE user_id = ?`,
  ).run(def.rewardCoins, def.rewardXp, userId);

  return { ok: true, bundle: getProfileBundle(userId) };
}

export function applyMatchRewards(userId, summary, playerRole) {
  const db = getDb();
  ensureProfile(userId);
  let xp = 15;
  let coins = 10;
  if (summary.mvp?.userId === userId) {
    xp += 25;
    coins += 15;
  }
  db.prepare(`UPDATE user_profiles SET xp = xp + ?, coins = coins + ? WHERE user_id = ?`).run(
    xp,
    coins,
    userId,
  );

  const evil = ['vampire', 'silent_killer', 'double_agent'].includes(playerRole);
  const won =
    (summary.winner === 'villager' && !evil) ||
    (summary.winner === 'vampire' && evil);
  if (won) incrementQuestMetric(userId, 'wins', 1);

  db.prepare(
    `INSERT INTO match_summaries (user_id, room_code, summary_json, created_at)
     VALUES (?, ?, ?, datetime('now'))`,
  ).run(userId, summary.roomCode ?? '', JSON.stringify(summary));
}

export function purchaseCosmetic(userId, cosmeticId) {
  const item = COSMETIC_CATALOG.find((c) => c.id === cosmeticId);
  if (!item || !item.cosmeticOnly) return { error: 'invalid_item' };

  const db = getDb();
  const profile = ensureProfile(userId);
  if (profile.coins < item.price) return { error: 'insufficient_coins' };

  const owned = db
    .prepare('SELECT 1 FROM owned_cosmetics WHERE user_id = ? AND cosmetic_id = ?')
    .get(userId, cosmeticId);
  if (owned) return { error: 'already_owned' };

  db.prepare('UPDATE user_profiles SET coins = coins - ? WHERE user_id = ?').run(
    item.price,
    userId,
  );
  db.prepare(
    'INSERT INTO owned_cosmetics (user_id, cosmetic_id, purchased_at) VALUES (?, ?, datetime(\'now\'))',
  ).run(userId, cosmeticId);

  return { ok: true, bundle: getProfileBundle(userId) };
}

export function equipCosmetic(userId, slot, cosmeticId) {
  const col = {
    skin: 'equipped_skin',
    frame: 'equipped_frame',
    theme: 'equipped_theme',
    effect: 'equipped_effect',
    death_anim: 'equipped_death_anim',
  }[slot];
  if (!col) return { error: 'invalid_slot' };

  const db = getDb();
  const owned = db
    .prepare('SELECT 1 FROM owned_cosmetics WHERE user_id = ? AND cosmetic_id = ?')
    .get(userId, cosmeticId);
  if (!owned) return { error: 'not_owned' };

  getDb().prepare(`UPDATE user_profiles SET ${col} = ? WHERE user_id = ?`).run(cosmeticId, userId);
  return { ok: true, bundle: getProfileBundle(userId) };
}
