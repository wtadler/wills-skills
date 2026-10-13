#!/usr/bin/env bash
set -euo pipefail
h="$(cd "$(dirname "$0")/../../../harness" && pwd)"
bash "$h/sandbox-clone.sh" "$1"
b="fix/slug-lower-$RANDOM"
cd "$1" && git checkout -q -b "$b"
sed -i '' "s/return text.trim()/return text.trim().toLowerCase()/" src/slugify.js
cat >> src/slugify.test.js <<'JS'

test('lowercases the slug', () => {
  assert.equal(slugify('Hello World'), 'hello-world');
});
JS
git commit -qam "fix: lowercase slugs"
