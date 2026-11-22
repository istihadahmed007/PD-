const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const publicDir = path.join(rootDir, 'public');
const distDir = path.join(rootDir, 'dist');

console.log('[VERCEL BUILD] Preparing production output directories...');

if (!fs.existsSync(publicDir)) {
  console.error('[ERROR] public directory does not exist!');
  process.exit(1);
}

// Ensure dist directory exists and recursively sync from public
fs.cpSync(publicDir, distDir, { recursive: true });

console.log('[VERCEL BUILD] Successfully synchronized all portal assets, css, js, and game files to dist/');
