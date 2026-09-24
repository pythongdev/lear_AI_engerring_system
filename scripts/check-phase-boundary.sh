#!/usr/bin/env bash
# Gate 1d — ranh giới pha (CLAUDE.md §2, docs/decisions.md ADR-035 · ADR-050)
#
# VÌ SAO CÓ:
#   Một pha không được đặt tên thứ pha sau sở hữu. Trước gate này không script
#   nào đọc được ranh giới đó — chỉ có một bước rà cuối pha và mắt người. Đây
#   đúng là chỗ một LLM trượt: nó *biết* schema và endpoint trông thế nào, nên
#   câu văn nó viết ra rất hợp lý.
#
# HAI VÙNG, HAI BỘ MẪU KHÁC NHAU — đây là điểm dễ đọc sai nhất của script này:
#   docs/product/1-system-design/  (pha 1)  → đỏ với SQL · endpoint · route
#   docs/product/2-db/             (pha 2)  → đỏ với endpoint · route
#                                             IM LẶNG với SQL
#   Pha 2 PHẢI viết SQL: đó là đầu ra của nó (ADR-049 · ADR-050). Dùng chung
#   một bộ mẫu cho cả hai vùng thì hoặc pha 2 đỏ ở mọi lượt, hoặc pha 1 được
#   phép đặt tên bảng — cả hai đều mất đúng cái cổng này sinh ra để giữ.
#   Vùng pha 2 thêm 2026-09-24 bởi P2-02; trước đó vùng ấy KHÔNG có cổng nào.
#
# VÌ SAO MẪU ENDPOINT CỦA HAI VÙNG KHÁC NHAU:
#   Mẫu của pha 1 nhận 'DELETE' + khoảng trắng + chữ. Trong một file pha 2 thì
#   'ON DELETE CASCADE' và 'DELETE FROM ...' là SQL hợp lệ, nên mẫu ấy sẽ kêu
#   oan ở mọi lát lược đồ. Mẫu vùng pha 2 vì thế đòi một DẤU GẠCH CHÉO nằm
#   trong đường dẫn ngay sau động từ — đủ để bắt cả 'POST staff/debts' (bài học
#   F-041: thiếu '/' ở đầu chuỗi là toàn bộ khoảng cách giữa BẮT ĐƯỢC và KHÔNG
#   THẤY GÌ) mà không kêu oan SQL.
#
# BẮT GÌ:
#   Các mẫu chắc chắn thuộc pha sau, trong file ĐÃ THAY ĐỔI của hai vùng trên.
#   Cố ý bảo thủ — bắt lớp vi phạm phổ biến nhất, im lặng khi không chắc.
#   Nó KHÔNG bắt hết. Bước rà cuối pha (P1-12 · P2-14) và mắt người vẫn là lớp
#   cuối.
#
# KHÔNG BẮT:
#   Mọi thứ ngoài hai thư mục trên.
#   File chưa thay đổi trong lượt này.
#   Dòng đã khai trong scripts/check-phase-boundary.ignore.
#
# EXIT: 0 = sạch hoặc không có gì để soát · 1 = có vi phạm

set -uo pipefail

PHASE1_DIR="docs/product/1-system-design"
PHASE2_DIR="docs/product/2-db"
IGNORE_FILE="scripts/check-phase-boundary.ignore"

# --- file .md ĐÃ ĐỔI của một vùng (tracked + untracked) ----------------------
changed_md() { # changed_md <thư mục> → in danh sách file, cách nhau bằng khoảng trắng
  local dir="$1" out="" f
  local list
  list=$(
    {
      git diff --name-only HEAD -- "$dir" 2>/dev/null
      git ls-files --others --exclude-standard -- "$dir" 2>/dev/null
    } | sort -u
  )
  [ -z "$list" ] && return 0
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    [ -f "$f" ] || continue
    case "$f" in *.md) out="$out $f" ;; esac
  done <<< "$list"
  printf '%s' "$out"
}

# --- Các mẫu thuộc pha sau ---------------------------------------------------
# Pha 2 — schema. CHỈ áp cho vùng pha 1: trong vùng pha 2 đây là đầu ra hợp lệ.
PAT_DB='CREATE[[:space:]]+TABLE|ALTER[[:space:]]+TABLE|DROP[[:space:]]+TABLE'
PAT_DB="$PAT_DB"'|FOREIGN[[:space:]]+KEY|PRIMARY[[:space:]]+KEY|REFERENCES[[:space:]]+[a-z_]+[[:space:]]*\('
PAT_DB="$PAT_DB"'|\b(VARCHAR|BIGINT|SERIAL|TIMESTAMPTZ|NOT[[:space:]]+NULL)\b'

