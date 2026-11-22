const fs = require('fs');
const path = require('path');

// Search upwards from __dirname to find the repository root containing 'public'
let current = __dirname;
let publicDir = null;
for (let i = 0; i < 6; i++) {
  const candidate = path.join(current, 'public');
  if (fs.existsSync(candidate)) {
    publicDir = candidate;
    break;
  }
  const parent = path.dirname(current);
  if (parent === current) break;
  current = parent;
}

if (!publicDir) {
  console.error(`[ERROR] Could not locate public/ folder from ${__dirname}`);
  process.exit(1);
}

const cwd = process.cwd();
const distDir = path.join(cwd, 'dist');
const vercelOutputDir = path.join(cwd, '.vercel', 'output');
const staticDir = path.join(vercelOutputDir, 'static');

console.log(`[VERCEL BUILD] Working Directory: ${cwd}`);
console.log(`[VERCEL BUILD] Source Public Dir: ${publicDir}`);
console.log(`[VERCEL BUILD] Target Dist Dir:   ${distDir}`);
console.log(`[VERCEL BUILD] Target Static Dir: ${staticDir}`);

// 1. Prepare dist directory
fs.rmSync(distDir, { recursive: true, force: true });
fs.mkdirSync(distDir, { recursive: true });
fs.cpSync(publicDir, distDir, { recursive: true });

// 2. Prepare .vercel/output directory
fs.rmSync(vercelOutputDir, { recursive: true, force: true });
fs.mkdirSync(staticDir, { recursive: true });
fs.cpSync(publicDir, staticDir, { recursive: true });

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

const copiedDist = fs.readdirSync(distDir);
console.log(`[VERCEL BUILD] Success! Copied ${copiedDist.length} items to dist/ and .vercel/output/static/`);
