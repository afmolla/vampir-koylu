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
} from '../services/authService.js';

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
    const status = result.error === 'email_taken' ? 409 : 400;
    return res.status(status).json({ error: result.error });
  }
  authResponse(result.user, res);
});

authRouter.post('/login', (req, res) => {
  const result = loginWithEmail({
    email: req.body?.email,
    password: req.body?.password,
  });
  if (result.error) return res.status(401).json({ error: result.error });
  authResponse(result.user, res);
});

authRouter.post('/guest', (req, res) => {
  const result = guestLogin({
    nick: req.body?.nick,
    locale: req.body?.locale,
  });
  if (result.error) return res.status(400).json({ error: result.error });
  authResponse(result.user, res);
});

authRouter.post('/google', async (req, res) => {
  try {
    const result = await loginWithGoogle({ idToken: req.body?.idToken });
    if (result.error) {
      const status = result.error === 'google_not_configured' ? 501 : 401;
      return res.status(status).json({ error: result.error });
    }
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
