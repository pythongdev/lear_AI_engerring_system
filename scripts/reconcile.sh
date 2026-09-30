#!/usr/bin/env bash
# Bộ đối chiếu bất biến — MỘT lệnh chạy sau khi đóng quán (P2-11,
# docs/product/2-db/09-doi-chieu-bat-bien.md). Chạy tay:
#
#   ./scripts/reconcile.sh                    # database làm việc của compose.yaml
#   ./scripts/reconcile.sh --project <tên>    # database của một compose project khác
#   ./scripts/reconcile.sh --codes            # chỉ so danh sách mã, không cần database
#
# Hai nhóm, in tách nhau, không trộn (ADR-053 luật 3):
#   I-0xx/n  mỗi tập "phải rỗng" của docs/product/1-system-design/03-bao-ve-invariant.md là MỘT
#            câu trong db/reconcile/i0xx.sql, mở bằng dòng `-- @@ I-0xx/n — <tập>`;
#   QD-XX    mọi khối ```sql dưới tiêu đề `### QD-XX` của docs/product/2-db/01-quy-uoc-du-lieu.md
#            — đọc THẲNG từ tài liệu (work/findings.md F-001) — cộng các câu `-- @@ QD-XX/…` của
#            db/reconcile/qd.sql, phần cần danh sách đọc lúc chạy từ owner.
# Mỗi câu ra 0 dòng là PASS; khác 0 là FAIL kèm tối đa vài dòng của tập. Câu không chạy được là FAIL.
#
# Trước mọi câu: `comm -3` giữa mã `### I-0xx` ở quality/invariants.md và mã có câu trong
# db/reconcile/ phải rỗng; cùng phép cho mã `### QD-XX` và nhóm quy ước. Một mệnh đề mới chưa có câu
# ⇒ FAIL ở đây, không cần ai nhớ cập nhật một con số (F-018 · F-026).
#
# Đọc lúc chạy, không chép: tham số `:schema`… ở bảng §0 của 01-quy-uoc-du-lieu.md; múi giờ và giờ
# bán ở master_plan/shop-facts.md §1; mã kênh §2, mã trạm §3; bảng chuyển trạng thái
# docs/product/0-ba/ban-hang/05-vong-doi.md §5.2–§5.4 đổi tên sang mã qua bảng ánh xạ QD-40 của các
# file lát. Owner đổi hình mà lệnh không đọc được ⇒ FAIL, không chạy với danh sách rỗng.
#
# Mọi câu chạy trong MỘT phiên kết nối, chỉ đọc; bảng và hàm tạm ở db/reconcile/prelude.sql mất khi
# phiên đóng. Hai chế độ cho bộ chứng minh của scripts/db-check.sh (không dùng tay):
#   --emit-prelude   in phần dựng bảng tạm + hàm tạm; --emit-queries   in mọi câu đã bọc.
set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1

DIR=db/reconcile
DOCS=docs/product/2-db
PARAMS_FILE="$DOCS/01-quy-uoc-du-lieu.md"
FACTS=master_plan/shop-facts.md
LIFECYCLE=docs/product/0-ba/ban-hang/05-vong-doi.md
INVARIANTS=quality/invariants.md

PROJECT=""
MODE=run
while [ $# -gt 0 ]; do
  case "$1" in
    --project)      PROJECT="${2:-}"; shift 2 ;;
    --codes)        MODE=codes; shift ;;
    --emit-prelude) MODE=prelude; shift ;;
    --emit-queries) MODE=queries; shift ;;
    -h|--help)      sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)              echo "reconcile: không hiểu tham số '$1' — xem --help"; exit 2 ;;
  esac
done

die() { echo "reconcile: FAIL — $*"; exit 1; }

# --- đọc owner -----------------------------------------------------------------
SHOP_TZ="$(grep -m1 '^| Múi giờ |' "$FACTS" | grep -o '`[^`]*`' | head -1 | tr -d '`')"
[ -n "$SHOP_TZ" ] || die "không đọc được múi giờ ở $FACTS §1 (dòng '| Múi giờ |')"
HOURS="$(grep -m1 '^| Giờ bán |' "$FACTS" | grep -oE '[0-9]{2}:[0-9]{2}')"
GIO_MO="$(printf '%s\n' "$HOURS" | sed -n 1p)"; GIO_DONG="$(printf '%s\n' "$HOURS" | sed -n 2p)"
[ -n "$GIO_MO" ] && [ -n "$GIO_DONG" ] || die "không đọc được giờ bán ở $FACTS §1 (dòng '| Giờ bán |')"

