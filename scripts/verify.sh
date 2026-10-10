#!/usr/bin/env bash
# Gate 1 — the change builds and its tests pass.
#
# gate.sh calls it after the file-only gates, and SKIPS it when the turn changed documentation
# only (ADR-005) — that is why Gates 1b · 1c · 1d · 1e · 1f · 1g live outside this script and
# run on every turn. Run by hand: ./scripts/verify.sh
#
# What it runs, in order; each step runs only when its trigger exists:
#   be    — be/go.mod present: gofmt must list nothing, go vet, go build.
#           be-check.sh runs when be/, db/, compose.yaml or scripts/be-check.sh
#           changed; it requires Docker and fails if Docker is unavailable. It runs the
#           QC-17 test-name check first, so a turn that changes only be/ is checked (F-061).
#   Node  — package.json present and npm installed: npm test / lint / build,
#           each only if the package defines it (--if-present).
#   db    — db/ exists AND this turn changed something under db/, compose.yaml,
#           scripts/db-check.sh, scripts/reconcile.sh or docs/product/2-db/:
#           scripts/db-check.sh.
#           It needs Docker; without Docker db-check.sh FAILS, it does not skip
#           (docs/product/2-db/10-quy-uoc-code.md QC-07).
#   test  — every scripts/*.test.sh, always. These guard the gates themselves.
#
# set -e: the first failing step stops the run and the exit code is non-zero.
# The last line "Verification passed." is what gate.sh labels PASS (T-084).
# The related-invariant regression test of an L2+ task (CLAUDE.md §3) runs here
# only if it exists as one of the steps above.
set -euo pipefail

echo "=== Lean AI Engineering Verification ==="

if [ -f "be/go.mod" ]; then
  echo "[be] formatting"
  test -z "$(gofmt -l be)"
  echo "[be] vet"
  (cd be && go vet ./...)
  echo "[be] build"
  (cd be && go build ./...)
  if [ -n "$(git status --porcelain --untracked-files=all -- be db compose.yaml scripts/be-check.sh)" ]; then
    echo "[be] scripts/be-check.sh"
    "$(cd "$(dirname "$0")" && pwd)"/be-check.sh
  else
    echo "[be] skipped — nothing under be/, db/, compose.yaml or scripts/be-check.sh changed"
  fi
else
  echo "[be] skipped — no be/go.mod"
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
# này đổi gì dưới db/, compose.yaml, scripts/db-check.sh, scripts/reconcile.sh
# (bộ đối chiếu P2-11 — db-check chứng minh nó) hay docs/product/2-db/.
# Không có Docker thì db-check.sh tự FAIL — không bỏ qua.
if [ -d db ] && [ -n "$(git status --porcelain --untracked-files=all -- db compose.yaml scripts/db-check.sh scripts/reconcile.sh docs/product/2-db 2>/dev/null)" ]; then
  echo "[db] scripts/db-check.sh"
  "$(cd "$(dirname "$0")" && pwd)"/db-check.sh
else
  echo "[db] skipped — nothing under db/, compose.yaml, scripts/db-check.sh, scripts/reconcile.sh or docs/product/2-db/ changed"
fi

for t in "$(cd "$(dirname "$0")" && pwd)"/*.test.sh; do
  [ -f "$t" ] || continue
  echo "[test] $t"
  "$t"
done

echo "Verification passed."
