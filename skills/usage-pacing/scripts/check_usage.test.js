'use strict';
// Run: node --test skills/usage-pacing/scripts/check_usage.test.js
//
// Builds fake Chromium cache entries in a temp dir and runs check_usage.js and
// usage_hook.sh against them. CLAUDE_USAGE_CACHE_DIR points the script at the
// fake cache; TMPDIR isolates the remembered-entries state and hook stamps.

const test = require('node:test');
const assert = require('node:assert');
const fs = require('fs');
const os = require('os');
const path = require('path');
const zlib = require('zlib');
const { spawnSync } = require('child_process');

const SCRIPT = path.join(__dirname, 'check_usage.js');
const HOOK = path.join(__dirname, 'usage_hook.sh');
const ORG = '11111111-2222-3333-4444-555555555555';
const MIN = 60_000;

function setup() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'usage-test-'));
  const cache = path.join(root, 'Cache_Data');
  const tmp = path.join(root, 'tmp');
  fs.mkdirSync(cache); fs.mkdirSync(tmp);
  return { cache, tmp };
}

// A cache entry shaped like Chromium's simple cache: key, zstd body, headers.
function writeEntry(cache, name, { url = `https://claude.ai/api/organizations/${ORG}/usage`, utilization, resetsAt, fetchedAt, mtime }) {
  const body = JSON.stringify({ five_hour: { utilization, resets_at: new Date(resetsAt).toISOString() }, seven_day: null });
  const buf = Buffer.concat([
    Buffer.from([0x30, 0x5c, 0x72, 0xa7, 0x1b, 0x6d, 0xfb, 0xfc]),
    Buffer.from(`1/0/_dk_https://claude.ai https://claude.ai ${url}`, 'latin1'),
    zlib.zstdCompressSync(Buffer.from(body)),
    Buffer.from(`\r\nHTTP/1.1 200\r\ndate: ${new Date(fetchedAt).toUTCString()}\r\ncontent-encoding: zstd\r\n`, 'latin1'),
  ]);
  const file = path.join(cache, name);
  fs.writeFileSync(file, buf);
  if (mtime) fs.utimesSync(file, new Date(mtime), new Date(mtime));
  return file;
}

function run(env, args = []) {
  return spawnSync('node', [SCRIPT, ...args], {
    encoding: 'utf8',
    env: { ...process.env, CLAUDE_USAGE_CACHE_DIR: env.cache, TMPDIR: env.tmp },
  });
}

function json(env) {
  const r = run(env, ['--json']);
  assert.strictEqual(r.status, 0, r.stderr);
  return JSON.parse(r.stdout);
}

const now = Date.now();
const H = 60 * MIN;

test('picks the entry with the newest response date', () => {
  const env = setup();
  writeEntry(env.cache, 'aaa_0', { utilization: 10, resetsAt: now + 2 * H, fetchedAt: now - 20 * MIN });
  writeEntry(env.cache, 'bbb_0', { utilization: 55, resetsAt: now + 2 * H, fetchedAt: now - 1 * MIN });
  assert.strictEqual(json(env).five_hour.utilization, 55);
});

test('regression: a remembered stale entry does not hide a newer URL variant', () => {
  const env = setup();
  const old = writeEntry(env.cache, 'old_0', {
    url: `https://claude.ai/api/organizations/${ORG}/usage?source=limit_probe`,
    utilization: 12, resetsAt: now - 500 * H, fetchedAt: now - 520 * H, mtime: now - 520 * H,
  });
  // Old-style state file: the script used to trust this path forever.
  fs.writeFileSync(path.join(env.tmp, 'claude_usage_cachefile.txt'), old);
  fs.writeFileSync(path.join(env.tmp, 'claude_usage_cachefiles.json'), JSON.stringify([old]));
  writeEntry(env.cache, 'new_0', { utilization: 37, resetsAt: now + 3 * H, fetchedAt: now - 2 * MIN });
  const d = json(env);
  assert.strictEqual(d.five_hour.utilization, 37);
  assert.strictEqual(d.stale, false);
});

test('finds entries with no saved state (first run)', () => {
  const env = setup();
  writeEntry(env.cache, 'x_0', { utilization: 20, resetsAt: now + H, fetchedAt: now - MIN, mtime: now - 30 * H });
  assert.strictEqual(json(env).five_hour.utilization, 20);
});

