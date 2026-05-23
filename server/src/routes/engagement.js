import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config.js';
import {
  applyReferralCode,
  claimDailyLogin,
  claimFirstMatchBonus,
  claimQuest,
  claimSeasonTier,
  claimWeeklyQuest,
  getHomeDashboard,
  getLeaderboard,
  getSeasonPass,
  registerPushToken,
} from '../services/engagement.js';
import { listPublicRooms } from '../rooms/roomStore.js';
import { getOnlinePlayerCount } from '../services/liveStats.js';
import { getLiveSummary } from '../rooms/roomStore.js';

export const engagementRouter = Router();

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

engagementRouter.get('/live', (_req, res) => {
  const rooms = listPublicRooms();
  const live = getLiveSummary();
  res.json({
    onlinePlayers: getOnlinePlayerCount(),
    openRooms: rooms.length,
    playersInLobbies: live.playersInLobbies,
    rooms,
  });
});

engagementRouter.get('/home', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  res.json(getHomeDashboard(userId));
});

engagementRouter.post('/daily-login', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  res.json(claimDailyLogin(userId));
});

engagementRouter.post('/quests/:questId/claim', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  res.json(claimQuest(userId, req.params.questId));
});

engagementRouter.post('/weekly/:questId/claim', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  res.json(claimWeeklyQuest(userId, req.params.questId));
});

engagementRouter.post('/first-match-bonus', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  res.json(claimFirstMatchBonus(userId));
});

engagementRouter.post('/referral', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  res.json(applyReferralCode(userId, req.body?.code));
});

engagementRouter.get('/leaderboard', (req, res) => {
  const type = req.query.type === 'wins' ? 'wins' : 'xp';
  const limit = Number(req.query.limit) || 20;
  res.json(getLeaderboard({ type, limit }));
});

engagementRouter.get('/season', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  res.json(getSeasonPass(userId));
});

engagementRouter.post('/season/claim', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  res.json(
    claimSeasonTier(userId, Number(req.body?.tier), req.body?.track ?? 'free'),
  );
});

engagementRouter.post('/push-token', (req, res) => {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  res.json(
    registerPushToken(userId, req.body?.token, req.body?.platform ?? 'android'),
  );
});
