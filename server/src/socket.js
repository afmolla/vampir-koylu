import { Server } from 'socket.io';
import semver from 'semver';
import jwt from 'jsonwebtoken';
import { config } from './config.js';
import { getDb } from './db/database.js';
import {
  createRoom,
  joinRoom,
  leaveRoom,
  startGame,
  gameAction,
  viewsForRoom,
  getRoomForSocket,
} from './rooms/roomStore.js';
import {
  canAccessTextChannel,
  canAccessVoiceProximity,
  chatRoomForSocket,
} from './game/chatChannels.js';
import { ensureProfile } from './services/progression.js';
import {
  buildDmChannelId,
  joinSocketsToDmChannel,
  joinUserToAllDmSockets,
  listDmConversations,
  peerUserId,
  upsertDmSession,
} from './services/dmChannels.js';
import { getDb } from './db/database.js';

function emitRoomState(io, room) {
  for (const { userId, view } of viewsForRoom(room)) {
    const player = room.players.find((p) => p.userId === userId);
    if (player?.socketId) {
      io.to(player.socketId).emit('room:state', view);
    }
  }
}

function joinChatChannels(socket, room, userId) {
  for (const ch of chatRoomForSocket(room, userId)) {
    socket.join(ch);
  }
}

function saveMessage({ channel, userId, nick, content }) {
  const db = getDb();
  const stmt = db.prepare(
    'INSERT INTO messages (channel, user_id, nick, content) VALUES (?, ?, ?, ?)',
  );
  const result = stmt.run(channel, userId, nick, content);
  return {
    id: Number(result.lastInsertRowid),
    channel,
    user_id: userId,
    nick,
    content,
    created_at: new Date().toISOString(),
  };
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
      ensureProfile(socket.data.user.sub);
      next();
    } catch {
      next(new Error('UNAUTHORIZED'));
    }
  });

  io.on('connection', (socket) => {
    const userId = socket.data.user.sub;
    socket.emit('connected', { ok: true, userId });

    socket.join('chat:general');
    socket.join(`user:${userId}`);
    joinUserToAllDmSockets(socket, userId);

    socket.on('chat:dm:open', (payload, ack) => {
      try {
        const targetUserId = String(payload?.targetUserId ?? '').trim();
        if (!targetUserId || targetUserId === userId) {
          if (typeof ack === 'function') ack({ ok: false, error: 'invalid_target' });
          return;
        }
        const channel = buildDmChannelId(userId, targetUserId);
        upsertDmSession(channel, userId, targetUserId);
        socket.join(`chat:${channel}`);
        joinSocketsToDmChannel(io, channel, userId, targetUserId);

        const db = getDb();
        const peer = db.prepare('SELECT id, nick FROM users WHERE id = ?').get(targetUserId);

        io.to(`user:${targetUserId}`).emit('chat:dm:opened', {
          channel,
          fromUserId: userId,
          fromNick: payload?.myNick ?? 'Player',
        });

        if (typeof ack === 'function') {
          ack({
            ok: true,
            channel,
            peer: {
              userId: targetUserId,
              nick: peer?.nick ?? payload?.targetNick ?? '?',
            },
          });
        }
      } catch (err) {
        console.error('chat:dm:open error:', err);
        if (typeof ack === 'function') ack({ ok: false, error: 'server_error' });
      }
    });

    socket.on('chat:dm:list', (_payload, ack) => {
      const list = listDmConversations(userId);
      if (typeof ack === 'function') ack({ ok: true, conversations: list });
    });

    socket.on('room:create', (payload, ack) => {
      const maxPlayers = payload?.maxPlayers ?? 6;
      const nick = payload?.nick ?? 'Player';
      const view = createRoom({
        hostId: userId,
        hostNick: String(nick).slice(0, 24),
        maxPlayers,
        socketId: socket.id,
        fillWithBots: Boolean(payload?.fillWithBots),
      });
      const room = getRoomForSocket(socket.id);
      if (room) joinChatChannels(socket, room, userId);
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
      if (room) {
        joinChatChannels(socket, room, userId);
        emitRoomState(io, room);
      }
      if (typeof ack === 'function') ack({ ok: true, room: result.room });
    });

    socket.on('room:leave', (_payload, ack) => {
      const room = getRoomForSocket(socket.id);
      if (room) {
        for (const ch of chatRoomForSocket(room, userId)) socket.leave(ch);
      }
      const result = leaveRoom(socket.id);
      if (result?.room && !result.deleted) {
        emitRoomState(io, result.room);
      }
      if (typeof ack === 'function') {
        ack({ ok: true, hostLeft: Boolean(result?.hostLeft) });
      }
    });

    socket.on('room:start', (payload, ack) => {
      const result = startGame(socket.id, userId, {
        fillWithBots: Boolean(payload?.fillWithBots),
      });
      if (result.error) {
        if (typeof ack === 'function') ack({ ok: false, error: result.error });
        return;
      }
      const room = getRoomForSocket(socket.id);
      if (room) {
        for (const ch of chatRoomForSocket(room, userId)) socket.join(ch);
        emitRoomState(io, room);
      }
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

    socket.on('chat:send', (payload, ack) => {
      try {
        const content = String(payload?.content ?? '').trim();
        if (!content || content.length > 500) {
          if (typeof ack === 'function') ack({ ok: false, error: 'invalid_message' });
          return;
        }

        const channel = payload?.channel ?? 'general';
        const nick = payload?.nick ?? 'Player';
        const room = getRoomForSocket(socket.id);

        if (channel !== 'general') {
          const access = canAccessTextChannel({ channel, userId, room });
          if (!access.ok) {
            if (typeof ack === 'function') ack({ ok: false, error: access.error });
            return;
          }
          if (channel.startsWith('dm:')) {
            const other = peerUserId(channel, userId);
            if (other) upsertDmSession(channel, userId, other);
          }
        }

        const message = saveMessage({
          channel,
          userId,
          nick: String(nick).slice(0, 24),
          content,
        });

        io.to(`chat:${channel}`).emit('chat:message', message);
        if (typeof ack === 'function') ack({ ok: true, message });
      } catch (err) {
        console.error('chat:send error:', err);
        if (typeof ack === 'function') ack({ ok: false, error: 'server_error' });
      }
    });

    socket.on('chat:join', (payload) => {
      const channel = payload?.channel;
      if (!channel || typeof channel !== 'string') return;
      const room = getRoomForSocket(socket.id);
      if (channel !== 'general') {
        const access = canAccessTextChannel({ channel, userId, room });
        if (!access.ok) return;
      }
      socket.join(`chat:${channel}`);
    });

    /** Yakın ses — WebRTC sinyal relay (beta, kozmetik ses efekti client'ta) */
    socket.on('voice:join', (payload, ack) => {
      const room = getRoomForSocket(socket.id);
      const access = canAccessVoiceProximity({ userId, room });
      if (!access.ok) {
        if (typeof ack === 'function') ack({ ok: false, error: access.error });
        return;
      }
      socket.join(`voice:${access.channel}`);
      socket.data.voiceChannel = access.channel;
      if (typeof ack === 'function') ack({ ok: true, channel: access.channel });
    });

    socket.on('voice:leave', () => {
      if (socket.data.voiceChannel) {
        socket.leave(`voice:${socket.data.voiceChannel}`);
        socket.data.voiceChannel = null;
      }
    });

    socket.on('voice:signal', (payload) => {
      const room = getRoomForSocket(socket.id);
      if (!room?.game) return;
      const channel = socket.data.voiceChannel ?? `proximity:${room.code}`;
      socket.to(`voice:${channel}`).emit('voice:signal', {
        from: userId,
        ...payload,
      });
    });

    socket.on('disconnect', () => {
      if (socket.data.voiceChannel) {
        socket.leave(`voice:${socket.data.voiceChannel}`);
      }
      const room = getRoomForSocket(socket.id);
      if (room) {
        for (const ch of chatRoomForSocket(room, userId)) socket.leave(ch);
      }
      const result = leaveRoom(socket.id);
      if (result?.room && !result.deleted) {
        emitRoomState(io, result.room);
      }
    });
  });

  return io;
}
