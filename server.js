// Simple static server with SPA fallback for ShortURL
// Serves index and assets; routes non-file requests to index.html so client JS can handle redirects.

const express = require('express');
const path = require('path');

const ROOT = path.resolve(__dirname);
const PORT = process.env.PORT ? Number(process.env.PORT) : 8000;

const app = express();
app.disable('x-powered-by');

// Healthcheck
app.get('/healthz', (req, res) => res.json({ ok: true }));

// Serve static assets
app.use(express.static(ROOT, {
  extensions: ['html'], // allow /path to resolve to /path.html
  maxAge: '1h',
  setHeaders(res, filePath) {
    if (filePath.endsWith('index.html')) {
      res.setHeader('Cache-Control', 'no-cache');
    }
  }
}));

// SPA fallback: any non-file path returns index.html
app.get('*', (req, res) => {
  // If the request looks like a direct file (has a dot), let 404 happen
  if (path.basename(req.path).includes('.')) {
    return res.status(404).send('Not found');
  }
  res.sendFile(path.join(ROOT, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`ShortURL static server running on http://localhost:${PORT}`);
});
