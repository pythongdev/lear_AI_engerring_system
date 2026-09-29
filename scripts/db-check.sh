#!/usr/bin/env bash
# Bộ kiểm database — Gate 1 gọi qua scripts/verify.sh (P2-12,
# docs/product/2-db/10-quy-uoc-code.md QC-07). Chạy tay: ./scripts/db-check.sh
#
# Mỗi lần chạy dựng một database RIÊNG và RỖNG (compose project banhcuon_check,
# cổng ngẫu nhiên, gỡ sạch khi xong — database làm việc `banhcuon` không bị
# đụng), chạy migration ở db/migrations/ xuôi từng bước từ số 0, lùi từng bước về
# số 0 rồi xuôi lại, so lược đồ sau mỗi lần lùi (P2-09), rồi:
#   1. mọi khối ```sql và ```sh nằm dưới một tiêu đề `### QD-XX` / `### QC-XX`
#      trong docs/product/2-db/*.md — lấy thẳng từ tài liệu, không chép
#      (work/findings.md F-001). Khối sql phải ra 0 dòng, khối sh phải in rỗng;
#   2. bốn phép kiểm dạng lệnh mà một câu SQL không viết nổi: QD-02, QD-31(b),
#      QD-32, QD-40(b) — hàm cùng tên ở dưới;
#   3. từng file db/tests/*.sql, mỗi file trong một transaction rồi ROLLBACK.
# Tham số `:schema`, `:kieu_moc`… lấy từ bảng §0 của 01-quy-uoc-du-lieu.md; múi
# giờ của quán lấy từ master_plan/shop-facts.md §1. Bước 4: dựng dữ liệu mồi (db/seed/,
# P2-10) vào database ấy rồi tính lại các ca giá §4.8. Bước 5: trên dữ liệu mồi ấy,
# lùi một bước phải bị khoá chặn từ chối (07-thu-tu-migration.md). Không có Docker, hay database
# không lên ⇒ FAIL, không bỏ qua: một bộ kiểm im lặng khi thiếu máy là một bộ
# kiểm không ai biết đã không chạy.
set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1

PROJECT=banhcuon_check
DOCS=docs/product/2-db
PARAMS_FILE="$DOCS/01-quy-uoc-du-lieu.md"
export DB_PORT=0
failed=0

compose() { docker compose -p "$PROJECT" "$@"; }
cleanup() { compose down -v --remove-orphans >/dev/null 2>&1; }
fail() { echo "FAIL $*"; failed=1; }

if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
  echo "db-check: FAIL — Docker không chạy. Bật Docker rồi chạy lại ./scripts/db-check.sh"
  exit 1
fi

SHOP_TZ="$(grep -m1 '^| Múi giờ |' master_plan/shop-facts.md | grep -o '`[^`]*`' | head -1 | tr -d '`')"
if [ -z "$SHOP_TZ" ]; then
  echo "db-check: FAIL — không đọc được múi giờ ở master_plan/shop-facts.md §1 (dòng '| Múi giờ |')"
  exit 1
fi

cleanup
trap cleanup EXIT
if ! compose up -d --wait db >/dev/null 2>&1; then
  echo "db-check: FAIL — database không lên"
  compose logs db 2>&1 | tail -20
  exit 1
fi

# Mọi kết nối của bộ kiểm đặt múi giờ TƯỜNG MINH (QD-32), không dựa vào mặc định.
# psql_f đọc câu lệnh từ stdin; psql_q thì KHÔNG được đọc stdin — `compose exec`
# sẽ nuốt nốt phần còn lại của vòng lặp đang đọc danh sách khối kiểm.
psql_f() {
  compose exec -T -e PGTZ="$SHOP_TZ" db \
    psql -X -q -v ON_ERROR_STOP=1 -U shop_owner -d banhcuon -tA "$@"
}
psql_q() { psql_f "$@" </dev/null; }

echo "=== db-check — $(psql_q -c 'SHOW server_version' 2>&1) · múi giờ kết nối $SHOP_TZ ==="

