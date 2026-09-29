#!/usr/bin/env bash
# Gate 1e — tên bảng tài liệu ↔ migration (docs/decisions.md ADR-053 luật 2; P2-09)
#
# VÌ SAO CÓ:
#   File migration thắng về tên bảng; file lát ở docs/product/2-db/ giữ ý định và
#   nhắc tên bảng để trỏ. Hai bản trôi khỏi nhau mà không ai thấy — dự án cũ đo ba
#   lần như vậy (work/proposals/from_old_project/data_base/nghien-cuu.md §4.1–§4.3).
#   ADR-053 đòi phép so này là MỘT LỆNH trong ./scripts/gate.sh: luật không có
#   lệnh gác thì tự trôi. Nó chỉ đọc file, không cần database, nên chạy MỌI lượt
#   — kể cả lượt chỉ đổi tài liệu, đúng lượt hay làm lệch tên nhất.
#
# SO GÌ VỚI GÌ:
#   migration — tên bảng còn tồn tại sau khi chạy mọi db/migrations/*.up.sql theo
#               thứ tự tên file: CREATE TABLE thêm, DROP TABLE bớt, ALTER TABLE …
#               RENAME TO đổi. Chú thích SQL (--) bị bỏ trước khi đọc.
#   tài liệu  — tên bảng mà docs/product/2-db/*.md NHẮC theo một trong hai dạng:
#               (1) ô đầu của một hàng trong bảng markdown có tiêu đề mở đầu bằng
#                   "Bảng" (| Bảng | … hay | Bảng · cột | …): mã đầu tiên trong
#                   backtick, phần trước dấu chấm nếu có;
#               (2) mọi `bảng.cột` trong backtick — trừ tên file (phần sau dấu
#                   chấm là đuôi file) và schema (shop · public · pg_catalog ·
#                   information_schema).
#   Hai danh sách, comm -3 ⇒ RỖNG thì đạt. Lệch ⇒ FAIL, và theo ADR-053 luật 2 ý 3
#   cách xử là một dòng F-XXX — KHÔNG sửa migration cho khớp chữ, không lặng lẽ
#   sửa chữ cho khớp migration.
#
# F-017: một danh sách rỗng vì biểu thức lọc sai cũng cho comm -3 rỗng. Vì thế
#   script in CẢ HAI danh sách đầy đủ trước kết quả, và đỏ khi một trong hai rỗng
#   mà thư mục của nó có file.
#
# KHÔNG BẮT:
#   Tên bảng chỉ nhắc trong văn xuôi dạng `bill` trơn (không trong bảng "Bảng",
#   không kèm cột) — một mã trơn trong backtick có thể là cột, ràng buộc hay mã
#   trạng thái, và đoán thì kêu oan. Tên cột. Tên ràng buộc.
#
# Thư mục đổi được bằng biến môi trường cho test: SCHEMA_NAMES_MIG_DIR ·
# SCHEMA_NAMES_DOC_DIR. Test: scripts/check-schema-names.test.sh.
#
# EXIT: 0 = khớp, hoặc không có gì để so (in "… skipping") · 1 = lệch
set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1

MIG_DIR="${SCHEMA_NAMES_MIG_DIR:-db/migrations}"
DOC_DIR="${SCHEMA_NAMES_DOC_DIR:-docs/product/2-db}"

mig_files="$(find "$MIG_DIR" -maxdepth 1 -name '*.up.sql' 2>/dev/null | sort)"
doc_files="$(find "$DOC_DIR" -maxdepth 1 -name '*.md' 2>/dev/null | sort)"
if [ -z "$mig_files" ] && [ -z "$doc_files" ]; then
  echo "check-schema-names: chưa có file migration nào ở $MIG_DIR, chưa có tài liệu ở $DOC_DIR, skipping"
  exit 0
fi

