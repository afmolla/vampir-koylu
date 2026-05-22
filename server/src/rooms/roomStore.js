import { randomBytes } from 'crypto';

const rooms = new Map();
const socketToRoom = new Map();

function randomCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let code = '';
  const bytes = randomBytes(6);
  for (let i = 0; i < 6; i++) {
    code += chars[bytes[i] % chars.length];
  }
  if (rooms.has(code)) return randomCode();
  return code;
}

export function listPublicRooms() {
  return [...rooms.values()]
    .filter((r) => r.status === 'lobby')
    .map((r) => ({
      code: r.code,
      playerCount: r.players.length,
      maxPlayers: r.maxPlayers,
      hostNick: r.players.find((p) => p.userId === r.hostId)?.nick ?? '?',
    }));
}

export function getRoomByCode(code) {
  return rooms.get(String(code).toUpperCase()) ?? null;
}

export function getRoomForSocket(socketId) {
  const code = socketToRoom.get(socketId);
  if (!code) return null;
  return rooms.get(code) ?? null;
}

function sanitizeRoom(room) {
  return {
    code: room.code,
    status: room.status,
    maxPlayers: room.maxPlayers,
    hostId: room.hostId,
    players: room.players.map((p) => ({
      userId: p.userId,
      nick: p.nick,
      isHost: p.userId === room.hostId,
    })),
    game: room.game ? publicGameState(room) : null,
  };
}

function publicGameState(room) {
  const g = room.game;
  return {
    phase: g.phase,
    dayNumber: g.dayNumber,
    message: g.message,
    lastVictimName: g.lastVictimName,
    winner: g.winner,
    players: g.players.map((p) => ({
      id: p.id,
      nick: p.nick,
      alive: p.alive,
    })),
    yourRole: null,
  };
}

function playerView(room, userId) {
  const base = sanitizeRoom(room);
  if (!room.game) return base;
  const me = room.game.players.find((p) => p.userId === userId);
  base.game = {
    ...publicGameState(room),
    yourRole: me?.alive ? me.role : me?.role ?? null,
    canAct: canPlayerAct(room, userId),
    validTargets: validTargets(room, userId),
    votes: room.game.phase === 'dayVote' ? room.game.votes : undefined,
  };
  return base;
}

function canPlayerAct(room, userId) {
  const g = room.game;
  if (!g || g.winner) return false;
  const me = g.players.find((p) => p.userId === userId);
  if (!me?.alive) return false;
  if (g.phase === 'night') {
    return me.role === 'vampire' && !g.nightChoices.has(userId);
  }
  if (g.phase === 'dayVote') {
    return !g.dayVotes.has(userId);
  }
  return false;
}

function validTargets(room, userId) {
  const g = room.game;
  if (!g) return [];
  const me = g.players.find((p) => p.userId === userId);
  if (!me?.alive) return [];
  const alive = g.players.filter((p) => p.alive && p.userId !== userId);
  if (g.phase === 'night' && me.role === 'vampire') {
    return alive.filter((p) => p.role !== 'vampire').map((p) => p.id);
  }
  if (g.phase === 'dayVote') {
    return alive.map((p) => p.id);
  }
  return [];
}

export function createRoom({ hostId, hostNick, maxPlayers = 6, socketId }) {
  const max = Math.min(8, Math.max(6, Number(maxPlayers) || 6));
  const code = randomCode();
  const room = {
    code,
    status: 'lobby',
    maxPlayers: max,
    hostId,
    players: [{ userId: hostId, nick: hostNick, socketId }],
    game: null,
  };
  rooms.set(code, room);
  socketToRoom.set(socketId, code);
  return playerView(room, hostId);
}

export function joinRoom({ code, userId, nick, socketId }) {
  const room = getRoomByCode(code);
  if (!room) return { error: 'room_not_found' };
  if (room.status !== 'lobby') return { error: 'game_already_started' };
  if (room.players.some((p) => p.userId === userId)) {
    const existing = room.players.find((p) => p.userId === userId);
    existing.socketId = socketId;
    socketToRoom.set(socketId, room.code);
    return { room: playerView(room, userId) };
  }
  if (room.players.length >= room.maxPlayers) return { error: 'room_full' };
  room.players.push({ userId, nick, socketId });
  socketToRoom.set(socketId, room.code);
  return { room: playerView(room, userId) };
}

export function leaveRoom(socketId) {
  const code = socketToRoom.get(socketId);
  if (!code) return null;
  socketToRoom.delete(socketId);
  const room = rooms.get(code);
  if (!room) return null;

  room.players = room.players.filter((p) => p.socketId !== socketId);
  if (room.players.length === 0) {
    rooms.delete(code);
    return { deleted: true, code };
  }
  if (room.hostId && !room.players.some((p) => p.userId === room.hostId)) {
    room.hostId = room.players[0].userId;
  }
  return { deleted: false, code, room };
}

