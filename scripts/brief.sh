#!/usr/bin/env bash
# Session brief — prints the CURRENT state of the system, not the state of the
# day the documents were written.
#
# Wired as a SessionStart hook in .claude/settings.json, so it runs on startup,
# /clear, resume and compaction, and its stdout lands in the session's context
# before the first instruction. That is the point: a session cannot forget to
# read something that arrives on its own.
# Also runnable by hand whenever the state may have moved under you:
#   ./scripts/brief.sh
#
# HARD RULE — this script is a POINTER, never a COPY.
# It may print file names, IDs (T-/F-/U-/ADR-), dates and headings. It must
# never restate a business fact: no price, no rule text, no channel list. A
# brief that carried the prices would be the second copy that work/findings.md
# F-001 was written about. Owners in CLAUDE.md §2 stay the only place to read.
#
# Never blocks a session: every failure path still exits 0.

set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "brief: not a git repository — no state to report."
  exit 0
}
cd "$ROOT" || exit 0

# Ngưỡng cắt. Cắt là quyết định ĐÚNG — brief trỏ chứ không chép (CLAUDE.md §7.1),
# và một brief dài bốn mươi dòng thì không ai đọc. Thứ từng hỏng là cắt mà KHÔNG
# NÓI đã cắt: danh sách bảy mục in ra sáu mục, trông y hệt một danh sách sáu mục,
# nên U-011 vô hình với mọi phiên mới kể từ dòng đầu tiên nó được viết ra
# (work/findings.md F-012 · T-027). Sửa bằng cách nói ra, không bằng cách nâng số:
# số nào cũng có một danh sách vượt qua nó, và lúc đó im lặng vẫn im lặng.
MAX_LIST=6        # In Progress · Ready · Open findings — ba danh sách để định hướng.

# Câu hỏi mở có ngưỡng RIÊNG, và đó là một quyết định, không phải một hằng số bị
# quên. Ba danh sách kia trả lời "làm gì tiếp"; danh sách này là thứ CLAUDE.md
# §3.5 bắt phiên phải BIẾT trước khi nó tự suy ra một câu trả lời. Nó cũng ngắn
# tự nhiên — bảy câu là đỉnh từ trước tới nay — nên ngưỡng đặt cao hơn hẳn: cắt
# nó phải là chuyện hiếm, và khi xảy ra thì nói thẳng hậu quả (F-012).
MAX_UNKNOWNS=12

section() { printf '\n%s\n' "$1"; }
none()    { printf '  (none)\n'; }

# emit <max> <đọc đủ ở đâu> [dòng nói thêm khi bị cắt]   — danh sách vào từ stdin.
# In tối đa <max> mục, rồi NÓI RA phần đã cắt: in mấy trên mấy, còn mấy, đọc ở đâu.
# Người đọc phải phân biệt được "hết rồi" với "còn nữa"; im lặng thì không.
emit() {
  local max="$1" where="$2" extra="${3-}" items total
  items="$(cat)"
  if [ -z "$items" ]; then none; return 0; fi
  total="$(printf '%s\n' "$items" | grep -c .)"
  printf '%s\n' "$items" | head -n "$max" | sed 's/^/  /'
  if [ "$total" -gt "$max" ]; then
    printf '  → ĐÃ CẮT: in %s/%s mục. Còn %s mục nữa chỉ có ở %s.\n' \
      "$max" "$total" "$((total - max))" "$where"
    [ -n "$extra" ] && printf '%s\n' "$extra" | sed 's/^/    /'
  fi
  return 0   # brief không bao giờ đổi mã thoát (CLAUDE.md §7.1)
}

# Lines of a "## Heading" block in a markdown file, up to the next "## ".
block() {
  local file="$1" heading="$2"
  [ -f "$file" ] || return 0
  awk -v h="$heading" '
    $0 == h { inblk = 1; next }
    inblk && /^## / { exit }
    inblk { print }
  ' "$file"
}

printf '=== Lean AI Engineering — session brief (%s) ===\n' "$(date +%F)"
printf 'Read CLAUDE.md first. This brief points; the owners in §2 hold the facts.\n'

# --- What is being worked on -------------------------------------------------
section "IN PROGRESS (work/backlog.md)"
# Không cắt ở đây nữa: $inprog phải là danh sách ĐỦ, vì cảnh báo scope bên dưới
# hỏi "có task nào đang chạy không" — cắt xong mới hỏi là hỏi trên một nửa sự thật.
inprog="$(block work/backlog.md '## In Progress' | grep -E '^- \[')"
printf '%s\n' "$inprog" | emit "$MAX_LIST" 'work/backlog.md → In Progress'

