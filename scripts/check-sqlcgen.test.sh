#!/usr/bin/env bash
# Sinh thật bằng tool đã ghim, toàn bộ migration thật; chỉ viết trong mktemp.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMP_TREE="$(mktemp -d)"
trap 'rm -rf "$TEMP_TREE"' EXIT
mkdir -p "$TEMP_TREE/be/internal/menu/sql/doi_gia" "$TEMP_TREE/db"
cp "$ROOT/be/go.mod" "$ROOT/be/go.sum" "$TEMP_TREE/be/"
ln -s "$ROOT/db/migrations" "$TEMP_TREE/db/migrations"
cat > "$TEMP_TREE/be/sqlc.yaml" <<'YAML'
version: "2"
sql:
  - engine: postgresql
    schema: ../db/migrations
    queries:
      - internal/menu/sql
      - internal/menu/sql/doi_gia
    gen:
      go:
        package: sqlcgen
        out: internal/menu/internal/sqlcgen
        sql_package: pgx/v5
YAML
cat > "$TEMP_TREE/be/internal/menu/sql/doc.sql" <<'SQL'
-- name: DocMenu :many
SELECT id FROM menu_item;
SQL
cat > "$TEMP_TREE/be/internal/menu/sql/doi_gia/ghi.sql" <<'SQL'
-- name: DoiGia :one
UPDATE menu_component SET base_price_vnd = $2 WHERE id = $1
RETURNING id, base_price_vnd;
SQL
(cd "$TEMP_TREE/be" && go tool sqlc generate)
test -s "$TEMP_TREE/be/internal/menu/internal/sqlcgen/ghi.sql.go"
echo "  ok generate toàn bộ migrations + SELECT menu_item + UPDATE menu_component (exit 0, có code sinh)"
check() {
  local name="$1" expected="$2" pattern="$3" out rc=0
  out="$(SQLCGEN_BE_DIR="$TEMP_TREE/be" SQLCGEN_MIG_DIR="$ROOT/db/migrations" "$ROOT/scripts/check-sqlcgen.sh" 2>&1)" || rc=$?
  if [ "$rc" != "$expected" ] || [[ "$out" != *"$pattern"* ]]; then
    printf 'FAIL %s: exit %s\n%s\n' "$name" "$rc" "$out"
    exit 1
  fi
  echo "  ok $name (exit $rc): $pattern"
}
check khop 0 'check-sqlcgen: PASS'
cp -R "$TEMP_TREE/be/internal/menu/internal/sqlcgen" "$TEMP_TREE/original"
printf '\n// sua tay\n' >> "$TEMP_TREE/be/internal/menu/internal/sqlcgen/db.go"
check sua 1 'code sinh thiếu, dư hoặc lệch nội dung'
cp "$TEMP_TREE/original/db.go" "$TEMP_TREE/be/internal/menu/internal/sqlcgen/db.go"
rm "$TEMP_TREE/be/internal/menu/internal/sqlcgen/db.go"
check thieu 1 'Only in'
cp "$TEMP_TREE/original/db.go" "$TEMP_TREE/be/internal/menu/internal/sqlcgen/db.go"
printf 'package sqlcgen\n' > "$TEMP_TREE/be/internal/menu/internal/sqlcgen/du.go"
check du 1 'Only in'
rm "$TEMP_TREE/be/internal/menu/internal/sqlcgen/du.go"
mkdir -p "$TEMP_TREE/be/internal/khac/internal/sqlcgen"
check du_mien 1 'sqlcgen của miền không có mục'
rmdir "$TEMP_TREE/be/internal/khac/internal/sqlcgen"
printf '\nBAD SQL\n' >> "$TEMP_TREE/be/internal/menu/sql/doc.sql"
check generate_loi 1 'đúng một câu SQL'
# Câu đúng số lượng nhưng không có bảng: phải thấy lỗi từ chính sqlc.
printf '%s\n' '-- name: DocMenu :many' 'SELECT id FROM bang_khong_co;' > "$TEMP_TREE/be/internal/menu/sql/doc.sql"
rm -r "$TEMP_TREE/be/internal/menu/internal/sqlcgen"
check sqlc_loi 1 'sqlc generate lỗi'
cp -R "$TEMP_TREE/original" "$TEMP_TREE/be/internal/menu/internal/sqlcgen"
rm "$TEMP_TREE/be/sqlc.yaml"
check khong_cau_hinh 1 'sqlcgen không có sqlc.yaml'
rm -r "$TEMP_TREE/be/internal/menu/internal/sqlcgen"
check chua_chuyen 0 'chưa miền nào chuyển'
echo 'check-sqlcgen.test: OK'
