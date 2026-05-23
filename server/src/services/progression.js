import { getDb } from '../db/database.js';

export const RANKS = [
  { id: 'bronze', minXp: 0, theme: 'Bronze', labelTr: 'Bronz Köylü', labelEn: 'Bronze Villager', perkTr: 'Temel oyun', perkEn: 'Core play' },
  { id: 'silver', minXp: 300, theme: 'Silver', labelTr: 'Gümüş Avcı', labelEn: 'Silver Hunter', perkTr: '+%5 maç coin', perkEn: '+5% match coins' },
  { id: 'gold', minXp: 1000, theme: 'Gold', labelTr: 'Altın Stratej', labelEn: 'Gold Strategist', perkTr: 'Turnuva erişimi', perkEn: 'Tournament access' },
  { id: 'platinum', minXp: 2500, theme: 'Platinum', labelTr: 'Platin Usta', labelEn: 'Platinum Master', perkTr: 'Turnuva ücreti -%10', perkEn: '-10% tournament fee' },
  { id: 'diamond', minXp: 4500, theme: 'Diamond', labelTr: 'Elmas Efsane', labelEn: 'Diamond Legend', perkTr: 'Özel çerçeve', perkEn: 'Exclusive frame' },
  { id: 'immortal_vampire', minXp: 8000, theme: 'Immortal', labelTr: 'Ölümsüz Vampir', labelEn: 'Immortal Vampire', perkTr: 'Efsane rozeti', perkEn: 'Legend badge' },
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

export const DAILY_QUESTS = [
  { id: 'win_3', metric: 'wins', goal: 3, rewardCoins: 50, rewardXp: 30 },
  { id: 'trick_2', metric: 'deceptions', goal: 2, rewardCoins: 40, rewardXp: 25 },
  { id: 'doctor_save', metric: 'saves', goal: 1, rewardCoins: 35, rewardXp: 20 },
];

export function rankForXp(xp) {
  let rank = RANKS[0];
  for (const r of RANKS) {
    if (xp >= r.minXp) rank = r;
  }
  return rank;
}

export function rankProgress(xp) {
  const current = rankForXp(xp);
  const idx = RANKS.findIndex((r) => r.id === current.id);
  const next = RANKS[idx + 1] ?? null;
  if (!next) {
    return { current, next: null, xpIntoTier: xp - current.minXp, xpToNext: 0, percent: 100 };
  }
  const xpIntoTier = xp - current.minXp;
  const xpSpan = next.minXp - current.minXp;
  const percent = Math.min(100, Math.floor((xpIntoTier / xpSpan) * 100));
  return {
    current,
    next,
    xpIntoTier,
    xpToNext: next.minXp - xp,
    percent,
  };
}

export function syncRankTier(userId) {
  const db = getDb();
  const row = db.prepare('SELECT xp FROM user_profiles WHERE user_id = ?').get(userId);
  if (!row) return;
  const rank = rankForXp(row.xp);
  db.prepare('UPDATE user_profiles SET rank_tier = ? WHERE user_id = ?').run(rank.id, userId);
}

export function ensureProfile(userId) {
  const db = getDb();
  let row = db.prepare('SELECT * FROM user_profiles WHERE user_id = ?').get(userId);
  if (row) return row;

  db.prepare(
    `INSERT INTO user_profiles (user_id, xp, coins, balance, rank_tier, login_streak, last_login_date)
     VALUES (?, 0, 1000, 0, 'bronze', 0, NULL)`,
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
  const progress = rankProgress(profile.xp);
  const stats = getUserStats(userId);
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
      balance: profile.balance ?? 0,
      rankTier: rank.id,
      rankTheme: rank.theme,
      rankLabelTr: rank.labelTr,
      rankLabelEn: rank.labelEn,
      rankPerkTr: rank.perkTr,
      rankPerkEn: rank.perkEn,
      loginStreak: profile.login_streak,
      lastLoginDate: profile.last_login_date,
      equippedSkin: profile.equipped_skin,
      equippedFrame: profile.equipped_frame,
      equippedTheme: profile.equipped_theme,
      equippedEffect: profile.equipped_effect,
      equippedDeathAnim: profile.equipped_death_anim,
      voiceEffect: profile.voice_effect ?? 'proximity_default',
    },
    rankProgress: {
      currentId: progress.current.id,
      nextId: progress.next?.id ?? null,
      nextMinXp: progress.next?.minXp ?? null,
      xpToNext: progress.xpToNext,
      percent: progress.percent,
    },
    stats,
    dailyQuests: questDefs,
    ownedCosmetics: owned,
    catalog: COSMETIC_CATALOG,
    ranks: RANKS,
  };
}

export function getUserStats(userId) {
  const db = getDb();
  const rows = db
    .prepare(
      `SELECT summary_json FROM match_summaries WHERE user_id = ? ORDER BY created_at DESC LIMIT 200`,
    )
    .all(userId);

  let wins = 0;
  let mvpCount = 0;
  for (const row of rows) {
    try {
      const s = JSON.parse(row.summary_json);
      const my = (s.players ?? []).find((p) => p.userId === userId);
      const evil = ['vampire', 'silent_killer', 'double_agent'].includes(my?.role);
      const won =
        (s.winner === 'villager' && !evil) || (s.winner === 'vampire' && evil);
      if (won) wins += 1;
      if (s.mvp?.userId === userId) mvpCount += 1;
    } catch {
      /* skip */
    }
  }

  const total = rows.length;
  const tournamentsJoined = db
    .prepare('SELECT COUNT(*) AS c FROM tournament_entries WHERE user_id = ?')
    .get(userId).c;

  return {
    totalMatches: total,
    wins,
    losses: Math.max(0, total - wins),
    winRate: total > 0 ? Math.round((wins / total) * 100) : 0,
    mvpCount,
    tournamentsJoined,
  };
}

