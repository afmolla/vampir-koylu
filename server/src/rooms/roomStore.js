import { randomBytes } from 'crypto';
import {
  assignRoles,
  countEvilAlive,
  countGoodAlive,
  isEvilTeam,
  ROLES,
} from '../game/roles.js';
import {
  createMatchLog,
  logEvent,
  recordAccusation,
  buildMatchSummary,
} from '../game/matchLog.js';
import { listClientChannels } from '../game/chatChannels.js';
import {
  applyMatchRewards,
  applyHostLeavePenalty,
  grantMatchEntry,
  incrementQuestMetric,
  isBotUserId,
} from '../services/progression.js';

const MIN_PLAYERS = 6;
const MIN_HUMANS_TO_START = 2;

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
    .filter((r) => r.status === 'lobby' && !r.isTournament)
    .map((r) => ({
      code: r.code,
      playerCount: r.players.length,
      maxPlayers: r.maxPlayers,
      hostNick: r.players.find((p) => p.userId === r.hostId)?.nick ?? '?',
    }));
}

/** Turnuva lobisi — kod T ile baslar */
export function createTournamentRoom({ tournamentId, hostId, hostNick, maxPlayers }) {
  const max = Math.min(8, Math.max(2, Number(maxPlayers) || 6));
  let code;
  do {
    code = `T${randomCode().slice(0, 5)}`;
  } while (rooms.has(code));

  const room = {
    code,
    status: 'lobby',
    maxPlayers: max,
    hostId: hostId ?? null,
    tournamentId,
    isTournament: true,
    players: [],
    game: null,
  };
  if (hostId && hostNick) {
    room.players.push({ userId: hostId, nick: hostNick, socketId: null });
  }
  rooms.set(code, room);
  return code;
}

