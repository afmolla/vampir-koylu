import { Router } from 'express';
import { getDb } from '../db/database.js';
import { config } from '../config.js';

/** Sunucu yazılım sürümü — /health'te 0.2.7 görünmüyorsa eski API çalışıyor demektir. */
export const SERVER_BUILD = '0.2.16';

export const healthRouter = Router();

healthRouter.get('/', (_req, res) => {
  try {
    const db = getDb();
    const row = db.prepare('SELECT COUNT(*) AS n FROM users').get();
    res.json({
      ok: true,
      service: 'vampir-koylu-server',
      serverBuild: SERVER_BUILD,
      version: {
        minRequiredVersion: config.minRequiredVersion,
        latestVersion: config.latestVersion,
        forceUpdate: config.forceUpdate,
        updateUrlAndroid: config.updateUrlAndroid,
      },
      database: { ok: true, engine: 'sqlite', users: row?.n ?? 0 },
    });
  } catch (err) {
    res.status(503).json({
      ok: false,
      service: 'vampir-koylu-server',
      serverBuild: SERVER_BUILD,
      database: { ok: false, error: err.message },
    });
  }
});
