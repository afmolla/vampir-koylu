import { Server } from 'socket.io';
import semver from 'semver';
import jwt from 'jsonwebtoken';
import { config } from './config.js';

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
    socket.emit('connected', { ok: true });

    socket.on('ping_room', (payload, ack) => {
      if (typeof ack === 'function') {
        ack({ ok: true, echo: payload ?? null });
      }
    });
  });

  return io;
}
