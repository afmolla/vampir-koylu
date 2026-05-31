export function createMatchLog() {
  return {
    events: [],
    accusationCounts: new Map(),
    nightProtects: new Map(),
    deceptions: 0,
  };
}

export function logEvent(log, type, payload) {
  log.events.push({
    type,
    at: new Date().toISOString(),
    ...payload,
  });
}

export function recordAccusation(log, targetUserId) {
  log.accusationCounts.set(
    targetUserId,
    (log.accusationCounts.get(targetUserId) ?? 0) + 1,
  );
}

export function buildMatchSummary(room) {
  const g = room.game;
  const log = g?.matchLog;
  if (!log) return null;

  const kills = log.events
    .filter((e) => e.type === 'kill' || e.type === 'night_kill' || e.type === 'day_execute')
    .map((e) => ({
      killerNick: e.killerNick ?? '?',
      victimNick: e.victimNick ?? '?',
      phase: e.phase ?? g.phase,
    }));

  let mostAccused = null;
  let maxAcc = 0;
  for (const [userId, count] of log.accusationCounts) {
    if (count > maxAcc) {
      maxAcc = count;
      const p = g.players.find((pl) => pl.userId === userId);
      mostAccused = { userId, nick: p?.nick ?? '?', count };
    }
  }

  const mvpScores = new Map();
  for (const p of g.players) {
    let score = 0;
    if (g.winner === 'villager' && p.role !== 'vampire' && !['silent_killer', 'double_agent'].includes(p.role)) {
      score += 2;
    }
    if (g.winner === 'vampire' && ['vampire', 'silent_killer'].includes(p.role)) score += 3;
    if (g.winner === 'fool' && p.role === 'fool') score += 10;
    score += (log.accusationCounts.get(p.userId) ?? 0) * 0.5;
    kills.forEach((k) => {
      if (k.killerNick === p.nick) score += 2;
    });
    mvpScores.set(p.userId, score);
  }

  let mvp = null;
  let best = -1;
  for (const [userId, score] of mvpScores) {
    if (score > best) {
      best = score;
      const p = g.players.find((pl) => pl.userId === userId);
      mvp = { userId, nick: p?.nick ?? '?', score: Math.round(score) };
    }
  }

  const lies = log.events
    .filter((e) => e.type === 'deception' || e.type === 'lie_claim')
    .map((e) => ({
      nick: e.nick ?? '?',
      detail: e.detail ?? 'Yalan iddiası',
    }));

  return {
    winner: g.winner,
    kills,
    lies,
    mostAccused,
    mvp,
    dayNumber: g.dayNumber,
  };
}
