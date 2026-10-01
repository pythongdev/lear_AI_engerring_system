#!/usr/bin/env bash
# Bộ kiểm database — Gate 1 gọi qua scripts/verify.sh (P2-12,
# docs/product/2-db/10-quy-uoc-code.md QC-07). Chạy tay: ./scripts/db-check.sh
#
# Mỗi lần chạy dựng một database RIÊNG và RỖNG (compose project banhcuon_check,
# cổng ngẫu nhiên, gỡ sạch khi xong — database làm việc `banhcuon` không bị
# đụng), chạy migration ở db/migrations/ xuôi từng bước từ số 0, lùi từng bước về
# số 0 rồi xuôi lại, so lược đồ sau mỗi lần lùi (P2-09), rồi:
#   1. mọi khối ```sql và ```sh nằm dưới một tiêu đề `### QC-XX` trong
#      docs/product/2-db/*.md — lấy thẳng từ tài liệu, không chép
#      (work/findings.md F-001). Khối sql phải ra 0 dòng, khối sh phải in rỗng;
#   3. từng file db/tests/*.sql, mỗi file trong một transaction rồi ROLLBACK.
# Tham số `:schema`… lấy từ bảng §0 của 01-quy-uoc-du-lieu.md; múi giờ của quán
# lấy từ master_plan/shop-facts.md §1. Bước 4: dựng dữ liệu mồi (db/seed/, P2-10)
# vào database ấy rồi tính lại các ca giá §4.8. Bước 5: trên dữ liệu mồi ấy, lùi
# từng bước qua chỗ còn rỗng tới bước đầu có dữ liệu bị từ chối, gỡ dirty rồi xuôi
# lại đỉnh và so lược đồ (07-thu-tu-migration.md). Bước 6: bộ đối chiếu
# (scripts/reconcile.sh, P2-11) — nhóm I-0xx và nhóm quy ước QD-XX (các phép QD
# chạy ở đây, không ở bước 1) — ra 0 dòng trên dữ liệu mồi, 0 dòng trên ngày bán mẫu
# đúng, và mỗi lỗi cài ở db/reconcile/proof/ làm kêu ĐÚNG tập câu nó khai
# (09-doi-chieu-bat-bien.md §3). Bước 7: ba scenario nghiệm thu diễn qua lược đồ
# (db/scenario/, P2-13, 11-cong-chat-luong-pha-2.md) — mỗi bước ở quán một giao dịch
# được COMMIT; đọc lại ở kết nối khác; bộ đối chiếu chạy lại trên ngày ấy ⇒ mọi câu
# rỗng; rồi chấm hai câu cho mỗi mã YC mà 04-yeu-cau-du-lieu.md giao pha 2 (các mã
# đứng trước §8 của file ấy). Không có Docker, hay database
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

