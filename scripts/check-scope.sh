#!/usr/bin/env bash
# Gate 3 — scope drift check.
#
# Compares the files changed in the working tree against the scope declared for
# the tasks in flight. Catches the failure test cannot catch: the change is
# correct but touches files the task never authorised.
#
# MỖI TASK MỘT FILE SCOPE (đổi 2026-09-27, T-085 — docs/decisions.md ADR-063):
# scope khai ở work/scope/<MÃ-TASK>.txt, ví dụ work/scope/T-085.txt. Thư mục bị
# git bỏ qua (work/scope/.gitignore), nên file scope là trạng thái của phiên
# đang chạy và không bao giờ đi vào commit (F-020), `git checkout --` hay
# `git stash` không xoá được nó (F-014), và hai phiên song song không ghi đè lên
# nhau (F-010). Trước đó mọi phiên dùng chung một work/scope.txt.
#
# Format of each scope file (one pattern per line, # starts a comment):
#   order/*        allow anything under order/
#   docs/x.md      allow exactly this file
#   !order/db.go   deny, even if an allow pattern above matches it
#
# A pattern ending in / is treated as "everything under this directory".
# Note: * matches across / (order/* also matches order/sub/a.go).
#
# Một path là TRONG SCOPE khi có ÍT NHẤT MỘT file scope cho phép nó và chính file
# ấy không cấm nó. Dòng `!` của task này không chặn file task khác được phép —
# git không biết phiên nào sửa file nào, nên hợp các scope là mức tốt nhất khi hai
# phiên chung một cây; muốn tách hẳn thì dùng worktree riêng (CLAUDE.md §7.4).
# T-319 (2026-11-11): chỉ hợp scope của task ở In Progress (kể cả đã tick)
# và mã chưa có dòng backlog. Scope của task ở mục khác là orphan, bỏ khỏi Gate 3;
# --list là chủ duy nhất phân loại để brief dùng lại, tránh chép luật (F-001).
# Không có file active/unknown nào mang pattern → scope not declared, skip.
#
# TRACKED vs UNTRACKED (đổi 2026-08-30, T-010 — xem docs/decisions.md ADR-003):
# Chỉ file **git đang theo dõi** mới làm gate đỏ. File chưa track (`??`) nằm ngoài
# scope chỉ được in thành một dòng `note:` và exit 0.
# Lý do: git không biết file chưa track có từ bao giờ, nên một file nằm sẵn trong
# cây từ trước khi task bắt đầu (prompt chưa commit, ghi chú nháp, output tạm) bị
# tính cho task đang chạy. Gate đỏ vì lý do sai dạy người ta bỏ qua gate — mất
# nhiều hơn thứ nó bắt được.
# Cái giá đã chấp nhận: file **mới** do chính task tạo ra ngoài scope nay chỉ được
# ghi chú. Dòng `note:` là chỗ nhìn thấy nó — đọc, đừng lướt.
#
# CHẾ ĐỘ --match (thêm 2026-08-31, T-016 — xem docs/decisions.md ADR-006):
#   ./scripts/check-scope.sh --match [--task <MÃ>]... <path>...
# In ra những path nằm NGOÀI scope, mỗi path một dòng, rồi exit 0. Không đọc
# `git status`, không kết luận gì về trạng thái track — người gọi tự quyết.
# Có chế độ này để `check-commit-block.sh` (Gate 7) hỏi được câu "file trong khối
# commit có thuộc scope không" mà KHÔNG phải chép lại ngữ nghĩa pattern: hai bản
# so khớp sẽ trôi khỏi nhau, đúng họ lỗi work/findings.md F-001.
# `--task <MÃ>` (T-085): chỉ chấm theo file scope của những mã ấy. Không mã nào
# có file scope ⇒ chấm theo hợp active + unknown, như khi không truyền `--task`.
#
# HAI HÌNH BẤT BIẾN (chế độ "gate", không phải --match — thay phép chấm baseline
# của T-047/ADR-043, vì F-020 nay được .gitignore chặn từ gốc):
#   - work/scope.txt còn pattern ⇒ FAIL. File ấy nay là stub chỉ-comment; cách
#     khai cũ không còn được đọc, và im lặng thì scope của phiên đó mất tác dụng
#     mà không ai biết.
#   - một file work/scope/*.txt bị git theo dõi (ai đó `git add -f`) ⇒ FAIL.
# Đếm pattern dùng ĐÚNG một phép — bỏ phần từ `#`, cắt khoảng trắng, còn khác
# rỗng — cho mọi file (work/findings.md F-001).

set -uo pipefail

MODE="gate"
case "${1:-}" in
  --match) MODE="match"; shift ;;
  --list) MODE="list"; shift ;;
esac

