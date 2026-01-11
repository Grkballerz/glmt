-- GLMT Database Schema
-- Game Library Management Tool

-- Configuration table (key-value store)
CREATE TABLE IF NOT EXISTS config (
    key TEXT PRIMARY KEY,
    value TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Known gaming systems
CREATE TABLE IF NOT EXISTS systems (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    short_name TEXT UNIQUE NOT NULL,
    extensions TEXT NOT NULL,  -- JSON array of extensions
    texture_folder_pattern TEXT,  -- Pattern for texture folders
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Detected emulator configurations
CREATE TABLE IF NOT EXISTS emulators (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT NOT NULL,  -- retroarch, dolphin, project64, pcsx2, etc.
    config_path TEXT,
    roms_path TEXT,
    textures_path TEXT,
    detected_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_verified DATETIME
);

-- Tracked files
CREATE TABLE IF NOT EXISTS files (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    path TEXT UNIQUE NOT NULL,
    filename TEXT NOT NULL,
    file_type TEXT NOT NULL,  -- rom, patch, texture, archive, unknown
    system_id INTEGER REFERENCES systems(id),
    status TEXT DEFAULT 'discovered',  -- discovered, processed, moved, patched, deleted
    original_path TEXT,  -- Where it came from
    destination_path TEXT,  -- Where it went
    file_hash TEXT,  -- MD5 or SHA1
    file_size INTEGER,
    game_id TEXT,  -- For texture pack matching
    metadata TEXT,  -- JSON for extra info
    discovered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    processed_at DATETIME
);

-- Operation log
CREATE TABLE IF NOT EXISTS operations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    operation_type TEXT NOT NULL,  -- scan, extract, move, patch, delete, verify
    file_id INTEGER REFERENCES files(id),
    source_path TEXT,
    destination_path TEXT,
    status TEXT NOT NULL,  -- pending, success, failed, cancelled
    details TEXT,  -- JSON for operation-specific data
    error_message TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME
);

-- Patches and their associations
CREATE TABLE IF NOT EXISTS patches (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    file_id INTEGER REFERENCES files(id),
    patch_type TEXT NOT NULL,  -- ips, bps, ups, xdelta
    target_rom_hash TEXT,  -- Hash of ROM this patch is for
    target_rom_id INTEGER REFERENCES files(id),
    applied BOOLEAN DEFAULT FALSE,
    applied_at DATETIME
);

-- Archive contents (for tracking what's inside archives)
CREATE TABLE IF NOT EXISTS archive_contents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    archive_id INTEGER REFERENCES files(id),
    internal_path TEXT NOT NULL,
    file_type TEXT,
    file_size INTEGER,
    extracted BOOLEAN DEFAULT FALSE,
    extracted_to TEXT
);

-- Insert default systems
INSERT OR IGNORE INTO systems (name, short_name, extensions, texture_folder_pattern) VALUES
    ('Nintendo Entertainment System', 'NES', '["nes","unf","unif","fds"]', NULL),
    ('Super Nintendo', 'SNES', '["smc","sfc","fig","swc"]', NULL),
    ('Nintendo 64', 'N64', '["z64","n64","v64"]', '[GAMEID]'),
    ('GameCube', 'GCN', '["iso","gcm","gcz","rvz","ciso"]', '[GAMEID]'),
    ('Wii', 'WII', '["iso","wbfs","rvz","wad"]', '[GAMEID]'),
    ('Wii U', 'WIIU', '["wud","wux","iso","rpx"]', '[TITLEID]'),
    ('Nintendo Switch', 'NSW', '["nsp","xci","nsz","xcz"]', '[TITLEID]'),
    ('Game Boy', 'GB', '["gb"]', NULL),
    ('Game Boy Color', 'GBC', '["gbc","gb"]', NULL),
    ('Game Boy Advance', 'GBA', '["gba"]', NULL),
    ('Nintendo DS', 'NDS', '["nds","dsi"]', NULL),
    ('Nintendo 3DS', '3DS', '["3ds","cia","cci"]', NULL),
    ('PlayStation', 'PS1', '["bin","cue","iso","img","pbp","chd"]', NULL),
    ('PlayStation 2', 'PS2', '["iso","bin","chd","gz","cso"]', '[CRC]'),
    ('PlayStation Portable', 'PSP', '["iso","cso","pbp"]', NULL),
    ('Sega Genesis', 'GEN', '["md","gen","smd","bin"]', NULL),
    ('Sega Saturn', 'SAT', '["iso","bin","cue","chd"]', NULL),
    ('Sega Dreamcast', 'DC', '["gdi","cdi","chd"]', NULL),
    ('Sega Master System', 'SMS', '["sms"]', NULL),
    ('Sega Game Gear', 'GG', '["gg"]', NULL),
    ('TurboGrafx-16', 'PCE', '["pce","sgx"]', NULL),
    ('Neo Geo', 'NEOGEO', '["zip"]', NULL),
    ('Arcade', 'ARCADE', '["zip"]', NULL),
    ('Atari 2600', 'A2600', '["a26","bin"]', NULL),
    ('Atari 7800', 'A7800', '["a78","bin"]', NULL),
    ('Xbox', 'XBOX', '["iso","xiso"]', NULL),
    ('Xbox 360', 'X360', '["iso","xex","god"]', NULL);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_files_type ON files(file_type);
CREATE INDEX IF NOT EXISTS idx_files_status ON files(status);
CREATE INDEX IF NOT EXISTS idx_files_system ON files(system_id);
CREATE INDEX IF NOT EXISTS idx_operations_type ON operations(operation_type);
CREATE INDEX IF NOT EXISTS idx_operations_status ON operations(status);
CREATE INDEX IF NOT EXISTS idx_archive_contents_archive ON archive_contents(archive_id);
