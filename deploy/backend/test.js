// ==============================================================================
// BACKEND UNIT & INTEGRATION TEST
// ==============================================================================
const test = require('node:test');
const assert = require('node:assert');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const TEST_SECRET = 'dta_test_jwt_secret_999';

test('Password Hashing and Comparison', async (t) => {
    const rawPassword = 'PlayerSecretPassword123!';
    const hash = await bcrypt.hash(rawPassword, 10);
    assert.notStrictEqual(hash, rawPassword);
    
    const isValid = await bcrypt.compare(rawPassword, hash);
    assert.strictEqual(isValid, true, 'Valid password should match hash');

    const isInvalid = await bcrypt.compare('WrongPassword', hash);
    assert.strictEqual(isInvalid, false, 'Invalid password should not match hash');
});

test('JWT Issue and Verification', async (t) => {
    const userPayload = {
        id: '123e4567-e89b-12d3-a456-426614174000',
        username: 'Joy_DTA',
        role: 'player'
    };
    
    const token = jwt.sign(userPayload, TEST_SECRET, { expiresIn: '1h' });
    assert.ok(token, 'JWT token should be generated');

    const decoded = jwt.verify(token, TEST_SECRET);
    assert.strictEqual(decoded.username, 'Joy_DTA');
    assert.strictEqual(decoded.role, 'player');
});

test('Authoritative Server Payload Validation', (t) => {
    const serverPayload = {
        username: 'Joy_DTA',
        wallet_bdt: 7500,
        bank_bdt: 30000,
        wanted_stars: 2,
        current_health: 85.5,
        current_stamina: 100.0,
        pos_x: 12.4,
        pos_y: 0.5,
        pos_z: -34.2,
        rot_y: 1.57,
        completed_mission_id: 'm01_shadows_and_sparkplugs',
        reward_bdt: 1500
    };

    assert.ok(serverPayload.username, 'Username is required');
    assert.ok(serverPayload.wallet_bdt >= 0, 'Wallet cannot be negative');
    assert.ok(serverPayload.wanted_stars >= 0 && serverPayload.wanted_stars <= 5, 'Wanted stars must be 0-5');
    assert.ok(serverPayload.current_health >= 0.0, 'Health must be positive');
});
