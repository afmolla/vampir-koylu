import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config.js';
import {
  getProfileBundle,
  claimDailyLogin,
  claimQuest,
} from '../services/progression.js';

export const profileRouter = Router();

function authUserId(req) {
  const header = req.headers.authorization ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return null;
  try {
    const payload = jwt.verify(token, config.jwtSecret);
    return payload.sub;
  } catch {
    return null;
  }
}

profileRouter.get('/me', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  res.json(getProfileBundle(userId));
});

profileRouter.post('/daily-login', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  res.json(claimDailyLogin(userId));
});

profileRouter.post('/quests/:questId/claim', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  const result = claimQuest(userId, req.params.questId);
  if (result.error) return res.status(400).json(result);
  res.json(result);
});
