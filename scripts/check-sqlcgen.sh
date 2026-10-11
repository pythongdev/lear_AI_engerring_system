#!/usr/bin/env bash
# So code sqlc sinh với nguồn (ADR-093, QC-13), chạy trong verify.sh sau build.
# VÌ SAO CÓ: code chạy phải đúng code sinh từ SQL mà Gate 1f đã kiểm.
# ĐỌC GÌ: sqlc.yaml, internal/*/sql/, internal/*/internal/sqlcgen/ và migrations.
#   SQLCGEN_BE_DIR / SQLCGEN_MIG_DIR đổi gốc cho test. Go chạy từ module be/.
# ĐỎ KHI NÀO: sqlcgen không có cấu hình/mục, cấu hình lệch khuôn Gate 1f,
#   generate lỗi, tập file hoặc nội dung khác bản sinh lại (thiếu, dư, sửa).
# KHÔNG BẮT: tính đúng nghiệp vụ của query; không thay test PostgreSQL thật.
#   Chép nguồn vào mktemp, liên kết migrations thật, xoá khi thoát; không sửa be/.
# EXIT: 0 = khớp hoặc chưa miền nào chuyển; 1 = lệch/lỗi sinh hay đọc.
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
BE_DIR="${SQLCGEN_BE_DIR:-$ROOT/be}"
MIG_DIR="${SQLCGEN_MIG_DIR:-$ROOT/db/migrations}"
BE_DIR="$(cd "$BE_DIR" && pwd)"
shopt -s nullglob
actual=("$BE_DIR"/internal/*/internal/sqlcgen)
if [ ! -f "$BE_DIR/sqlc.yaml" ]; then
  if [ "${#actual[@]}" -gt 0 ]; then
    printf '%s:1: sqlcgen không có sqlc.yaml\n' "${actual[@]}"
    echo "check-sqlcgen: FAIL — thiếu sqlc.yaml"
    exit 1
  fi
  echo "check-sqlcgen: chưa miền nào chuyển"
  exit 0
fi
# Dùng cùng bộ đọc khuôn, chặn mọi đường dẫn thoát cây tạm trước khi sinh.
if ! WRITE_PATHS_BE_DIR="$BE_DIR" WRITE_PATHS_MIG_DIR="$MIG_DIR" "$ROOT/scripts/check-write-paths.sh"; then
  echo "check-sqlcgen: FAIL — nguồn hoặc cấu hình vi phạm Gate 1f"
  exit 1
fi
MIG_DIR="$(cd "$MIG_DIR" && pwd)"
TEMP_TREE="$(mktemp -d)"
trap 'rm -rf "$TEMP_TREE"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
mkdir -p "$TEMP_TREE/be" "$TEMP_TREE/db"
ln -s "$MIG_DIR" "$TEMP_TREE/db/migrations"
cp "$BE_DIR/sqlc.yaml" "$TEMP_TREE/be/sqlc.yaml"
for sql in "$BE_DIR"/internal/*/sql; do
  [ -d "$sql" ] || continue
  rel="${sql#"$BE_DIR"/}"
  mkdir -p "$TEMP_TREE/be/$(dirname "$rel")"
  cp -R "$sql" "$TEMP_TREE/be/$rel"
done
if ! (cd "$BE_DIR" && go tool sqlc generate -f "$TEMP_TREE/be/sqlc.yaml"); then
  echo "check-sqlcgen: FAIL — sqlc generate lỗi"
  exit 1
fi
failed=0
for generated in "$TEMP_TREE"/be/internal/*/internal/sqlcgen; do
  rel="${generated#"$TEMP_TREE"/be/}"
  if [ ! -d "$BE_DIR/$rel" ]; then
    echo "$BE_DIR/$rel:1: thiếu thư mục code sinh"
    failed=1
  elif ! diff -ru "$generated" "$BE_DIR/$rel"; then
    failed=1
  fi
done
for dir in "${actual[@]}"; do
  rel="${dir#"$BE_DIR"/}"
  if [ ! -d "$TEMP_TREE/be/$rel" ]; then
    echo "$dir:1: dư thư mục sqlcgen"
    failed=1
  fi
done
if [ "$failed" -ne 0 ]; then
  echo "check-sqlcgen: FAIL — code sinh thiếu, dư hoặc lệch nội dung"
  exit 1
fi
echo "check-sqlcgen: PASS — tập file và nội dung khớp bản sinh lại"