export function getMatchHistory(userId, limit = 40) {
  const db = getDb();
  const rows = db
    .prepare(
      `SELECT id, room_code, summary_json, created_at FROM match_summaries
       WHERE user_id = ? ORDER BY created_at DESC LIMIT ?`,
    )
    .all(userId, limit);

  return rows.map((row) => {
    let summary = {};
    try {
      summary = JSON.parse(row.summary_json);
    } catch {
      summary = {};
    }
    const my = (summary.players ?? []).find((p) => p.userId === userId);
    const evil = ['vampire', 'silent_killer', 'double_agent'].includes(my?.role);
    const won =
      (summary.winner === 'villager' && !evil) ||
      (summary.winner === 'vampire' && evil);

    return {
      id: row.id,
      roomCode: row.room_code,
      createdAt: row.created_at,
      winner: summary.winner,
      won,
      role: my?.role ?? 'villager',
      mvp: summary.mvp?.userId === userId,
      playerCount: summary.players?.length ?? 0,
    };
  });
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

  const bonusCoins = 100;
  const bonusXp = 10 + Math.min(streak, 7) * 3;

  db.prepare(
    `UPDATE user_profiles SET coins = coins + ?, xp = xp + ?, login_streak = ?, last_login_date = ? WHERE user_id = ?`,
  ).run(bonusCoins, bonusXp, streak, today, userId);
  syncRankTier(userId);

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
  syncRankTier(userId);

  return { ok: true, bundle: getProfileBundle(userId) };
}

export function resolveUserId({ userId, nick, email }) {
  const db = getDb();
  if (userId) {
    const row = db.prepare('SELECT id FROM users WHERE id = ?').get(userId);
    return row?.id ?? null;
  }
  if (email) {
    const mail = String(email).trim().toLowerCase();
    const row = db.prepare('SELECT id FROM users WHERE email = ?').get(mail);
    return row?.id ?? null;
  }
  if (nick) {
    const row = db.prepare('SELECT id FROM users WHERE nick = ? COLLATE NOCASE').get(
      String(nick).trim(),
    );
    return row?.id ?? null;
  }
  return null;
}

/** Admin / sistem: bakiye yukleme (TL birimi, tam sayi). */
export function addUserBalance(targetUserId, amount, note = '') {
  const db = getDb();
  const delta = Math.trunc(Number(amount));
  if (!targetUserId || !Number.isFinite(delta) || delta === 0) {
    return { error: 'invalid_amount' };
  }

  const profile = ensureProfile(targetUserId);
  const next = Math.max(0, (profile.balance ?? 0) + delta);
  db.prepare('UPDATE user_profiles SET balance = ? WHERE user_id = ?').run(
    next,
    targetUserId,
  );
  db.prepare(
    `INSERT INTO balance_ledger (user_id, amount, balance_after, note)
     VALUES (?, ?, ?, ?)`,
  ).run(targetUserId, delta, next, String(note ?? '').slice(0, 200));

  return {
    ok: true,
    userId: targetUserId,
    added: delta,
    balance: next,
    bundle: getProfileBundle(targetUserId),
  };
}

export function getBalanceHistory(userId, limit = 20) {
  const db = getDb();
  return db
    .prepare(
      `SELECT id, amount, balance_after, note, created_at
       FROM balance_ledger WHERE user_id = ? ORDER BY id DESC LIMIT ?`,
    )
    .all(userId, Math.min(50, limit));
}

export function isBotUserId(userId) {
  return String(userId).startsWith('bot:');
}

/** Maça giriş ödülü (insan oyuncular). */
export function grantMatchEntry(userId) {
  if (isBotUserId(userId)) return;
  const db = getDb();
  ensureProfile(userId);
  db.prepare(
    `UPDATE user_profiles SET coins = coins + 8, xp = xp + 5 WHERE user_id = ?`,
  ).run(userId);
  syncRankTier(userId);
}

/** Kurucu oyundan kaçınca ceza. */
export function refundHostLeaveCoins(userId, amount = 15) {
  if (isBotUserId(userId)) return;
  const db = getDb();
  ensureProfile(userId);
  db.prepare(
    `UPDATE user_profiles SET coins = coins + ? WHERE user_id = ?`,
  ).run(amount, userId);
}

export function applyHostLeavePenalty(userId) {
  if (isBotUserId(userId)) return { penalty: 0 };
  const db = getDb();
  ensureProfile(userId);
  const penalty = 25;
  db.prepare(
    `UPDATE user_profiles SET coins = MAX(0, coins - ?) WHERE user_id = ?`,
  ).run(penalty, userId);
  return { penalty };
}

export function applyMatchRewards(userId, summary, playerRole) {
  if (isBotUserId(userId)) return;
  const db = getDb();
  ensureProfile(userId);
  let xp = 15;
  let coins = 10;
  const evil = ['vampire', 'silent_killer', 'double_agent'].includes(playerRole);
  const won =
    (summary.winner === 'villager' && !evil) ||
    (summary.winner === 'vampire' && evil);
  if (won) {
    xp += 35;
    coins += 30;
    incrementQuestMetric(userId, 'wins', 1);
  }
  if (summary.mvp?.userId === userId) {
    xp += 25;
    coins += 15;
  }
  db.prepare(`UPDATE user_profiles SET xp = xp + ?, coins = coins + ? WHERE user_id = ?`).run(
    xp,
    coins,
    userId,
  );
  syncRankTier(userId);

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
