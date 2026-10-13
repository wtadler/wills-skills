#!/usr/bin/env node
'use strict';

// Read Claude subscription usage WITHOUT any network call.
//
// Claude Desktop fetches https://claude.ai/api/organizations/{org}/usage itself
// and stores the (zstd-compressed) JSON response in its Chromium HTTP cache on
// disk. We read that cached response directly. This sidesteps the OAuth
// endpoint's rate limit AND Cloudflare's bot challenge (the desktop app already
// solved both). The only cost is freshness: the data is as recent as the app's
// last fetch, so we always surface the response's `date:` header as "as of".
//
// Usage:
//   node check_usage.js            → full JSON + summary (for the skill)
//   node check_usage.js --compact  → one-liner (for the periodic hook)
//   node check_usage.js --json     → machine-readable, with staleness (for scripts)
//
// The app may cache the usage endpoint under more than one URL (e.g. a
// `?source=limit_probe` variant), each in its own cache file, and switch between
// them. So every run compares all known entries plus any recently written ones
// and takes the newest response by its `date:` header. Never trust a single
// remembered path: that is how this once reported a 3-week-old reading.

const fs = require('fs');
const os = require('os');
const path = require('path');
const zlib = require('zlib');
const { spawnSync } = require('child_process');

const COMPACT = process.argv.includes('--compact');
const JSON_OUT = process.argv.includes('--json');
const CACHE_DIR = process.env.CLAUDE_USAGE_CACHE_DIR
  || path.join(os.homedir(), 'Library/Application Support/Claude/Cache/Cache_Data');
const KNOWN_FILE = path.join(os.tmpdir(), 'claude_usage_cachefiles.json'); // every usage entry seen so far
const USAGE_PATTERN = 'organizations/[a-f0-9-]+/usage';
const USAGE_URL_RE = new RegExp(USAGE_PATTERN);
const ZSTD_MAGIC = Buffer.from([0x28, 0xb5, 0x2f, 0xfd]);
const RECENT_MINUTES = 240; // cheap scan window for newly written entries
const STALE_MINUTES = 30;   // older than this, the reading is "unknown"

// ── Locate the Desktop cache entry for the usage endpoint ────────────────────

function entryLooksValid(file) {
  try {
    const buf = fs.readFileSync(file);
    return USAGE_URL_RE.test(buf.toString('latin1'));
  } catch { return false; }
}

function grepList(args) {
  const r = spawnSync(args[0], args.slice(1), { encoding: 'utf8', maxBuffer: 8 << 20 });
  return (r.stdout || '').split('\n').filter(Boolean);
}

// Full scan: ~3s on a large cache. Only when nothing is known yet.
function fullScan() {
  return grepList(['grep', '-rlaE', USAGE_PATTERN, CACHE_DIR]);
}

// Cheap scan: only small files written recently (~0.1s). Catches new URL variants.
function recentScan() {
  return grepList(['find', CACHE_DIR, '-type', 'f', '-mmin', `-${RECENT_MINUTES}`, '-size', '-256k',
    '-exec', 'grep', '-laE', USAGE_PATTERN, '{}', '+']);
}

function readKnown() {
  try { return JSON.parse(fs.readFileSync(KNOWN_FILE, 'utf8')); } catch { return []; }
}

function discoverEntry() {
  let candidates = [...new Set([...readKnown(), ...recentScan()])].filter(entryLooksValid);
  if (!candidates.length) candidates = fullScan().filter(entryLooksValid);
  if (!candidates.length) return null;

  candidates.sort();
  try { fs.writeFileSync(KNOWN_FILE, JSON.stringify(candidates)); } catch {}

  let best = null, bestTs = -Infinity;
  for (const f of candidates) {
    const ts = cacheDate(f) ?? -Infinity;
    if (ts > bestTs) { best = f; bestTs = ts; }
  }
  return best;
}

// ── Decompress the zstd response body out of the cache entry ─────────────────

function zstdDecompress(buf) {
  if (typeof zlib.zstdDecompressSync === 'function') {
    return zlib.zstdDecompressSync(buf); // Node >= 24
  }
  const r = spawnSync('zstd', ['-dc', '--no-check'], { input: buf, maxBuffer: 1 << 20 });
  if (r.status !== 0 && !(r.stdout && r.stdout.length)) throw new Error('zstd decode failed');
  return r.stdout;
}

function extractUsage(file) {
  const buf = fs.readFileSync(file);

  // The response body may be zstd-framed, or stored uncompressed. Try each zstd
  // frame offset until one yields valid usage JSON; fall back to scanning for a
  // raw JSON object.
  let from = 0;
  while (true) {
    const idx = buf.indexOf(ZSTD_MAGIC, from);
    if (idx === -1) break;
    for (let end = buf.length; end > idx; end--) {
      try {
        const out = zstdDecompress(buf.subarray(idx, end));
        const s = out.toString('utf8');
        if (s.includes('five_hour') || s.includes('utilization')) return JSON.parse(s);
      } catch {}
      if (buf.length - end > 96) break; // don't brute-force a long trailer
    }
    from = idx + 4;
  }

  // Uncompressed fallback
  const txt = buf.toString('latin1');
  const m = txt.match(/\{"five_hour".*?\}\}/s) || txt.match(/\{.*"utilization".*\}/s);
  if (m) { try { return JSON.parse(m[0]); } catch {} }
  return null;
}

function cacheDate(file) {
  try {
    const txt = fs.readFileSync(file).toString('latin1');
    const m = txt.match(/date:\s*([^\r\n]+GMT)/i);
    if (m) {
      const t = Date.parse(m[1]);
      if (!Number.isNaN(t)) return t;
    }
  } catch {}
  // fall back to file mtime
  try { return fs.statSync(file).mtimeMs; } catch { return null; }
}

