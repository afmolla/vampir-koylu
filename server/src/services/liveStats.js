/** Bağlı socket sayısı — ana sayfa canlı özet */
const connectedUsers = new Set();

export function trackConnection(userId) {
  if (userId) connectedUsers.add(userId);
}

export function trackDisconnect(userId) {
  if (userId) connectedUsers.delete(userId);
}

export function getOnlinePlayerCount() {
  return connectedUsers.size;
}
