#!/usr/bin/env bash
# Bộ kiểm backend — QC-15 · QC-16, Gate 1 gọi qua scripts/verify.sh.
# Vì sao: chứng minh vai và múi giờ qua chính hàm kết nối trên PostgreSQL thật.
# Dựng database riêng, rỗng; migrate từ số 0 rồi go test; chỉ gỡ project của mình.
# F-045: tên chứa PID, khớp khuôn dọn rác của db-check, không dùng chung database.
# Không Docker hoặc database không lên ⇒ FAIL, không bỏ qua.
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 1
cd "$ROOT" || exit 1
PROJECT="banhcuon_check_$$_be_$(date +%s)_${RANDOM}"
export DB_PORT=0
unset PGTZ PGOPTIONS
compose() { docker compose -p "$PROJECT" "$@"; }
cleanup_on_exit() {
  local status=$?
  trap - EXIT
  trap '' INT TERM
  compose down -v --remove-orphans >/dev/null 2>&1
  exit "$status"
}
if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
  echo "be-check: FAIL — Docker không chạy. Bật Docker rồi chạy lại ./scripts/be-check.sh"
  exit 1
fi
SHOP_TZ="$(grep -m1 '^| Múi giờ |' master_plan/shop-facts.md | grep -o '`[^`]*`' | head -1 | tr -d '`')"
if [ -z "$SHOP_TZ" ]; then
  echo "be-check: FAIL — không đọc được múi giờ ở master_plan/shop-facts.md §1"
  exit 1
fi
trap cleanup_on_exit EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
echo "NOTE be-check — compose project $PROJECT"
if ! compose up -d --wait db; then
  compose logs db 2>&1 | tail -20
  echo "be-check: FAIL — database không lên"
  exit 1
fi
if ! compose run --rm migrate up; then
  echo "be-check: FAIL — migration không chạy được"
  exit 1
fi
if ! address="$(compose port db 5432)"; then
  echo "be-check: FAIL — không đọc được cổng database"
  exit 1
fi
port="${address##*:}"
if ! [[ "$port" =~ ^[0-9]+$ ]]; then
  echo "be-check: FAIL — cổng database không hợp lệ: $address"
  exit 1
fi
export BANHCUON_TEST_APP_DSN="postgres://shop_app:shop_app_dev@127.0.0.1:$port/banhcuon?sslmode=disable"
export BANHCUON_TEST_OWNER_DSN="postgres://shop_owner:shop_owner_dev@127.0.0.1:$port/banhcuon?sslmode=disable"
export BANHCUON_SHOP_TZ="$SHOP_TZ"
if (cd be && go test -count=1 -p 1 -v ./...); then
  echo "be-check: PASS — mọi test backend qua PostgreSQL thật đều đạt"
else
  echo "be-check: FAIL — test backend không đạt"
  exit 1
fi
