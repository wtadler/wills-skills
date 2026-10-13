# Usage Pacing Reference

## How it works (for maintenance)

`skills/usage-pacing/scripts/check_usage.js`:
1. Finds cache entries for the usage URL in
   `~/Library/Application Support/Claude/Cache/Cache_Data/` (override with
   `CLAUDE_USAGE_CACHE_DIR`). The app can cache the endpoint under more than one
   URL (e.g. `?source=limit_probe`), each in its own file, so every run compares
   all known entries (`$TMPDIR/claude_usage_cachefiles.json`) plus files written in
   the last 4 hours, and takes the newest by `date:` header. A full-cache grep
   (~3s) only runs when nothing is known. (Until 2026-10-05 it trusted one
   remembered path and reported a 3-week-old reading.)
2. Locates the zstd frame (`28 b5 2f fd`) in the entry and decompresses it
   (Node ≥24 native `zlib.zstdDecompressSync`, else the `zstd` CLI).
3. Parses the JSON and the `date:` header, decides staleness, then prints full,
   `--compact`, or `--json`.

Tests: `node --test skills/usage-pacing/scripts/check_usage.test.js` (fake cache
entries in a temp dir, plus one check that the real Desktop entry still decodes).

## Troubleshooting

- **"No cached usage found":** the desktop app hasn't fetched usage yet. Open it.
- **"could not decode the usage JSON":** the script clears its list of known
  entries so the next run re-discovers. If it persists, reopen the
  desktop app to repopulate the cache.
- **Numbers disagree with the app:** check the `as of` stamp — the cache may be
  stale. Reopen/focus Claude Desktop and rerun.