# Tham số: bảng §0 của 01 (dòng | `:ten` | … | `giá trị SQL` |), cộng ba tham số từ shop-facts §1.
params() {
  grep -E '^\| `:[a-z_]+` \|' "$PARAMS_FILE" | while IFS= read -r row; do
    printf '%s\t%s\n' "$(printf '%s' "$row" | grep -o '`:[a-z_]*`' | head -1 | tr -d '`:')" \
                      "$(printf '%s' "$row" | grep -o '`[^`]*`' | tail -1 | tr -d '`')"
  done
  printf 'mui_gio\t%s\ngio_mo\t%s\ngio_dong\t%s\n' "'$SHOP_TZ'" "'$GIO_MO'::time" "'$GIO_DONG'::time"
}

# Mọi câu, mỗi câu một bản ghi "mã<TAB>tập<TAB>thân" kết thúc bằng \036. Nhóm I trước, rồi QD.
blocks() {
  perl -e '
    my @out;
    for my $f (@ARGV) {
      open my $fh, "<", $f or die "$f: $!";
      if ($f =~ /\.md$/) {                         # khối sql dưới ### QD-XX, trong đúng mục ###
        my ($code, $inb, $body) = ("", 0, "");
        while (<$fh>) {
          if (/^## /)                          { $code = ""; next }
          if (/^### (QD-\d+)/)                  { $code = $1; next }
          if ($code ne "" && !$inb && /^\s*```sql\s*$/) { $inb = 1; $body = ""; next }
          if ($inb && /^\s*```\s*$/)            { push @out, [$code, "khối sql của $code ở $f", $body]; $inb = 0; next }
          $body .= $_ if $inb;
        }
      } else {                                     # -- @@ MÃ — tập, thân tới marker kế
        my $cur;
        while (<$fh>) {
          if (/^-- @@ (\S+) — (.*)$/) { push @out, $cur if $cur; $cur = [$1, $2, ""]; next }
          $cur->[2] .= $_ if $cur;
        }
        push @out, $cur if $cur;
      }
    }
    for (@out) { my $b = $_->[2]; $b =~ s/\s+\z//; $b =~ s/;\z//; print "$_->[0]\t$_->[1]\t$b\036" }
  ' "$DIR"/i[0-9][0-9][0-9].sql "$PARAMS_FILE" "$DIR"/qd.sql
}

# --- so danh sách mã -------------------------------------------------------------
check_codes() {
  local want got d ok=0
  want="$(grep -oE '^### I-0[0-9]{2}' "$INVARIANTS" | cut -c5- | sort -u)"
  got="$(grep -ohE '^-- @@ I-0[0-9]{2}/' "$DIR"/i[0-9][0-9][0-9].sql | cut -c7-11 | sort -u)"
  d="$(comm -3 <(printf '%s\n' "$want") <(printf '%s\n' "$got"))"
  if [ -n "$want" ] && [ -z "$d" ]; then
    echo "PASS mã I-0xx — comm -3 rỗng: $(printf '%s\n' "$want" | grep -c .) mã ở $INVARIANTS, cùng từng ấy mã có câu"
  else
    echo "FAIL mã I-0xx — lệch giữa $INVARIANTS (cột trái) và $DIR/ (cột phải):"
    printf '%s\n' "$d" | sed 's/^/     /'; ok=1
  fi
  want="$(grep -oE '^### QD-[0-9]+' "$PARAMS_FILE" | cut -c5- | sort -u)"
  got="$(blocks | tr '\036' '\n' | grep -oE '^QD-[0-9]+' | sort -u)"
  d="$(comm -3 <(printf '%s\n' "$want") <(printf '%s\n' "$got"))"
  if [ -n "$want" ] && [ -z "$d" ]; then
    echo "PASS mã QD-XX — comm -3 rỗng: $(printf '%s\n' "$want" | grep -c .) mã ở $PARAMS_FILE, cùng từng ấy mã có phép kiểm"
  else
    echo "FAIL mã QD-XX — lệch giữa $PARAMS_FILE (cột trái) và nhóm quy ước (cột phải):"
    printf '%s\n' "$d" | sed 's/^/     /'; ok=1
  fi
  return $ok
}

# --- phần dựng: bảng tạm + hàm tạm + ba danh sách từ owner ------------------------
emit_prelude() {
  cat "$DIR/prelude.sql"
  # Mã kênh (§2) và mã trạm (§3): cột đầu của bảng mã trong mục ấy, dạng | `ma` |.
  local pair col sec codes
  for pair in "channel_code:2" "station_code:3"; do
    col="${pair%%:*}"; sec="${pair##*:}"
    codes="$(awk -v s="^## $sec\\\\." '$0 ~ s {on=1; next} on && /^## / {exit} on' "$FACTS" \
             | grep -E '^\| `[a-z_]+`' | grep -o '^| `[a-z_]*`' | tr -d '|` ' | sort -u)"
    [ -n "$codes" ] || { echo "\\echo 'reconcile: FAIL — không đọc được bảng mã ở $FACTS §$sec'"; continue; }
    printf '%s\n' "$codes" | sed "s/.*/INSERT INTO pg_temp.dc_owner_code VALUES ('$col', '&');/"
  done
  # Bảng ánh xạ QD-40 của các file lát, rồi bảng chuyển trạng thái §5.2–§5.4 đổi tên sang mã.
  perl -e '
    my $life = shift; my (%map, @rows);
    for my $f (@ARGV) {
      open my $fh, "<", $f or die "$f: $!";
      while (<$fh>) {
        next unless /^\| `([a-z_]+)\.status` \| `([a-z_]+)` \| (.+?) \(§(5\.\d)\) \|/;
        $map{"$4|$3"} = [$1, $2];
        push @rows, "INSERT INTO pg_temp.dc_status_map VALUES (\x27$1\x27, \x27$2\x27);\n";
      }
    }
    print @rows;
    sub clean { my $s = shift; $s =~ s/\*\([^)]*\)\*//g; $s =~ s/\*//g; $s =~ s/^\s+|\s+$//g; $s }
    open my $fh, "<", $life or die "$life: $!";
    my $sec = "";
    while (<$fh>) {
      if (/^### (5\.\d)/) { $sec = $1; next }
      next unless $sec =~ /^5\.[234]$/ && /^\|/ && !/^\|\s*-/;
      my @c = split /\|/;
      my ($a, $b) = (clean($c[1]), clean($c[3]));
      my ($x, $y) = ($map{"$sec|$a"}, $map{"$sec|$b"});
      next unless $x && $y && $x->[0] eq $y->[0];
      print "INSERT INTO pg_temp.dc_transition VALUES (\x27$x->[0]\x27, \x27$x->[1]\x27, \x27$y->[1]\x27);\n";
    }
  ' "$LIFECYCLE" "$DOCS"/*.md
}

# --- mọi câu, đã thay tham số và bọc: một dòng @@|mã|số dòng|mẫu -------------------
emit_queries() {
  local subst; subst="$(params)"
  blocks | SUBST="$subst" perl -0777 -ne '
    my %p = map { split /\t/, $_, 2 } grep { length } split /\n/, $ENV{SUBST};
    for my $rec (split /\036/) {
      my ($code, $set, $body) = split /\t/, $rec, 3;
      next unless defined $body;
      for my $k (sort { length $b <=> length $a } keys %p) { $body =~ s/:\Q$k\E\b/$p{$k}/g }
      print "\\echo \x27@@@|$code\x27\n";
      print "SELECT \x27@@|$code|\x27 || count(*) || \x27|\x27 || coalesce(left(string_agg(row_to_json(q)::text, \x27 ; \x27), 600), \x27\x27)\nFROM (\n$body\n) q;\n";
    }'
}

case "$MODE" in
  codes)   check_codes; exit $? ;;
  prelude) emit_prelude; exit 0 ;;
  queries) emit_queries; exit 0 ;;
