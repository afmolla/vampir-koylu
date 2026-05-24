import { getDb } from '../db/database.js';
import { config } from '../config.js';

/** FCM Legacy HTTP API — FCM_SERVER_KEY gerekli */
export async function sendPushToUser(userId, { title, body, data = {} }) {
  const tokens = getTokensForUser(userId);
  if (!tokens.length) return { sent: 0, skipped: 'no_tokens' };
  return sendPushToTokens(tokens, { title, body, data });
}

export async function sendPushToUsers(userIds, payload) {
  const tokens = [];
  for (const id of userIds) {
    tokens.push(...getTokensForUser(id));
  }
  return sendPushToTokens([...new Set(tokens)], payload);
}

function getTokensForUser(userId) {
  const db = getDb();
  return db
    .prepare('SELECT token FROM push_tokens WHERE user_id = ?')
    .all(userId)
    .map((r) => r.token);
}

async function sendPushToTokens(tokens, { title, body, data = {} }) {
  if (!config.fcmServerKey) {
    console.log(`[push] (no FCM_SERVER_KEY) ${title}: ${body}`);
    return { sent: 0, skipped: 'not_configured' };
  }
  if (!tokens.length) return { sent: 0 };

  let sent = 0;
  for (const token of tokens) {
    try {
      const res = await fetch('https://fcm.googleapis.com/fcm/send', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `key=${config.fcmServerKey}`,
        },
        body: JSON.stringify({
          to: token,
          notification: { title, body },
          data: Object.fromEntries(
            Object.entries(data).map(([k, v]) => [k, String(v)]),
          ),
          priority: 'high',
        }),
      });
      if (res.ok) sent += 1;
      else console.warn('[push] FCM error', await res.text());
    } catch (err) {
      console.error('[push]', err.message);
    }
  }
  return { sent, total: tokens.length };
}

export async function notifyTournamentLobbyOpen(tournamentId, title, userIds) {
  return sendPushToUsers(userIds, {
    title: 'Turnuva lobisi açıldı',
    body: `${title} — hemen katıl!`,
    data: { type: 'tournament_lobby', tournamentId },
  });
}

export async function notifyDailyBonus(userId) {
  return sendPushToUser(userId, {
    title: 'Vampir Köylü',
    body: 'Günlük bonusunu almayı unutma!',
    data: { type: 'daily_bonus' },
  });
}

export async function notifyFriendRoomInvite(userId, hostNick, roomCode) {
  return sendPushToUser(userId, {
    title: 'Oda daveti',
    body: `${hostNick} seni ${roomCode} odasına davet ediyor`,
    data: { type: 'room_invite', roomCode },
  });
}

export async function notifyTournamentWinner(tournamentId, title, userId, prizeCoins) {
  return sendPushToUser(userId, {
    title: 'Turnuva kazandın!',
    body: `${title}: +${prizeCoins} coin ödül.`,
    data: { type: 'tournament_win', tournamentId, prizeCoins: String(prizeCoins) },
  });
}
