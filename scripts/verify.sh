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

# Database (docs/product/2-db/10-quy-uoc-code.md QC-07): chạy bộ kiểm khi lượt
# này đổi gì dưới db/, compose.yaml, scripts/db-check.sh hay docs/product/2-db/.
# Không có Docker thì db-check.sh tự FAIL — không bỏ qua.
if [ -d db ] && [ -n "$(git status --porcelain --untracked-files=all -- db compose.yaml scripts/db-check.sh docs/product/2-db 2>/dev/null)" ]; then
  echo "[db] scripts/db-check.sh"
  "$(cd "$(dirname "$0")" && pwd)"/db-check.sh
else
  echo "[db] skipped — nothing under db/, compose.yaml, scripts/db-check.sh or docs/product/2-db/ changed"
fi

for t in "$(cd "$(dirname "$0")" && pwd)"/*.test.sh; do
  [ -f "$t" ] || continue
  echo "[test] $t"
  "$t"
done

echo "Verification passed."
