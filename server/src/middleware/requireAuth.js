import jwt from 'jsonwebtoken';
import { config } from '../config.js';
import { getUserById } from '../services/authService.js';

export function requireAuth(req, res, next) {
  const header = req.headers.authorization ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'unauthorized' });

  try {
    const payload = jwt.verify(token, config.jwtSecret);
    const user = getUserById(payload.sub);
    if (!user) return res.status(404).json({ error: 'user_not_found' });
    req.userId = user.id;
    req.authUser = user;
    next();
  } catch {
    return res.status(401).json({ error: 'invalid_token' });
  }
}
