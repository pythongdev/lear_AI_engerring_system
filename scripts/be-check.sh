#!/usr/bin/env bash
# Bộ kiểm backend — QC-15 · QC-16, Gate 1 gọi qua scripts/verify.sh.
# T-323 lát 2, ADR-144 (2026-11-12): mỗi gói Go có test nhận một database
# sao từ banhcuon đã migrate; không gói nào chạy trên database mẫu.
# Vì sao: chứng minh vai và múi giờ qua chính hàm kết nối trên PostgreSQL thật.
# Dựng database mẫu riêng, rỗng; migrate từ số 0 rồi test từng gói; chỉ gỡ project của mình.
# F-045: tên chứa PID, khớp khuôn dọn rác của db-check, không dùng chung database.
# Không Docker hoặc database không lên ⇒ FAIL, không bỏ qua.
# QC-17 (F-061): chạy các khối phép kiểm sh dưới "### QC-17" của
# docs/product/2-db/10-quy-uoc-code.md, đọc từ owner lúc chạy, trước khi dựng database;
# một dòng output ⇒ FAIL. Nhờ vậy lượt chỉ đổi be/ cũng bị chấm tên test.
#   ./scripts/be-check.sh --names-only   chỉ chạy phép kiểm QC-17 (scripts/be-check.test.sh dùng).
# BE_CHECK_KEEP_DB=1: test đỏ ⇒ không gỡ compose project, in tên project, DSN chủ
# của từng gói đỏ và lệnh dọn
# "docker compose -p <project> down -v" để điều tra database lúc lỗi. Mặc định (không đặt,
# hay mọi giá trị khác 1) và mọi đường khác (xanh, migrate hỏng, Ctrl-C) vẫn gỡ như cũ (F-045).
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 1
cd "$ROOT" || exit 1
QC_OWNER="docs/product/2-db/10-quy-uoc-code.md"
qc17_blocks="$(awk '
  /^## /                      { code="" }
  /^### /                     { code=($2=="QC-17") }
  code && !inb && /^ *```sh *$/ { inb=1; body=""; next }
  inb && /^ *``` *$/          { printf "%s\036", body; inb=0; next }
  inb                         { body = body $0 "\n" }
' "$QC_OWNER" 2>/dev/null)"
if [ -z "$qc17_blocks" ]; then
  echo "be-check: FAIL — không đọc được khối phép kiểm QC-17 ở $QC_OWNER"
  exit 1
fi
qc17_out=""
while IFS= read -r -d $'\036' body; do
  qc17_out="$qc17_out$(bash -c "$body" </dev/null 2>&1)"
done <<<"$qc17_blocks"
if [ -n "$qc17_out" ]; then
  echo "be-check: FAIL — QC-17 tên test không mang mã mệnh đề ($QC_OWNER):"
  printf '%s\n' "$qc17_out" | sed 's/^/     /'
  exit 1
fi
echo "PASS be-check QC-17 — mọi tên test mang mã mệnh đề"
[ "${1:-}" = "--names-only" ] && exit 0
PROJECT="banhcuon_check_$$_be_$(date +%s)_${RANDOM}"
export DB_PORT=0
unset PGTZ PGOPTIONS
compose() { docker compose -p "$PROJECT" "$@"; }
keep_db=0
cleanup_on_exit() {
  local status=$?
  trap - EXIT
  trap '' INT TERM
  if [ "$keep_db" = 1 ]; then
    local kept_dir kept_marker
    kept_dir="$(git rev-parse --git-common-dir)/lean-ai-kept-db"
    kept_marker="$kept_dir/$PROJECT"
    if mkdir -p "$kept_dir" 2>/dev/null && : > "$kept_marker" 2>/dev/null; then
      :
    else
      echo "NOTE be-check — không tạo được dấu giữ $kept_marker; database vẫn giữ nhưng db-check có thể dọn lượt sau"
    fi
    echo "NOTE be-check — BE_CHECK_KEEP_DB=1, giữ database lúc đỏ: project $PROJECT"
    printf '%s' "${failed_owner_dsns:-}"
    printf '     dọn khi xong: docker compose -p %s down -v && rm -f -- %q\n' "$PROJECT" "$kept_marker"
    exit "$status"
  fi
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
export BANHCUON_SHOP_TZ="$SHOP_TZ"
if ! packages="$(cd be && go list -f '{{if or .TestGoFiles .XTestGoFiles}}{{.ImportPath}}{{end}}' ./... | sed '/^$/d')"; then
  echo "be-check: FAIL — go list không liệt kê được gói test"
  exit 1
fi
if [ -z "$packages" ]; then
  echo "be-check: FAIL — go list không tìm thấy gói có test"
  exit 1
fi
expected_count="$(printf '%s\n' "$packages" | wc -l | tr -d '[:space:]')"

package_count=0
created_count=0
failed_count=0
failed_summary=""
failed_owner_dsns=""
record_failure() {
  failed_count=$((failed_count + 1))
  failed_summary="${failed_summary}${failed_summary:+, }$pkg ($dbname)"
  failed_owner_dsns="${failed_owner_dsns}     DSN chủ $pkg ($dbname): $BANHCUON_TEST_OWNER_DSN"$'\n'
}
while IFS= read -r pkg <&3; do
  package_count=$((package_count + 1))
  printf -v dbname 'banhcuon_g%03d' "$package_count"
  export BANHCUON_TEST_APP_DSN="postgres://shop_app:shop_app_dev@127.0.0.1:$port/$dbname?sslmode=disable"
  export BANHCUON_TEST_OWNER_DSN="postgres://shop_owner:shop_owner_dev@127.0.0.1:$port/$dbname?sslmode=disable"

  if ! compose exec -T db psql -U shop_owner -d postgres -v ON_ERROR_STOP=1 \
    -c "CREATE DATABASE $dbname TEMPLATE banhcuon" \
    -c "REVOKE ALL ON DATABASE $dbname FROM PUBLIC" \
    -c "GRANT CONNECT ON DATABASE $dbname TO shop_app" </dev/null; then
    echo "be-check: FAIL — không tạo hoặc cấp quyền database $dbname cho gói $pkg"
    record_failure
    continue
  fi
  created_count=$((created_count + 1))
  if ! (cd be && go test -count=1 -v "$pkg" </dev/null); then
    echo "be-check: FAIL — test gói $pkg trên database $dbname không đạt"
    record_failure
  fi
done 3<<< "$packages"

if [ "$package_count" -ne "$expected_count" ]; then
  echo "be-check: FAIL — chỉ xử lý $package_count/$expected_count gói"
  [ "${BE_CHECK_KEEP_DB:-}" = 1 ] && keep_db=1
  exit 1
fi

if [ "$failed_count" -eq 0 ]; then
  echo "be-check: PASS — mọi test backend qua PostgreSQL thật đều đạt ($package_count/$expected_count gói, $created_count database)"
else
  echo "be-check: FAIL — $failed_count/$package_count gói đỏ: $failed_summary"
  [ "${BE_CHECK_KEEP_DB:-}" = 1 ] && keep_db=1
  exit 1
fi