export function startGame(socketId, userId) {
  const room = getRoomForSocket(socketId);
  if (!room) return { error: 'not_in_room' };
  if (room.hostId !== userId) return { error: 'not_host' };
  if (room.status !== 'lobby') return { error: 'already_started' };
  if (room.players.length < 2) return { error: 'need_two_players' };

  const vampireCount = room.players.length >= 8 ? 2 : 1;
  const roles = [
    ...Array(vampireCount).fill('vampire'),
    ...Array(room.players.length - vampireCount).fill('villager'),
  ];
  for (let i = roles.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [roles[i], roles[j]] = [roles[j], roles[i]];
  }

  room.status = 'playing';
  room.game = {
    phase: 'night',
    dayNumber: 1,
    message: null,
    lastVictimName: null,
    winner: null,
    nightChoices: new Map(),
    dayVotes: new Map(),
    players: room.players.map((p, idx) => ({
      id: idx,
      userId: p.userId,
      nick: p.nick,
      role: roles[idx],
      alive: true,
    })),
  };

  return { room };
}

function checkWinner(game) {
  const alive = game.players.filter((p) => p.alive);
  const vampires = alive.filter((p) => p.role === 'vampire').length;
  const villagers = alive.length - vampires;
  if (vampires === 0) return 'villager';
  if (vampires >= villagers) return 'vampire';
  return null;
}

function resolveNight(room) {
  const g = room.game;
  const votes = [...g.nightChoices.values()];
  if (votes.length === 0) return;
  const counts = new Map();
  for (const id of votes) counts.set(id, (counts.get(id) ?? 0) + 1);
  let best = votes[0];
  let bestN = 0;
  for (const [id, n] of counts) {
    if (n > bestN) {
      bestN = n;
      best = id;
    }
  }
  const victim = g.players.find((p) => p.id === best);
  if (victim) {
    victim.alive = false;
    g.lastVictimName = victim.nick;
  }
  g.nightChoices.clear();
  g.phase = 'dayVote';
  g.message = 'day_vote';
}

function resolveDay(room) {
  const g = room.game;
  const votes = [...g.dayVotes.values()];
  g.dayVotes.clear();
  if (votes.length === 0) {
    g.phase = 'night';
    g.dayNumber += 1;
    g.message = 'night';
    return;
  }
  const counts = new Map();
  for (const id of votes) counts.set(id, (counts.get(id) ?? 0) + 1);
  let best = votes[0];
  let bestN = 0;
  for (const [id, n] of counts) {
    if (n > bestN) {
      bestN = n;
      best = id;
    }
  }
  const victim = g.players.find((p) => p.id === best);
  if (victim) {
    victim.alive = false;
    g.lastVictimName = victim.nick;
  }
  const winner = checkWinner(g);
  if (winner) {
    g.winner = winner;
    g.phase = 'gameOver';
    g.message = 'game_over';
    room.status = 'finished';
    return;
  }
  g.phase = 'night';
  g.dayNumber += 1;
  g.message = 'night';
}

export function gameAction(socketId, userId, { type, targetId }) {
  const room = getRoomForSocket(socketId);
  if (!room?.game) return { error: 'no_game' };
  const g = room.game;
  const me = g.players.find((p) => p.userId === userId);
  if (!me?.alive) return { error: 'dead' };

  if (type === 'night_kill' && g.phase === 'night' && me.role === 'vampire') {
    const target = g.players.find((p) => p.id === targetId && p.alive);
    if (!target || target.role === 'vampire') return { error: 'invalid_target' };
    g.nightChoices.set(userId, targetId);
    const vampires = g.players.filter((p) => p.alive && p.role === 'vampire');
    if (g.nightChoices.size >= vampires.length) resolveNight(room);
    return { room };
  }

  if (type === 'day_vote' && g.phase === 'dayVote') {
    const target = g.players.find((p) => p.id === targetId && p.alive);
    if (!target || target.userId === userId) return { error: 'invalid_target' };
    g.dayVotes.set(userId, targetId);
    const alive = g.players.filter((p) => p.alive);
    if (g.dayVotes.size >= alive.length) resolveDay(room);
    return { room };
  }

  return { error: 'invalid_action' };
}

export function viewsForRoom(room) {
  return room.players.map((p) => ({
    userId: p.userId,
    view: playerView(room, p.userId),
  }));
}

export { sanitizeRoom, playerView };
