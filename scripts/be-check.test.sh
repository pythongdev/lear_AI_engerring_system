#!/usr/bin/env bash
# Test cho phép kiểm QC-17 trong scripts/be-check.sh (F-061, T-148).
#
# Chạy tay:  ./scripts/be-check.test.sh
# verify.sh tự chạy mọi scripts/*.test.sh.
#
# Mỗi ca dựng một repo git tạm chứa be-check.sh, owner QC-17
# (docs/product/2-db/10-quy-uoc-code.md) và quality/invariants.md thật, cùng một be/ giả,
# rồi chạy "be-check.sh --names-only" — không Docker, không đụng cây thật. Tên sai
# phải đỏ (phép chấm chưa bao giờ đỏ là phép chấm chưa được chứng minh), tên đúng phải im.

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT
fails=0

mkrepo() { # mkrepo <thư mục> — repo tạm với script và hai owner thật
  local d="$1"
  mkdir -p "$d/scripts" "$d/docs/product/2-db" "$d/quality" "$d/be/internal/x"
  cp "$ROOT/scripts/be-check.sh" "$d/scripts/"
  cp "$ROOT/docs/product/2-db/10-quy-uoc-code.md" "$d/docs/product/2-db/"
  cp "$ROOT/quality/invariants.md" "$d/quality/"
  git -C "$d" init -q
}

check() { # check <tên ca> <exit mong đợi> <chuỗi phải có> <thư mục>
  local name="$1" want_rc="$2" want_txt="$3" d="$4" out rc
  out="$(cd "$d" && ./scripts/be-check.sh --names-only 2>&1)"
  rc=$?
  out="$(printf '%s' "$out" | tr '\n' ' ')"
  if [ "$rc" = "$want_rc" ] && [[ "$out" == *"$want_txt"* ]]; then
    echo "  ok   $name (exit $rc)"
  else
    echo "  FAIL $name — mong đợi exit $want_rc + \"$want_txt\", nhận exit $rc: $out"
    fails=$((fails + 1))
  fi
}

d="$TMPROOT/dung"; mkrepo "$d"
printf 'package x\nfunc TestMain(m *testing.M) {}\nfunc TestI020_HopLe(t *testing.T) {}\nfunc TestQC17_HopLe(t *testing.T) {}\n' > "$d/be/internal/x/x_test.go"
check "tên mang mã ⇒ xanh" 0 "PASS be-check QC-17" "$d"

d="$TMPROOT/saiten"; mkrepo "$d"
printf 'package x\nfunc TestSaiTen(t *testing.T) {}\n' > "$d/be/internal/x/x_test.go"
check "TestSaiTen ⇒ đỏ, nêu tên" 1 "TestSaiTen" "$d"

d="$TMPROOT/khongco"; mkrepo "$d"
printf 'package x\nfunc TestI999_KhongCoMenhDe(t *testing.T) {}\n' > "$d/be/internal/x/x_test.go"
check "mã I không có ở invariants ⇒ đỏ" 1 "không có I-999" "$d"

d="$TMPROOT/mattaiLieu"; mkrepo "$d"
printf '# rỗng\n' > "$d/docs/product/2-db/10-quy-uoc-code.md"
check "owner mất khối QC-17 ⇒ đỏ, không im" 1 "không đọc được khối phép kiểm QC-17" "$d"

# Chạy riêng cleanup_on_exit trong subshell: nhánh giữ không gọi Docker.
run_keep_cleanup() { # run_keep_cleanup <repo tạm> <project>
  (
    cd "$1" || exit 1
    eval "$(sed -n '/^cleanup_on_exit() {$/,/^}$/p' "$ROOT/scripts/be-check.sh")"
    PROJECT="$2"
    keep_db=1
    BANHCUON_TEST_OWNER_DSN=owner-test
    BANHCUON_TEST_APP_DSN=app-test
    false
    cleanup_on_exit
  ) 2>&1
}

project=banhcuon_check_123_be_1700000000_42
d="$TMPROOT/giulai"; mkdir -p "$d"; git -C "$d" init -q
out="$(run_keep_cleanup "$d" "$project")"; rc=$?
marker="$d/.git/lean-ai-kept-db/$project"
if [ "$rc" = 1 ] && [ -f "$marker" ] && [ ! -s "$marker" ] &&
   [[ "$out" == *"rm -f -- .git/lean-ai-kept-db/$project"* ]]; then
  echo "  ok   giữ database ⇒ tạo dấu rỗng và in lệnh dọn (exit $rc)"
else
  echo "  FAIL giữ database — exit $rc, dấu: $marker, output: $out"
  fails=$((fails + 1))
fi

d="$TMPROOT/khongtaodau"; mkdir -p "$d"; git -C "$d" init -q
: > "$d/.git/lean-ai-kept-db"
out="$(run_keep_cleanup "$d" "$project")"; rc=$?
if [ "$rc" = 1 ] && [[ "$out" == *"NOTE be-check — không tạo được dấu giữ"* ]] &&
   [[ "$out" == *"BE_CHECK_KEEP_DB=1, giữ database lúc đỏ"* ]]; then
  echo "  ok   không tạo được dấu ⇒ báo NOTE và vẫn giữ database (exit $rc)"
else
  echo "  FAIL không tạo được dấu — exit $rc, output: $out"
  fails=$((fails + 1))
fi

if [ "$fails" -eq 0 ]; then
  echo "be-check.test: PASS"
else
  echo "be-check.test: FAIL — $fails ca"
  exit 1
fi