esac

# --- chạy ------------------------------------------------------------------------
if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
  die "Docker không chạy. Bật Docker rồi chạy lại ./scripts/reconcile.sh"
fi
compose() { if [ -n "$PROJECT" ]; then docker compose -p "$PROJECT" "$@"; else docker compose "$@"; fi; }
psql_run() {
  compose exec -T -e PGTZ="$SHOP_TZ" db psql -X -q -U shop_owner -d banhcuon -tA "$@"
}

failed=0
check_codes || failed=1

prelude="$(emit_prelude)"
if printf '%s\n' "$prelude" | grep -q "reconcile: FAIL"; then
  printf '%s\n' "$prelude" | grep -o "reconcile: FAIL.*" | tr -d "'"; failed=1
fi
queries="$(emit_queries)"
set_names="$(blocks | tr '\036' '\n' | awk -F'\t' 'NF >= 2 {print $1 "\t" $2}')"

out="$({ printf '%s\n' "$prelude"
         echo "\\echo '@@@|danh sách'"
         echo "SELECT '@@L|' || (SELECT count(*) FROM pg_temp.dc_owner_code WHERE column_name = 'channel_code') || '|'
                    || (SELECT count(*) FROM pg_temp.dc_owner_code WHERE column_name = 'station_code') || '|'
                    || (SELECT count(*) FROM pg_temp.dc_status_map) || '|'
                    || (SELECT count(DISTINCT table_name) FROM pg_temp.dc_transition) || '|'
                    || (SELECT count(*) FROM (SELECT DISTINCT * FROM pg_temp.dc_transition) t);
               SELECT '@@O|' || string_agg(k || ': ' || v, ' · ' ORDER BY k) FROM (
                 SELECT column_name AS k, string_agg(code, ' ' ORDER BY code) AS v FROM pg_temp.dc_owner_code GROUP BY 1
                 UNION ALL
                 SELECT table_name || '.status', string_agg(code, ' ' ORDER BY code) FROM pg_temp.dc_status_map GROUP BY 1) x;
               SELECT '@@D|' || string_agg(k || ': ' || v, ' · ' ORDER BY k) FROM (
                 SELECT u.table_name || '.' || u.column_name AS k, string_agg(DISTINCT m[1], ' ' ORDER BY m[1]) AS v
                 FROM information_schema.constraint_column_usage u
                 JOIN information_schema.check_constraints c
                   ON c.constraint_schema = u.constraint_schema AND c.constraint_name = u.constraint_name
                 CROSS JOIN LATERAL regexp_matches(c.check_clause, '''([^'']*)''', 'g') m
                 WHERE u.table_schema = current_schema()
                   AND u.column_name IN ('channel_code', 'station_code', 'status')
                 GROUP BY 1) x;"
         printf '%s\n' "$queries"; } | psql_run 2>&1)" || { printf '%s\n' "$out" | tail -5; die "không chạy được psql trên database"; }

