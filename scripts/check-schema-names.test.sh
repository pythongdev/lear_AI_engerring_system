#!/usr/bin/env bash
# Test cho Gate 1e (scripts/check-schema-names.sh, P2-09).
#
# Chạy tay:  ./scripts/check-schema-names.test.sh
# verify.sh tự chạy mọi scripts/*.test.sh.
#
# Mỗi ca dựng hai thư mục tạm (migration · tài liệu) và trỏ script vào đó bằng
# SCHEMA_NAMES_MIG_DIR · SCHEMA_NAMES_DOC_DIR — không đụng cây thật. Mỗi chiều
# lệch phải đỏ (biết kêu), và các dạng không phải tên bảng phải im (không kêu oan).

set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-schema-names.sh"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT
fails=0

newcase() { # newcase <tên> → in đường dẫn; tạo mig/ và doc/ rỗng
  mkdir -p "$TMPROOT/$1/mig" "$TMPROOT/$1/doc"
  printf '%s' "$TMPROOT/$1"
}

run() { # run <ca> → in "<exit>|<output một dòng>"
  local out rc
  out="$(SCHEMA_NAMES_MIG_DIR="$1/mig" SCHEMA_NAMES_DOC_DIR="$1/doc" "$SCRIPT" 2>&1)"
  rc=$?
  printf '%s|%s' "$rc" "$(printf '%s' "$out" | tr '\n' ' ')"
}

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

base() { # base <ca> — hai bảng, tài liệu nhắc cả hai theo hai dạng
  cat > "$1/mig/20260101000000_a.up.sql" <<'EOF'
CREATE TABLE dining_table (id bigint);
CREATE TABLE sales_order (id bigint, status text);
EOF
  cat > "$1/doc/02-lat.md" <<'EOF'
| Bảng | Giữ gì |
|---|---|
| `dining_table` | một cái bàn |

Trạng thái đơn ở `sales_order.status`.
EOF
}

# 1 — khớp ⇒ đạt, và in cả hai danh sách (F-017)
c="$(newcase khop)"; base "$c"
got="$(run "$c")"
check "khớp: đạt" 0 "comm -3: (rỗng)" "$got"
check "khớp: in danh sách migration" 0 "migration (" "$got"
check "khớp: in danh sách tài liệu" 0 "tài liệu (" "$got"

# 2 — migration có bảng tài liệu không nhắc ⇒ đỏ
c="$(newcase thieu_tai_lieu)"; base "$c"
echo "CREATE TABLE refund (id bigint);" >> "$c/mig/20260101000000_a.up.sql"
check "migration có, tài liệu không nhắc: đỏ" 1 "chỉ migration có, tài liệu không nhắc: refund" "$(run "$c")"

# 3 — tài liệu nhắc `bảng.cột` của một bảng không tồn tại ⇒ đỏ
c="$(newcase ma_cot)"; base "$c"
echo 'Cột `pin_code.hash` giữ mã.' >> "$c/doc/02-lat.md"
check "tài liệu nhắc bảng.cột không có: đỏ" 1 "chỉ tài liệu nhắc, migration không có: pin_code" "$(run "$c")"

# 4 — một hàng của bảng "Bảng · cột" nêu bảng không tồn tại ⇒ đỏ
c="$(newcase ma_hang)"; base "$c"
printf '\n| Bảng · cột | Nhận gì |\n|---|---|\n| `ghost_table` — ràng buộc thêm | x |\n' >> "$c/doc/02-lat.md"
check "hàng bảng Bảng nêu bảng không có: đỏ" 1 "chỉ tài liệu nhắc, migration không có: ghost_table" "$(run "$c")"

# 5 — migration sau DROP bảng mà tài liệu còn nhắc ⇒ đỏ
c="$(newcase drop)"; base "$c"
echo "DROP TABLE sales_order;" > "$c/mig/20260102000000_b.up.sql"
check "bảng đã DROP mà tài liệu còn nhắc: đỏ" 1 "chỉ tài liệu nhắc, migration không có: sales_order" "$(run "$c")"

# 6 — RENAME: tên mới phải là tên tài liệu nhắc
c="$(newcase rename)"; base "$c"
echo "ALTER TABLE sales_order RENAME TO customer_order;" > "$c/mig/20260102000000_b.up.sql"
got="$(run "$c")"
check "RENAME: tên mới chỉ ở migration" 1 "chỉ migration có, tài liệu không nhắc: customer_order" "$got"
check "RENAME: tên cũ chỉ ở tài liệu" 1 "chỉ tài liệu nhắc, migration không có: sales_order" "$got"

# 7 — file lùi không được tính: DROP trong .down.sql không bớt bảng
c="$(newcase down)"; base "$c"
echo "DROP TABLE sales_order, dining_table;" > "$c/mig/20260101000000_a.down.sql"
check "DROP trong file lùi không tính" 0 "comm -3: (rỗng)" "$(run "$c")"

# 8 — không kêu oan: tên file, schema, chú thích SQL
c="$(newcase im)"; base "$c"
echo 'Xem `compose.yaml`, `i001_x.sql`, `go.mod`, `shop.actor_person_id`, `public.schema_migrations`.' >> "$c/doc/02-lat.md"
echo "-- CREATE TABLE old_idea (id bigint);" >> "$c/mig/20260101000000_a.up.sql"
check "tên file · schema · chú thích SQL: im" 0 "comm -3: (rỗng)" "$(run "$c")"

# 9 — F-017: có file migration mà không đọc ra bảng nào ⇒ đỏ, không "rỗng nên đạt"
c="$(newcase loc_sai)"; base "$c"
echo "ALTER TABLE x ADD COLUMN y int;" > "$c/mig/20260101000000_a.up.sql"
check "có file mà danh sách rỗng: đỏ" 1 "không đọc ra bảng nào" "$(run "$c")"

# 10 — chưa có gì để so ⇒ skipping, exit 0
c="$(newcase rong)"
check "chưa có file nào: skipping" 0 "skipping" "$(run "$c")"

if [ "$fails" -ne 0 ]; then
  echo "check-schema-names.test: FAIL ($fails ca)"
  exit 1
fi
echo "check-schema-names.test: OK"
