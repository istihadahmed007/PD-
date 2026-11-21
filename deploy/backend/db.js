// ==============================================================================
// DATABASE CONNECTION POOL & MIGRATION CONTROLLER
// ==============================================================================
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://dta_user:dta_secure_pass@localhost:5432/dta_bangladesh',
    ssl: process.env.NODE_ENV === 'production' && process.env.DATABASE_SSL === 'true' ? { rejectUnauthorized: false } : false,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 5000,
});

async function initDatabase() {
    try {
        const client = await pool.connect();
        console.log('[DB] Connected successfully to PostgreSQL database.');
        
        const schemaPath = path.join(__dirname, 'schema.sql');
        if (fs.existsSync(schemaPath)) {
            const schemaSql = fs.readFileSync(schemaPath, 'utf8');
            await client.query(schemaSql);
            console.log('[DB] Schema verified and tables synchronized successfully.');
        }
        client.release();
    } catch (err) {
        console.error('[DB-ERROR] Database connection/migration failed:', err.message);
    }
}

module.exports = {
    query: (text, params) => pool.query(text, params),
    pool,
    initDatabase
};