# --- migration: xuôi · lùi · xuôi lại (P2-09, docs/product/2-db/07-thu-tu-migration.md)
# (a) xuôi TỪNG bước từ số không, chụp lược đồ sau mỗi bước; (b) lùi từng bước về số
# không — lược đồ sau khi lùi bước N phải GIỐNG HỆT ảnh chụp trước khi xuôi bước N;
# (c) xuôi lại cả dãy — giống hệt lần xuôi đầu. Ảnh chụp là pg_dump --schema-only
# của schema `shop` (gồm quyền), bỏ dòng chú thích và cặp \restrict có khoá ngẫu nhiên.
migrate() { compose run --rm migrate "$@" </dev/null 2>&1; }
schema_dump() {
  compose exec -T db pg_dump -U shop_owner -d banhcuon --schema-only --schema=shop </dev/null \
    | grep -Ev '^(--|\\(un)?restrict )' | grep -v '^$'
}
snap="$(mktemp -d)"
versions="$(find db/migrations -maxdepth 1 -name '*.up.sql' 2>/dev/null | sed 's|.*/||' | sort)"
n_mig="$(printf '%s' "$versions" | grep -c .)"
if [ "$n_mig" -gt 0 ]; then
  mig_ok=1
  prev=0; schema_dump > "$snap/0"
  for f in $versions; do
    v="${f%%_*}"
    if out="$(migrate up 1)"; then
      schema_dump > "$snap/$v"; echo "PASS xuôi ${f%.up.sql}"
      printf '%s\n' "$prev" > "$snap/$v.prev"; prev="$v"
    else
      fail "xuôi ${f%.up.sql}"; printf '%s\n' "$out" | tail -20 | sed 's/^/     /'; mig_ok=0; break
    fi
  done
  top="$prev"
  # F-017: pg_dump hỏng thì mọi ảnh chụp cùng rỗng, và "rỗng giống rỗng" là một PASS giả.
  if [ "$mig_ok" -eq 1 ] && [ "$(grep -c . "$snap/$top")" -le "$(grep -c . "$snap/0")" ]; then
    fail "ảnh chụp lược đồ — sau $n_mig bước không dài hơn lược đồ rỗng; pg_dump có chạy không?"
    mig_ok=0
  fi
  if [ "$mig_ok" -eq 1 ]; then
    for f in $(printf '%s\n' $versions | sort -r); do
      v="${f%%_*}"; before="$(cat "$snap/$v.prev")"
      if ! out="$(migrate down 1)"; then
        fail "lùi ${f%.up.sql}"; printf '%s\n' "$out" | tail -20 | sed 's/^/     /'; mig_ok=0; break
      fi
      if d="$(diff "$snap/$before" <(schema_dump))"; then
        echo "PASS lùi ${f%.up.sql} — lược đồ giống hệt lúc trước bước ấy ($(grep -c . "$snap/$before") dòng)"
      else
        fail "lùi ${f%.up.sql} — lược đồ khác lúc trước bước ấy:"; printf '%s\n' "$d" | head -20 | sed 's/^/     /'
        mig_ok=0; break
      fi
    done
  fi
  if [ "$mig_ok" -eq 1 ]; then
    if out="$(migrate up)" && d="$(diff "$snap/$top" <(schema_dump))"; then
      echo "PASS xuôi lại — $n_mig bước từ số không, lược đồ giống hệt lần xuôi đầu ($(grep -c . "$snap/$top") dòng)"
    else
      fail "xuôi lại"; printf '%s\n' "$out" "${d:-}" | head -20 | sed 's/^/     /'
    fi
  else
    # Vòng hỏng giữa chừng để lại lược đồ dở và dấu dirty: dựng lại database sạch để
    # các phép kiểm sau chạy trên lược đồ đầy đủ, không đỏ dây chuyền.
    echo "NOTE migrate — dựng lại database rỗng và xuôi cả dãy cho các phép kiểm sau"
    cleanup; compose up -d --wait db >/dev/null 2>&1 && migrate up >/dev/null \
      || fail "migrate — không dựng lại được lược đồ đầy đủ"
    top=0   # không kiểm khoá chặn trên một vòng đã hỏng
  fi
else
  echo "NOTE migrate — db/migrations/ chưa có file nào; kiểm trên lược đồ rỗng"
fi

# --- tham số từ bảng §0 ------------------------------------------------------
# Dòng dạng: | `:ten` | nghĩa | ai điền | `giá trị SQL` |
subst_file="$(mktemp)"
grep -E '^\| `:[a-z_]+` \|' "$PARAMS_FILE" | while IFS= read -r row; do
  name="$(printf '%s' "$row" | grep -o '`:[a-z_]*`' | head -1 | tr -d '`:')"
  value="$(printf '%s' "$row" | grep -o '`[^`]*`' | tail -1 | tr -d '`')"
  printf '%s\t%s\n' "$name" "$value"