// ── Formatting ───────────────────────────────────────────────────────────────

function fmtResetsIn(resets_at) {
  if (!resets_at) return '';
  const diffMs = new Date(resets_at) - Date.now();
  if (diffMs <= 0) return '';
  const min = Math.round(diffMs / 60000);
  const h = Math.floor(min / 60), m = min % 60;
  return h > 0 ? ` (resets in ${h}h${String(m).padStart(2, '0')}m)` : ` (resets in ${m}m)`;
}

function fmtAge(ts) {
  if (!ts) return '';
  const ageMin = Math.round((Date.now() - ts) / 60000);
  const clock = new Date(ts).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
  if (ageMin <= 1) return `as of ${clock} (just now)`;
  if (ageMin < 60) return `as of ${clock} (${ageMin}m ago)`;
  const h = Math.floor(ageMin / 60);
  return `as of ${clock} (${h}h${ageMin % 60}m ago)`;
}

// A reading is stale if the app hasn't refetched recently, or if its 5-hour
// window has already rolled over (the percentage then describes a past window).
function staleness(d, ts) {
  const ageMin = ts ? (Date.now() - ts) / 60000 : Infinity;
  const resetsAt = d.five_hour && d.five_hour.resets_at ? Date.parse(d.five_hour.resets_at) : NaN;
  if (!Number.isNaN(resetsAt) && resetsAt <= Date.now()) return { stale: true, reason: 'window-reset', ageMin };
  if (ageMin > STALE_MINUTES) return { stale: true, reason: 'old', ageMin };
  return { stale: false, reason: null, ageMin };
}

function printJson(d, ts) {
  const s = staleness(d, ts);
  console.log(JSON.stringify({
    five_hour: d.five_hour ? { utilization: d.five_hour.utilization, resets_at: d.five_hour.resets_at } : null,
    seven_day: d.seven_day ? { utilization: d.seven_day.utilization, resets_at: d.seven_day.resets_at } : null,
    as_of: ts ? new Date(ts).toISOString() : null,
    age_minutes: Number.isFinite(s.ageMin) ? Math.round(s.ageMin) : null,
    stale: s.stale,
    stale_reason: s.reason,
  }));
}

function printCompact(d, ts) {
  const s = staleness(d, ts);
  if (s.stale) {
    const why = s.reason === 'window-reset' ? 'the cached window has already reset' : 'the cached reading is too old';
    console.log(`\n[Claude usage] 5h: unknown (${why}; open or focus Claude Desktop to refresh)  ·  ${fmtAge(ts)}`);
    return;
  }
  const parts = [];
  for (const [label, key] of [['5h', 'five_hour'], ['7d', 'seven_day']]) {
    const b = d[key];
    if (b && b.utilization != null) parts.push(`${label}: ${Math.round(b.utilization)}%${fmtResetsIn(b.resets_at)}`);
  }
  if (!parts.length) return;
  console.log(`\n[Claude usage] ${parts.join('  |  ')}  ·  ${fmtAge(ts)}`);
}

function printFull(d, ts) {
  console.log(JSON.stringify(d, null, 2));
  console.log();
  const line = (label, b) => {
    if (!b || b.utilization == null) return;
    let when = '';
    if (b.resets_at) {
      try { when = `  (resets ${new Date(b.resets_at).toISOString().replace('T', ' ').slice(0, 16)} UTC)`; } catch {}
    }
    console.log(`  ${label.padEnd(24)} ${b.utilization.toFixed(1).padStart(5)}%${when}`);
  };
  console.log(`=== Usage summary (utilization = % of cap) · ${fmtAge(ts)} ===`);
  line('5-hour', d.five_hour);
  line('weekly (7-day)', d.seven_day);
  line('weekly Opus', d.seven_day_opus);
  line('weekly Sonnet', d.seven_day_sonnet);
  line('weekly cowork', d.seven_day_cowork);
  line('weekly oauth apps', d.seven_day_oauth_apps);
  const eu = d.extra_usage || {};
  if (eu.is_enabled) {
    console.log(`  extra usage (overflow)   enabled: ${eu.used_credits || 0} / ${eu.monthly_limit} ${eu.currency || ''} used`);
  } else if (Object.keys(eu).length) {
    console.log(`  extra usage (overflow)   disabled (${eu.disabled_reason})`);
  }
}

// ── Main ─────────────────────────────────────────────────────────────────────

function fail(code, msg) {
  if (JSON_OUT) console.log(JSON.stringify({ error: code, message: msg }));
  else if (!COMPACT) console.error(msg);
  process.exit(1);
}

const entry = discoverEntry();
if (!entry) {
  fail('no-cache-entry', 'No cached usage found. Open the Claude Desktop app (it fetches usage on launch),\nthen rerun. This skill reads the desktop app\'s on-disk cache — no network call.');
}

const data = extractUsage(entry);
if (!data) {
  try { fs.unlinkSync(KNOWN_FILE); } catch {} // force re-discovery next run
  fail('decode-failed', 'Found the cache entry but could not decode the usage JSON. Try reopening Claude Desktop.');
}

const ts = cacheDate(entry);
if (JSON_OUT) printJson(data, ts);
else if (COMPACT) printCompact(data, ts);
else {
  printFull(data, ts);
  const s = staleness(data, ts);
  if (s.stale) console.log(`\n  ⚠ STALE (${s.reason}): don't rely on these numbers. Open or focus Claude Desktop to refresh.`);
}
