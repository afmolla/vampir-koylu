import { isBotUserId } from '../services/progression.js';

const FIRST_NAMES = [
  'Ahmet',
  'Mehmet',
  'Ayşe',
  'Fatma',
  'Can',
  'Elif',
  'Murat',
  'Zeynep',
  'Emre',
  'Deniz',
  'Selin',
  'Burak',
  'Cem',
  'Ece',
  'Oğuz',
  'Merve',
];

const LOBBY_LINES = [
  'Hazır mısınız?',
  'Geliyor musunuz?',
  'Ben hazırım.',
  'Oyunu bekliyorum.',
  'Bugün vampir kim acaba?',
  'Dikkatli oylayalım.',
];

const NIGHT_LINES = [
  'Gece oldu… sessizlik.',
  'Kimse dışarı çıkmasın.',
  'Garip bir gece.',
];

const VOTE_LINES = [
  'Bence şüpheli biri var.',
  'Oylamaya hazır mısınız?',
  'Mehmet\'e mi oy verelim?',
  'Bir dakika düşünelim.',
  'Ben emin değilim ama…',
];

function pick(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

export function randomBotNick() {
  return `Bot ${pick(FIRST_NAMES)}`;
}

/** Benzersiz bot userId */
export function botUserId(roomCode, slot) {
  return `bot:${roomCode}:${slot}`;
}

/**
 * Odaya en az bir bot mesajı (lobi / oyun).
 * @returns {{ channel: string, userId: string, nick: string, content: string }[]}
 */
export function generateBotChat(room, { phase = 'lobby', force = false } = {}) {
  const bots = room.players.filter((p) => isBotUserId(p.userId));
  if (!bots.length) return [];

  const chance = force ? 1 : phase === 'lobby' ? 0.45 : 0.55;
  if (Math.random() > chance) return [];

  const speaker = pick(bots);
  let pool = LOBBY_LINES;
  if (phase === 'night') pool = NIGHT_LINES;
  if (phase === 'dayVote') pool = VOTE_LINES;

  return [
    {
      channel: `room:${room.code}`,
      userId: speaker.userId,
      nick: speaker.nick,
      content: pick(pool),
    },
  ];
}
