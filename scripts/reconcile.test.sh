#!/usr/bin/env bash
# Test --codes của reconcile.sh (T-123), không cần Docker.
# Ba biến RECONCILE_* trỏ vào dữ liệu tạm; verify.sh tự chạy file này.
set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")" && pwd)/reconcile.sh"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT
fails=0
newcase() {
  mkdir -p "$TMPROOT/$1/queries"
  # Giữ nguyên QD; chỉ thay bộ mã I của từng ca.
  cp "$ROOT/db/reconcile/qd.sql" "$TMPROOT/$1/queries/qd.sql"
  printf '### I-001\n' > "$TMPROOT/$1/invariants.md"
  printf '%s\n' '-- @@ I-001/1 — mẫu' 'SELECT 1;' > "$TMPROOT/$1/queries/i001.sql"
  printf '## 2. Tập chưa có câu\n### 2.1 Mệnh đề chưa có lát — cả mệnh đề chưa có câu\n' > "$TMPROOT/$1/09-doi-chieu-bat-bien.md"
  printf '%s' "$TMPROOT/$1"
}
run() {
  local out rc
  out="$(RECONCILE_INVARIANTS="$1/invariants.md" RECONCILE_QUERY_DIR="$1/queries" \
    RECONCILE_DOC="$1/09-doi-chieu-bat-bien.md" "$SCRIPT" --codes 2>&1)"
  rc=$?
  printf '%s|%s' "$rc" "$(printf '%s' "$out" | tr '\n' ' ')"
}
row() { printf '| %s | chưa có lát | %s | %s |\n' "$2" "$3" "$4" >> "$1/09-doi-chieu-bat-bien.md"; }
missing() { printf '### I-002\n' >> "$1/invariants.md"; }
check() { # check <tên ca> <exit mong đợi> <chuỗi phải có trong output> <kết quả run>
  local name="$1" want_rc="$2" want_txt="$3" got="$4"
  local rc="${got%%|*}" out="${got#*|}"
  if [ "$rc" = "$want_rc" ] && [[ "$out" == *"$want_txt"* ]]; then
    echo "  ok   $name (exit $rc)"
  else
    echo "  FAIL $name — mong đợi exit $want_rc + \"$want_txt\", nhận exit $rc: $out"
    fails=$((fails + 1))
  fi
}

c="$(newcase all)"
check "mọi mã có câu, L rỗng" 0 "PASS mã I-0xx" "$(run "$c")"
c="$(newcase pending)"; missing "$c"; row "$c" '`I-002`' 'chưa dựng' '`P2A-07`'
got="$(run "$c")"
check "(a) NOTE gọi mã và người nợ" 0 'NOTE I-002 chưa có lát — ai nợ: `P2A-07`' "$got"
check "PASS đếm cả hai nhóm" 0 '1 mã có câu + 1 mã chưa có lát = 2 mã' "$got"
c="$(newcase absent)"; missing "$c"
check "(b) thiếu câu ngoài danh sách" 1 'FAIL mã I-0xx — I-002 chưa có câu' "$(run "$c")"
c="$(newcase expired)"; row "$c" '`I-001`' 'chưa dựng' '`P2A-07`'
check "(c) dòng hết hạn phải gỡ" 1 'I-001 đã có câu, dòng hết hạn — gỡ dòng ở' "$(run "$c")"
c="$(newcase unknown)"; row "$c" '`I-002`' 'chưa dựng' '`P2A-07`'
check "(d) mã ngoài invariant" 1 'FAIL mã I-0xx — I-002 không có ở' "$(run "$c")"
for field in owner reason; do
  for value in '' '—'; do
    c="$(newcase "empty_${field}_${value:-blank}")"; missing "$c"
    if [ "$field" = owner ]; then row "$c" '`I-002`' 'chưa dựng' "$value"
    else row "$c" '`I-002`' "$value" '`P2A-07`'; fi
    check "(e) $field = ${value:-rỗng}" 1 'I-002 thiếu vì sao hoặc ai nợ' "$(run "$c")"
  done
done
for code in 'I-002' '`I-002` tập 3' '`I-002` `I-003`' '`I-100`' ''; do
  c="$(newcase malformed)"; missing "$c"; row "$c" "$code" 'chưa dựng' '`P2A-07`'
  check "(e) sai mã: $code" 1 'dòng chưa có lát sai mã/cột' "$(run "$c")"
done
c="$(newcase neighbor)"; missing "$c"; printf '### I-003\n' >> "$c/invariants.md"
row "$c" '`I-002`' 'chưa dựng' '`P2A-07`'
check "không miễn trừ mã đứng cạnh" 1 'FAIL mã I-0xx — I-003 chưa có câu' "$(run "$c")"
c="$(newcase old_table)"; printf '### I-003\n' >> "$c/invariants.md"
printf '%s\n' '## 2. Tập chưa có câu' '| `I-003` tập 3 — bàn kẹt | chưa có câu | lý do | pha 3 |' \
  '### 2.1 Mệnh đề chưa có lát — cả mệnh đề chưa có câu' > "$c/09-doi-chieu-bat-bien.md"
check "bảng tập §2 không miễn trừ mệnh đề" 1 'FAIL mã I-0xx — I-003 chưa có câu' "$(run "$c")"
c="$(newcase extra_query)"; printf '%s\n' '-- @@ I-002/1 — mẫu' 'SELECT 1;' > "$c/queries/i002.sql"
check "(f) câu ngoài invariant" 1 'I-002 có câu nhưng không có ở' "$(run "$c")"
c="$(newcase missing_doc)"; missing "$c"; rm "$c/09-doi-chieu-bat-bien.md"
check "vắng file 09 vẫn đỏ" 1 'FAIL mã I-0xx — I-002 chưa có câu' "$(run "$c")"
c="$(newcase missing_section)"; missing "$c"
printf '%s\n' '## 2. Tập chưa có câu' > "$c/09-doi-chieu-bat-bien.md"
row "$c" '`I-002`' 'chưa dựng' '`P2A-07`'
check "vắng §2.1 vẫn đỏ" 1 'FAIL mã I-0xx — I-002 chưa có câu' "$(run "$c")"
c="$(newcase outside_section)"; missing "$c"
printf '\n---\n## 3. Khác\n' >> "$c/09-doi-chieu-bat-bien.md"
row "$c" '`I-002`' 'chưa dựng' '`P2A-07`'
check "không đọc dòng ngoài §2.1" 1 'FAIL mã I-0xx — I-002 chưa có câu' "$(run "$c")"
if [ "$fails" -ne 0 ]; then
  echo "reconcile.test: FAIL ($fails ca)"
  exit 1
fi
echo "reconcile.test: OK"
