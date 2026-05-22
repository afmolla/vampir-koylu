import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config.js';
import {
  COSMETIC_CATALOG,
  purchaseCosmetic,
  equipCosmetic,
  getProfileBundle,
} from '../services/progression.js';

export const shopRouter = Router();

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

shopRouter.get('/catalog', (_req, res) => {
  res.json({
    items: COSMETIC_CATALOG,
    note: 'Kozmetik only — oyun gücü etkilemez (pay-to-win yok).',
  });
});

shopRouter.post('/purchase', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  const result = purchaseCosmetic(userId, req.body?.cosmeticId);
  if (result.error) return res.status(400).json(result);
  res.json(result);
});

shopRouter.post('/equip', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  const result = equipCosmetic(userId, req.body?.slot, req.body?.cosmeticId);
  if (result.error) return res.status(400).json(result);
  res.json(result);
});