echo "=== reconcile — $(date '+%Y-%m-%d %H:%M') · múi giờ $SHOP_TZ · giờ bán ${GIO_MO}–${GIO_DONG} ==="
# F-017: một danh sách đọc từ owner mà rỗng làm câu của nó xanh vì không có gì để so.
IFS='|' read -r _ n_kenh n_tram n_map n_vd n_tr <<<"$(printf '%s\n' "$out" | grep -m1 '^@@L|')"
echo "     danh sách từ owner: ${n_kenh:-0} mã kênh · ${n_tram:-0} mã trạm · ${n_map:-0} dòng ánh xạ trạng thái · ${n_tr:-0} chuyển tiếp của ${n_vd:-0} vòng đời"
# QD-02 · QD-40(b): in cả hai danh sách chưa lọc cạnh kết quả so (F-017).
echo "     owner   — $(printf '%s\n' "$out" | grep -m1 '^@@O|' | cut -c5-)"
echo "     ràng buộc — $(printf '%s\n' "$out" | grep -m1 '^@@D|' | cut -c5-)"
if [ "${n_kenh:-0}" -eq 0 ] || [ "${n_tram:-0}" -eq 0 ] || [ "${n_map:-0}" -eq 0 ] || [ "${n_vd:-0}" -lt 3 ]; then
  echo "FAIL danh sách từ owner — có danh sách rỗng hoặc thiếu vòng đời (cần đủ ba: đơn · phiên · việc trạm)"
  failed=1
fi

n_i=0; n_q=0; n_bad=0
while IFS="$(printf '\t')" read -r code set; do
  [ -n "$code" ] || continue
  case "$code" in I-*) n_i=$((n_i + 1)) ;; *) n_q=$((n_q + 1)) ;; esac
  res="$(printf '%s\n' "$out" | awk -v c="$code" '
    $0 == "@@@|" c         { on = 1; next }
    on && /^@@@\|/         { exit }
    on && index($0, "@@|" c "|") == 1 { print; exit }
    on && /ERROR:/         { sub(/^.*ERROR: */, ""); print "ERR|" $0; exit }')"
  case "$res" in
    "@@|$code|0|"*) echo "PASS $code — 0 dòng · $set" ;;
    "@@|$code|"*)   n="$(printf '%s' "$res" | cut -d'|' -f3)"
                    echo "FAIL $code — $n dòng · $set"
                    printf '%s' "$res" | cut -d'|' -f4- | tr ';' '\n' | sed 's/^ */     /' | head -5
                    failed=1; n_bad=$((n_bad + 1)) ;;
    ERR\|*)         echo "FAIL $code — câu không chạy được: ${res#ERR|}"; failed=1; n_bad=$((n_bad + 1)) ;;
    *)              echo "FAIL $code — không thấy kết quả của câu"; failed=1; n_bad=$((n_bad + 1)) ;;
  esac
done <<<"$set_names"

n_open="$(grep -c '^| .* | chưa có câu |' "$DOCS/09-doi-chieu-bat-bien.md" 2>/dev/null)"
echo "NOTE $n_open tập của pha 1 chưa có câu, mỗi tập một lý do và một người nợ — $DOCS/09-doi-chieu-bat-bien.md §2"
if [ "$failed" -ne 0 ]; then
  echo "reconcile: FAIL — $n_bad câu có phần tử hoặc không chạy được (trong $n_i câu I-0xx · $n_q câu QD)"
  exit 1
fi
echo "reconcile: PASS — $n_i câu I-0xx · $n_q câu QD, mọi tập rỗng"
