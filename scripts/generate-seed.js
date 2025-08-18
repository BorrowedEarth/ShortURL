// Generate urls.data.js from urls.csv
// Usage: node scripts/generate-seed.js

const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const csvPath = path.join(root, 'urls.csv');
const outPath = path.join(root, 'urls.data.js');

function parseCSVLine(line) {
  // naive split on first two commas
  const parts = [];
  let current = '';
  let commas = 0;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (ch === ',' && commas < 2) {
      parts.push(current);
      current = '';
      commas++;
    } else {
      current += ch;
    }
  }
  parts.push(current);
  while (parts.length < 3) parts.push('');
  return parts.map(p => p.trim());
}

function toShortCode(cell) {
  try {
    if (cell.startsWith('http')) {
      const u = new URL(cell);
      return u.pathname.replace(/^\//, '').replace(/\/$/, '');
    }
  } catch {}
  return cell.replace(/^\//, '').replace(/\/$/, '');
}

function main() {
  console.time('generate-seed');
  if (!fs.existsSync(csvPath)) {
    console.error('urls.csv not found:', csvPath);
    process.exit(1);
  }
  const text = fs.readFileSync(csvPath, 'utf8');
  const lines = text.split(/\r?\n/).filter(l => l.trim().length > 0);
  if (lines.length <= 1) {
    console.warn('No data rows found in urls.csv');
  }

  // Deduplicate by short code (last one wins)
  const dedup = new Map();
  for (let i = 1; i < lines.length; i++) { // skip header
    const [shortCell, longCell, tagsCell] = parseCSVLine(lines[i]);
    if (!shortCell || !longCell) continue;
    const short = toShortCode(shortCell);
    const long = longCell.trim();
    const tags = (tagsCell || 'Imported').trim();
    if (!short) continue;
    dedup.set(short, { long, tags });
  }

  const items = Array.from(dedup, ([short, v]) => ({ short, long: v.long, tags: v.tags }));

  const banner = '// Generated from urls.csv. Do not edit manually.\n';
  // Minified payload to reduce file size and speed up build
  const payload = `window.URL_SEED = ${JSON.stringify(items)};\n`;
  const nextContent = banner + payload;

  const force = process.argv.includes('--force') || process.env.FORCE_SEED === '1';

  let wrote = false;
  if (force) {
    fs.writeFileSync(outPath, nextContent, 'utf8');
    wrote = true;
  } else {
    try {
      const prev = fs.readFileSync(outPath, 'utf8');
      if (prev !== nextContent) {
        fs.writeFileSync(outPath, nextContent, 'utf8');
        wrote = true;
      }
    } catch {
      // No previous file; write new
      fs.writeFileSync(outPath, nextContent, 'utf8');
      wrote = true;
    }
  }

  console.log(`Seed entries: ${items.length}`);
  console.log(wrote ? `Updated ${outPath}` : 'No changes in seed; skipped write');
  console.timeEnd('generate-seed');
}

main();