done > "$subst_file"
if [ ! -s "$subst_file" ]; then
  fail "tham số — không đọc được bảng §0 của $PARAMS_FILE"
fi
apply_params() {
  local sql="$1" name value
  while IFS="$(printf '\t')" read -r name value; do
    sql="$(NAME="$name" VALUE="$value" perl -pe 's/:\Q$ENV{NAME}\E\b/$ENV{VALUE}/g' <<<"$sql")"
  done < "$subst_file"
  printf '%s' "$sql"
}
param() { awk -F'\t' -v n="$1" '$1==n {print $2}' "$subst_file" | tr -d "'"; }
SCHEMA="$(param schema)"

# --- 1. khối kiểm trong tài liệu --------------------------------------------
blocks="$(mktemp)"
for f in "$DOCS"/*.md; do
  awk -v file="$f" '
    /^## /                                  { code="" }
    /^### Q[CD]-[0-9]+/                     { code=$2 }
    code!="" && !inb && /^ *```(sql|sh) *$/ { inb=1; lang=$0; gsub(/[ `]/,"",lang); body=""; next }
    inb && /^ *``` *$/                      { printf "%s\t%s\t%s\t%s\036", code, lang, file, body; inb=0; next }
    inb                                     { body = body $0 "\n" }
  ' "$f"
done > "$blocks"

n_blocks=0
while IFS="$(printf '\t')" read -r -d $'\036' code lang file body; do
  n_blocks=$((n_blocks + 1))
  if [ "$lang" = "sql" ]; then
    if out="$(psql_q -c "$(apply_params "$body")" 2>&1)"; then
      if [ -z "$out" ]; then echo "PASS $code (sql) — 0 dòng"
      else fail "$code (sql) — $(printf '%s\n' "$out" | wc -l | tr -d ' ') dòng:"; printf '%s\n' "$out" | sed 's/^/     /'
      fi
    else
      fail "$code (sql) — câu kiểm không chạy được:"; printf '%s\n' "$out" | sed 's/^/     /'
    fi
  else
    out="$(bash -c "$body" </dev/null 2>&1)"
    if [ -z "$out" ]; then echo "PASS $code (sh) — rỗng"
    else fail "$code (sh):"; printf '%s\n' "$out" | sed 's/^/     /'
    fi
  fi
done < "$blocks"
[ "$n_blocks" -gt 0 ] || fail "không tìm thấy khối kiểm nào trong $DOCS/*.md"
rm -f "$blocks"

# --- 2. bốn phép kiểm dạng lệnh ---------------------------------------------

# Tập giá trị trong ràng buộc kiểm trên một cột, mỗi dòng một giá trị.
check_values() {
  psql_q -c "SELECT k.check_clause
             FROM information_schema.constraint_column_usage u
             JOIN information_schema.check_constraints k
               ON k.constraint_schema = u.constraint_schema AND k.constraint_name = u.constraint_name
             WHERE u.table_schema = '$SCHEMA' AND u.table_name = '$1' AND u.column_name = '$2'" \
    | grep -o "'[^']*'" | tr -d "'" | sort -u
}
tables_with_column() {
  psql_q -c "SELECT table_name FROM information_schema.columns
             WHERE table_schema = '$SCHEMA' AND column_name = '$1' ORDER BY 1"
}

# QD-02 — cột mang mã kênh tên `channel_code` (bảng shop-facts §2), cột mang mã
# trạm tên `station_code` (bảng §3); tập mã trong ràng buộc = tập mã của owner.
qd02() {
  local col sec owner t db_codes diff
  for pair in "channel_code:2" "station_code:3"; do
    col="${pair%%:*}"; sec="${pair##*:}"
    owner="$(awk -v s="^## $sec\\\\." '$0 ~ s {on=1; next} on && /^## / {exit} on' master_plan/shop-facts.md \
             | grep -E '^\| `[a-z_]+`' | grep -o '^| `[a-z_]*`' | tr -d '|` ' | sort -u)"
    echo "     QD-02 owner §$sec ($col): $(printf '%s' "$owner" | tr '\n' ' ')"
    [ -n "$owner" ] || fail "QD-02 — không đọc được bảng mã ở shop-facts §$sec"
    local tables; tables="$(tables_with_column "$col")"
    if [ -z "$tables" ]; then
      echo "PASS QD-02 ($col) — chưa bảng nào mang cột này, 0 dòng"
      continue
    fi
    for t in $tables; do
      db_codes="$(check_values "$t" "$col")"
      echo "     QD-02 $t.$col: $(printf '%s' "$db_codes" | tr '\n' ' ')"
      diff="$(comm -3 <(printf '%s\n' "$owner") <(printf '%s\n' "$db_codes"))"
      if [ -z "$diff" ]; then echo "PASS QD-02 ($t.$col) — comm -3 rỗng"
      else fail "QD-02 ($t.$col) — lệch với shop-facts §$sec:"; printf '%s\n' "$diff" | sed 's/^/     /'
      fi
    done
  done
}

# QD-31(b) — mỗi bảng có cả booked_at và sale_date: sale_date = ngày lịch của
# booked_at quy bằng múi giờ của quán.
qd31b() {
  local t n
  local tables; tables="$(psql_q -c "SELECT table_name FROM information_schema.columns
      WHERE table_schema = '$SCHEMA' AND column_name IN ('booked_at','sale_date')
      GROUP BY table_name HAVING COUNT(*) = 2 ORDER BY 1")"
  if [ -z "$tables" ]; then echo "PASS QD-31(b) — chưa bảng nào có booked_at, 0 dòng"; return; fi
  for t in $tables; do
    n="$(psql_q -c "SELECT COUNT(*) FROM $SCHEMA.$t
                    WHERE sale_date <> (booked_at AT TIME ZONE '$SHOP_TZ')::date")"
    if [ "$n" = "0" ]; then echo "PASS QD-31(b) ($t) — 0 dòng"
    else fail "QD-31(b) ($t) — $n dòng có sale_date lệch ngày của booked_at"
    fi
  done
}

# QD-32 — kết nối của bộ kiểm (cũng là kết nối chạy db/tests/) đọc mốc đúng múi
# giờ của quán. Kết nối của backend chạy thật chưa có — chỗ trống có tên, QC-06.
qd32() {
  local seen; seen="$(psql_q -c 'SHOW TimeZone')"
  echo "     QD-32 shop-facts §1: $SHOP_TZ"
  echo "     QD-32 kết nối bộ kiểm: $seen"
  if [ "$seen" = "$SHOP_TZ" ]; then echo "PASS QD-32 — hai dòng giống hệt"
  else fail "QD-32 — múi giờ kết nối lệch múi giờ của quán"
  fi
}

# QD-40(b) — tập mã trong ràng buộc kiểm của cột `status` = cột mã của bảng ánh
# xạ ở file lát. Mỗi dòng ánh xạ viết: | `<bảng>.status` | `<mã>` | tên ở owner |
qd40b() {
  local t db_codes doc_codes diff
  local tables; tables="$(tables_with_column status)"
  if [ -z "$tables" ]; then echo "PASS QD-40(b) — chưa bảng nào có cột status, 0 dòng"; return; fi
  for t in $tables; do
    db_codes="$(check_values "$t" status)"
    doc_codes="$(grep -h "^| \`$t.status\` |" "$DOCS"/*.md | awk -F'`' '{print $4}' | sort -u)"
    echo "     QD-40(b) $t.status ràng buộc: $(printf '%s' "$db_codes" | tr '\n' ' ')"
    echo "     QD-40(b) $t.status file lát: $(printf '%s' "$doc_codes" | tr '\n' ' ')"
    diff="$(comm -3 <(printf '%s\n' "$doc_codes") <(printf '%s\n' "$db_codes"))"
    if [ -n "$doc_codes" ] && [ -z "$diff" ]; then echo "PASS QD-40(b) ($t) — comm -3 rỗng"
    else fail "QD-40(b) ($t) — ràng buộc và bảng ánh xạ lệch, hoặc chưa có bảng ánh xạ"
         printf '%s\n' "$diff" | sed 's/^/     /'
    fi
  done
}

qd02; qd31b; qd32; qd40b

# --- 3. db/tests/*.sql --------------------------------------------------------
n_tests=0
for t in db/tests/*.sql; do
  [ -f "$t" ] || continue
  n_tests=$((n_tests + 1))
  if out="$({ echo 'BEGIN;'; cat "$t"; echo 'ROLLBACK;'; } | psql_f -f - 2>&1)"; then
    echo "PASS $t"; [ -z "$out" ] || printf '%s\n' "$out" | sed 's/^/     /'
  else
    fail "$t"; printf '%s\n' "$out" | sed 's/^/     /'
  fi
done
[ "$n_tests" -gt 0 ] || echo "NOTE db/tests/ — chưa có file test nào"

# --- 4. dữ liệu mồi (P2-10, docs/product/2-db/08-du-lieu-moi.md) ----------------
# Sinh từ master_plan/shop-facts.md lúc chạy, dựng vào database này (sau mọi test,
# vì các test chạy trên database rỗng), rồi tính lại các ca giá của §4.8 ⇒ khớp
# từng đồng. Owner đổi hình mà bộ dựng không đọc được ⇒ FAIL.
n_seed=0
if seed_sql="$(perl db/seed/seed.pl 2>&1)"; then
  if out="$(printf '%s\n' "$seed_sql" | psql_f -f - 2>&1)"; then
    n_seed="$(psql_q -c "SELECT format('%s bàn · %s mã QR hiện hành · %s thành phần · %s dòng menu · %s nhóm tuỳ chọn · %s trạm của thành phần',
      (SELECT count(*) FROM dining_table), (SELECT count(*) FROM qr_code WHERE replaced_at IS NULL),
      (SELECT count(*) FROM menu_component), (SELECT count(*) FROM menu_item),
      (SELECT count(*) FROM option_group), (SELECT count(*) FROM menu_component_station))")"
    echo "PASS dữ liệu mồi — $n_seed"
    if out="$(perl db/seed/seed.pl --price-cases | psql_f -f - 2>&1)"; then
      echo "PASS §4.8 ca giá"; printf '%s\n' "$out" | sed 's/^psql:[^N]*NOTICE: */     /'
    else
      fail "§4.8 ca giá"; printf '%s\n' "$out" | sed 's/^/     /'
    fi
  else
    fail "dữ liệu mồi — không dựng được"; printf '%s\n' "$out" | sed 's/^/     /'
  fi
