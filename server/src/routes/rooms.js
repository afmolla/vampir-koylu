import { Router } from 'express';
import { listPublicRooms, getLiveSummary } from '../rooms/roomStore.js';
import { getOnlinePlayerCount } from '../services/liveStats.js';

export const roomsRouter = Router();

roomsRouter.get('/', (_req, res) => {
  const live = getLiveSummary();
  res.json({
    rooms: listPublicRooms(),
    onlinePlayers: getOnlinePlayerCount(),
    openRooms: live.openRooms,
    playersInLobbies: live.playersInLobbies,
  });
});
