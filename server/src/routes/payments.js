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
 */
paymentsRouter.post('/play/verify', async (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });

  const { tournamentId, paymentRef, purchaseToken, productId } = req.body ?? {};
  if (!tournamentId || !paymentRef) {
    return res.status(400).json({ error: 'missing_fields' });
  }

  const hasPlayApi =
    Boolean(config.googlePlayPackageName?.trim()) &&
    Boolean(config.googlePlayServiceAccount?.trim());

  if (hasPlayApi) {
    // TODO: googleapis androidpublisher.purchases.products.get
    console.log('[play] verify — service account configured, API not wired yet');
  } else if (config.nodeEnv === 'production') {
    return res.status(503).json({
      error: 'play_verify_not_configured',
      message: 'Google Play doğrulama sunucuda yapılandırılmamış.',
    });
  } else if (!purchaseToken) {
    return res.status(400).json({
      error: 'missing_purchase_token',
      message: 'Geliştirme modunda bile purchaseToken gerekli.',
    });
  }

  const result = confirmTournamentPayment(userId, tournamentId, paymentRef);
  if (result.error) return res.status(400).json(result);

  res.json({
    ok: true,
    verified: hasPlayApi,
    devMode: !hasPlayApi,
    purchaseToken: purchaseToken ?? null,
    productId: productId ?? null,
    tournament: result.tournament,
  });
});
