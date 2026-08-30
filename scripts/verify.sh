#!/usr/bin/env bash
set -euo pipefail

echo "=== Lean AI Engineering Verification ==="

if [ -f "go.mod" ]; then
  echo "[Go] formatting"
  test -z "$(gofmt -l .)"
  echo "[Go] build"
  go build ./...
  echo "[Go] test"
  go test ./...
fi

if [ -f "package.json" ]; then
  echo "[Node] package scripts"
  if command -v npm >/dev/null 2>&1; then
    npm test --if-present
    npm run lint --if-present
    npm run build --if-present
  fi
fi

for t in "$(cd "$(dirname "$0")" && pwd)"/*.test.sh; do
  [ -f "$t" ] || continue
  echo "[test] $t"
  "$t"
done

echo "Verification passed."
