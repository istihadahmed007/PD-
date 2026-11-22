const http = require('http');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

let PORT = 8080;
const PUBLIC_DIR = path.resolve(__dirname, '..', 'public');

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.wasm': 'application/wasm',
  '.pck': 'application/octet-stream',
  '.zip': 'application/zip',
  '.exe': 'application/octet-stream'
};

function serveFile(req, res, filePath) {
  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
      res.end(`404 Not Found: ${path.basename(filePath)}`);
      return;
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';
    const totalSize = stats.size;

    // Handle HTTP Range header for chunked PCK/WASM loading
    const range = req.headers.range;
    if (range) {
      const parts = range.replace(/bytes=/, '').split('-');
      const start = parseInt(parts[0], 10);
      const end = parts[1] ? parseInt(parts[1], 10) : totalSize - 1;

      if (start >= totalSize || end >= totalSize || start > end) {
        res.writeHead(416, {
          'Content-Range': `bytes */${totalSize}`,
          'Cross-Origin-Opener-Policy': 'same-origin',
          'Cross-Origin-Embedder-Policy': 'require-corp',
          'Cross-Origin-Resource-Policy': 'cross-origin',
          'Access-Control-Allow-Origin': '*'
        });
        res.end();
        return;
      }

      const chunkSize = end - start + 1;
      res.writeHead(206, {
        'Content-Range': `bytes ${start}-${end}/${totalSize}`,
        'Accept-Ranges': 'bytes',
        'Content-Length': chunkSize,
        'Content-Type': contentType,
        'Cross-Origin-Opener-Policy': 'same-origin',
        'Cross-Origin-Embedder-Policy': 'require-corp',
        'Cross-Origin-Resource-Policy': 'cross-origin',
        'Access-Control-Allow-Origin': '*'
      });

      fs.createReadStream(filePath, { start, end }).pipe(res);
    } else {
      res.writeHead(200, {
        'Content-Length': totalSize,
        'Content-Type': contentType,
        'Accept-Ranges': 'bytes',
        'Cross-Origin-Opener-Policy': 'same-origin',
        'Cross-Origin-Embedder-Policy': 'require-corp',
        'Cross-Origin-Resource-Policy': 'cross-origin',
        'Access-Control-Allow-Origin': '*'
      });

      fs.createReadStream(filePath).pipe(res);
    }
  });
}

function createServer() {
  const server = http.createServer((req, res) => {
    // Standard CORS and COOP/COEP isolation headers
    res.setHeader('Cross-Origin-Opener-Policy', 'same-origin');
    res.setHeader('Cross-Origin-Embedder-Policy', 'require-corp');
    res.setHeader('Cross-Origin-Resource-Policy', 'cross-origin');
    res.setHeader('Access-Control-Allow-Origin', '*');

    let reqUrl = decodeURI(req.url.split('?')[0]);

    if (reqUrl === '/' || reqUrl === '') {
      return serveFile(req, res, path.join(PUBLIC_DIR, 'index.html'));
    }

    if (reqUrl === '/play' || reqUrl === '/play/') {
      return serveFile(req, res, path.join(PUBLIC_DIR, 'play', 'index.html'));
    }

    if (reqUrl === '/game' || reqUrl === '/game.html' || reqUrl === '/play.html') {
      const gameHtml = path.join(PUBLIC_DIR, 'game.html');
      if (fs.existsSync(gameHtml)) {
        return serveFile(req, res, gameHtml);
      }
      return serveFile(req, res, path.join(PUBLIC_DIR, 'play', 'index.html'));
    }

    let filePath = path.join(PUBLIC_DIR, reqUrl);

    // Guard against path traversal
    if (!filePath.startsWith(PUBLIC_DIR)) {
      res.writeHead(403, { 'Content-Type': 'text/plain; charset=utf-8' });
      res.end('403 Forbidden');
      return;
    }

    // If requested file doesn't exist, check fallback in parent or play dir
    if (!fs.existsSync(filePath)) {
      if (reqUrl.startsWith('/play/')) {
        const fallbackRoot = path.join(PUBLIC_DIR, path.basename(reqUrl));
        if (fs.existsSync(fallbackRoot)) {
          filePath = fallbackRoot;
        }
      } else {
        const fallbackPlay = path.join(PUBLIC_DIR, 'play', path.basename(reqUrl));
        if (fs.existsSync(fallbackPlay)) {
          filePath = fallbackPlay;
        }
      }
    }

    serveFile(req, res, filePath);
  });

  server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      console.log(`[WARN] Port ${PORT} is in use, trying port ${PORT + 1}...`);
      PORT++;
      server.listen(PORT, '127.0.0.1');
    } else {
      console.error('[ERROR] Server error:', err.message);
    }
  });

  server.listen(PORT, '127.0.0.1', () => {
    const portalUrl = `http://localhost:${PORT}/`;
    const playUrl = `http://localhost:${PORT}/play/`;

    console.log('===============================================================================');
    console.log(`  DTA: DHAKA THEFT AUTO (ঢাকা থেফট অটো) — LOCAL WEB PREVIEW SERVER RUNNING`);
    console.log('===============================================================================');
    console.log(`  * Web Portal:      ${portalUrl}`);
    console.log(`  * Web Game Client: ${playUrl}`);
    console.log('  * Security:        Cross-Origin Isolation (COOP: same-origin, COEP: require-corp)');
    console.log('  * Streaming:       HTTP 206 Partial Content Range Support Active');
    console.log('===============================================================================');
    console.log('  Opening your web browser now...');
    console.log('  Press Ctrl+C to stop the server.');
    console.log('===============================================================================');

    // Launch default browser on Windows
    exec(`cmd.exe /c start "" "${portalUrl}"`, (launchErr) => {
      if (launchErr) {
        console.log(`[INFO] Please open in your browser manually: ${portalUrl}`);
      }
    });
  });
}

createServer();