# shellcheck disable=SC2086
mig_tables="$(perl -e '
  my %t;
  for my $f (@ARGV) {
    open my $h, "<", $f or die "$f: $!";
    local $/; my $s = <$h>; close $h;
    $s =~ s/--[^\n]*//g;
    while ($s =~ /\b(?:(CREATE)\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:shop\.)?([a-z_][a-z0-9_]*)
                     |(DROP)\s+TABLE\s+(?:IF\s+EXISTS\s+)?([a-z0-9_.,\s]+?)\s*(?:CASCADE|RESTRICT)?\s*;
                     |ALTER\s+TABLE\s+(?:IF\s+EXISTS\s+)?(?:shop\.)?([a-z_][a-z0-9_]*)\s+RENAME\s+TO\s+([a-z_][a-z0-9_]*))/gix) {
      if    (defined $1) { $t{lc $2} = 1 }
      elsif (defined $3) { delete $t{lc(s/^shop\.//r)} for split /\s*,\s*/, $4 }
      else               { delete $t{lc $5}; $t{lc $6} = 1 }
    }
  }
  print "$_\n" for sort keys %t;
' $mig_files)" || { echo "check-schema-names: FAIL — không đọc được file migration"; exit 1; }

# shellcheck disable=SC2086
doc_tables="$(perl -e '
  my %t;
  my %ext = map { $_ => 1 } qw(md sh sql yaml yml json mod pl txt go ts tsx js);
  my %schema = map { $_ => 1 } qw(shop public pg_catalog information_schema);
  for my $f (@ARGV) {
    open my $h, "<", $f or die "$f: $!";
    my $in_bang = 0;
    while (my $line = <$h>) {
      if ($line =~ /^\|\s*Bảng\b/) { $in_bang = 1; next }
      if ($line !~ /^\|/)          { $in_bang = 0 }
      if ($in_bang && $line =~ /^\|\s*[^|`]*`([a-z_][a-z0-9_]*)/) { $t{$1} = 1 }
      while ($line =~ /`([a-z_][a-z0-9_]*)\.([a-z_][a-z0-9_]*)`/g) {
        next if $ext{$2} || $schema{$1};
        $t{$1} = 1;
      }
    }
    close $h;
  }
  print "$_\n" for sort keys %t;
' $doc_files)" || { echo "check-schema-names: FAIL — không đọc được tài liệu"; exit 1; }

n_mig="$(printf '%s' "$mig_tables" | grep -c .)"
n_doc="$(printf '%s' "$doc_tables" | grep -c .)"
diff="$(comm -3 <(printf '%s\n' "$mig_tables") <(printf '%s\n' "$doc_tables") | grep .)"

status="PASS"
reason="$n_mig bảng ở migration, $n_doc bảng tài liệu nhắc, comm -3 rỗng"
if [ -n "$mig_files" ] && [ "$n_mig" -eq 0 ]; then
  status="FAIL"; reason="$MIG_DIR có file mà không đọc ra bảng nào — biểu thức lọc sai? (F-017)"
elif [ -n "$doc_files" ] && [ "$n_doc" -eq 0 ]; then
  status="FAIL"; reason="$DOC_DIR có file mà không đọc ra bảng nào — biểu thức lọc sai? (F-017)"
elif [ -n "$diff" ]; then
  status="FAIL"; reason="tên bảng tài liệu và migration lệch nhau — ghi một dòng F-XXX (ADR-053 luật 2), đừng sửa migration cho khớp chữ"
fi

echo "check-schema-names: $status — $reason"
echo "  migration ($MIG_DIR/*.up.sql, $n_mig): $(printf '%s' "$mig_tables" | tr '\n' ' ')"
echo "  tài liệu ($DOC_DIR/*.md, $n_doc): $(printf '%s' "$doc_tables" | tr '\n' ' ')"
if [ -n "$diff" ]; then
  printf '%s\n' "$diff" | while IFS= read -r l; do
    case "$l" in
      $'\t'*) echo "  chỉ tài liệu nhắc, migration không có: ${l#$'\t'}" ;;
      *)      echo "  chỉ migration có, tài liệu không nhắc: $l" ;;
    esac
  done
else
  echo "  comm -3: (rỗng)"
fi
[ "$status" = "PASS" ]
