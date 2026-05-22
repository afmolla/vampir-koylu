import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config.js';
import {
  listTournaments,
  getTournament,
  registerForTournament,
  confirmTournamentPayment,
} from '../services/tournaments.js';

export const tournamentsRouter = Router();

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

tournamentsRouter.get('/', (req, res) => {
  const userId = authUserId(req);
  res.json({ tournaments: listTournaments(userId) });
});

tournamentsRouter.get('/:id', (req, res) => {
  const userId = authUserId(req);
  const t = getTournament(req.params.id, userId);
  if (!t) return res.status(404).json({ error: 'not_found' });
  res.json(t);
});

tournamentsRouter.post('/:id/register', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  const method = req.body?.method === 'iap' ? 'iap' : 'coins';
  const result = registerForTournament(userId, req.params.id, method);
  if (result.error) {
    const status =
      result.error === 'insufficient_coins' || result.error === 'rank_too_low' ? 400 : 404;
    return res.status(status).json(result);
  }
  res.json(result);
});

/** Geliştirme: IAP onayı simülasyonu */
tournamentsRouter.post('/:id/confirm-payment', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  const { paymentRef } = req.body ?? {};
  if (!paymentRef) return res.status(400).json({ error: 'payment_ref_required' });
  const result = confirmTournamentPayment(userId, req.params.id, paymentRef);
  if (result.error) return res.status(404).json(result);
  res.json(result);
});
