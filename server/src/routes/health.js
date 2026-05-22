import { Router } from 'express';
import { getDb } from '../db/database.js';

export const healthRouter = Router();

healthRouter.get('/', (_req, res) => {
  try {
    const db = getDb();
    const row = db.prepare('SELECT COUNT(*) AS n FROM users').get();
    res.json({
      ok: true,
      service: 'vampir-koylu-server',
      database: { ok: true, engine: 'sqlite', users: row?.n ?? 0 },
    });
  } catch (err) {
    res.status(503).json({
      ok: false,
      service: 'vampir-koylu-server',
      database: { ok: false, error: err.message },
    });
  }
});