test('remembers entries so later runs find an old-mtime entry without a full scan', () => {
  const env = setup();
  const f = writeEntry(env.cache, 'x_0', { utilization: 20, resetsAt: now + H, fetchedAt: now - MIN });
  json(env);
  const known = JSON.parse(fs.readFileSync(path.join(env.tmp, 'claude_usage_cachefiles.json'), 'utf8'));
  assert.deepStrictEqual(known, [f]);
});

test('ignores cache files that are not usage responses', () => {
  const env = setup();
  fs.writeFileSync(path.join(env.cache, 'other_0'), 'https://claude.ai/api/organizations/x/settings five_hour');
  writeEntry(env.cache, 'u_0', { utilization: 44, resetsAt: now + H, fetchedAt: now - MIN });
  assert.strictEqual(json(env).five_hour.utilization, 44);
});

test('fresh data: not stale, compact line shows the percentage and reset', () => {
  const env = setup();
  writeEntry(env.cache, 'u_0', { utilization: 40, resetsAt: now + 2 * H + 5 * MIN, fetchedAt: now - 3 * MIN });
  const d = json(env);
  assert.strictEqual(d.stale, false);
  assert.strictEqual(d.stale_reason, null);
  assert.ok(d.age_minutes >= 2 && d.age_minutes <= 4, String(d.age_minutes));
  const c = run(env, ['--compact']).stdout;
  assert.match(c, /5h: 40% \(resets in 2h0[45]m\)/);
});

test('stale when the response is older than 30 minutes', () => {
  const env = setup();
  writeEntry(env.cache, 'u_0', { utilization: 40, resetsAt: now + 4 * H, fetchedAt: now - 45 * MIN });
  const d = json(env);
  assert.strictEqual(d.stale, true);
  assert.strictEqual(d.stale_reason, 'old');
  const c = run(env, ['--compact']).stdout;
  assert.match(c, /5h: unknown/);
  assert.doesNotMatch(c, /40%/);
});

test('stale when the window has already reset, even if the response is recent', () => {
  const env = setup();
  writeEntry(env.cache, 'u_0', { utilization: 90, resetsAt: now - 10 * MIN, fetchedAt: now - 5 * MIN });
  const d = json(env);
  assert.strictEqual(d.stale, true);
  assert.strictEqual(d.stale_reason, 'window-reset');
});

test('no usage entries: exits non-zero; --json reports an error', () => {
  const env = setup();
  assert.notStrictEqual(run(env).status, 0);
  const r = run(env, ['--json']);
  assert.notStrictEqual(r.status, 0);
  assert.strictEqual(JSON.parse(r.stdout).error, 'no-cache-entry');
});

function hook(env) {
  const r = spawnSync('bash', [HOOK], {
    input: '{}', encoding: 'utf8',
    env: { ...process.env, CLAUDE_USAGE_CACHE_DIR: env.cache, TMPDIR: env.tmp },
  });
  assert.strictEqual(r.status, 0, r.stderr);
  return r.stdout ? JSON.parse(r.stdout).hookSpecificOutput.additionalContext : '';
}

test('hook: fresh and under 80% says healthy', () => {
  const env = setup();
  writeEntry(env.cache, 'u_0', { utilization: 20, resetsAt: now + H, fetchedAt: now - MIN });
  assert.match(hook(env), /usage healthy/);
});

test('hook: fresh and at 80% or more gives the wrap-up warning', () => {
  const env = setup();
  writeEntry(env.cache, 'u_0', { utilization: 85, resetsAt: now + H, fetchedAt: now - MIN });
  assert.match(hook(env), /past 80%/);
});

test('hook: stale data never claims usage is healthy', () => {
  const env = setup();
  writeEntry(env.cache, 'u_0', { utilization: 12, resetsAt: now - 500 * H, fetchedAt: now - 520 * H });
  const msg = hook(env);
  assert.doesNotMatch(msg, /healthy/);
  assert.match(msg, /unknown/);
});

test('real Desktop cache entry still decodes (skipped if none on this machine)', (t) => {
  const real = path.join(os.homedir(), 'Library/Application Support/Claude/Cache/Cache_Data');
  const r = spawnSync('grep', ['-rlaE', 'organizations/[a-f0-9-]+/usage', real], { encoding: 'utf8' });
  const files = (r.stdout || '').split('\n').filter(Boolean);
  if (!files.length) return t.skip('no Desktop cache');
  const env = setup();
  for (const f of files) fs.copyFileSync(f, path.join(env.cache, path.basename(f)));
  const d = json(env);
  assert.strictEqual(typeof d.five_hour.utilization, 'number');
});
