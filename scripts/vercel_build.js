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

// Ensure dist directory exists and sync from public
if (!fs.existsSync(distDir)) {
  fs.mkdirSync(distDir, { recursive: true });
}

const files = fs.readdirSync(publicDir);
for (const file of files) {
  const src = path.join(publicDir, file);
  const dest = path.join(distDir, file);
  fs.copyFileSync(src, dest);
}

console.log(`[VERCEL BUILD] Successfully synchronized ${files.length} static assets to dist/ and public/`);