# --- 1. khối kiểm trong tài liệu --------------------------------------------
blocks="$(mktemp)"
for f in "$DOCS"/*.md; do
  awk -v file="$f" '
    /^## /                                  { code="" }
    /^### QC-[0-9]+/                        { code=$2 }
    /^### QD-[0-9]+/                        { code="" }
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
    n_seed="$(psql_q -c "SELECT format('%s bàn · %s mã QR hiện hành · %s thành phần · %s dòng menu · %s nhóm tuỳ chọn · %s trạm của thành phần · %s hàng mua vào · %s hàng chưa có đơn vị',
      (SELECT count(*) FROM dining_table), (SELECT count(*) FROM qr_code WHERE replaced_at IS NULL),
      (SELECT count(*) FROM menu_component), (SELECT count(*) FROM menu_item),
      (SELECT count(*) FROM option_group), (SELECT count(*) FROM menu_component_station),
      (SELECT count(*) FROM supply_item), (SELECT count(*) FROM supply_item WHERE purchase_unit IS NULL))")"
    echo "PASS dữ liệu mồi — $n_seed"
    if supply_names="$(perl db/seed/seed.pl --supply-names)" &&
       stored_names="$(psql_q -c 'SELECT name FROM supply_item')"; then
      d="$(comm -3 <(printf '%s\n' "$supply_names" | sort) <(printf '%s\n' "$stored_names" | sort))"
      if [ -z "$d" ]; then
        echo "PASS tên hàng mua vào — comm -3 rỗng (owner ↔ supply_item)"
      else
        fail "tên hàng mua vào — danh sách owner và database lệch:"
        printf 'owner:\n%s\ndatabase:\n%s\n' "$supply_names" "$stored_names" | sed 's/^/     /'
      fi
    else
      fail "tên hàng mua vào — không đọc được owner hoặc database"
    fi
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
# Database có dữ liệu mồi: bước rỗng được lùi (luật 2), bước đầu có dữ liệu phải
# từ chối mà không đổi lược đồ. Gỡ dirty về bước ấy rồi xuôi lại đỉnh, so ảnh seeded.
if [ "$n_mig" -gt 0 ] && [ "${top:-0}" != 0 ]; then
  schema_dump > "$snap/seeded"
  empty_steps=0; blocked=0; guard_ok=1; standing="$top"
  for f in $(printf '%s\n' $versions | sort -r); do
    v="${f%%_*}"; before="$(cat "$snap/$v.prev")"
    if out="$(migrate down 1)"; then
      echo "NOTE khoá chặn — ${f%.up.sql} còn rỗng, lùi được (luật 2)"
      empty_steps=$((empty_steps + 1)); standing="$before"
      if ! d="$(diff "$snap/$before" <(schema_dump))"; then
        fail "khoá chặn — lùi ${f%.up.sql} nhưng lược đồ khác ảnh bước ngay dưới:"
        printf '%s\n' "$d" | head -20 | sed 's/^/     /'
        guard_ok=0; break
      fi
    elif ! printf '%s\n' "$out" | grep -q 'đường lùi từ chối'; then
      fail "khoá chặn — lùi hỏng vì lý do khác:"; printf '%s\n' "$out" | tail -5 | sed 's/^/     /'
      guard_ok=0; break
    elif ! d="$(diff "$snap/$v" <(schema_dump))"; then
      fail "khoá chặn — từ chối nhưng lược đồ đã đổi:"; printf '%s\n' "$d" | head -20 | sed 's/^/     /'
      guard_ok=0; break
    else
      blocked=1; standing="$v"
      printf '%s\n' "$out" | grep -o 'đường lùi từ chối: .* gỡ nó là xoá dữ liệu' | head -1 | sed 's/^/     /'
      echo "     sau lệnh hỏng: $(migrate version | tail -1)"
      break
    fi
  done
  if [ "$guard_ok" -eq 1 ] && [ "$blocked" -eq 0 ]; then
    fail "khoá chặn — lùi tới số không trên database có dữ liệu mồi mà KHÔNG bị từ chối"
  elif [ "$guard_ok" -eq 1 ]; then
    if migrate force "$standing" >/dev/null && [ "$(migrate version | tail -1)" = "$standing" ]; then
      if out="$(migrate up)" && d="$(diff "$snap/seeded" <(schema_dump))"; then
        echo "PASS khoá chặn — bước đầu có dữ liệu từ chối, lược đồ không đổi; đã lùi qua $empty_steps bước rỗng và xuôi lại, lược đồ giống hệt trước bước 5"
        echo "PASS force $standing — dấu dirty gỡ; đã xuôi lại $empty_steps bước rỗng, phiên bản: $(migrate version | tail -1)"
      else
        fail "khoá chặn — xuôi lại đỉnh hoặc so lược đồ seeded hỏng:"
        printf '%s\n' "$out" "${d:-}" | head -20 | sed 's/^/     /'
      fi
    else
      fail "force $standing — không gỡ được dấu dirty: $(migrate version | tail -1)"
    fi
  fi
fi

# --- 6. bộ đối chiếu (P2-11, docs/product/2-db/09-doi-chieu-bat-bien.md) ---------
# (a) comm -3 danh sách mã và (b) cả bộ trên dữ liệu mồi: chính lệnh chạy sau khi đóng quán.
n_proof=0
if out="$(scripts/reconcile.sh --project "$PROJECT" 2>&1)"; then
  printf '%s\n' "$out" | grep -E '^(PASS mã|NOTE I-0[0-9]{2} chưa có lát|     (danh sách|owner|ràng buộc)|reconcile:)'
else
  fail "đối chiếu trên dữ liệu mồi:"; printf '%s\n' "$out" | grep -Ev '^PASS I-|^PASS QD-' | sed 's/^/     /'
fi
# (c) biết kêu: MỘT giao dịch không bao giờ COMMIT — ngày bán mẫu đúng ⇒ mọi câu 0 dòng; rồi mỗi
# file lỗi trong một savepoint: cài lỗi, trạng thái sau lỗi phải qua mọi ràng buộc còn lại (SET
# CONSTRAINTS ALL IMMEDIATE, như lúc COMMIT), và tập câu kêu phải BẰNG ĐÚNG tập khai ở dòng
# "-- kêu:" của file. Mỗi câu phải là mã đầu của ít nhất một file lỗi.
PROOF=db/reconcile/proof
queries="$(scripts/reconcile.sh --emit-queries)"
n_q="$(printf '%s\n' "$queries" | grep -c "^.echo '@@@|")"
faults="$(grep -l '^-- kêu: ' "$PROOF"/*.sql | sort)"
refusals="$(grep -l '^-- tu-choi: ' "$PROOF"/*.sql | sort)"
proof_out="$({ echo 'BEGIN;'
               scripts/reconcile.sh --emit-prelude
               cat "$PROOF/baseline.sql"
               echo "\\echo '@@@@|ngày mẫu'"; printf '%s\n' "$queries"
               for f in $refusals; do
                 echo 'SAVEPOINT loi;'; echo "\\echo '@@@@|$(basename "$f" .sql)'"; cat "$f"
                 echo 'ROLLBACK TO SAVEPOINT loi;'
               done
               for f in $faults; do
                 echo 'SAVEPOINT loi;'
                 echo "\\echo '@@@@|$(basename "$f" .sql)'"
                 cat "$f"
                 echo 'SET CONSTRAINTS ALL IMMEDIATE;'
                 printf '%s\n' "$queries"
                 echo 'ROLLBACK TO SAVEPOINT loi;'
                 echo 'SET CONSTRAINTS ALL DEFERRED;'
               done
               echo 'ROLLBACK;'; } \
             | compose exec -T -e PGTZ="$SHOP_TZ" db psql -X -q -U shop_owner -d banhcuon -tA 2>&1)"
# Mỗi đoạn: tên · số câu đã chạy · tập câu kêu (sắp xếp) · lỗi đầu tiên (nếu có).
sections="$(printf '%s\n' "$proof_out" | awk '
  function flush() { if (name != "") printf "%s\t%d\t%s\t%s\n", name, ran, fired, err }
  /^@@@@\|/        { flush(); name = substr($0, 6); ran = 0; fired = ""; err = ""; next }
  /^@@\|/          { split($0, a, "|"); ran++; if (a[3] > 0) fired = fired (fired == "" ? "" : " ") a[2]; next }
  /ERROR:/ && err == "" { e = $0; sub(/^.*ERROR: */, "", e); err = e }
  END { flush() }')"
