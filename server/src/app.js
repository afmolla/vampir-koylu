import express from 'express';
import cors from 'cors';
import { versionRouter } from './routes/version.js';
import { authRouter } from './routes/auth.js';
import { healthRouter } from './routes/health.js';
import { roomsRouter } from './routes/rooms.js';
import { chatRouter } from './routes/chat.js';

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

  app.use('/health', healthRouter);
  app.use('/api/version', versionRouter);
  app.use('/api/auth', authRouter);
  app.use('/api/rooms', roomsRouter);
  app.use('/api/chat', chatRouter);

  app.use((err, _req, res, _next) => {
    console.error(err);
    res.status(500).json({ error: 'internal_error' });
  });

  return app;
}