# Pha 3 — hợp đồng API, mẫu của VÙNG PHA 1.
# Đường dẫn KHÔNG mở đầu bằng '/' cũng là endpoint: bốn dòng hợp đồng nợ ở
# architecture.md §12.2 viết 'staff/debts', và một dấu gạch chéo thiếu ở đầu
# chuỗi là toàn bộ khoảng cách giữa BẮT ĐƯỢC và KHÔNG THẤY GÌ (F-041, T-079).
PAT_API='\b(GET|POST|PUT|PATCH|DELETE)[[:space:]]+[A-Za-z/]'
PAT_API="$PAT_API"'|/api/|/v[0-9]+/'

# Pha 3 — hợp đồng API, mẫu của VÙNG PHA 2: đòi một '/' NẰM TRONG đường dẫn
# ngay sau động từ, nên 'ON DELETE CASCADE' và 'DELETE FROM x' không kêu oan.
# Hai nhánh: '/xxx' (gạch chéo mở đầu) hoặc 'xxx/' (gạch chéo giữa đường dẫn).
PAT_API2='\b(GET|POST|PUT|PATCH|DELETE)[[:space:]]+(/[A-Za-z0-9_]|[A-Za-z0-9_:-]+/)'
PAT_API2="$PAT_API2"'|/api/|/v[0-9]+/'

# Pha 4 — route / component. Áp cho cả hai vùng.
PAT_FE='\.(jsx|tsx|vue)\b|<[A-Z][A-Za-z]+[[:space:]]*/?>'
PAT_FE="$PAT_FE"'|path=["'"'"'][^"'"'"']*/'

PATTERN1="$PAT_DB|$PAT_API|$PAT_FE"
PATTERN2="$PAT_API2|$PAT_FE"

# --- Quét một vùng -----------------------------------------------------------
scan() { # scan <thư mục> <mẫu> → in các dòng khớp, hoặc rỗng
  local dir="$1" pat="$2" files
  files="$(changed_md "$dir")"
  [ -z "${files// /}" ] && return 0
  grep -nEI "$pat" $files 2>/dev/null || true
}

hits1="$(scan "$PHASE1_DIR" "$PATTERN1")"
hits2="$(scan "$PHASE2_DIR" "$PATTERN2")"

# --- Trừ các dòng đã khai trong ignore ---------------------------------------
# Định dạng ignore: mỗi dòng là một chuỗi con; dòng trống và dòng bắt đầu
# bằng # bị bỏ qua. Mỗi mục PHẢI kèm lý do ở dòng # ngay trên nó.
if [ -f "$IGNORE_FILE" ] && { [ -n "$hits1" ] || [ -n "$hits2" ]; }; then
  while IFS= read -r rule; do
    case "$rule" in ''|'#'*) continue ;; esac
    [ -n "$hits1" ] && hits1=$(printf '%s\n' "$hits1" | grep -vF -- "$rule" || true)
    [ -n "$hits2" ] && hits2=$(printf '%s\n' "$hits2" | grep -vF -- "$rule" || true)
  done < "$IGNORE_FILE"
fi

[ -z "$hits1" ] && [ -z "$hits2" ] && exit 0

echo "Gate 1d — một pha đang đặt tên thứ pha sau sở hữu (CLAUDE.md §2, ADR-035):"
echo

if [ -n "$hits1" ]; then
  echo "pha 1 đang đặt tên thứ pha 2/3/4 sở hữu — $PHASE1_DIR"
  printf '%s\n' "$hits1"
  echo
fi

if [ -n "$hits2" ]; then
  echo "pha 2 đang đặt tên thứ pha 3/4 sở hữu — $PHASE2_DIR"
  echo "  (SQL ở vùng này là ĐẦU RA HỢP LỆ và không bị chấm; endpoint và route thì không)"
  printf '%s\n' "$hits2"
  echo
fi

echo "Pha 1 mô tả hành vi và ranh giới, không mô tả bảng, endpoint hay route."
echo "Pha 2 mô tả chỗ cất dữ liệu, không mô tả endpoint hay route — ADR-050 nói"
echo "pha 2 được viết gì thay vào cho từng câu bị cấm."
echo "Nếu chỗ này thật sự cần: đó là tín hiệu pha sau phải mở ra trước —"
echo "kèm thư mục và dòng chủ sở hữu trong CLAUDE.md §2, cùng một change."
echo "Nếu đây là trích dẫn cố ý: khai vào $IGNORE_FILE kèm lý do."
exit 1
