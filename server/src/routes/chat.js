import { Router } from 'express';
import { getDb } from '../db/database.js';

export const chatRouter = Router();

chatRouter.get('/:channel', (req, res) => {
  const { channel } = req.params;
  const limit = Math.min(Number(req.query.limit) || 50, 200);

  const db = getDb();
  const messages = db
    .prepare(
      'SELECT id, channel, user_id, nick, content, created_at FROM messages WHERE channel = ? ORDER BY created_at DESC LIMIT ?',
    )
    .all(channel, limit)
    .reverse();

  res.json({ messages });
});
