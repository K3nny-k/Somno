CREATE TABLE IF NOT EXISTS profile (
  user_id TEXT PRIMARY KEY DEFAULT 'local',
  age_band TEXT NOT NULL,
  chronotype TEXT,
  wake_constraints TEXT,
  privacy_flags TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sleep_episode (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date_local TEXT NOT NULL,
  onset_ts INTEGER NOT NULL,
  wake_ts INTEGER NOT NULL,
  duration_min INTEGER NOT NULL,
  efficiency REAL,
  source TEXT,
  confidence REAL,
  features_json TEXT,
  edited INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS habit_event (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ts INTEGER NOT NULL,
  type TEXT NOT NULL,
  value TEXT,
  source TEXT
);

CREATE TABLE IF NOT EXISTS action_event (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date_local TEXT NOT NULL,
  action_id TEXT NOT NULL,
  context_json TEXT,
  reco_ts INTEGER,
  taken INTEGER DEFAULT 0,
  reward REAL
);

CREATE TABLE IF NOT EXISTS feature_window (
  ts INTEGER PRIMARY KEY,
  accel_stats_json TEXT,
  screen_ratio REAL,
  gap INTEGER,
  charging_flag INTEGER,
  posture_hint TEXT
);

