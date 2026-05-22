import http from 'http';
import { config } from './config.js';
import { createApp } from './app.js';
import { attachSocket } from './socket.js';
import { getDb } from './db/database.js';

const app = createApp();
const server = http.createServer(app);
attachSocket(server);

try {
  const db = getDb();
  const users = db.prepare('SELECT COUNT(*) AS n FROM users').get();
  console.log(`SQLite OK — ${users?.n ?? 0} kullanici kaydi`);
} catch (err) {
  console.error('SQLite baslatilamadi:', err.message);
  process.exit(1);
}

server.listen(config.port, '0.0.0.0', () => {
  console.log(`vampir-koylu server listening on http://0.0.0.0:${config.port}`);
  console.log(`minRequiredVersion=${config.minRequiredVersion} latest=${config.latestVersion}`);
});
