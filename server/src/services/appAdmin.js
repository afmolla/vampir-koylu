import { config } from '../config.js';
import { getUserById } from './authService.js';

function parseList(raw) {
  return String(raw ?? '')
    .split(',')
    .map((s) => s.trim().toLowerCase())
    .filter(Boolean);
}

/** Uygulama içi yönetici (afmolla vb.) — API anahtarı değil. */
export function isAppAdmin(userOrId) {
  const user =
    typeof userOrId === 'string' ? getUserById(userOrId) : userOrId;
  if (!user) return false;

  const adminNicks = parseList(config.adminNicks);
  const nick = String(user.nick ?? '').trim().toLowerCase();
  if (adminNicks.includes(nick)) return true;

  const adminEmails = parseList(config.adminEmails);
  const mail = String(user.email ?? '').trim().toLowerCase();
  if (mail && adminEmails.includes(mail)) return true;

  return false;
}
