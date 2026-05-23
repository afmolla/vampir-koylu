import { randomBytes } from 'crypto';
import bcrypt from 'bcryptjs';
import { getDb } from '../db/database.js';
import { config } from '../config.js';

export function requestPasswordReset(email) {
  const db = getDb();
  const mail = String(email).trim().toLowerCase();
  const user = db.prepare('SELECT id FROM users WHERE email = ?').get(mail);
  if (!user) return { ok: true };

  const token = randomBytes(32).toString('hex');
  const expires = new Date(Date.now() + 3600_000).toISOString();
  db.prepare(
    `INSERT INTO password_reset_tokens (token, user_id, expires_at) VALUES (?, ?, ?)`,
  ).run(token, user.id, expires);

  const resetUrl = `${config.publicAppUrl}/reset?token=${token}`;
  if (config.smtpHost && config.smtpUser) {
    sendMail({
      to: mail,
      subject: 'Vampir Köylü — Şifre sıfırlama',
      text: `Şifrenizi sıfırlamak için: ${resetUrl}\nBu link 1 saat geçerlidir.`,
    }).catch((err) => console.error('mail error:', err));
  } else {
    console.log(`[dev] password reset ${mail}: ${resetUrl}`);
  }

  return { ok: true, devToken: config.nodeEnv === 'development' ? token : undefined };
}

export function resetPasswordWithToken(token, newPassword) {
  const db = getDb();
  const row = db
    .prepare('SELECT * FROM password_reset_tokens WHERE token = ? AND used = 0')
    .get(token);
  if (!row) return { error: 'invalid_token' };
  if (new Date(row.expires_at) < new Date()) return { error: 'expired' };
  if (String(newPassword ?? '').length < 6) return { error: 'weak_password' };

  const hash = bcrypt.hashSync(newPassword, 10);
  db.prepare('UPDATE users SET password_hash = ? WHERE id = ?').run(hash, row.user_id);
  db.prepare('UPDATE password_reset_tokens SET used = 1 WHERE token = ?').run(token);
  return { ok: true };
}

async function sendMail({ to, subject, text }) {
  if (!config.smtpHost) return;
  const nodemailer = await import('nodemailer');
  const transport = nodemailer.createTransport({
    host: config.smtpHost,
    port: config.smtpPort,
    secure: config.smtpSecure,
    auth: { user: config.smtpUser, pass: config.smtpPass },
  });
  await transport.sendMail({
    from: config.mailFrom,
    to,
    subject,
    text,
  });
}
