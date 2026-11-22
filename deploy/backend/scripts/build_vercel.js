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

// Output directly to .vercel/output relative to current working directory
const cwd = process.cwd();
const vercelOutputDir = path.join(cwd, '.vercel', 'output');
const staticDir = path.join(vercelOutputDir, 'static');

console.log(`[VERCEL BUILD] Working Directory: ${cwd}`);
console.log(`[VERCEL BUILD] Resolved Public Dir: ${publicDir}`);
console.log(`[VERCEL BUILD] Target Output Dir:   ${staticDir}`);

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

const copiedFiles = fs.readdirSync(staticDir);
console.log(`[VERCEL BUILD] Success! Copied ${copiedFiles.length} items to ${staticDir}`);
console.log(`[VERCEL BUILD] Generated config.json for Edge CDN headers and routing.`);
