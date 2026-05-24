import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config.js';
import { isAppAdmin } from '../services/appAdmin.js';
import { listUsersForAdmin } from '../services/adminUsers.js';

export const adminPanelRouter = Router();

function authUserId(req) {
  const header = req.headers.authorization ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return null;
  try {
    const payload = jwt.verify(token, config.jwtSecret);
    return payload.sub;
  } catch {
    return null;
  }
}

function requireAppAdmin(req, res, next) {
  const userId = authUserId(req);
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  if (!isAppAdmin(userId)) {
    return res.status(403).json({ error: 'forbidden', message: 'Not an app admin' });
  }
  req.adminUserId = userId;
  next();
}

/** GET ?filter=all|registered|guest&search=&limit=80&offset=0 */
adminPanelRouter.get('/users', requireAppAdmin, (req, res) => {
  const filter = req.query.filter ?? 'all';
  if (!['all', 'registered', 'guest'].includes(filter)) {
    return res.status(400).json({ error: 'invalid_filter' });
  }
  const data = listUsersForAdmin({
    filter,
    search: req.query.search,
    limit: req.query.limit,
    offset: req.query.offset,
  });
  res.json({ ok: true, ...data });
});