IFS="$(printf '\t')" read -r _ ran fired err <<<"$(printf '%s\n' "$sections" | grep -m1 "^ngày mẫu$(printf '\t')")"
if [ "${ran:-0}" -eq "$n_q" ] && [ -z "$fired" ] && [ -z "$err" ]; then
  echo "PASS ngày bán mẫu đúng ($PROOF/baseline.sql) — $n_q câu chạy, mọi tập rỗng"
else
  fail "ngày bán mẫu — ${ran:-0}/$n_q câu chạy, câu kêu: ${fired:-không}${err:+, lỗi: $err}"
fi
# Lời từ chối (QC-07) chạy một lần trên ngày mẫu: không lỗi nào, và in dòng NOTICE của nó.
for f in $refusals; do
  name="$(basename "$f" .sql)"
  IFS="$(printf '\t')" read -r _ ran fired err <<<"$(printf '%s\n' "$sections" | grep -m1 "^$name$(printf '\t')")"
  note="$(printf '%s\n' "$proof_out" | grep -m1 "NOTICE: *$(sed -n '1s/^-- tu-choi: //p' "$f")" | sed 's/^.*NOTICE: *//')"
  if [ -z "$err" ] && [ -n "$note" ]; then echo "PASS từ chối $name — $note"
  else fail "từ chối $name — ${err:-không in dòng NOTICE nào}"
  fi
