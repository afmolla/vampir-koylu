import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config.js';
import {
  getUserById,
  guestLogin,
  loginWithEmail,
  loginWithFacebook,
  loginWithGoogle,
  registerAccount,
  updateAccount,
} from '../services/authService.js';
import { requestPasswordReset, resetPasswordWithToken } from '../services/mail.js';
import { applyReferralCode } from '../services/engagement.js';
import { recordLogin } from '../services/engagement.js';

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
      },
    });
  } catch {
    res.status(401).json({ error: 'invalid_token' });
  }
});
