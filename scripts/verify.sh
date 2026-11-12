#!/usr/bin/env bash
# Gate 1 — the change builds and its tests pass.
#
# gate.sh calls it after the file-only gates, and SKIPS it when the turn changed documentation
# only (ADR-005) — that is why Gates 1b · 1c · 1d · 1e · 1f · 1g · 1h live outside this script and
# run on every turn. Run by hand: ./scripts/verify.sh
#
# What it runs, in order; each step runs only when its trigger exists:
#   be    — be/go.mod present: gofmt must list nothing, go vet, go build, check-sqlcgen.sh (regenerate in a temporary tree and compare).
#           be-check.sh runs when be/, db/, compose.yaml or scripts/be-check.sh
#           changed; it requires Docker and fails if Docker is unavailable. It runs the
#           QC-17 test-name check first, so a turn that changes only be/ is checked (F-061).
#   fe    — fe/package.json present: always check-fe-rules.sh; fe-check.sh runs
#           lint, typecheck, tests, build and compares generated API types when fe/,
#           docs/product/3-be/openapi.yaml, scripts/fe-check.sh or
#           scripts/check-fe-rules.sh changed. Missing node_modules: npm ci.
#   Node  — package.json present and npm installed: npm test / lint / build,
#           each only if the package defines it (--if-present).
#   db    — db/ exists AND this turn changed something under db/, compose.yaml,
#           scripts/db-check.sh, scripts/reconcile.sh or docs/product/2-db/:
#           scripts/db-check.sh.
#           It needs Docker; without Docker db-check.sh FAILS, it does not skip
#           (docs/product/2-db/10-quy-uoc-code.md QC-07).
#   test  — scripts/ changed: every scripts/*.test.sh. Otherwise, only tests
#           whose own real-repo inputs changed; report how many were skipped.
#
# set -e: the first failing step stops the run and the exit code is non-zero.
# The last line "Verification passed." is what gate.sh labels PASS (T-084).
# The related-invariant regression test of an L2+ task (CLAUDE.md §3) runs here
# only if it exists as one of the steps above.
# T-321 (2026-11-11): in số giây nguyên của mỗi bước đã chạy và mỗi file test;
# dòng cuối vẫn là "Verification passed." để gate.sh nhận kết quả như trước.
# T-324 (2026-11-12): lượt đổi fe/ đo 143 giây ở gate, riêng 20 script test tốn
# 94 giây (gate.test.sh 26 giây, brief.test.sh 20 giây), gần hạn 180 giây của Stop hook.
# Mọi test chạy khi scripts/ đổi; lượt khác chọn từng test theo đầu vào riêng,
# để lượt chỉ đổi fe/ không kéo theo cả 20 test script.
set -euo pipefail

time_step() { # time_step <tên bước> <lệnh> [đối số...]
  local name="$1" started=$SECONDS rc
  shift
  if "$@"; then rc=0; else rc=$?; fi
  printf '[time] %s %ss\n' "$name" "$((SECONDS - started))"
  return "$rc"
}

echo "=== Lean AI Engineering Verification ==="

if [ -f "be/go.mod" ]; then
  static_started=$SECONDS
  echo "[be] formatting"
  test -z "$(gofmt -l be)" || { rc=$?; printf '[time] be-static %ss\n' "$((SECONDS - static_started))"; exit "$rc"; }
  echo "[be] vet"
  (cd be && go vet ./...) || { rc=$?; printf '[time] be-static %ss\n' "$((SECONDS - static_started))"; exit "$rc"; }
  echo "[be] build"
  (cd be && go build ./...) || { rc=$?; printf '[time] be-static %ss\n' "$((SECONDS - static_started))"; exit "$rc"; }
  echo "[be] scripts/check-sqlcgen.sh"
  "$(cd "$(dirname "$0")" && pwd)"/check-sqlcgen.sh || { rc=$?; printf '[time] be-static %ss\n' "$((SECONDS - static_started))"; exit "$rc"; }
  printf '[time] be-static %ss\n' "$((SECONDS - static_started))"
  if [ -n "$(git status --porcelain --untracked-files=all -- be db compose.yaml scripts/be-check.sh)" ]; then
    echo "[be] scripts/be-check.sh"
    time_step be-check "$(cd "$(dirname "$0")" && pwd)"/be-check.sh
  else
    echo "[be] skipped — nothing under be/, db/, compose.yaml or scripts/be-check.sh changed"
  fi
else
  echo "[be] skipped — no be/go.mod"
fi

