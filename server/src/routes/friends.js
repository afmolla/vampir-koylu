import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config.js';
import { addFriend, listFriends, removeFriend } from '../services/friends.js';
import { notifyFriendRoomInvite } from '../services/pushNotifications.js';
import { emitToUser } from '../ioInstance.js';

export const friendsRouter = Router();

function authUserId(req) {
  const header = req.headers.authorization ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return null;
  try {
    return jwt.verify(token, config.jwtSecret).sub;
  } catch {
    return null;
  }
}

friendsRouter.get('/', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  res.json({ friends: listFriends(userId) });
});

friendsRouter.post('/add', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  const target = req.body?.friendId ?? req.body?.nick;
  const result = addFriend(userId, target);
  if (result.error) return res.status(400).json(result);
  res.json(result);
});

friendsRouter.post('/invite-room', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  const friendId = req.body?.friendId;
  const roomCode = String(req.body?.roomCode ?? '').toUpperCase();
  const hostNick = String(req.body?.hostNick ?? 'Oyuncu');
  if (!friendId || roomCode.length < 4) {
    return res.status(400).json({ error: 'invalid_payload' });
  }
  notifyFriendRoomInvite(friendId, hostNick, roomCode).catch(() => {});
  emitToUser(friendId, 'room:invite', {
    roomCode,
    fromUserId: userId,
    fromNick: hostNick,
  });
  res.json({ ok: true });
});

friendsRouter.delete('/:friendId', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  res.json(removeFriend(userId, req.params.friendId));
});
