import express from 'express';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';

const releasesDir = path.join(path.dirname(fileURLToPath(import.meta.url)), '../../releases');
const uploadsDir = path.join(path.dirname(fileURLToPath(import.meta.url)), '../uploads');
import { versionRouter } from './routes/version.js';
import { authRouter } from './routes/auth.js';
import { healthRouter } from './routes/health.js';
import { roomsRouter } from './routes/rooms.js';
import { chatRouter } from './routes/chat.js';
import { profileRouter } from './routes/profile.js';
import { shopRouter } from './routes/shop.js';
import { tournamentsRouter } from './routes/tournaments.js';
import { adminRouter } from './routes/admin.js';
import { adminPanelRouter } from './routes/adminPanel.js';
import { engagementRouter } from './routes/engagement.js';
import { friendsRouter } from './routes/friends.js';
import { socialRouter } from './routes/social.js';
import { paymentsRouter } from './routes/payments.js';
import { publicConfigRouter } from './routes/publicConfig.js';
import { seedTournamentsIfEmpty } from './services/tournaments.js';

export function createApp() {
  const app = express();

  app.use(cors());
  app.use(express.json());

  app.get('/', (_req, res) => {
    res.json({
      ok: true,
      service: 'vampir-koylu-server',
      hint: 'Use /health or /api/version from the mobile app',
    });
  });

  app.use(
    '/uploads',
    express.static(uploadsDir, {
      maxAge: '7d',
    }),
  );

  app.use(
    '/releases',
    express.static(releasesDir, {
      setHeaders(res, filePath) {
        if (filePath.endsWith('.apk')) {
          res.setHeader('Content-Type', 'application/vnd.android.package-archive');
        }
      },
    }),
  );

  app.use('/health', healthRouter);
  app.use('/api/config/public', publicConfigRouter);
  app.use('/api/version', versionRouter);
  app.use('/api/auth', authRouter);
  app.use('/api/rooms', roomsRouter);
  app.use('/api/chat', chatRouter);
  app.use('/api/profile', profileRouter);
  app.use('/api/shop', shopRouter);
  app.use('/api/tournaments', tournamentsRouter);
  app.use('/api/admin', adminRouter);
  app.use('/api/admin-panel', adminPanelRouter);
  app.use('/api/engagement', engagementRouter);
  app.use('/api/friends', friendsRouter);
  app.use('/api/social', socialRouter);
  app.use('/api/payments', paymentsRouter);

  try {
    seedTournamentsIfEmpty();
  } catch (e) {
    console.warn('tournament seed skipped', e?.message);
  }

  app.use((err, _req, res, _next) => {
    console.error(err);
    res.status(500).json({ error: 'internal_error' });
  });

  return app;
}
