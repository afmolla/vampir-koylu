import { isDmChannel } from './dmChannels.js';

/** Kullanici basina bu oturumda acik DM kanallari (uygulama kapaninca silinir). */
const dmByUser = new Map();

function dmMap(userId) {
  if (!dmByUser.has(userId)) dmByUser.set(userId, new Map());
  return dmByUser.get(userId);
}

export function trackDmOpen(userId, channel, peerUserId, peerNick) {
  if (!isDmChannel(channel)) return;
  dmMap(userId).set(channel, {
    peerUserId,
    peerNick: peerNick ?? '?',
    lastMessage: '',
    updatedAt: new Date().toISOString(),
  });
}

export function trackDmMessage(channel, { content }) {
  if (!isDmChannel(channel)) return;
  const at = new Date().toISOString();
  for (const channels of dmByUser.values()) {
    if (!channels.has(channel)) continue;
    const meta = channels.get(channel);
    channels.set(channel, {
      ...meta,
      lastMessage: content,
      updatedAt: at,
    });
  }
}

export function listActiveDmConversations(userId) {
  const channels = dmMap(userId);
  return [...channels.entries()].map(([channel, meta]) => ({
    channel,
    peerUserId: meta.peerUserId,
    peerNick: meta.peerNick,
    lastMessage: meta.lastMessage,
    updatedAt: meta.updatedAt,
  }));
}

export function clearUserEphemeralChat(userId) {
  dmByUser.delete(userId);
}

/** DB yok — sadece socket yayini icin mesaj nesnesi. */
export function createEphemeralMessage({ channel, userId, nick, content }) {
  const message = {
    id: Date.now() * 1000 + Math.floor(Math.random() * 1000),
    channel,
    user_id: userId,
    nick,
    content,
    created_at: new Date().toISOString(),
  };
  if (isDmChannel(channel)) {
    trackDmMessage(channel, { content });
  }
  return message;
}
