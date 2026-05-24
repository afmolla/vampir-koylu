import { Router } from 'express';
import { authRequired } from '../middleware/auth.js';
import { buildDmChannelId } from '../services/dmChannels.js';

export const chatRouter = Router();

/** Gecmis mesaj yok — sohbet sadece acik oturumda (socket). */
const emptyHistory = { messages: [], ephemeral: true };

chatRouter.get('/dm/list', authRequired, (_req, res) => {
  res.json({ conversations: [], ephemeral: true });
});

chatRouter.get('/dm/:otherUserId', authRequired, (req, res) => {
  const channel = buildDmChannelId(req.user.sub, req.params.otherUserId);
  res.json({ channel, ...emptyHistory });
});

chatRouter.get('/:channel', (_req, res) => {
  res.json(emptyHistory);
});