if [ -f "fe/package.json" ]; then
  echo "[fe] scripts/check-fe-rules.sh"
  time_step fe-rules "$(cd "$(dirname "$0")" && pwd)"/check-fe-rules.sh
  if [ -n "$(git status --porcelain --untracked-files=all -- fe docs/product/3-be/openapi.yaml scripts/fe-check.sh scripts/check-fe-rules.sh)" ]; then
    echo "[fe] scripts/fe-check.sh"
    time_step fe-check "$(cd "$(dirname "$0")" && pwd)"/fe-check.sh
  else
    echo "[fe] skipped — nothing under fe/, docs/product/3-be/openapi.yaml, scripts/fe-check.sh or scripts/check-fe-rules.sh changed"
  fi
else
  echo "[fe] skipped — no fe/package.json"
fi

if [ -f "package.json" ]; then
  echo "[Node] package scripts"
  if command -v npm >/dev/null 2>&1; then
    node_started=$SECONDS
    npm test --if-present || { rc=$?; printf '[time] node %ss\n' "$((SECONDS - node_started))"; exit "$rc"; }
    npm run lint --if-present || { rc=$?; printf '[time] node %ss\n' "$((SECONDS - node_started))"; exit "$rc"; }
    npm run build --if-present || { rc=$?; printf '[time] node %ss\n' "$((SECONDS - node_started))"; exit "$rc"; }
    printf '[time] node %ss\n' "$((SECONDS - node_started))"
  fi
fi

# Database (docs/product/2-db/10-quy-uoc-code.md QC-07): chạy bộ kiểm khi lượt
# này đổi gì dưới db/, compose.yaml, scripts/db-check.sh, scripts/reconcile.sh
# (bộ đối chiếu P2-11 — db-check chứng minh nó) hay docs/product/2-db/.
# Không có Docker thì db-check.sh tự FAIL — không bỏ qua.
if [ -d db ] && [ -n "$(git status --porcelain --untracked-files=all -- db compose.yaml scripts/db-check.sh scripts/reconcile.sh docs/product/2-db 2>/dev/null)" ]; then
  echo "[db] scripts/db-check.sh"
  time_step db-check "$(cd "$(dirname "$0")" && pwd)"/db-check.sh
else
  echo "[db] skipped — nothing under db/, compose.yaml, scripts/db-check.sh, scripts/reconcile.sh or docs/product/2-db/ changed"
fi

# Bảng file test → đầu vào NGOÀI scripts/ đọc từ repo thật. Không có nhánh
# nghĩa là test chỉ đọc script/fixture; brief.test.sh/E7 chỉ đo trạng thái.
test_input_changed() { # test_input_changed <tên file test>
  case "$1" in
    fe-check.test.sh)          # fe/ thật và hợp đồng API thật
      set -- fe/ docs/product/3-be/openapi.yaml ;;
    check-write-paths.test.sh) # chạy check-write-paths.sh trên cây be/ và migration thật
      set -- be/ db/migrations/ ;;
    check-sqlcgen.test.sh)     # chép go.mod, go.sum và dùng migration thật
      set -- be/go.mod be/go.sum db/migrations/ ;;
    reconcile.test.sh)         # chép QD thật vào fixture
      set -- db/reconcile/qd.sql ;;
    be-check.test.sh)          # chép owner QC-17 và invariant thật vào fixture
      set -- docs/product/2-db/10-quy-uoc-code.md quality/invariants.md ;;
    *) return 1 ;;
  esac
  [ -n "$(git status --porcelain --untracked-files=all -- "$@")" ]
}

scripts_changed="$(git status --porcelain --untracked-files=all -- scripts/)"
tests_to_run=()
tests_to_run_count=0
skipped_tests=0
for t in "$(cd "$(dirname "$0")" && pwd)"/*.test.sh; do
  [ -f "$t" ] || continue
  if [ -n "$scripts_changed" ] || test_input_changed "${t##*/}"; then
    tests_to_run+=("$t")
    tests_to_run_count=$((tests_to_run_count + 1))
  else
    skipped_tests=$((skipped_tests + 1))
  fi
done
if [ "$skipped_tests" -gt 0 ]; then
  printf '[test] skipped — %s file: không có gì dưới scripts/ đổi và đầu vào riêng của chúng không đổi\n' "$skipped_tests"
fi
if [ "$tests_to_run_count" -gt 0 ]; then
  for t in "${tests_to_run[@]}"; do
    echo "[test] $t"
    time_step "test:${t##*/}" "$t"
  done
fi

echo "Verification passed."
