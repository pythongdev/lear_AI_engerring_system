#!/usr/bin/env bash
# Gate 1d — ranh giới pha (CLAUDE.md §2.2, docs/decisions.md ADR-035)
#
# VÌ SAO CÓ:
#   Pha 1 (system design) không được đặt tên thứ pha 2/3/4 sở hữu: tên bảng,
#   tên cột, khoá ngoại, endpoint, route. Trước gate này không script nào đọc
#   được ranh giới đó — chỉ có P1-12 và mắt người. Đây đúng là chỗ một LLM
#   trượt: nó *biết* schema trông thế nào, nên câu văn nó viết ra rất hợp lý.
#
# BẮT GÌ:
#   Các mẫu chắc chắn thuộc pha sau, trong file pha 1 đã thay đổi.
#   Cố ý bảo thủ — bắt lớp vi phạm phổ biến nhất, im lặng khi không chắc.
#   Nó KHÔNG bắt hết. P1-12 và mắt người vẫn là lớp cuối.
#
# KHÔNG BẮT:
#   Mọi thứ ngoài docs/product/1-system-design/.
#   File chưa thay đổi trong lượt này.
#   Dòng đã khai trong scripts/check-phase-boundary.ignore.
#
# EXIT: 0 = sạch hoặc không có gì để soát · 1 = có vi phạm

set -uo pipefail

PHASE1_DIR="docs/product/1-system-design"
IGNORE_FILE="scripts/check-phase-boundary.ignore"

# Chỉ soát file pha 1 đã đổi trong lượt này (tracked + untracked).
changed=$(
  {
    git diff --name-only HEAD -- "$PHASE1_DIR" 2>/dev/null
    git ls-files --others --exclude-standard -- "$PHASE1_DIR" 2>/dev/null
  } | sort -u
)

[ -z "$changed" ] && exit 0

# Lọc lại: chỉ .md còn tồn tại trên đĩa.
files=""
while IFS= read -r f; do
  [ -f "$f" ] || continue
  case "$f" in *.md) files="$files $f" ;; esac
done <<< "$changed"

[ -z "${files// /}" ] && exit 0

# --- Các mẫu thuộc pha sau ---------------------------------------------------
# Pha 2 — schema
PAT_DB='CREATE[[:space:]]+TABLE|ALTER[[:space:]]+TABLE|DROP[[:space:]]+TABLE'
PAT_DB="$PAT_DB"'|FOREIGN[[:space:]]+KEY|PRIMARY[[:space:]]+KEY|REFERENCES[[:space:]]+[a-z_]+[[:space:]]*\('
PAT_DB="$PAT_DB"'|\b(VARCHAR|BIGINT|SERIAL|TIMESTAMPTZ|NOT[[:space:]]+NULL)\b'

# Pha 3 — hợp đồng API
PAT_API='\b(GET|POST|PUT|PATCH|DELETE)[[:space:]]+/'
PAT_API="$PAT_API"'|/api/|/v[0-9]+/'

# Pha 4 — route / component
PAT_FE='\.(jsx|tsx|vue)\b|<[A-Z][A-Za-z]+[[:space:]]*/?>'

PATTERN="$PAT_DB|$PAT_API|$PAT_FE"

hits=$(grep -nEI "$PATTERN" $files 2>/dev/null || true)

# --- Trừ các dòng đã khai trong ignore ---------------------------------------
# Định dạng ignore: mỗi dòng là một chuỗi con; dòng trống và dòng bắt đầu
# bằng # bị bỏ qua. Mỗi mục PHẢI kèm lý do ở dòng # ngay trên nó.
if [ -n "$hits" ] && [ -f "$IGNORE_FILE" ]; then
  while IFS= read -r rule; do
    case "$rule" in ''|'#'*) continue ;; esac
    hits=$(printf '%s\n' "$hits" | grep -vF -- "$rule" || true)
  done < "$IGNORE_FILE"
fi

[ -z "$hits" ] && exit 0

echo "Gate 1d — pha 1 đang đặt tên thứ pha sau sở hữu (CLAUDE.md §2.2, ADR-035):"
echo
printf '%s\n' "$hits"
echo
echo "Pha 1 mô tả hành vi và ranh giới, không mô tả bảng, endpoint hay route."
echo "Nếu chỗ này thật sự cần: đó là tín hiệu pha 2/3/4 phải mở ra trước —"
echo "kèm thư mục và dòng chủ sở hữu trong CLAUDE.md §2, cùng một change."
echo "Nếu đây là trích dẫn cố ý: khai vào $IGNORE_FILE kèm lý do."
exit 1