done
targets=""
for f in $faults; do
  name="$(basename "$f" .sql)"
  want="$(sed -n '1s/^-- kêu: //p' "$f" | tr ' ' '\n' | grep . | sort | tr '\n' ' ' | sed 's/ $//')"
  targets="$targets $(sed -n '1s/^-- kêu: //p' "$f" | awk '{print $1}')"
  IFS="$(printf '\t')" read -r _ ran fired err <<<"$(printf '%s\n' "$sections" | grep -m1 "^$name$(printf '\t')")"
  got="$(printf '%s\n' $fired | grep . | sort | tr '\n' ' ' | sed 's/ $//')"
  n_proof=$((n_proof + 1))
  if [ -z "$want" ]; then
    fail "kêu $name — dòng đầu không khai '-- kêu: <mã> …'"
  elif [ -n "$err" ]; then
    fail "kêu $name — lỗi cài không đứng được, hoặc một câu không chạy: $err"
  elif [ "${ran:-0}" -ne "$n_q" ]; then
    fail "kêu $name — chỉ ${ran:-0}/$n_q câu chạy"
  elif [ "$got" = "$want" ]; then
    echo "PASS kêu $name — $got"
  else
    fail "kêu $name — khai: $want · kêu: ${got:-không câu nào}"
  fi
done
all_codes="$(printf '%s\n' "$queries" | grep "^.echo '@@@|" | sed "s/^.*@@@|//; s/'$//" | sort -u)"
d="$(comm -3 <(printf '%s\n' "$all_codes") <(printf '%s\n' $targets | sort -u))"
if [ -z "$d" ]; then
  echo "PASS mọi câu có lỗi cài nhắm vào nó — comm -3 rỗng ($n_q câu, $n_proof file lỗi)"
else
  fail "câu không có lỗi cài nào nhắm vào (cột trái) / lỗi cài nhắm vào câu không có (cột phải):"
  printf '%s\n' "$d" | sed 's/^/     /'
fi

# --- 7. ba scenario nghiệm thu diễn qua lược đồ (P2-13, docs/product/2-db/11-cong-chat-luong-pha-2.md)
# Database lúc này chỉ có dữ liệu mồi: bước 6 không COMMIT gì. (a) diễn: prelude + mở ngày + s1 · s2 ·
# s3 trong MỘT phiên, mỗi khối DO một giao dịch được COMMIT; (b) đọc lại ở một kết nối KHÁC; (c) bộ
# đối chiếu chạy lại trên ngày ấy ⇒ mọi câu rỗng; (d) chấm YC trong một giao dịch ROLLBACK — mỗi mã
# YC đứng trước §8 của 04-yeu-cau-du-lieu.md phải có một dòng "đọc" và một dòng "sai", và mỗi
# "GỌI TÊN: <mã> (proof/<file>)" phải trỏ tới một file lỗi cài còn đó, khai đúng mã ấy.
SC=db/scenario
YC_OWNER=docs/product/1-system-design/04-yeu-cau-du-lieu.md
n_yc=0
notices() { sed -n 's/^psql:[^N]*NOTICE: */     /p'; }
if out="$(cat "$SC/prelude.sql" "$SC/mo_ngay.sql" $(ls "$SC"/s[0-9]_*.sql | sort) | psql_f -f - 2>&1)"; then
  echo "PASS ba scenario diễn qua lược đồ — $(printf '%s\n' "$out" | grep -c 'NOTICE: *S[0-9]') dòng bước, mỗi bước một giao dịch COMMIT"
  printf '%s\n' "$out" | notices
else
  fail "ba scenario — một bước không ghi được:"; printf '%s\n' "$out" | tail -15 | sed 's/^/     /'
fi
if out="$(psql_f -f - < "$SC/doc_lai.sql" 2>&1)"; then
  echo "PASS đọc lại ba scenario ở kết nối khác — mọi dòng Kết quả mong đợi đúng"
  printf '%s\n' "$out" | notices; printf '%s\n' "$out" | grep '^TIỀN' | sed 's/^/     /'
