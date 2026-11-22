// ==============================================================================
// GTA BANGLADESH (DTA: DHAKA THEFT AUTO) — OFFICIAL PORTAL ENGINE
// ==============================================================================

const API_BASE = (function() {
  const host = window.location.hostname;
  if (host === 'localhost' || host === '127.0.0.1') {
    return 'http://localhost:4000';
  }
  return window.location.origin; // Proxied through Nginx (/api/)
})();

// 1. TELEMETRY & LIVE SERVER STATUS
async function fetchServerStatus() {
  const statusEl = document.getElementById('telemetry-status');
  const playersEl = document.getElementById('telemetry-players');
  const pingEl = document.getElementById('telemetry-ping');
  const portEl = document.getElementById('telemetry-port');

  if (!statusEl && !playersEl) return;

  const startTime = performance.now();
  try {
    const res = await fetch(`${API_BASE}/api/server/status`, { cache: 'no-store' });
    const latency = Math.round(performance.now() - startTime);

    if (res.ok) {
      const data = await res.json();
      if (statusEl) {
        statusEl.textContent = data.status || 'ONLINE';
        statusEl.style.color = data.status === 'ONLINE' ? '#00e599' : '#f5a623';
      }
      if (playersEl) {
        playersEl.textContent = `${data.online_players || 0} / ${data.max_players || 16}`;
      }
      if (pingEl) pingEl.textContent = `${latency} ms`;
      if (portEl) portEl.textContent = `${data.port || 7777} (UDP/ENet)`;
    } else {
      if (statusEl) statusEl.textContent = 'STANDBY';
      if (playersEl) playersEl.textContent = '0 / 16';
      if (pingEl) pingEl.textContent = '--';
    }
  } catch (err) {
    if (statusEl) statusEl.textContent = 'STANDBY';
    if (playersEl) playersEl.textContent = '0 / 16';
    if (pingEl) pingEl.textContent = '--';
  }
}

// 2. AUTHENTICATION & PROFILE
function getToken() {
  return localStorage.getItem('dta_auth_token');
}

function setToken(token) {
  localStorage.setItem('dta_auth_token', token);
}

function clearAuth() {
  localStorage.removeItem('dta_auth_token');
  localStorage.removeItem('dta_user_info');
}

async function handleRegister(e) {
  e.preventDefault();
  const alertEl = document.getElementById('auth-alert');
  const username = document.getElementById('reg-username').value;
  const email = document.getElementById('reg-email').value;
  const password = document.getElementById('reg-password').value;

  try {
    const res = await fetch(`${API_BASE}/api/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, email, password })
    });
    const data = await res.json();

    if (res.ok && data.token) {
      setToken(data.token);
      localStorage.setItem('dta_user_info', JSON.stringify(data.user));
      showAlert(alertEl, 'Account created successfully! Loading player profile...', 'success');
      setTimeout(loadProfile, 800);
    } else {
      showAlert(alertEl, data.error || 'Registration failed', 'error');
    }
  } catch (err) {
    showAlert(alertEl, 'Could not reach authentication server.', 'error');
  }
}

async function handleLogin(e) {
  e.preventDefault();
  const alertEl = document.getElementById('auth-alert');
  const login = document.getElementById('login-id').value;
  const password = document.getElementById('login-password').value;

  try {
    const res = await fetch(`${API_BASE}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ login, password })
    });
    const data = await res.json();

    if (res.ok && data.token) {
      setToken(data.token);
      localStorage.setItem('dta_user_info', JSON.stringify(data.user));
      showAlert(alertEl, 'Welcome back, Joynal! Loading dossier...', 'success');
      setTimeout(loadProfile, 600);
    } else {
      showAlert(alertEl, data.error || 'Invalid username or password.', 'error');
    }
  } catch (err) {
    showAlert(alertEl, 'Could not reach authentication server.', 'error');
  }
}

async function loadProfile() {
  const token = getToken();
  const profileSection = document.getElementById('profile-section');
  const authSection = document.getElementById('auth-forms-section');

  if (!token || !profileSection) {
    if (authSection) authSection.style.display = 'block';
    if (profileSection) profileSection.style.display = 'none';
    return;
  }

  try {
    const res = await fetch(`${API_BASE}/api/player/profile`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });

    if (res.ok) {
      const data = await res.json();
      renderProfile(data);
      if (authSection) authSection.style.display = 'none';
      if (profileSection) profileSection.style.display = 'block';
    } else {
      clearAuth();
      if (authSection) authSection.style.display = 'block';
      if (profileSection) profileSection.style.display = 'none';
    }
  } catch (err) {
    console.warn('[PORTAL] Failed to load profile:', err);
  }
}

