import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config.js';
import {
  filterProfanity,
  listMutes,
  muteUser,
  submitReport,
  unmuteUser,
} from '../services/moderation.js';

export const socialRouter = Router();

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

socialRouter.post('/report', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  res.json(
    submitReport({
      reporterId: userId,
      targetId: req.body?.targetId,
      targetNick: req.body?.targetNick,
      channel: req.body?.channel,
      reason: req.body?.reason,
    }),
  );
});

socialRouter.get('/mutes', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  res.json({ mutes: listMutes(userId) });
});

socialRouter.post('/mute', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  res.json(muteUser(userId, req.body?.userId));
});

socialRouter.post('/unmute', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  res.json(unmuteUser(userId, req.body?.userId));
});

export { filterProfanity };
