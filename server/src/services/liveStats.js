/** Bağlı socket sayısı ve çevrimiçi takma ad takibi */
const connectedUsers = new Set();
/** userId -> normalized nick */
const onlineByUserId = new Map();
/** normalized nick -> bağlı oturum sayısı */
const onlineNickCounts = new Map();

function normalizeNick(nick) {
  return String(nick ?? '').trim().toLowerCase();
}

function incrementNick(key) {
  if (!key) return;
  onlineNickCounts.set(key, (onlineNickCounts.get(key) ?? 0) + 1);
}

function decrementNick(key) {
  if (!key) return;
  const n = (onlineNickCounts.get(key) ?? 0) - 1;
  if (n <= 0) onlineNickCounts.delete(key);
  else onlineNickCounts.set(key, n);
}

export function trackConnection(userId, nick) {
  if (!userId) return;
  connectedUsers.add(userId);

  const prev = onlineByUserId.get(userId);
  if (prev) decrementNick(prev);

  const key = normalizeNick(nick);
  if (key) {
    onlineByUserId.set(userId, key);
    incrementNick(key);
  } else {
    onlineByUserId.delete(userId);
  }
}

export function trackDisconnect(userId) {
  if (!userId) return;
  const key = onlineByUserId.get(userId);
  if (key) decrementNick(key);
  onlineByUserId.delete(userId);
  connectedUsers.delete(userId);
}

export function getOnlinePlayerCount() {
  return connectedUsers.size;
}

/** Başka bir çevrimiçi oyuncu bu takma adı kullanıyor mu? */
export function isNickOnline(nick, excludeUserId = null) {
  const key = normalizeNick(nick);
  if (!key) return false;
  const count = onlineNickCounts.get(key) ?? 0;
  if (count === 0) return false;
  if (!excludeUserId) return true;
  const theirs = onlineByUserId.get(excludeUserId);
  if (theirs === key && count <= 1) return false;
  return true;
}
