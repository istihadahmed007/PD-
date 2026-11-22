// ==============================================================================
// PRODUCTION BACKEND REST API
// Project: Bangladesh Open-World (DTA)
// Endpoints: Authentication, Profiles, Inventory, Server-Authoritative Save & Sync
// ==============================================================================
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('./db');

const app = express();
const PORT = process.env.PORT || 4000;
const JWT_SECRET = process.env.JWT_SECRET || 'dta_bangladesh_super_secret_jwt_key_2026';
const SERVER_API_KEY = process.env.SERVER_API_KEY || 'dta_dedicated_server_internal_token_99';

// Middleware
app.use(helmet());
app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Server-Key']
}));
app.use(express.json());

// Rate Limiting
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 50,
    message: { error: 'Too many authentication attempts from this IP, please try again later.' }
});

// Authentication Middleware
function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.status(401).json({ error: 'Access token required' });

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ error: 'Invalid or expired token' });
        req.user = user;
        next();
    });
}

// Server Key Middleware (For Dedicated Headless Server Auth)
function authenticateServerKey(req, res, next) {
    const serverKey = req.headers['x-server-key'];
    if (!serverKey || serverKey !== SERVER_API_KEY) {
        return res.status(403).json({ error: 'Unauthorized: Invalid server internal key' });
    }
    next();
}

// Server Heartbeat Cache for Real-Time Status Telemetry
let serverHeartbeat = {
    online_players: 0,
    max_players: 16,
    last_ping: Date.now(),
    instance_name: "Dhaka Central 01",
    region: "Dhaka, Bangladesh",
    protocol: "ENet / UDP",
    port: 7777
};

// ==============================================================================
// HEALTH & MONITORING
// ==============================================================================
app.get('/health', async (req, res) => {
    try {
        await db.query('SELECT 1');
        res.json({
            status: 'HEALTHY',
            timestamp: new Date().toISOString(),
            service: 'dta-backend-api',
            database: 'CONNECTED'
        });
    } catch (err) {
        res.status(503).json({
            status: 'UNHEALTHY',
            timestamp: new Date().toISOString(),
            service: 'dta-backend-api',
            database: 'DISCONNECTED',
            error: err.message
        });
    }
});

// Live Authoritative Game Server Telemetry (Public)
app.get('/api/server/status', async (req, res) => {
    let dbStatus = "CONNECTED";
    try {
        await db.query('SELECT 1');
    } catch (e) {
        dbStatus = "DISCONNECTED";
    }

    // Check if heartbeat is recent (within 30 seconds)
    const isServerAlive = (Date.now() - serverHeartbeat.last_ping) < 30000;

    res.json({
        status: isServerAlive ? "ONLINE" : "STANDBY",
        server_name: serverHeartbeat.instance_name,
        region: serverHeartbeat.region,
        protocol: serverHeartbeat.protocol,
        host: process.env.DOMAIN_NAME || "bc.vartualtutor.com",
        port: serverHeartbeat.port,
        online_players: isServerAlive ? serverHeartbeat.online_players : 0,
        max_players: serverHeartbeat.max_players,
        tick_rate: 60,
        game_version: "1.1.0",
        database: dbStatus,
        uptime_seconds: Math.floor(process.uptime()),
        timestamp: new Date().toISOString()
    });
});

// Server Heartbeat Ping (From Dedicated Headless Godot Server)
app.post('/api/server/heartbeat', authenticateServerKey, (req, res) => {
    const { online_players, max_players, port, region } = req.body;
    serverHeartbeat.online_players = typeof online_players === 'number' ? online_players : serverHeartbeat.online_players;
    serverHeartbeat.max_players = typeof max_players === 'number' ? max_players : serverHeartbeat.max_players;
    serverHeartbeat.port = typeof port === 'number' ? port : serverHeartbeat.port;
    if (region) serverHeartbeat.region = region;
    serverHeartbeat.last_ping = Date.now();
    res.json({ success: true, timestamp: serverHeartbeat.last_ping });
});

