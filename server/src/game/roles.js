/** Tüm roller — kozmetik / rank oyun gücünü etkilemez. */
export const ROLES = {
  vampire: { team: 'evil', nightOrder: 90, nightAction: 'kill' },
  silent_killer: { team: 'evil', nightOrder: 85, nightAction: 'kill' },
  double_agent: { team: 'evil', nightOrder: 80, nightAction: 'deceive' },
  doctor: { team: 'good', nightOrder: 20, nightAction: 'protect' },
  seer: { team: 'good', nightOrder: 30, nightAction: 'investigate' },
  hunter: { team: 'good', nightOrder: 40, nightAction: 'trap' },
  guard: { team: 'good', nightOrder: 15, nightAction: 'guard' },
  sheriff: { team: 'good', nightOrder: 25, nightAction: 'investigate' },
  wizard: { team: 'good', nightOrder: 35, nightAction: 'buff' },
  villager: { team: 'good', nightOrder: 0, nightAction: null },
  cursed_villager: { team: 'good', nightOrder: 0, nightAction: null },
  fool: { team: 'neutral', nightOrder: 0, nightAction: null },
};

export const ROLE_IDS = Object.keys(ROLES);

export function isEvilTeam(role) {
  return ROLES[role]?.team === 'evil';
}

export function isGoodTeam(role) {
  const t = ROLES[role]?.team;
  return t === 'good' || role === 'cursed_villager';
}

/** Oyuncu sayısına göre rol dağılımı (2–8). */
export function assignRoles(playerCount) {
  const n = Math.min(8, Math.max(2, playerCount));
  const pool = [];

  if (n <= 3) {
    pool.push('vampire');
    while (pool.length < n) pool.push('villager');
  } else if (n <= 5) {
    pool.push('vampire', 'doctor', 'seer');
    while (pool.length < n) pool.push('villager');
  } else if (n <= 6) {
    pool.push('vampire', 'doctor', 'seer', 'hunter', 'sheriff');
    while (pool.length < n) pool.push('villager');
  } else {
    pool.push(
      'vampire',
      'silent_killer',
      'doctor',
      'seer',
      'hunter',
      'guard',
      'sheriff',
      'wizard',
    );
    if (n >= 8) {
      pool.push('double_agent', 'cursed_villager', 'fool');
    }
    while (pool.length < n) pool.push('villager');
  }

  const roles = pool.slice(0, n);
  for (let i = roles.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [roles[i], roles[j]] = [roles[j], roles[i]];
  }
  return roles;
}

export function countEvilAlive(players) {
  return players.filter((p) => p.alive && isEvilTeam(p.role)).length;
}

export function countGoodAlive(players) {
  return players.filter((p) => p.alive && (isGoodTeam(p.role) || p.role === 'fool')).length;
}
