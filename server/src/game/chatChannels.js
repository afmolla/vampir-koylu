import { ROLES, isEvilTeam } from './roles.js';
import {
  canAccessDmChannel,
  isDmChannel,
} from '../services/dmChannels.js';

/**
 * Kanallar:
 * - general
 * - dm:UID_A:UID_B — kalici ozel ikili oda (oyundan bagimsiz)
 * - room:CODE — canlı oyuncu sohbeti
 * - dead:CODE — ölüler
 * - vampire:CODE — gece vampir gizli sohbet
 * - proximity:CODE — yakın ses (voice sinyali, metin yok)
 */
export function parseChannel(channel) {
  if (!channel || typeof channel !== 'string') return { type: 'unknown' };
  if (channel === 'general') return { type: 'general' };
  if (isDmChannel(channel)) {
    const parts = channel.split(':');
    return { type: 'dm', peerA: parts[1], peerB: parts[2] };
  }
  const [kind, code] = channel.split(':');
  return { type: kind, code: code?.toUpperCase() };
}

export function canAccessTextChannel({ channel, userId, room }) {
  const { type, code } = parseChannel(channel);
  if (type === 'general') return { ok: true };
  if (type === 'dm') return canAccessDmChannel(channel, userId);
  if (!room || room.code !== code) return { ok: false, error: 'not_in_room' };

  const g = room.game;
  const player = g?.players.find((p) => p.userId === userId)
    ?? room.players.find((p) => p.userId === userId);
  if (!player) return { ok: false, error: 'not_in_room' };

  if (!g || room.status !== 'playing') {
    if (type === 'room') return { ok: true };
    return { ok: false, error: 'game_not_started' };
  }

  const gp = g.players.find((p) => p.userId === userId);
  if (!gp) return { ok: false, error: 'not_in_game' };

  if (type === 'room') {
    return { ok: true };
  }

  if (type === 'dead') {
    if (gp.alive) return { ok: false, error: 'alive_use_room_chat' };
    return { ok: true };
  }

  if (type === 'vampire') {
    if (g.phase !== 'night') return { ok: false, error: 'vampire_chat_night_only' };
    if (!isEvilTeam(gp.role)) return { ok: false, error: 'not_vampire_team' };
    return { ok: true };
  }

  return { ok: false, error: 'invalid_channel' };
}

export function canAccessVoiceProximity({ userId, room }) {
  if (!room) return { ok: false, error: 'not_in_room' };
  const inRoom = room.players.some((p) => p.userId === userId);
  if (!inRoom) return { ok: false, error: 'not_in_room' };

  if (room.status === 'lobby') {
    return { ok: true, channel: `proximity:${room.code}` };
  }

  if (!room.game) return { ok: false, error: 'no_game' };
  const gp = room.game.players.find((p) => p.userId === userId);
  if (!gp?.alive) return { ok: false, error: 'dead_no_voice' };
  return { ok: true, channel: `proximity:${room.code}` };
}

/** Mobil: hangi sohbet sekmeleri görünsün */
export function listClientChannels(room, userId) {
  const g = room.game;
  const out = [];
  if (!g || room.status !== 'playing') {
    out.push({ id: `room:${room.code}`, type: 'room', voice: true });
    return out;
  }
  const gp = g.players.find((p) => p.userId === userId);
  if (!gp) return out;

  if (gp.alive) {
    out.push({ id: `room:${room.code}`, type: 'room', voice: true });
    out.push({ id: `proximity:${room.code}`, type: 'proximity', voice: true });
  } else {
    out.push({ id: `room:${room.code}`, type: 'room', voice: false });
    out.push({ id: `dead:${room.code}`, type: 'dead', voice: false });
  }
  if (isEvilTeam(gp.role)) {
    out.push({ id: `vampire:${room.code}`, type: 'vampire', voice: false });
  }
  return out;
}

export function chatRoomForSocket(room, userId) {
  const g = room.game;
  if (!g) return [`chat:room:${room.code}`];
  const gp = g.players.find((p) => p.userId === userId);
  if (!gp) return [];
  const channels = [];
  if (gp.alive) {
    channels.push(`chat:room:${room.code}`);
  } else {
    channels.push(`chat:room:${room.code}`);
    channels.push(`chat:dead:${room.code}`);
  }
  if (isEvilTeam(gp.role)) channels.push(`chat:vampire:${room.code}`);
  return channels;
}
