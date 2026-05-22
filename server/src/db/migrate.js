import { getDb, closeDb } from './database.js';

console.log('Running migrations...');
const db = getDb();

const count = db.prepare('SELECT COUNT(*) as c FROM users').get();
console.log(`Users: ${count.c}`);

const msgCount = db.prepare('SELECT COUNT(*) as c FROM messages').get();
console.log(`Messages: ${msgCount.c}`);

console.log('Migration complete.');
closeDb();