section "DECLARED SCOPE (work/scope.txt)"
# Scope đã khai + có task In Progress = bình thường. Scope đã khai + KHÔNG có task
# nào In Progress = scope của task trước chưa dọn (CLAUDE.md §7.3) — đã đi thẳng
# vào hai commit, `5c41f65` và `25f0f88`. Xem docs/decisions.md ADR-006.
# Cảnh báo, không chặn: brief không bao giờ đổi mã thoát (§7.1).
if [ -f work/scope.txt ]; then
  # No cap here. A scope line hidden by truncation is a scope line nobody
  # honours, and Gate 3 would then reject a file the brief said nothing about.
  scope="$(grep -vE '^\s*(#|$)' work/scope.txt)"
  if [ -n "$scope" ]; then
    printf '%s\n' "$scope" | sed 's/^/  /'
    if [ -n "$inprog" ]; then
      printf '  → a task is open. Finish or hand it off before starting another.\n'
    else
      npat="$(printf '%s\n' "$scope" | grep -c .)"
      printf '  → CẢNH BÁO: work/scope.txt còn %s pattern nhưng work/backlog.md không có\n' "$npat"
      printf '    task nào ở In Progress. Scope của task đã xong chưa được dọn (CLAUDE.md §7.3).\n'
      printf '    Dọn nó TRƯỚC khi bắt task mới: Gate 3 sẽ chấm bạn bằng scope của người khác,\n'
      printf '    và §6 cấm pattern đi vào commit. Nếu bạn đang giữa một task: mở lại nó ở\n'
      printf '    In Progress, đừng xoá scope.\n'
    fi
  else
    printf '  (not declared — no task in flight, or an L0 change)\n'
  fi
else
  printf '  (no work/scope.txt)\n'
fi

# --- Cổng nào đang thật sự đứng gác -----------------------------------------
# Gate 8 (scripts/hooks/commit-msg) sống trong `.git/`, mà `.git/` không đi theo
# `git clone`: một bản clone mới có file hook trong repo nhưng KHÔNG có nó đang
# chạy, và không có gì kêu lên. Đây là chỗ kêu (docs/decisions.md ADR-010,
# work/findings.md F-011). Cảnh báo, không chặn — brief không đổi mã thoát (§7.1).
if [ -x scripts/install-hooks.sh ]; then
  if ! ./scripts/install-hooks.sh --check >/dev/null 2>&1; then
    section "GIT HOOKS (scripts/hooks/)"
    printf '  → CẢNH BÁO: Gate 8 CHƯA cài trong bản clone này. `git commit -m` gõ tay\n'
    printf '    không bị chấm gì cả — đúng lỗ hổng work/findings.md F-011.\n'
    printf '    Cài một lần:  ./scripts/install-hooks.sh\n'
  fi
fi

section "NEXT READY (work/backlog.md)"
block work/backlog.md '## Ready' | grep -E '^- \[ \]' \
  | emit "$MAX_LIST" 'work/backlog.md → Ready'

# --- What is unresolved ------------------------------------------------------
# An Open finding that blocks a Ready task is done first (CLAUDE.md §3.3).
section "OPEN FINDINGS (work/findings.md)"
openf="$(awk '
  /^### F-/ { title = $0; sub(/^### /, "", title); status = "" ; next }
  /^\*\*Status:\*\*/ { getline s; gsub(/^[ \t]+|[ \t]+$/, "", s);
                       if (s == "Open" && title != "") print title; title = "" }
' work/findings.md 2>/dev/null)"
printf '%s\n' "$openf" | emit "$MAX_LIST" 'work/findings.md (mục có **Status:** Open)'

