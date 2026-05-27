import { Router } from 'express';
import jwt from 'jsonwebtoken';
import multer from 'multer';
import { config } from '../config.js';
import { requireAuth } from '../middleware/requireAuth.js';
import {
  getUserById,
  guestLogin,
  loginWithEmail,
  loginWithFacebook,
  loginWithGoogle,
  registerAccount,
  updateAccount,
} from '../services/authService.js';
import {
  AVATAR_MAX_BYTES,
  avatarsDir,
  deleteStoredAvatarIfLocal,
  isAllowedAvatarMime,
  newAvatarFilename,
  publicAvatarUrl,
} from '../services/avatarUpload.js';
import { requestPasswordReset, resetPasswordWithToken } from '../services/mail.js';
import { applyReferralCode } from '../services/engagement.js';
import { recordLogin } from '../services/engagement.js';
import { isAppAdmin } from '../services/appAdmin.js';

const avatarUpload = multer({
  storage: multer.diskStorage({
    destination: (_req, _file, cb) => cb(null, avatarsDir),
    filename: (req, file, cb) => {
      const name = newAvatarFilename(req.userId, file.mimetype);
      cb(null, name);
    },
  }),
  limits: { fileSize: AVATAR_MAX_BYTES, files: 1 },
  fileFilter: (_req, file, cb) => {
    if (!isAllowedAvatarMime(file.mimetype)) {
      return cb(new Error('invalid_file_type'));
    }
    cb(null, true);
  },
});

export const authRouter = Router();

function signToken(user) {
  return jwt.sign(
    { sub: user.id, isGuest: user.isGuest },
    config.jwtSecret,
    { expiresIn: config.jwtExpiresIn },
  );
}

function authResponse(user, res) {
  res.json({
    token: signToken(user),
    user: {
      id: user.id,
      nick: user.nick,
      isGuest: user.isGuest,
      locale: user.locale,
      email: user.email,
      avatarUrl: user.avatarUrl,
      createdAt: user.createdAt,
      isAdmin: isAppAdmin(user),
    },
  });
}

authRouter.post('/register', (req, res) => {
  const result = registerAccount({
    email: req.body?.email,
    password: req.body?.password,
    nick: req.body?.nick,
    locale: req.body?.locale,
  });
  if (result.error) {
    const status =
      result.error === 'email_taken' || result.error === 'nick_taken'
        ? 409
        : 400;
    return res.status(status).json({ error: result.error });
  }
  if (result.user && req.body?.referralCode) {
    applyReferralCode(result.user.id, req.body.referralCode);
  }
  authResponse(result.user, res);
});

authRouter.post('/login', (req, res) => {
  const result = loginWithEmail({
    login: req.body?.login ?? req.body?.email ?? req.body?.nick,
    password: req.body?.password,
  });
  if (result.error) return res.status(401).json({ error: result.error });
  recordLogin(result.user.id);
  authResponse(result.user, res);
});

authRouter.post('/forgot-password', (req, res) => {
  res.json(requestPasswordReset(req.body?.email));
});

authRouter.post('/reset-password', (req, res) => {
  const result = resetPasswordWithToken(req.body?.token, req.body?.password);
  if (result.error) return res.status(400).json(result);
  res.json(result);
});

authRouter.post('/me/avatar', requireAuth, (req, res, next) => {
  avatarUpload.single('avatar')(req, res, (err) => {
    if (err) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(400).json({ error: 'file_too_large' });
      }
      if (err.message === 'invalid_file_type') {
        return res.status(400).json({ error: 'invalid_file_type' });
      }
      return res.status(400).json({ error: 'upload_failed' });
    }
    next();
  });
}, (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'no_file' });

  try {
    deleteStoredAvatarIfLocal(req.authUser.avatarUrl);
    const avatarUrl = publicAvatarUrl(req, req.file.filename);
    const result = updateAccount(req.userId, { avatarUrl });
    if (result.error) return res.status(400).json(result);
    res.json({
      avatarUrl: result.user.avatarUrl,
      user: {
        id: result.user.id,
        nick: result.user.nick,
        isGuest: result.user.isGuest,
        locale: result.user.locale,
        email: result.user.email,
        avatarUrl: result.user.avatarUrl,
      },
    });
  } catch (e) {
    console.error('avatar upload:', e);
    res.status(500).json({ error: 'server_error' });
  }
});

authRouter.patch('/me', (req, res) => {
  const header = req.headers.authorization ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'unauthorized' });
  try {
    const payload = jwt.verify(token, config.jwtSecret);
    const result = updateAccount(payload.sub, req.body ?? {});
    if (result.error) return res.status(400).json(result);
    res.json({
      user: {
        id: result.user.id,
        nick: result.user.nick,
        isGuest: result.user.isGuest,
        locale: result.user.locale,
        email: result.user.email,
        avatarUrl: result.user.avatarUrl,
        createdAt: result.user.createdAt,
      },
    });
  } catch {
    res.status(401).json({ error: 'invalid_token' });
  }
});

authRouter.post('/guest', (req, res) => {
  const result = guestLogin({
    nick: req.body?.nick,
    locale: req.body?.locale,
  });
  if (result.error) {
    const status =
      result.error === 'nick_taken' || result.error === 'nick_in_use'
        ? 409
        : 400;
    return res.status(status).json({ error: result.error });
  }
  recordLogin(result.user.id);
  authResponse(result.user, res);
});

authRouter.post('/google', async (req, res) => {
  try {
    const result = await loginWithGoogle({ idToken: req.body?.idToken });
    if (result.error) {
      const status = result.error === 'google_not_configured' ? 501 : 401;
      return res.status(status).json({ error: result.error });
    }
    recordLogin(result.user.id);
    authResponse(result.user, res);
  } catch (err) {
    console.error('google auth:', err);
    res.status(500).json({ error: 'server_error' });
  }
});

authRouter.post('/facebook', async (req, res) => {
  try {
    const result = await loginWithFacebook({
      accessToken: req.body?.accessToken,
    });
    if (result.error) {
      const status = result.error === 'facebook_not_configured' ? 501 : 401;
      return res.status(status).json({ error: result.error });
    }
    recordLogin(result.user.id);
    authResponse(result.user, res);
  } catch (err) {
    console.error('facebook auth:', err);
    res.status(500).json({ error: 'server_error' });
  }
});

authRouter.get('/me', (req, res) => {
  const header = req.headers.authorization ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'unauthorized' });

  try {
    const payload = jwt.verify(token, config.jwtSecret);
    const user = getUserById(payload.sub);
    if (!user) return res.status(404).json({ error: 'user_not_found' });
    res.json({
      user: {
        id: user.id,
        nick: user.nick,
        isGuest: user.isGuest,
        locale: user.locale,
        email: user.email,
        avatarUrl: user.avatarUrl,
        createdAt: user.createdAt,
        isAdmin: isAppAdmin(user),
      },
    });
  } catch {
    res.status(401).json({ error: 'invalid_token' });
  }
});