export function getTournamentRoomSnapshot(code) {
  const room = getRoomByCode(code);
  if (!room || !room.isTournament) return null;
  return {
    code: room.code,
    tournamentId: room.tournamentId,
    status: room.status,
    maxPlayers: room.maxPlayers,
    hostId: room.hostId,
    players: room.players.map((p) => ({
      userId: p.userId,
      nick: p.nick,
      connected: Boolean(p.socketId),
    })),
    canStart:
      room.status === 'lobby' &&
      room.players.length >= 2 &&
      room.players.every((p) => p.socketId),
  };
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
    fillWithBots: Boolean(room.fillWithBots),
    isTournament: Boolean(room.isTournament),
    tournamentId: room.tournamentId ?? null,
    players: room.players.map((p) => ({
      userId: p.userId,
      nick: p.nick,
      isHost: p.userId === room.hostId,
      isBot: Boolean(p.isBot) || isBotUserId(p.userId),
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
  const g = room.game;
  base.game = {
    ...publicGameState(room),
    yourRole: me?.alive ? me.role : me?.role ?? null,
    canAct: canPlayerAct(room, userId),
    validTargets: validTargets(room, userId),
    votes: g.phase === 'dayVote' ? g.dayVotes : undefined,
    chatChannels: listClientChannels(room, userId),
    matchSummary:
      g.phase === 'gameOver' || g.winner
        ? buildMatchSummary(room)
        : null,
  };
  return base;
}

function canPlayerAct(room, userId) {
  const g = room.game;
  if (!g || g.winner) return false;
  const me = g.players.find((p) => p.userId === userId);
  if (!me?.alive) return false;
  if (g.phase === 'night') {
    const meta = ROLES[me.role];
    return meta?.nightAction === 'kill' && !g.nightChoices.has(userId);
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
  if (g.phase === 'night' && ROLES[me.role]?.nightAction === 'kill') {
    return alive.filter((p) => !isEvilTeam(p.role)).map((p) => p.id);
  }
  if (g.phase === 'dayVote') {
    return alive.map((p) => p.id);
  }
  return [];
}

function addBotPlayers(room, targetCount) {
  let n = 1;
  while (room.players.length < targetCount) {
    room.players.push({
      userId: `bot:${room.code}:${n}`,
      nick: `Bot ${n}`,
      socketId: null,
      isBot: true,
    });
    n += 1;
  }
}

function pickRandom(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

function tickBotActions(room) {
  const g = room.game;
  if (!g || g.winner) return;

  const alive = g.players.filter((p) => p.alive);
  const bots = alive.filter((p) => isBotUserId(p.userId));

  if (g.phase === 'night') {
    for (const bot of bots) {
      if (ROLES[bot.role]?.nightAction === 'kill' && !g.nightChoices.has(bot.userId)) {
        const targets = alive.filter(
          (p) => p.userId !== bot.userId && !isEvilTeam(p.role),
        );
        if (targets.length) g.nightChoices.set(bot.userId, pickRandom(targets).id);
      }
      if (bot.role === 'doctor' && !g.nightProtects.has(bot.userId)) {
        const others = alive.filter((p) => p.userId !== bot.userId);
        if (others.length) g.nightProtects.set(pickRandom(others).userId, bot.userId);
      }
    }
    const killers = g.players.filter(
      (p) => p.alive && ROLES[p.role]?.nightAction === 'kill',
    );
    if (g.nightChoices.size >= killers.length) resolveNight(room);
  }

  if (g.phase === 'dayVote') {
    for (const bot of bots) {
      if (!g.dayVotes.has(bot.userId)) {
        const targets = alive.filter((p) => p.userId !== bot.userId);
        if (targets.length) {
          const t = pickRandom(targets);
          g.dayVotes.set(bot.userId, t.id);
          recordAccusation(g.matchLog, t.userId);
        }
      }
    }
    if (g.dayVotes.size >= alive.length) resolveDay(room);
  }
}

export function createRoom({
  hostId,
  hostNick,
  maxPlayers = MIN_PLAYERS,
  socketId,
  fillWithBots = false,
}) {
  const max = Math.min(8, Math.max(MIN_PLAYERS, Number(maxPlayers) || MIN_PLAYERS));
  const code = randomCode();
  const room = {
    code,
    status: 'lobby',
    maxPlayers: max,
    hostId,
    fillWithBots: Boolean(fillWithBots),
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

function cancelGameForHostLeave(room) {
  if (!room.game) return;
  room.game.winner = null;
  room.game.phase = 'gameOver';
  room.game.message = 'host_left';
  room.status = 'finished';
}

export function leaveRoom(socketId) {
  const code = socketToRoom.get(socketId);
  if (!code) return null;
  socketToRoom.delete(socketId);
  const room = rooms.get(code);
  if (!room) return null;

  const leaving = room.players.find((p) => p.socketId === socketId);
  const wasHostInGame =
    room.status === 'playing' && leaving && leaving.userId === room.hostId;

  room.players = room.players.filter((p) => p.socketId !== socketId);

  if (wasHostInGame) {
    applyHostLeavePenalty(leaving.userId);
    cancelGameForHostLeave(room);
    const humans = room.players.filter((p) => !isBotUserId(p.userId));
    if (humans.length === 0) {
      rooms.delete(code);
      return { deleted: true, code, hostLeft: true };
    }
    if (room.hostId && !room.players.some((p) => p.userId === room.hostId)) {
      const nextHuman = humans[0];
      if (nextHuman) room.hostId = nextHuman.userId;
    }
    return { deleted: false, code, room, hostLeft: true };
  }

  if (room.players.length === 0) {
    rooms.delete(code);
    return { deleted: true, code };
  }
  if (room.hostId && !room.players.some((p) => p.userId === room.hostId)) {
    const next = room.players.find((p) => !isBotUserId(p.userId)) ?? room.players[0];
    if (next) room.hostId = next.userId;
  }
  return { deleted: false, code, room };
}

export function startGame(socketId, userId, { fillWithBots } = {}) {
  const room = getRoomForSocket(socketId);
  if (!room) return { error: 'not_in_room' };
  if (room.hostId !== userId) return { error: 'not_host' };
  if (room.status !== 'lobby') return { error: 'already_started' };

  const humans = room.players.filter((p) => !isBotUserId(p.userId));
  if (humans.length < MIN_HUMANS_TO_START) return { error: 'need_two_humans' };

  const useBots = fillWithBots ?? room.fillWithBots;
  if (room.players.length < MIN_PLAYERS) {
    if (!useBots) return { error: 'need_six_players' };
    addBotPlayers(room, MIN_PLAYERS);
  }

  const roles = assignRoles(room.players.length);

  room.status = 'playing';
  room.game = {
    phase: 'night',
    dayNumber: 1,
    message: 'night',
    lastVictimName: null,
    winner: null,
    nightChoices: new Map(),
    dayVotes: new Map(),
    nightProtects: new Map(),
    matchLog: createMatchLog(),
    players: room.players.map((p, idx) => ({
      id: idx,
      userId: p.userId,
      nick: p.nick,
      role: roles[idx],
      alive: true,
    })),
  };

  logEvent(room.game.matchLog, 'game_start', {
    playerCount: room.players.length,
    roles: roles.length,
  });

  for (const p of room.players) {
    if (!isBotUserId(p.userId)) grantMatchEntry(p.userId);
  }

  tickBotActions(room);

  return { room };
}

function checkWinner(game) {
  const alive = game.players.filter((p) => p.alive);
  const evil = countEvilAlive(alive);
  const good = countGoodAlive(alive);
  if (evil === 0) return 'villager';
  if (evil >= good) return 'vampire';
  return null;
}

function finalizeMatch(room) {
  const summary = buildMatchSummary(room);
  summary.roomCode = room.code;
  if (!summary) return;
  for (const p of room.game.players) {
    applyMatchRewards(p.userId, summary, p.role);
  }
  room.game.matchSummary = summary;
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
  const killer = g.players.find((p) => [...g.nightChoices.keys()].includes(p.userId));
  const victim = g.players.find((p) => p.id === best);
  if (victim) {
    if (!g.nightProtects.has(victim.userId)) {
      victim.alive = false;
      g.lastVictimName = victim.nick;
      logEvent(g.matchLog, 'night_kill', {
        killerNick: killer?.nick,
        victimNick: victim.nick,
        phase: 'night',
      });
    } else {
      incrementQuestMetric(g.nightProtects.get(victim.userId), 'saves', 1);
      g.lastVictimName = null;
      logEvent(g.matchLog, 'doctor_save', { victimNick: victim.nick });
    }
  }
  g.nightChoices.clear();
  g.phase = 'dayVote';
  g.message = 'day_vote';
  tickBotActions(room);
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
    recordAccusation(g.matchLog, victim.userId);
    victim.alive = false;
    g.lastVictimName = victim.nick;
    logEvent(g.matchLog, 'day_execute', {
      victimNick: victim.nick,
      phase: 'dayVote',
    });
  }
  const winner = checkWinner(g);
  if (winner) {
    g.winner = winner;
    g.phase = 'gameOver';
    g.message = 'game_over';
    room.status = 'finished';
    finalizeMatch(room);
    return;
  }
  g.phase = 'night';
  g.dayNumber += 1;
  g.message = 'night';
  tickBotActions(room);
}

export function gameAction(socketId, userId, { type, targetId }) {
  const room = getRoomForSocket(socketId);
  if (!room?.game) return { error: 'no_game' };
  if (isBotUserId(userId)) return { error: 'bot_player' };
  const g = room.game;
  const me = g.players.find((p) => p.userId === userId);
  if (!me?.alive) return { error: 'dead' };

  if (type === 'night_kill' && g.phase === 'night' && ROLES[me.role]?.nightAction === 'kill') {
    const target = g.players.find((p) => p.id === targetId && p.alive);
    if (!target || isEvilTeam(target.role)) return { error: 'invalid_target' };
    g.nightChoices.set(userId, targetId);
    const killers = g.players.filter(
      (p) => p.alive && ROLES[p.role]?.nightAction === 'kill',
    );
    if (g.nightChoices.size >= killers.length) resolveNight(room);
    tickBotActions(room);
    return { room };
  }

  if (type === 'doctor_protect' && g.phase === 'night' && me.role === 'doctor') {
    const target = g.players.find((p) => p.id === targetId && p.alive);
    if (!target) return { error: 'invalid_target' };
    g.nightProtects.set(target.userId, userId);
    return { room };
  }

  if (type === 'day_vote' && g.phase === 'dayVote') {
    const target = g.players.find((p) => p.id === targetId && p.alive);
    if (!target || target.userId === userId) return { error: 'invalid_target' };
    g.dayVotes.set(userId, targetId);
    recordAccusation(g.matchLog, target.userId);
    const alive = g.players.filter((p) => p.alive);
    if (g.dayVotes.size >= alive.length) resolveDay(room);
    tickBotActions(room);
    return { room };
  }

  if (type === 'deception' && g.phase === 'dayVote') {
    logEvent(g.matchLog, 'deception', { nick: me.nick, userId });
    incrementQuestMetric(userId, 'deceptions', 1);
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