section "OPEN UNKNOWNS (docs/product/99-unknowns.md → Unknowns)"
# Đọc CẤU TRÚC, không đọc hình dạng dòng (T-021 · ADR-007 · work/findings.md F-008).
# Bản cũ grep '^\s*[-*]?\s*U-[0-9]' trên cả mục, nên hỏng hai chiều cùng lúc:
# một dấu `*` chen vào trước định danh là giấu mất câu đang mở, còn một dòng văn
# xuôi vắt đúng chỗ để bắt đầu bằng `U-004` là in một câu đã đóng như đang mở.
# Hợp đồng thay thế nó — viết ở docs/product/99-unknowns.md ngay đầu mục Unknowns
# (DOC-2 · ADR-014 chỉ đổi ĐƯỜNG DẪN; thuật toán dưới đây giữ nguyên từng dòng):
#   1. vùng đang mở = đầu mục (trước '###' đầu tiên) + mọi khối dưới '### Đang mở';
#      mọi thứ dưới một tiêu đề '###' khác đều không được đọc;
#   2. trong vùng đó, một gạch đầu dòng = một unknown đang mở;
#   3. định danh U-XXX tìm ở bất cứ đâu trong gạch đầu dòng ấy.
# Trang trí và cách vắt dòng không còn tham gia vào kết luận.
openu="$(block docs/product/99-unknowns.md '## Unknowns' \
  | awk 'BEGIN { open = 1 }
         /^### / { open = ($0 ~ /^###[ \t]+Đang mở/); next }
         open' \
  | awk '
      function flush(   id, rest, cut, n, w, i) {
        if (item == "") return
        if (match(item, /U-[0-9]+/)) {
          id   = substr(item, RSTART, RLENGTH)
          rest = substr(item, RSTART + RLENGTH)
          gsub(/[*_`~]/, "", rest)                 # in đậm/nghiêng không phải dữ liệu
          sub(/^[ \t]*[-—:]+[ \t]*/, "", rest)     # dấu nối ngay sau định danh
          gsub(/[ \t]+/, " ", rest)                # dòng đã nối lại -> một khoảng trắng
          sub(/^ /, "", rest); sub(/ $/, "", rest)
          # Cắt theo TỪ, không theo ký tự: substr() ở đây đếm byte, nên cắt giữa
          # một chữ tiếng Việt là để lại byte hỏng, và regex kế tiếp chết vì
          # "towc: multibyte conversion failure" — brief mất luôn mục Unknowns.
          if (length(rest) > 96) {
            n = split(rest, w, " "); cut = ""
            for (i = 1; i <= n; i++) {
              if (cut != "" && length(cut " " w[i]) > 96) break
              cut = (cut == "" ? w[i] : cut " " w[i])
            }
            if (cut != "") rest = cut "…"
          }
          print (rest == "" ? id : id " — " rest)
        }
        item = ""
      }
      /^[ \t]*[-*+][ \t]/ { flush(); sub(/^[ \t]*[-*+][ \t]+/, ""); item = $0; next }
      /^[ \t]*$/           { flush(); next }
      item != ""            { item = item " " $0 }
      END                   { flush() }
    ' \
  )"
printf '%s\n' "$openu" \
  | emit "$MAX_UNKNOWNS" 'docs/product/99-unknowns.md → Unknowns → Đang mở' \
      'Câu hỏi không có trong brief là câu hỏi phiên này không biết là mình đang
thiếu, và CLAUDE.md §3.5 chỉ dừng được phiên BIẾT mình thiếu. Đọc hết mục
đó TRƯỚC khi quyết bất cứ điều gì chạm tới nghiệp vụ.'

# --- What was decided --------------------------------------------------------
section "LATEST DECISIONS (docs/decisions.md)"
adr="$(grep -E '^### ADR-' docs/decisions.md 2>/dev/null | grep -v ' — Title$' | tail -n 3)"
if [ -n "$adr" ]; then printf '%s\n' "$adr" | sed 's/^### /  /'; else none; fi

# --- What moved since last time ----------------------------------------------
section "RECENT COMMITS"
git log -n 5 --format='  %h %ad %s' --date=short 2>/dev/null || none

section "OWNER FILES — last changed (CLAUDE.md §2)"
# Re-read any owner whose date is newer than the fact you are carrying in your
# head. Dates come from git, so they cannot go stale the way a hand-typed
# "last updated" line does.
for f in \
  docs/product/ docs/architecture.md docs/decisions.md \
  quality/invariants.md work/backlog.md work/findings.md \
  master_plan/shop-facts.md CLAUDE.md
do
  # -e, không -f: owner docs/product/ là một THƯ MỤC, và [ -f ] trên thư mục là
  # false — dòng ấy sẽ biến mất im lặng, đúng kiểu hỏng mà brief không được phép.
  [ -e "$f" ] || continue
  d="$(git log -1 --format=%ad --date=short -- "$f" 2>/dev/null)"
  [ -n "$d" ] || d="uncommitted"
  printf '  %-30s %s\n' "$f" "$d"
done

section "UNCOMMITTED"
dirty="$(git -c core.quotepath=false status --porcelain --untracked-files=all 2>/dev/null | head -n 10)"
if [ -n "$dirty" ]; then
  printf '%s\n' "$dirty" | sed 's/^/  /'
  printf '  → someone was mid-change. Understand it before editing on top of it.\n'
else
  printf '  (clean)\n'
fi

printf '\n'
exit 0
