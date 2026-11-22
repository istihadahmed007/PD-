const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const publicDir = path.join(rootDir, 'public');
const vercelOutputDir = path.join(rootDir, '.vercel', 'output');
const staticDir = path.join(vercelOutputDir, 'static');

console.log('[VERCEL BUILD] Starting compilation to Build Output API v3...');

// 1. Ensure clean .vercel/output/static directory exists
fs.rmSync(vercelOutputDir, { recursive: true, force: true });
fs.mkdirSync(staticDir, { recursive: true });

// 2. Recursively copy all files and folders from public/ to .vercel/output/static/
console.log(`[VERCEL BUILD] Copying assets from ${publicDir} to ${staticDir}...`);
fs.cpSync(publicDir, staticDir, { recursive: true });

// 3. Write Vercel Build Output API v3 config.json
const config = {
  version: 3,
  routes: [
    {
      src: '/(.*)',
      headers: {
        'Cross-Origin-Opener-Policy': 'same-origin',
        'Cross-Origin-Embedder-Policy': 'require-corp',
        'Cross-Origin-Resource-Policy': 'cross-origin',
        'Access-Control-Allow-Origin': '*'
      },
      continue: true
    },
    {
      src: '/(.*\\.wasm)',
      headers: {
        'Content-Type': 'application/wasm',
        'Cache-Control': 'public, max-age=31536000, immutable'
      },
      continue: true
    },
    {
      src: '/(.*\\.pck)',
      headers: {
        'Content-Type': 'application/octet-stream',
        'Cache-Control': 'public, max-age=31536000, immutable'
      },
      continue: true
    },
    {
      src: '/play',
      dest: '/play/index.html'
    },
    {
      handle: 'filesystem'
    }
  ]
};

fs.writeFileSync(
  path.join(vercelOutputDir, 'config.json'),
  JSON.stringify(config, null, 2),
  'utf8'
);

const copiedFiles = fs.readdirSync(staticDir);
console.log(`[VERCEL BUILD] Success! Copied ${copiedFiles.length} items to .vercel/output/static`);
console.log(`[VERCEL BUILD] Generated config.json for Edge CDN headers and routing.`);
