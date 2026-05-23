import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config.js';
import { confirmTournamentPayment } from '../services/tournaments.js';

export const paymentsRouter = Router();

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

/**
 * Google Play satın alma doğrulama.
 * Üretimde Google Play Developer API ile doğrulanmalı.
 * Geliştirme: purchaseToken + paymentRef eşleşmesi ile onay.
 */
paymentsRouter.post('/play/verify', async (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });

  const { tournamentId, paymentRef, purchaseToken, productId } = req.body ?? {};
  if (!tournamentId || !paymentRef) {
    return res.status(400).json({ error: 'missing_fields' });
  }

  if (config.googlePlayPackageName && config.googlePlayServiceAccount) {
    // TODO: googleapis androidpublisher.purchases.products.get
    console.log('[play] verify stub — service account configured but not wired');
  }

  const result = confirmTournamentPayment(userId, tournamentId, paymentRef);
  if (result.error) return res.status(400).json(result);

  res.json({
    ok: true,
    verified: true,
    purchaseToken: purchaseToken ?? null,
    productId: productId ?? null,
    tournament: result.tournament,
  });
});