else
  fail "đọc lại ba scenario:"; printf '%s\n' "$out" | grep -E 'ERROR|SAI' | head -5 | sed 's/^/     /'
fi
if out="$(scripts/reconcile.sh --project "$PROJECT" 2>&1)"; then
  echo "PASS đối chiếu trên ngày vừa diễn — $(printf '%s\n' "$out" | grep '^reconcile:' | sed 's/^reconcile: PASS — //')"
else
  fail "đối chiếu trên ngày vừa diễn:"; printf '%s\n' "$out" | grep -Ev '^PASS' | sed 's/^/     /'
fi
yc_want="$(sed -n '1,/^## 8\./p' "$YC_OWNER" | grep -oE '\*\*YC-[0-9]{2}' | tr -d '*' | sort -u)"
if out="$(cat "$SC/prelude.sql" "$SC/yc.sql" | psql_f -f - 2>&1)"; then
  lines="$(printf '%s\n' "$out" | notices | sed 's/^ *//')"
  both="$(comm -12 <(printf '%s\n' "$lines" | grep -oE '^YC-[0-9]{2} đọc' | cut -c1-5 | sort -u) \
                   <(printf '%s\n' "$lines" | grep -oE '^YC-[0-9]{2} sai' | cut -c1-5 | sort -u))"
  n_yc="$(printf '%s\n' "$both" | grep -c .)"
  d="$(comm -3 <(printf '%s\n' "$yc_want") <(printf '%s\n' "$both"))"
  bad_ref=""
  while read -r code file; do
    [ -n "$code" ] || continue
    grep -q "^-- kêu: .*${code}" "$PROOF/$file.sql" 2>/dev/null || bad_ref="$bad_ref $code→proof/$file"
  done < <(printf '%s\n' "$lines" | grep -oE 'GỌI TÊN: [^ ]+ \(proof/[a-z0-9_]+\)' \
             | sed -E 's/GỌI TÊN: ([^ ]+) \(proof\/([a-z0-9_]+)\)/\1 \2/')
  if [ -z "$yc_want" ]; then
    fail "chấm YC — không đọc được mã YC nào ở $YC_OWNER"
  elif [ -n "$d" ]; then
    fail "chấm YC — mã owner giao mà thiếu đọc/sai (cột trái) / mã chấm mà owner không giao (cột phải):"
    printf '%s\n' "$d" | sed 's/^/     /'
  elif [ -n "$bad_ref" ]; then
    fail "chấm YC — GỌI TÊN trỏ tới lỗi cài không có hoặc không khai mã ấy:$bad_ref"
  else
    echo "PASS chấm YC — $n_yc mã, mỗi mã đọc + sai; comm -3 với $YC_OWNER rỗng · $(printf '%s\n' "$lines" | grep -c '⇒ TỪ CHỐI') TỪ CHỐI · $(printf '%s\n' "$lines" | grep -c '⇒ KHÔNG CHỖ') KHÔNG CHỖ · $(printf '%s\n' "$lines" | grep -c '⇒ ĐI QUA') ĐI QUA · $(printf '%s\n' "$lines" | grep -c '⇒ GỌI TÊN') GỌI TÊN · $(printf '%s\n' "$lines" | grep -c '⇒ DỰNG ĐƯỢC') DỰNG ĐƯỢC · $(printf '%s\n' "$lines" | grep -c '⇒ CHƯA TRẢ LỜI ĐƯỢC') CHƯA TRẢ LỜI ĐƯỢC"
    printf '%s\n' "$lines" | sed 's/^/     /'
  fi
else
  fail "chấm YC — một kết cục không còn đúng:"; printf '%s\n' "$out" | grep -E 'ERROR' | head -5 | sed 's/^/     /'
fi

rm -rf "$snap"
rm -f "$subst_file"
if [ "$failed" -ne 0 ]; then
  echo "db-check: FAIL"
  exit 1
fi
echo "db-check: PASS — $n_mig bước xuôi · lùi · xuôi lại, $n_blocks khối kiểm QC, $n_tests file test, dữ liệu mồi + §4.8, khoá chặn, đối chiếu: $n_q câu trên dữ liệu mồi và ngày mẫu, $n_proof lỗi cài, ba scenario + đối chiếu trên ngày diễn, $n_yc mã YC"
