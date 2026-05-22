import Database from 'better-sqlite3';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DB_PATH = path.join(__dirname, '..', '..', 'data', 'vampir_koylu.db');

let db;

export function getDb() {
  if (!db) {
    db = new Database(DB_PATH);
    db.pragma('journal_mode = WAL');
    db.pragma('foreign_keys = ON');
    initTables();
  }
  return db;
}

function initTables() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      nick TEXT NOT NULL,
      is_guest INTEGER NOT NULL DEFAULT 1,
      locale TEXT NOT NULL DEFAULT 'tr',
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      channel TEXT NOT NULL,
      user_id TEXT NOT NULL,
      nick TEXT NOT NULL,
      content TEXT NOT NULL,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      FOREIGN KEY (user_id) REFERENCES users(id)
    );

    CREATE INDEX IF NOT EXISTS idx_messages_channel ON messages(channel, created_at);

    CREATE TABLE IF NOT EXISTS user_profiles (
      user_id TEXT PRIMARY KEY,
      xp INTEGER NOT NULL DEFAULT 0,
      coins INTEGER NOT NULL DEFAULT 100,
      rank_tier TEXT NOT NULL DEFAULT 'bronze',
      login_streak INTEGER NOT NULL DEFAULT 0,
      last_login_date TEXT,
      equipped_skin TEXT,
      equipped_frame TEXT,
      equipped_theme TEXT,
      equipped_effect TEXT,
      equipped_death_anim TEXT,
      voice_effect TEXT DEFAULT 'proximity_default',
      FOREIGN KEY (user_id) REFERENCES users(id)
    );

    CREATE TABLE IF NOT EXISTS owned_cosmetics (
      user_id TEXT NOT NULL,
      cosmetic_id TEXT NOT NULL,
      purchased_at TEXT NOT NULL DEFAULT (datetime('now')),
      PRIMARY KEY (user_id, cosmetic_id),
      FOREIGN KEY (user_id) REFERENCES users(id)
    );

    CREATE TABLE IF NOT EXISTS daily_quest_progress (
      user_id TEXT NOT NULL,
      quest_id TEXT NOT NULL,
      progress INTEGER NOT NULL DEFAULT 0,
      goal INTEGER NOT NULL,
      quest_date TEXT NOT NULL,
      claimed INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (user_id, quest_id, quest_date),
      FOREIGN KEY (user_id) REFERENCES users(id)
    );

    CREATE TABLE IF NOT EXISTS match_summaries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      room_code TEXT,
      summary_json TEXT NOT NULL,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      FOREIGN KEY (user_id) REFERENCES users(id)
    );

    CREATE INDEX IF NOT EXISTS idx_match_summaries_user ON match_summaries(user_id, created_at DESC);

    CREATE TABLE IF NOT EXISTS tournaments (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT,
      status TEXT NOT NULL DEFAULT 'registration',
      entry_fee_coins INTEGER NOT NULL DEFAULT 0,
      entry_fee_try REAL,
      prize_pool_coins INTEGER NOT NULL DEFAULT 0,
      min_players INTEGER NOT NULL DEFAULT 6,
      max_players INTEGER NOT NULL DEFAULT 32,
      registration_deadline TEXT,
      starts_at TEXT,
      winner_user_id TEXT,
      lobby_room_code TEXT,
      host_user_id TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      FOREIGN KEY (winner_user_id) REFERENCES users(id)
    );

    CREATE TABLE IF NOT EXISTS tournament_entries (
      tournament_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      payment_method TEXT NOT NULL DEFAULT 'coins',
      payment_status TEXT NOT NULL DEFAULT 'paid',
      payment_ref TEXT,
      placement INTEGER,
      prize_coins INTEGER NOT NULL DEFAULT 0,
      joined_at TEXT NOT NULL DEFAULT (datetime('now')),
      PRIMARY KEY (tournament_id, user_id),
      FOREIGN KEY (tournament_id) REFERENCES tournaments(id),
      FOREIGN KEY (user_id) REFERENCES users(id)
    );
  `);

  try {
    db.exec(`ALTER TABLE tournaments ADD COLUMN lobby_room_code TEXT`);
  } catch {
    /* exists */
  }
  try {
    db.exec(`ALTER TABLE tournaments ADD COLUMN host_user_id TEXT`);
  } catch {
    /* exists */
  }
}

export function closeDb() {
  if (db) {
    db.close();
    db = null;
  }
}
