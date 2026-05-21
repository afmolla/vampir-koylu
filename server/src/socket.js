import { Server } from 'socket.io';
import semver from 'semver';
import jwt from 'jsonwebtoken';
import { config } from './config.js';
import {
  createRoom,
  joinRoom,
  leaveRoom,
  startGame,
  gameAction,
  viewsForRoom,
  getRoomForSocket,
  playerView,
} from './rooms/roomStore.js';

function emitRoomState(io, room) {
  for (const { userId, view } of viewsForRoom(room)) {
    const player = room.players.find((p) => p.userId === userId);
    if (player?.socketId) {
      io.to(player.socketId).emit('room:state', view);
    }
  }
}

export function attachSocket(httpServer) {
  const io = new Server(httpServer, {
    cors: { origin: '*' },
    transports: ['websocket', 'polling'],
    pingInterval: 25000,
    pingTimeout: 20000,
  });

  io.use((socket, next) => {
    const clientVersion = socket.handshake.auth?.clientVersion ?? '0.0.0';
    if (
      !semver.valid(clientVersion) ||
      semver.lt(clientVersion, config.minRequiredVersion)
    ) {
      return next(new Error('VERSION_OUTDATED'));
    }

    const token = socket.handshake.auth?.token;
    if (!token) return next(new Error('UNAUTHORIZED'));

    try {
      socket.data.user = jwt.verify(token, config.jwtSecret);
      next();
    } catch {
      next(new Error('UNAUTHORIZED'));
    }
  });

  io.on('connection', (socket) => {
    const userId = socket.data.user.sub;
    socket.emit('connected', { ok: true, userId });

    socket.on('room:create', (payload, ack) => {
      const maxPlayers = payload?.maxPlayers ?? 6;
      const nick = payload?.nick ?? 'Player';
      const view = createRoom({
        hostId: userId,
        hostNick: String(nick).slice(0, 24),
        maxPlayers,
        socketId: socket.id,
      });
      if (typeof ack === 'function') ack({ ok: true, room: view });
      socket.emit('room:state', view);
    });

    socket.on('room:join', (payload, ack) => {
      const result = joinRoom({
        code: payload?.code,
        userId,
        nick: String(payload?.nick ?? 'Player').slice(0, 24),
        socketId: socket.id,
      });
      if (result.error) {
        if (typeof ack === 'function') ack({ ok: false, error: result.error });
        return;
      }
      const room = getRoomForSocket(socket.id);
      if (room) emitRoomState(io, room);
      if (typeof ack === 'function') ack({ ok: true, room: result.room });
    });

    socket.on('room:leave', (_payload, ack) => {
      const result = leaveRoom(socket.id);
      if (result?.room && !result.deleted) {
        emitRoomState(io, result.room);
      }
      if (typeof ack === 'function') ack({ ok: true });
    });

    socket.on('room:start', (_payload, ack) => {
      const result = startGame(socket.id, userId);
      if (result.error) {
        if (typeof ack === 'function') ack({ ok: false, error: result.error });
        return;
      }
      const room = getRoomForSocket(socket.id);
      if (room) emitRoomState(io, room);
      if (typeof ack === 'function') ack({ ok: true });
    });

    socket.on('game:action', (payload, ack) => {
      const result = gameAction(socket.id, userId, payload ?? {});
      if (result.error) {
        if (typeof ack === 'function') ack({ ok: false, error: result.error });
        return;
      }
      const room = getRoomForSocket(socket.id);
      if (room) emitRoomState(io, room);
      if (typeof ack === 'function') ack({ ok: true });
    });

    socket.on('disconnect', () => {
      const result = leaveRoom(socket.id);
      if (result?.room && !result.deleted) {
        emitRoomState(io, result.room);
      }
    });
  });

  return io;
}