tasks=()
if [ "$MODE" = "match" ]; then
  while [ "${1:-}" = "--task" ]; do
    [ -n "${2:-}" ] && tasks+=("$2")
    shift 2 || break
  done
fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "check-scope: not a git repository, skipping"
  exit 0
}
cd "$ROOT" || exit 0

SCOPE_DIR="${SCOPE_DIR:-work/scope}"
LEGACY_FILE="work/scope.txt"

# patterns <file> — in mỗi pattern hữu hiệu một dòng (bỏ `#` trở đi, cắt khoảng
# trắng, bỏ dòng rỗng). Phép đếm duy nhất của repo cho "file scope có pattern".
patterns() {
  local line
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [ -n "$line" ] && printf '%s\n' "$line"
  done < "$1"
}

# --- Chọn file scope và đọc backlog tối đa một lần --------------------------
files=()
states=()
ids=()
selected=()
orphan_indices=()
fast_task_match=0
if [ "$MODE" = match ] && [ ${#tasks[@]} -gt 0 ]; then
  # Gate 7b và Gate 9 gọi theo mã. Có file của mã ấy thì chỉ đọc chúng:
  # không cần biết trạng thái backlog hay mở mọi file scope khác.
  for t in "${tasks[@]}"; do
    f="$SCOPE_DIR/$t.txt"
    if [ -f "$f" ]; then files+=("$f"); fast_task_match=1; fi
  done
fi
if [ "$fast_task_match" -eq 0 ] && [ -d "$SCOPE_DIR" ]; then
  for f in "$SCOPE_DIR"/*.txt; do
    [ -f "$f" ] && files+=("$f")
  done
fi

# Tập mã có dòng task ở In Progress và ở mục khác. Chỉ đường --list, gate,
# và --match không tìm thấy file theo mã mới cần phân loại. Awk đọc backlog
# đúng một lần, rồi bash tra mã trọn vẹn trong hai chuỗi có dấu cách phân cách.
active_ids=" "
other_ids=" "
if [ "$fast_task_match" -eq 0 ] && [ -f work/backlog.md ]; then
  while IFS=$'\t' read -r kind id; do
    if [ "$kind" = A ]; then active_ids="$active_ids$id "; else other_ids="$other_ids$id "; fi
  done < <(awk '
    /^## / { progress = ($0 == "## In Progress") }
    /^- \[[ x]\] / {
      code = substr($0, 7); sub(/[[:space:]].*$/, "", code)
      if (code != "") print (progress ? "A" : "O") "\t" code
    }
  ' work/backlog.md)
fi

# rules: "<chỉ số file>|a|<pattern>" hoặc "<chỉ số file>|d|<pattern>"
rules=()
# rstart/rend: khoảng luật của từng file trong mảng rules. Trước T-319, mỗi lần hỏi một
# file scope là quét lại MỌI luật của MỌI file (đo 2026-11-11 ở cây chính: Gate 3 mất
# 106 giây trên 222 giây của cả gate, 250 file scope và hàng chục file chưa track).
rstart=()
rend=()
nfiles=0
orphans=0
unknown_ids=()
for i in "${!files[@]}"; do
  id="${files[$i]##*/}"; id="${id%.txt}"
  ids+=("$id")
  state=unknown
  if [ "$fast_task_match" -eq 0 ]; then
    case "$active_ids" in
      *" $id "*) state=active ;;
      *) case "$other_ids" in *" $id "*) state=orphan ;; esac ;;
    esac
  fi
  states+=("$state")
  had=0
  rstart[$i]=${#rules[@]}
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    case "$p" in
      !*) pat="${p#!}"; kind=d ;;
      *)  pat="$p";     kind=a ;;
    esac
    [ "${pat%/}" != "$pat" ] && pat="${pat}*"
    rules+=("$i|$kind|$pat")
    had=1
  done < <(patterns "${files[$i]}")
  rend[$i]=${#rules[@]}
  [ "$had" -eq 1 ] || continue
  if [ "$MODE" = list ]; then
    printf '%s\t%s\n' "$state" "$id"
    continue
  fi
  if [ "$fast_task_match" -eq 1 ] || [ "$state" != orphan ]; then
    selected+=("$i")
  fi
  if [ "$state" = orphan ]; then
    orphans=$((orphans + 1)); orphan_indices+=("$i")
  elif [ "$state" = unknown ]; then
    unknown_ids+=("$id")
  fi
done
[ "$MODE" = list ] && exit 0

nfiles=${#selected[@]}

# file_allows <index> <path> — deny chỉ tác dụng trong file ấy.
file_allows() {
  local i="$1" path="$2" r k kind pat allowed=0 denied=0
  for ((k = ${rstart[$i]:-0}; k < ${rend[$i]:-0}; k++)); do
    r="${rules[$k]}"
    kind="${r#*|}"; kind="${kind%%|*}"
    pat="${r#*|*|}"
    # shellcheck disable=SC2254 # pattern must stay unquoted to glob
    case "$path" in $pat) [ "$kind" = d ] && denied=1 || allowed=1 ;; esac
  done
  [ "$allowed" -eq 1 ] && [ "$denied" -eq 0 ]
}

in_scope() {
  local path="$1" i
  for i in ${selected[@]+"${selected[@]}"}; do
    if file_allows "$i" "$path"; then return 0; fi
  done
  return 1
}

# --- Chế độ --match: chấm một danh sách path do người gọi đưa, rồi thôi --------
if [ "$MODE" = "match" ]; then
  [ "$nfiles" -gt 0 ] || exit 0
  for path in "$@"; do
    [ -n "$path" ] || continue
    in_scope "$path" || printf '%s\n' "$path"
  done
  exit 0
fi

if [ "$orphans" -gt 0 ]; then
  echo "check-scope: note — $orphans file scope của việc không ở In Progress bị bỏ qua (xem: ./scripts/check-scope.sh --list)"
fi
if [ ${#unknown_ids[@]} -gt 0 ]; then
  echo "check-scope: note — mã chưa có dòng trong work/backlog.md: ${unknown_ids[*]}"
fi

# --- Hai hình bất biến -------------------------------------------------------
invariant_fail=0
if [ -f "$LEGACY_FILE" ] && [ -n "$(patterns "$LEGACY_FILE")" ]; then
  echo "check-scope: FAIL — $LEGACY_FILE còn pattern, nhưng file này không còn được đọc (T-085,"
  echo "  ADR-063). Chuyển các pattern sang $SCOPE_DIR/<MÃ-TASK>.txt — một file cho mỗi task —"
  echo "  rồi để $LEGACY_FILE chỉ còn comment."
  invariant_fail=1
fi
tracked="$(git -c core.quotepath=false ls-files -- "$SCOPE_DIR" 2>/dev/null | grep '\.txt$')"
if [ -n "$tracked" ]; then
  echo "check-scope: FAIL — file scope đang bị git theo dõi; file scope là trạng thái của phiên,"
  echo "  không bao giờ đi vào git (work/findings.md F-020). Gỡ khỏi index: git rm --cached <file>"
  printf '  - %s\n' $tracked
  invariant_fail=1
fi

if [ "$nfiles" -eq 0 ]; then
  echo "check-scope: $SCOPE_DIR/ has no scope file with patterns — scope not declared, skipping"
  exit "$invariant_fail"
fi

violations=()
orphan_matches=()
untracked=()
while IFS= read -r line; do
  [ -n "$line" ] || continue
  status="${line:0:2}"
  path="${line:3}"
  case "$path" in *" -> "*) path="${path##* -> }" ;; esac
  path="${path%\"}"; path="${path#\"}"
  [ -n "$path" ] || continue

  # File khai báo scope không bao giờ nằm trong scope nó khai báo (2026-08-30):
  # khai scope là việc BẮT BUỘC của mọi task L1+ (CLAUDE.md §3.4), nên tính nó là
  # vi phạm thì mọi task khai đúng luật đều mở màn bằng một Gate 3 đỏ (ADR-003).
  case "$path" in "$SCOPE_DIR"/*.txt) continue ;; esac

  in_scope "$path" && continue

  if [ "$status" = "??" ]; then
    untracked+=("$path")
  else
    violations+=("$path")
    matched=""
    for i in ${orphan_indices[@]+"${orphan_indices[@]}"}; do
      if file_allows "$i" "$path"; then matched="${matched:+$matched }${ids[$i]}"; fi
    done
    orphan_matches+=("$matched")
  fi
done < <(git -c core.quotepath=false status --porcelain --untracked-files=all)

if [ ${#untracked[@]} -gt 0 ]; then
  echo "check-scope: note — file chưa được git theo dõi, nằm ngoài scope (không chặn gate):"
  printf '  ? %s\n' "${untracked[@]}"
  echo "  Nếu file nào trong số này do chính task vừa tạo ra: đưa vào scope, hoặc xoá đi."
fi

if [ ${#violations[@]} -gt 0 ]; then
  echo "check-scope: FAIL — files changed outside every scope declared in $SCOPE_DIR/:"
  for i in "${!violations[@]}"; do
    printf '  - %s\n' "${violations[$i]}"
    [ -n "${orphan_matches[$i]}" ] && printf '    khớp scope của %s; đang làm thì đưa %s về In Progress.\n' "${orphan_matches[$i]}" "${orphan_matches[$i]}"
  done
  echo "Revert them, or update your $SCOPE_DIR/<MÃ-TASK>.txt if the task scope genuinely changed."
  exit 1
fi

[ "$invariant_fail" -eq 1 ] && exit 1

echo "check-scope: OK — all tracked changes within declared scope ($nfiles scope file(s))."