// Bug Reporting Endpoint
app.post('/api/support/bug-report', async (req, res) => {
    const { player_name, email, category, title, description, system_specs } = req.body;
    if (!player_name || !title || !description) {
        return res.status(400).json({ error: 'Player name, title, and description are required.' });
    }

    try {
        const result = await db.query(
            `INSERT INTO bug_reports (player_name, email, category, title, description, system_specs)
             VALUES ($1, $2, $3, $4, $5, $6)
             RETURNING id, created_at`,
            [
                player_name.trim().substring(0, 64),
                email ? email.trim().toLowerCase().substring(0, 255) : null,
                category || 'GENERAL',
                title.trim().substring(0, 128),
                description.trim(),
                system_specs ? system_specs.trim() : null
            ]
        );
        res.status(201).json({
            success: true,
            message: 'Bug report received. Our engineering team has logged the issue.',
            report_id: result.rows[0].id
        });
    } catch (err) {
        console.error('[BUG-REPORT-ERROR]', err);
        res.status(500).json({ error: 'Failed to record bug report.' });
    }
});

// ==============================================================================
// AUTHENTICATION
// ==============================================================================
app.post('/api/auth/register', authLimiter, async (req, res) => {
    const { username, email, password } = req.body;
    if (!username || !email || !password) {
        return res.status(400).json({ error: 'Username, email, and password are required.' });
    }
    if (username.length < 3 || username.length > 32) {
        return res.status(400).json({ error: 'Username must be between 3 and 32 characters.' });
    }
    if (password.length < 6) {
        return res.status(400).json({ error: 'Password must be at least 6 characters.' });
    }

    try {
        const passwordHash = await bcrypt.hash(password, 10);
        const result = await db.query(
            `INSERT INTO users (username, email, password_hash)
             VALUES ($1, $2, $3)
             RETURNING id, username, email, role, created_at`,
            [username.trim(), email.trim().toLowerCase(), passwordHash]
        );
        const user = result.rows[0];

        // Initialize default player profile
        await db.query(
            `INSERT INTO player_profiles (user_id, display_name)
             VALUES ($1, $2)`,
            [user.id, user.username]
        );

        // Issue initial JWT
        const token = jwt.sign(
            { id: user.id, username: user.username, role: user.role },
            JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.status(201).json({
            message: 'User registered successfully',
            token,
            user: { id: user.id, username: user.username, email: user.email }
        });
    } catch (err) {
        if (err.code === '23505') {
            return res.status(409).json({ error: 'Username or email already in use.' });
        }
        console.error('[AUTH-ERROR] Register failed:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

app.post('/api/auth/login', authLimiter, async (req, res) => {
    const { login, password } = req.body; // login can be username or email
    if (!login || !password) {
        return res.status(400).json({ error: 'Login identifier and password required.' });
    }

    try {
        const result = await db.query(
            `SELECT * FROM users WHERE (username = $1 OR email = $1) AND is_active = TRUE`,
            [login.trim()]
        );
        if (result.rows.length === 0) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        const user = result.rows[0];
        const match = await bcrypt.compare(password, user.password_hash);
        if (!match) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        await db.query('UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = $1', [user.id]);

        const token = jwt.sign(
            { id: user.id, username: user.username, role: user.role },
            JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.json({
            message: 'Login successful',
            token,
            user: { id: user.id, username: user.username, email: user.email, role: user.role }
        });
    } catch (err) {
        console.error('[AUTH-ERROR] Login failed:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// ==============================================================================
// PLAYER PROFILE & STATE PERSISTENCE
// ==============================================================================
app.get('/api/player/profile', authenticateToken, async (req, res) => {
    try {
        const profileRes = await db.query(
            `SELECT * FROM player_profiles WHERE user_id = $1`,
            [req.user.id]
        );
        if (profileRes.rows.length === 0) {
            return res.status(404).json({ error: 'Profile not found' });
        }

        const inventoryRes = await db.query(
            `SELECT item_id, quantity, metadata FROM player_inventory WHERE user_id = $1`,
            [req.user.id]
        );

        const vehiclesRes = await db.query(
            `SELECT id, vehicle_type, nickname, paint_color, engine_tune, armor_level, current_health, stored_in_garage
             FROM player_vehicles WHERE user_id = $1`,
            [req.user.id]
        );

        const missionsRes = await db.query(
            `SELECT mission_id, status, current_step, completed_at FROM player_missions WHERE user_id = $1`,
            [req.user.id]
        );

        res.json({
            profile: profileRes.rows[0],
            inventory: inventoryRes.rows,
            vehicles: vehiclesRes.rows,
            missions: missionsRes.rows
        });
    } catch (err) {
        console.error('[PROFILE-ERROR] Failed to fetch profile:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Client Checkpoint Save Request
app.post('/api/player/save', authenticateToken, async (req, res) => {
    const { pos_x, pos_y, pos_z, rot_y, current_outfit, current_region } = req.body;
    try {
        await db.query(
            `UPDATE player_profiles
             SET pos_x = COALESCE($1, pos_x),
                 pos_y = COALESCE($2, pos_y),
                 pos_z = COALESCE($3, pos_z),
                 rot_y = COALESCE($4, rot_y),
                 current_outfit = COALESCE($5, current_outfit),
                 current_region = COALESCE($6, current_region),
                 updated_at = CURRENT_TIMESTAMP
             WHERE user_id = $7`,
            [pos_x, pos_y, pos_z, rot_y, current_outfit, current_region, req.user.id]
        );
        res.json({ success: true, message: 'Position checkpoint persisted.' });
    } catch (err) {
        console.error('[SAVE-ERROR] Failed to save player checkpoint:', err);
        res.status(500).json({ error: 'Failed to persist save state' });
    }
});

// ==============================================================================
// SERVER-AUTHORITATIVE SYNC (Called directly by Dedicated Godot Server)
// ==============================================================================
app.post('/api/server/sync-player', authenticateServerKey, async (req, res) => {
    const {
        username,
        wallet_bdt,
        bank_bdt,
        wanted_stars,
        current_health,
        current_stamina,
        pos_x, pos_y, pos_z, rot_y,
        inventory_items,
        completed_mission_id,
        reward_bdt
    } = req.body;

    if (!username) {
        return res.status(400).json({ error: 'Username required for authoritative sync.' });
    }

    try {
        const userRes = await db.query('SELECT id FROM users WHERE username = $1', [username]);
        if (userRes.rows.length === 0) {
            return res.status(404).json({ error: 'Player user not found' });
        }
        const userId = userRes.rows[0].id;

        // Authoritatively update wallet, vitals, position
        await db.query(
            `UPDATE player_profiles
             SET wallet_bdt = COALESCE($1, wallet_bdt),
                 bank_bdt = COALESCE($2, bank_bdt),
                 wanted_stars = COALESCE($3, wanted_stars),
                 current_health = COALESCE($4, current_health),
                 current_stamina = COALESCE($5, current_stamina),
                 pos_x = COALESCE($6, pos_x),
                 pos_y = COALESCE($7, pos_y),
                 pos_z = COALESCE($8, pos_z),
                 rot_y = COALESCE($9, rot_y),
                 updated_at = CURRENT_TIMESTAMP
             WHERE user_id = $10`,
            [wallet_bdt, bank_bdt, wanted_stars, current_health, current_stamina, pos_x, pos_y, pos_z, rot_y, userId]
        );

        // Record mission completion if applicable
        if (completed_mission_id) {
            await db.query(
                `INSERT INTO player_missions (user_id, mission_id, status, completed_at)
                 VALUES ($1, $2, 'COMPLETED', CURRENT_TIMESTAMP)
                 ON CONFLICT (user_id, mission_id)
                 DO UPDATE SET status = 'COMPLETED', completed_at = CURRENT_TIMESTAMP`,
                [userId, completed_mission_id]
            );

            if (reward_bdt && reward_bdt > 0) {
                await db.query(
                    `INSERT INTO financial_audit_log (user_id, transaction_type, amount_bdt, resulting_balance, reason)
                     VALUES ($1, 'MISSION_REWARD', $2, $3, $4)`,
                    [userId, reward_bdt, wallet_bdt || 0, `Mission: ${completed_mission_id}`]
                );
            }
        }

        res.json({ success: true, message: 'Server authoritative sync recorded' });
    } catch (err) {
        console.error('[SERVER-SYNC-ERROR]', err);
        res.status(500).json({ error: 'Server sync failed' });
    }
});

// Start Server
app.listen(PORT, async () => {
    console.log(`[BACKEND] DTA Production API running on port ${PORT}`);
    await db.initDatabase();
});
