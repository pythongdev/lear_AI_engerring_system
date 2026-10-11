#!/usr/bin/env bash
# Test cho Gate 1f (scripts/check-write-paths.sh, P3-03, ADR-082 điểm 3, ADR-083).
#
# Chạy tay:  ./scripts/check-write-paths.test.sh
# verify.sh tự chạy mọi scripts/*.test.sh.
#
# Mỗi ca dựng hai thư mục tạm (be · migration) và trỏ script vào đó bằng
# WRITE_PATHS_BE_DIR · WRITE_PATHS_MIG_DIR — không đụng cây thật. Mỗi cách đi vòng
# một cửa phải đỏ (ADR-082 điểm 7 luật 3: phép chấm chưa bao giờ đỏ là phép chấm
# chưa được chứng minh), và các dạng không phải câu ghi phải im (không kêu oan).
# Claude viết các ca này TRƯỚC khi có script (docs/prompt-guideline.md §6.1).

set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-write-paths.sh"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT
fails=0
TAB="$(printf '\t')"

run() { # run <ca> [cờ…] → in "<exit>|<output một dòng>"
  local c="$1" out rc; shift
  out="$(WRITE_PATHS_BE_DIR="$c/be" WRITE_PATHS_MIG_DIR="$c/mig" "$SCRIPT" "$@" 2>&1)"
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

put() { # put <đường dẫn> — ghi stdin vào file, tạo thư mục cha
  mkdir -p "$(dirname "$1")"
  cat > "$1"
}

base() { # base <tên ca> → in đường dẫn ca; ba cửa, sáu ô ghi, và các dạng phải im
  local c="$TMPROOT/$1"
  put "$c/mig/20260101000000_a.up.sql" <<'EOF'
CREATE TABLE sales_order (id bigint, status text, note text);
CREATE TABLE order_line (id bigint, qty integer);
CREATE TABLE menu_item (id bigint, name text, price_vnd bigint);
-- Bảng vết: chỉ hàm trigger dưới đây ghi (ô thuộc migration).
CREATE TABLE audit_log (id bigint, what text);
CREATE FUNCTION audit_capture() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO audit_log (what) VALUES (TG_TABLE_NAME);
  RETURN NULL;
END $$;
-- Bảng mà vai ghi bị thu hồi quyền thêm · sửa (ô thuộc migration).
CREATE TABLE price_snapshot (id bigint, amount_vnd bigint);
REVOKE INSERT, UPDATE ON price_snapshot FROM shop_app;
EOF
  put "$c/be/internal/order/sql/create_order/insert_order.sql" <<'EOF'
INSERT INTO shop.sales_order (status) VALUES ($1) RETURNING id;
EOF
  put "$c/be/internal/order/sql/create_order/insert_line.sql" <<'EOF'
insert into order_line (qty) values ($1);
EOF
  put "$c/be/internal/order/sql/change_status/update_status.sql" <<'EOF'
-- UPDATE ghost SET x = 1 — chú thích, không phải câu ghi
UPDATE shop.sales_order AS o
   SET status = $2,
       note = coalesce($3, o.note)
 WHERE o.id = $1;
EOF
  put "$c/be/internal/order/sql/read_order.sql" <<'EOF'
SELECT id, status FROM sales_order WHERE note <> 'INSERT INTO ghost (x) VALUES (1)';
EOF
  put "$c/be/internal/menu/sql/upsert_item/upsert.sql" <<'EOF'
INSERT INTO menu_item (id, name, price_vnd) VALUES ($1, $2, $3)
ON CONFLICT (id) DO UPDATE SET price_vnd = EXCLUDED.price_vnd;
EOF
  put "$c/be/internal/order/order.go" <<'EOF'
package order

// Đọc đơn và giữ khoá dòng — câu đọc, không phải câu ghi.
const readForUpdate = "SELECT id FROM sales_order WHERE id = $1 FOR UPDATE"
EOF
  put "$c/be/internal/order/order_test.go" <<'EOF'
package order

// Test dựng trạng thái bằng tay — file test không phải đường ghi của backend.
const cleanup = "DELETE FROM sales_order; INSERT INTO order_line (qty) VALUES (1)"
EOF
  put "$c/be/internal/order/testdata/fixture.sql" <<'EOF'
INSERT INTO ghost_table (x) VALUES (1);
EOF
  printf '%s' "$c"
}

# 1 — không có be/ ⇒ không có gì để soát
c="$TMPROOT/khong_be"; mkdir -p "$c/mig"
check "không có be/: bỏ qua" 0 "skipping" "$(run "$c")"

# 2 — cây đúng ⇒ đạt, đếm đúng ô và cửa (F-017: con số cho thấy nó đã đọc)
c="$(base dung)"
got="$(run "$c")"
check "cây đúng: đạt" 0 "PASS" "$got"
check "cây đúng: 6 ô ghi" 0 "6 ô ghi" "$got"
check "cây đúng: 3 cửa" 0 "3 cửa" "$got"

# 3 — --list in bảng ô → cửa, mỗi dòng: bảng · loại · cột (hay -) · cửa, cách bằng tab
c="$(base liet_ke)"
got="$(run "$c" --list)"
check "--list: sửa cột qua UPDATE nhiều dòng" 0 "sales_order${TAB}sửa${TAB}status${TAB}order/change_status" "$got"
check "--list: cột thứ hai của cùng SET" 0 "sales_order${TAB}sửa${TAB}note${TAB}order/change_status" "$got"
check "--list: thêm dòng, schema shop. bị bỏ" 0 "sales_order${TAB}thêm${TAB}-${TAB}order/create_order" "$got"
check "--list: chữ thường vẫn là câu ghi" 0 "order_line${TAB}thêm${TAB}-${TAB}order/create_order" "$got"
check "--list: ON CONFLICT DO UPDATE là ô sửa" 0 "menu_item${TAB}sửa${TAB}price_vnd${TAB}menu/upsert_item" "$got"

# 4 — HỒI QUY CHÍNH: cài một đường ghi thứ hai tới một ô đã có cửa ⇒ đỏ, nêu cả hai cửa
c="$(base hai_cua)"
put "$c/be/internal/billing/sql/close_bill/set_status.sql" <<'EOF'
UPDATE sales_order SET status = 'paid' WHERE id = $1;
EOF
got="$(run "$c")"
check "đường ghi thứ hai: đỏ" 1 "hai cửa" "$got"
check "đường ghi thứ hai: nêu cửa mới" 1 "billing/close_bill" "$got"
check "đường ghi thứ hai: nêu cửa cũ" 1 "order/change_status" "$got"

# 5 — câu ghi trong chuỗi Go (không phải test) ⇒ ngoài mọi cửa
c="$(base go_insert)"
put "$c/be/internal/order/repo.go" <<'EOF'
package order

func addLine() string {
	return "insert into order_line (qty) values (1)"
}
EOF
got="$(run "$c")"
check "INSERT trong chuỗi Go: đỏ" 1 "ngoài mọi cửa" "$got"
check "INSERT trong chuỗi Go: nêu file:dòng" 1 "repo.go:4" "$got"

# 6 — UPDATE trải nhiều dòng trong chuỗi raw của Go ⇒ ngoài mọi cửa
c="$(base go_update)"
put "$c/be/internal/order/raw.go" <<'EOF'
package order

const q = `
UPDATE sales_order
   SET status = 'x'`
EOF
check "UPDATE nhiều dòng trong Go: đỏ" 1 "ngoài mọi cửa" "$(run "$c")"

# 7 — file .sql có câu ghi nằm ngay dưới sql/, không trong thư mục cửa ⇒ ngoài mọi cửa
c="$(base sql_le)"
put "$c/be/internal/order/sql/patch.sql" <<'EOF'
UPDATE sales_order SET note = 'x' WHERE id = 1;
EOF
check ".sql ghi ngoài thư mục cửa: đỏ" 1 "ngoài mọi cửa" "$(run "$c")"

# 8 — CopyFrom của pgx ⇒ ngoài mọi cửa
c="$(base copy_from)"
put "$c/be/internal/order/bulk.go" <<'EOF'
package order

func bulk() { _ = conn.CopyFrom(ctx, ident, cols, src) }
EOF
check "CopyFrom trong Go: đỏ" 1 "ngoài mọi cửa" "$(run "$c")"

# 9 — bảng đích không có trong migration ⇒ không nhận ra bảng đích
c="$(base bang_ma)"
put "$c/be/internal/order/sql/ghost/insert_ghost.sql" <<'EOF'
INSERT INTO ghost_table (x) VALUES (1);
EOF
got="$(run "$c")"
check "bảng không có: đỏ" 1 "không nhận ra bảng đích" "$got"
check "bảng không có: nêu tên" 1 "ghost_table" "$got"

# 10 — ô do hàm trigger trong migration ghi ⇒ thuộc migration
c="$(base trigger_ghi)"
put "$c/be/internal/order/sql/write_audit/insert_audit.sql" <<'EOF'
INSERT INTO audit_log (what) VALUES ('x');
EOF
got="$(run "$c")"
check "ghi vào bảng của trigger: đỏ" 1 "thuộc migration" "$got"
check "ghi vào bảng của trigger: nêu bảng" 1 "audit_log" "$got"

# 11 — loại ghi đã thu hồi khỏi shop_app ⇒ thuộc migration
c="$(base thu_hoi)"
put "$c/be/internal/menu/sql/fix_snapshot/update_snapshot.sql" <<'EOF'
UPDATE price_snapshot SET amount_vnd = 0 WHERE id = $1;
EOF
got="$(run "$c")"
check "ghi loại đã REVOKE: đỏ" 1 "thuộc migration" "$got"
check "ghi loại đã REVOKE: nêu bảng" 1 "price_snapshot" "$got"

# 12 — câu xoá trong một cửa ⇒ loại ghi không có ô (QC-03: shop_app không xoá)
c="$(base xoa)"
put "$c/be/internal/order/sql/drop_line/delete_line.sql" <<'EOF'
DELETE FROM order_line WHERE id = $1;
EOF
check "DELETE trong cửa: đỏ" 1 "không có ô" "$(run "$c")"

# 13 — SET không đọc ra cột ⇒ không nhận ra cột
c="$(base cot_ma)"
put "$c/be/internal/order/sql/bad_set/update_bad.sql" <<'EOF'
UPDATE order_line SET = 1 WHERE id = $1;
EOF
check "SET không có cột: đỏ" 1 "không nhận ra cột" "$(run "$c")"

# 14 — tên thư mục cửa sai khuôn [a-z][a-z0-9_]* ⇒ đỏ
c="$(base ten_sai)"
put "$c/be/internal/order/sql/CloseOrder/update_note.sql" <<'EOF'
UPDATE order_line SET qty = 0 WHERE id = $1;
EOF
check "tên cửa sai khuôn: đỏ" 1 "CloseOrder" "$(run "$c")"

# 15 — SET dạng bộ (a, b) = … đọc ra từng cột (im, không kêu oan)
c="$(base set_bo)"
put "$c/be/internal/order/sql/change_status/update_status.sql" <<'EOF'
UPDATE sales_order SET (status, note) = ($2, $3) WHERE id = $1;
EOF
got="$(run "$c" --list)"
check "SET (a, b): cột thứ nhất" 0 "sales_order${TAB}sửa${TAB}status${TAB}order/change_status" "$got"
check "SET (a, b): cột thứ hai" 0 "sales_order${TAB}sửa${TAB}note${TAB}order/change_status" "$got"

# 16 — cây thật của repo ⇒ đạt
got="$(cd "$ROOT" && "$SCRIPT" 2>&1)"; rc=$?
check "cây thật của repo: đạt" 0 "check-write-paths:" "$rc|$(printf '%s' "$got" | tr '\n' ' ')"

# 17 — bổ sung P3-03: vòng đời bảng, ONLY, chú thích và loại ghi bị cấm.
c="$(base doi_ten)"
put "$c/mig/20260102000000_b.up.sql" <<'EOF'
CREATE TABLE transient_table (id bigint);
DROP TABLE transient_table;
ALTER TABLE menu_item RENAME TO renamed_item;
EOF
put "$c/be/internal/menu/sql/upsert_item/upsert.sql" <<'EOF'
INSERT INTO renamed_item (id) VALUES ($1);
EOF
check "RENAME: tên mới tồn tại" 0 "renamed_item${TAB}thêm" "$(run "$c" --list)"
put "$c/be/internal/menu/sql/upsert_item/upsert.sql" <<'EOF'
INSERT INTO transient_table (id) VALUES ($1);
EOF
check "DROP: bảng không còn tồn tại" 1 "không nhận ra bảng đích transient_table" "$(run "$c")"
put "$c/be/internal/menu/sql/upsert_item/upsert.sql" <<'EOF'
INSERT INTO menu_item (id) VALUES ($1);
EOF
check "RENAME: tên cũ không tồn tại" 1 "không nhận ra bảng đích menu_item" "$(run "$c")"

c="$(base only_va_chu_thich)"
put "$c/be/internal/order/sql/change_status/update_status.sql" <<'EOF'
/* UPDATE ghost SET x=1; /* INSERT INTO ghost VALUES (1); */ */
UPDATE ONLY shop.sales_order o SET
 status = 'x, DELETE FROM ghost; --',
 note = coalesce($1, concat('a', 'b')) WHERE o.id = $2;
EOF
check "ONLY, bí danh, chuỗi và chú thích lồng" 0 "6 ô ghi" "$(run "$c")"

c="$(base thu_hoi_mot_loai)"
put "$c/mig/20260102000000_b.up.sql" <<'EOF'
CREATE TABLE restricted_table (id bigint);
REVOKE INSERT ON shop.restricted_table FROM shop_app;
EOF
put "$c/be/internal/order/sql/restricted/update.sql" <<'EOF'
UPDATE restricted_table SET id = 1;
EOF
check "REVOKE INSERT không cấm UPDATE" 0 "PASS" "$(run "$c")"
put "$c/be/internal/order/sql/restricted/update.sql" <<'EOF'
INSERT INTO restricted_table (id) VALUES (1);
EOF
check "REVOKE INSERT cấm đúng loại" 1 "thuộc migration" "$(run "$c")"

for q in 'TRUNCATE sales_order;' 'MERGE INTO sales_order USING x ON true WHEN MATCHED THEN DO NOTHING;' 'COPY sales_order FROM STDIN;' 'COPY sales_order (id) FROM STDIN;'; do
  c="$(base cam_loai)"
  printf '%s\n' "$q" | put "$c/be/internal/order/sql/create_order/forbidden.sql"
  check "trong cửa: $q" 1 "không có ô" "$(run "$c")"
  rm "$c/be/internal/order/sql/create_order/forbidden.sql"
  printf '%s\n' "$q" | put "$c/be/forbidden.sql"
  check "ngoài cửa: $q" 1 "ngoài mọi cửa" "$(run "$c")"
  rm "$c/be/forbidden.sql"
done

c="$(base go_for_update)"
put "$c/be/internal/order/read.go" <<'EOF'
package order
const q = `SELECT id FROM sales_order FOR UPDATE`
EOF
check "FOR UPDATE là đọc" 0 "PASS" "$(run "$c")"

c="$(base doi_ten_quyen)"
put "$c/mig/20260102000000_b.up.sql" <<'EOF'
CREATE TABLE restricted_table (id bigint);
REVOKE UPDATE ON restricted_table FROM shop_app;
ALTER TABLE restricted_table RENAME TO renamed_table;
EOF
put "$c/be/internal/order/sql/restricted/update.sql" <<'EOF'
UPDATE renamed_table SET id = 1;
EOF
check "REVOKE đi theo RENAME trong cùng file" 1 "thuộc migration" "$(run "$c")"

c="$(base cap_lai_cot)"
put "$c/mig/20260102000000_b.up.sql" <<'EOF'
CREATE TABLE column_granted (id bigint, a text, b text, c text);
REVOKE UPDATE ON column_granted FROM shop_app;
GRANT UPDATE (a, b) ON column_granted TO shop_app;
EOF
put "$c/be/internal/order/sql/restricted/update.sql" <<'EOF'
UPDATE column_granted SET a = 'x', b = 'y';
EOF
check "GRANT UPDATE (cột) sau REVOKE trao lại đúng cột" 0 "PASS" "$(run "$c")"
put "$c/be/internal/order/sql/restricted/update.sql" <<'EOF'
UPDATE column_granted SET a = 'x', c = 'z';
EOF
check "cột không được trao lại vẫn thuộc migration" 1 "column_granted sửa thuộc migration" "$(run "$c")"
put "$c/mig/20260103000000_c.up.sql" <<'EOF'
REVOKE UPDATE ON column_granted FROM shop_app;
EOF
put "$c/be/internal/order/sql/restricted/update.sql" <<'EOF'
UPDATE column_granted SET a = 'x';
EOF
check "REVOKE sau GRANT cột rút cả quyền cột" 1 "thuộc migration" "$(run "$c")"

c="$(base ham_sua)"
put "$c/mig/20260102000000_b.up.sql" <<'EOF'
CREATE TABLE function_owned (id bigint);
CREATE FUNCTION capture_update() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  UPDATE function_owned SET id = 1;
  RETURN NULL;
END $$;
EOF
put "$c/be/internal/order/sql/restricted/update.sql" <<'EOF'
INSERT INTO function_owned (id) VALUES (1);
EOF
check "hàm ghi giữ mọi loại của bảng" 1 "thuộc migration" "$(run "$c")"

# Miền mới dùng cấu hình thật theo khuôn; miền cũ vẫn được test ở trên.
config_entry() {
  local domain="$1"
  cat <<EOF
  - engine: postgresql
    schema: ../db/migrations
    queries:
      - internal/$domain/sql
      - internal/$domain/sql/ghi
    gen:
      go:
        package: sqlcgen
        out: internal/$domain/internal/sqlcgen
        sql_package: pgx/v5
EOF
}
converted() {
  local c="$TMPROOT/$1"
  put "$c/mig/1.up.sql" <<'EOF'
CREATE TABLE menu_item (id bigint, name text, price_vnd bigint);
EOF
  put "$c/be/internal/menu/sql/ghi/a.sql" <<'EOF'
-- chú thích trước annotation bị sqlc bỏ
-- name: Sua :exec
UPDATE menu_item SET name = 'a' WHERE id = $1;
EOF
  { printf 'version: "2"\nsql:\n'; config_entry menu; } | put "$c/be/sqlc.yaml"
  printf '%s' "$c"
}
generated() {
  put "$1/be/internal/menu/internal/sqlcgen/a.sql.go" <<'EOF'
// Code generated by sqlc. DO NOT EDIT.
package sqlcgen
const sua = `-- name: Sua :exec
UPDATE menu_item SET name = 'a' WHERE id = $1
`
EOF
}
c="$(converted sqlc_ok)"; generated "$c"
check 'sqlcgen khớp nguồn' 0 'check-write-paths: PASS' "$(run "$c")"
c="$(converted sqlc_zero)"
printf 'SELECT 1;\n' > "$c/be/internal/menu/sql/ghi/a.sql"
check '0 annotation' 1 'a.sql:1: phải có đúng một dòng -- name:' "$(run "$c")"
c="$(converted sqlc_two_names)"
printf '\n-- name: Khac :one\n' >> "$c/be/internal/menu/sql/ghi/a.sql"
check '2 annotation' 1 'a.sql:1: phải có đúng một dòng -- name:' "$(run "$c")"
c="$(converted sqlc_two_statements)"
printf '\nSELECT 1;\n' >> "$c/be/internal/menu/sql/ghi/a.sql"
check '2 câu' 1 'a.sql:1: phải có đúng một câu SQL' "$(run "$c")"
c="$(converted sqlc_duplicate)"
cp "$c/be/internal/menu/sql/ghi/a.sql" "$c/be/internal/menu/sql/ghi/b.sql"
check 'trùng tên trong miền' 1 'b.sql:1: trùng tên query Sua' "$(run "$c")"
c="$(converted sqlc_cross_domain)"
config_entry khac >> "$c/be/sqlc.yaml"
put "$c/be/internal/khac/sql/ghi/a.sql" <<'EOF'
-- name: Sua :one
SELECT 1;
EOF
check 'trùng tên khác miền' 0 'check-write-paths: PASS' "$(run "$c")"
c="$(converted sqlc_semicolon)"
put "$c/be/internal/menu/sql/ghi/a.sql" <<'EOF'
-- name: Sua :exec
UPDATE menu_item SET name = ';' /* ; */ WHERE id = $1 -- ;
EOF
check 'dấu ; trong chuỗi/chú thích, không ; cuối' 0 'check-write-paths: PASS' "$(run "$c")"
c="$(converted sqlc_old)"
rm "$c/be/sqlc.yaml"
printf 'UPDATE menu_item SET name = 1;\n' > "$c/be/internal/menu/sql/ghi/a.sql"
check 'miền chưa chuyển không annotation' 0 'check-write-paths: PASS' "$(run "$c")"
c="$(converted sqlc_missing_door)"
mkdir -p "$c/be/internal/menu/sql/khac"
check 'thiếu thư mục cửa' 1 'sqlc.yaml:3: thiếu thư mục cửa' "$(run "$c")"
c="$(converted sqlc_bad_config)"
printf 'extra: true\n' >> "$c/be/sqlc.yaml"
check 'mục lệch khuôn' 1 'sqlc.yaml:13: lệch khuôn' "$(run "$c")"
c="$(converted sqlc_changed)"; generated "$c"
perl -pi -e 's/SET name/SET price_vnd/' "$c/be/internal/menu/internal/sqlcgen/a.sql.go"
check 'hằng sửa cột' 1 'a.sql.go:3: lệch nguồn query Sua' "$(run "$c")"
c="$(converted sqlc_no_source)"; generated "$c"
perl -pi -e 's/name: Sua/name: Khac/' "$c/be/internal/menu/internal/sqlcgen/a.sql.go"
check 'hằng không nguồn' 1 'a.sql.go:3: thiếu nguồn query Khac' "$(run "$c")"
c="$(converted sqlc_handwritten)"; generated "$c"
printf '\nvar extra = `UPDATE menu_item SET price_vnd = 2`\n' >> "$c/be/internal/menu/internal/sqlcgen/a.sql.go"
check 'generated viết tay ngoài hằng' 1 'a.sql.go:7: câu ghi ngoài mọi cửa' "$(run "$c")"
c="$(converted sqlc_unregistered)"; generated "$c"
mkdir -p "$c/be/internal/khac/internal/sqlcgen"
check 'sqlcgen miền không mục' 1 'sqlcgen:1: sqlcgen của miền không có mục' "$(run "$c")"
c="$(converted sqlc_no_yaml)"; generated "$c"
rm "$c/be/sqlc.yaml"
check 'sqlcgen không yaml' 1 'sqlcgen:1: sqlcgen của miền không có mục' "$(run "$c")"
c="$(converted sqlc_duplicate_domain)"
config_entry menu >> "$c/be/sqlc.yaml"
check 'hai mục một miền' 1 'sqlc.yaml:13: hai mục cùng miền' "$(run "$c")"
c="$(converted sqlc_merged)"; generated "$c"
put "$c/be/internal/menu/sql/doc.sql" <<'EOF'
-- name: Doc :one
SELECT id FROM menu_item WHERE id = $1;
EOF
cat >> "$c/be/internal/menu/internal/sqlcgen/a.sql.go" <<'EOF'
const doc = `-- name: Doc :one
SELECT id FROM menu_item WHERE id = $1
`
EOF
check 'nhiều nguồn khác tên file gộp một Go file' 0 'check-write-paths: PASS' "$(run "$c")"
c="$(converted sqlc_fake_const)"; generated "$c"
# Chữ const trong một chú thích không phải hằng được miễn.
perl -0777 -pi -e 's/const sua/\/\* const sua/; s/`\n$/` *\/\n/' "$c/be/internal/menu/internal/sqlcgen/a.sql.go"
check 'const trong chú thích không được miễn' 1 'a.sql.go:4: câu ghi ngoài mọi cửa' "$(run "$c")"
c="$(converted sqlc_empty_statement)"
printf '%s\n' '-- name: Rong :exec' ' /* ; */ ' > "$c/be/internal/menu/sql/ghi/a.sql"
check 'không có câu sau clean' 1 'a.sql:1: phải có đúng một câu SQL' "$(run "$c")"
# Những giá trị cố định và đường queries đều phải được chấm.
for field in schema package sql_package out queries; do
  c="$(converted "sqlc_field_$field")"
  case "$field" in
    schema) perl -pi -e 's|../db/migrations|../khac|' "$c/be/sqlc.yaml" ;;
    package) perl -pi -e 's/package: sqlcgen/package: khac/' "$c/be/sqlc.yaml" ;;
    sql_package) perl -pi -e 's|pgx/v5|database/sql|' "$c/be/sqlc.yaml" ;;
    out) perl -pi -e 's|out: internal/menu/internal/sqlcgen|out: ../ngoai|' "$c/be/sqlc.yaml" ;;
    queries) perl -pi -e 's|      - internal/menu/sql$|      - internal/khac/sql|' "$c/be/sqlc.yaml" ;;
  esac
  check "cấu hình sai $field" 1 'sqlc.yaml:' "$(run "$c")"
done

if [ "$fails" -gt 0 ]; then
  echo "check-write-paths.test: FAIL — $fails ca hỏng"
  exit 1
fi
echo "check-write-paths.test: OK"
