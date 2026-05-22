import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config.js';
import { getDb } from '../db/database.js';
import { authRequired } from '../middleware/auth.js';
import {
  buildDmChannelId,
  canAccessDmChannel,
  isDmChannel,
  listDmConversations,
} from '../services/dmChannels.js';

export const chatRouter = Router();

chatRouter.get('/dm/list', authRequired, (req, res) => {
  const userId = req.user.sub;
  res.json({ conversations: listDmConversations(userId) });
});

chatRouter.get('/dm/:otherUserId', authRequired, (req, res) => {
  const userId = req.user.sub;
  const otherUserId = req.params.otherUserId;
  const channel = buildDmChannelId(userId, otherUserId);
  const limit = Math.min(Number(req.query.limit) || 50, 200);
  const db = getDb();
  const messages = db
    .prepare(
      `SELECT id, channel, user_id, nick, content, created_at
       FROM messages WHERE channel = ? ORDER BY created_at DESC LIMIT ?`,
    )
    .all(channel, limit)
    .reverse();
  res.json({ channel, messages });
});

chatRouter.get('/:channel', (req, res) => {
  const channel = decodeURIComponent(req.params.channel);
  const limit = Math.min(Number(req.query.limit) || 50, 200);

  if (isDmChannel(channel)) {
    const header = req.headers.authorization ?? '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) return res.status(401).json({ error: 'unauthorized' });
    try {
      const payload = jwt.verify(token, config.jwtSecret);
      const access = canAccessDmChannel(channel, payload.sub);
      if (!access.ok) return res.status(403).json({ error: access.error });
    } catch {
      return res.status(401).json({ error: 'invalid_token' });
    }
  }

  const db = getDb();
  const messages = db
    .prepare(
      'SELECT id, channel, user_id, nick, content, created_at FROM messages WHERE channel = ? ORDER BY created_at DESC LIMIT ?',
    )
    .all(channel, limit)
    .reverse();

  res.json({ messages });
});
