import { Router } from 'express';
import { config } from '../config.js';
import { addUserBalance, resolveUserId } from '../services/progression.js';
import { getUserById } from '../services/authService.js';

export const adminRouter = Router();

function requireAdmin(req, res, next) {
  const key = req.headers['x-admin-key'] ?? req.query.key;
  if (!config.adminApiKey || key !== config.adminApiKey) {
    return res.status(403).json({ error: 'forbidden', message: 'Gecersiz ADMIN_API_KEY' });
  }
  next();
}

adminRouter.use(requireAdmin);

/** POST { userId | nick | email, amount, note? } — bakiye yukle */
adminRouter.post('/balance/add', (req, res) => {
  const userId = resolveUserId({
    userId: req.body?.userId,
    nick: req.body?.nick,
    email: req.body?.email,
  });
  if (!userId) return res.status(404).json({ error: 'user_not_found' });

  const result = addUserBalance(userId, req.body?.amount, req.body?.note ?? 'admin');
  if (result.error) return res.status(400).json(result);

  const user = getUserById(userId);
  res.json({
    ok: true,
    nick: user?.nick,
    added: result.added,
    balance: result.balance,
  });
});
