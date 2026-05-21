import http from 'http';
import { config } from './config.js';
import { createApp } from './app.js';
import { attachSocket } from './socket.js';

const app = createApp();
const server = http.createServer(app);
attachSocket(server);

server.listen(config.port, () => {
  console.log(`vampir-koylu server listening on :${config.port}`);
});
