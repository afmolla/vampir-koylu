import { Router } from 'express';
import { listPublicRooms } from '../rooms/roomStore.js';

export const roomsRouter = Router();

roomsRouter.get('/', (_req, res) => {
  res.json({ rooms: listPublicRooms() });
});
