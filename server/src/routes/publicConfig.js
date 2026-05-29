import { Router } from 'express';
import { buildIceServers, config } from '../config.js';

export const publicConfigRouter = Router();

/** Mobil: Google/Facebook OAuth + WebRTC ICE. */
publicConfigRouter.get('/', (_req, res) => {
  const googleId = config.googleClientId?.trim() ?? '';
  res.json({
    googleWebClientId: googleId || null,
    googleSignInEnabled: googleId.length > 0,
    facebookAppId: config.facebookAppId?.trim() || null,
    facebookSignInEnabled:
      Boolean(config.facebookAppId?.trim()) &&
      Boolean(config.facebookAppSecret?.trim()),
    iceServers: buildIceServers(),
    tournamentAllowBots: config.tournamentAllowBots,
  });
});