else
  fail "dữ liệu mồi — db/seed/seed.pl không đọc được owner:"; printf '%s\n' "$seed_sql" | sed 's/^/     /'
fi

# --- 5. khoá chặn của đường lùi biết kêu (P2-09) ------------------------------
# Database lúc này có dữ liệu mồi. Lùi một bước ⇒ phải bị từ chối, lược đồ không
# đổi; rồi gỡ dấu dirty bằng force về đúng bước trước lệnh (07-thu-tu-migration.md §3).
if [ "$n_mig" -gt 0 ] && [ "${top:-0}" != 0 ]; then
  schema_dump > "$snap/seeded"
  if out="$(migrate down 1)"; then
    fail "khoá chặn — lùi một bước trên database có dữ liệu mồi mà KHÔNG bị từ chối"
  elif ! printf '%s\n' "$out" | grep -q 'đường lùi từ chối'; then
    fail "khoá chặn — lùi hỏng vì lý do khác:"; printf '%s\n' "$out" | tail -5 | sed 's/^/     /'
  elif ! d="$(diff "$snap/seeded" <(schema_dump))"; then
    fail "khoá chặn — từ chối nhưng lược đồ đã đổi:"; printf '%s\n' "$d" | head -20 | sed 's/^/     /'
  else
    echo "PASS khoá chặn — lùi trên dữ liệu mồi bị từ chối, lược đồ không đổi"
    printf '%s\n' "$out" | grep -o 'đường lùi từ chối: .* gỡ nó là xoá dữ liệu' | head -1 | sed 's/^/     /'
    echo "     sau lệnh hỏng: $(migrate version | tail -1)"
    if migrate force "$top" >/dev/null && [ "$(migrate version | tail -1)" = "$top" ]; then
      echo "PASS force $top — dấu dirty gỡ, phiên bản: $(migrate version | tail -1)"
    else
      fail "force $top — không gỡ được dấu dirty: $(migrate version | tail -1)"
    fi
  fi
fi

rm -rf "$snap"
rm -f "$subst_file"
if [ "$failed" -ne 0 ]; then
  echo "db-check: FAIL"
  exit 1
fi
echo "db-check: PASS — $n_mig bước xuôi · lùi · xuôi lại, $n_blocks khối kiểm tài liệu, 4 phép kiểm dạng lệnh, $n_tests file test, dữ liệu mồi + §4.8, khoá chặn"