function renderProfile(data) {
  const prof = data.profile || {};
  const user = JSON.parse(localStorage.getItem('dta_user_info') || '{}');

  const nameEl = document.getElementById('dossier-username');
  if (nameEl) nameEl.textContent = prof.display_name || user.username || 'Joynal';

  const walletEl = document.getElementById('dossier-wallet');
  if (walletEl) walletEl.textContent = `৳ ${(prof.wallet_bdt || 5000).toLocaleString()}`;

  const bankEl = document.getElementById('dossier-bank');
  if (bankEl) bankEl.textContent = `৳ ${(prof.bank_bdt || 25000).toLocaleString()}`;

  const starsEl = document.getElementById('dossier-stars');
  if (starsEl) {
    const stars = prof.wanted_stars || 0;
    starsEl.textContent = '★'.repeat(stars) + '☆'.repeat(5 - stars);
    starsEl.style.color = stars > 0 ? '#ff3366' : '#8b96a8';
  }

  const outfitEl = document.getElementById('dossier-outfit');
  if (outfitEl) outfitEl.textContent = (prof.current_outfit || 'dhaka_casual').replace('_', ' ').toUpperCase();

  const regionEl = document.getElementById('dossier-region');
  if (regionEl) regionEl.textContent = (prof.current_region || 'Lalbagh - Buriganga').replace(/_/g, ' ').toUpperCase();

  const vehiclesEl = document.getElementById('dossier-vehicles-count');
  if (vehiclesEl) vehiclesEl.textContent = `${(data.vehicles || []).length} Vehicles`;

  const missionsEl = document.getElementById('dossier-missions-count');
  if (missionsEl) {
    const completed = (data.missions || []).filter(m => m.status === 'COMPLETED').length;
    missionsEl.textContent = `${completed} / 3 Chapters Completed`;
  }
}

function logout() {
  clearAuth();
  window.location.reload();
}

function showAlert(el, msg, type) {
  if (!el) return;
  el.textContent = msg;
  el.className = `alert-box ${type}`;
}

// 3. BUG REPORT SUBMISSION
async function handleBugReport(e) {
  e.preventDefault();
  const alertEl = document.getElementById('bug-alert');
  const player_name = document.getElementById('bug-name').value;
  const email = document.getElementById('bug-email').value;
  const category = document.getElementById('bug-category').value;
  const title = document.getElementById('bug-title').value;
  const description = document.getElementById('bug-desc').value;
  const system_specs = document.getElementById('bug-specs').value;

  try {
    const res = await fetch(`${API_BASE}/api/support/bug-report`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ player_name, email, category, title, description, system_specs })
    });
    const data = await res.json();

    if (res.ok) {
      showAlert(alertEl, `Report submitted successfully! Ticket ID: ${data.report_id}`, 'success');
      e.target.reset();
    } else {
      showAlert(alertEl, data.error || 'Failed to submit bug report', 'error');
    }
  } catch (err) {
    showAlert(alertEl, 'Could not reach support server.', 'error');
  }
}

// 4. COPY CHECKSUM HELPER
function copyChecksum() {
  const hash = '605982CF1AD2A9C09475F652A5091E730BCC2D723276845CF703FA6EB5D0E3B2';
  navigator.clipboard.writeText(hash).then(() => {
    const btn = document.getElementById('btn-copy-hash');
    if (btn) {
      btn.textContent = 'COPIED TO CLIPBOARD!';
      setTimeout(() => { btn.textContent = 'COPY SHA-256 HASH'; }, 2000);
    }
  });
}

// 5. TABS SWITCHER
function switchTab(tabId) {
  const tabs = document.querySelectorAll('.tab-btn');
  tabs.forEach(t => t.classList.remove('active'));

  const loginBox = document.getElementById('box-login');
  const regBox = document.getElementById('box-register');

  if (tabId === 'login') {
    document.querySelector('[data-tab="login"]')?.classList.add('active');
    if (loginBox) loginBox.style.display = 'block';
    if (regBox) regBox.style.display = 'none';
  } else {
    document.querySelector('[data-tab="register"]')?.classList.add('active');
    if (loginBox) loginBox.style.display = 'none';
    if (regBox) regBox.style.display = 'block';
  }
}

// Initialize on DOM Ready
document.addEventListener('DOMContentLoaded', () => {
  fetchServerStatus();
  setInterval(fetchServerStatus, 5000); // Polling every 5s for live player telemetry

  if (document.getElementById('register-form')) {
    document.getElementById('register-form').addEventListener('submit', handleRegister);
  }
  if (document.getElementById('login-form')) {
    document.getElementById('login-form').addEventListener('submit', handleLogin);
  }
  if (document.getElementById('bug-report-form')) {
    document.getElementById('bug-report-form').addEventListener('submit', handleBugReport);
  }

  loadProfile();
});
