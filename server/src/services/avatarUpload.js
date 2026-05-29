import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { randomUUID } from 'crypto';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
export const avatarsDir = path.join(__dirname, '../../uploads/avatars');

fs.mkdirSync(avatarsDir, { recursive: true });

const MIME_EXT = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/webp': '.webp',
};

export const AVATAR_MAX_BYTES = 2 * 1024 * 1024;

export function extForMime(mime) {
  return MIME_EXT[mime] ?? null;
}

export function isAllowedAvatarMime(mime) {
  return MIME_EXT[mime] != null;
}

/** Eski yuklenen avatar dosyasini sil (yalnizca /uploads/avatars/). */
export function deleteStoredAvatarIfLocal(avatarUrl) {
  if (!avatarUrl || !avatarUrl.includes('/uploads/avatars/')) return;
  const name = path.basename(avatarUrl.split('?')[0]);
  if (!name || name.includes('..')) return;
  const full = path.join(avatarsDir, name);
  try {
    if (fs.existsSync(full)) fs.unlinkSync(full);
  } catch (_) {
    /* ignore */
  }
}

export function newAvatarFilename(userId, mime) {
  const ext = extForMime(mime) ?? '.jpg';
  return `${userId}-${randomUUID().slice(0, 8)}${ext}`;
}

export function publicAvatarUrl(req, filename) {
  const envBase = process.env.API_PUBLIC_BASE_URL?.replace(/\/$/, '');
  const base = envBase || `${req.protocol}://${req.get('host')}`;
  return `${base}/uploads/avatars/${filename}`;
}
