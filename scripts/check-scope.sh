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
# Không có file scope nào mang pattern → scope not declared, skip.
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
# có file scope ⇒ chấm theo hợp mọi file scope, như khi không truyền `--task`.
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
if [ "${1:-}" = "--match" ]; then MODE="match"; shift; fi

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

# --- Chọn file scope ---------------------------------------------------------
files=()
if [ ${#tasks[@]} -gt 0 ]; then
  for t in "${tasks[@]}"; do
    [ -f "$SCOPE_DIR/$t.txt" ] && files+=("$SCOPE_DIR/$t.txt")
  done
fi
if [ ${#files[@]} -eq 0 ] && [ -d "$SCOPE_DIR" ]; then
  for f in "$SCOPE_DIR"/*.txt; do
    [ -f "$f" ] && files+=("$f")
  done
fi

# rules: "<chỉ số file>|a|<pattern>" hoặc "<chỉ số file>|d|<pattern>"
rules=()
nfiles=0
for i in "${!files[@]}"; do
  had=0
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
  [ "$had" -eq 1 ] && nfiles=$((nfiles + 1))
done

# in_scope <path> — 0 khi có một file scope cho phép path và không cấm nó.
in_scope() {
  local path="$1" i r idx kind pat allowed denied
  for i in "${!files[@]}"; do
    allowed=0; denied=0
    for r in ${rules[@]+"${rules[@]}"}; do
      idx="${r%%|*}"; [ "$idx" = "$i" ] || continue
      kind="${r#*|}"; kind="${kind%%|*}"
      pat="${r#*|*|}"
      # shellcheck disable=SC2254 # pattern must stay unquoted to glob
      case "$path" in $pat) [ "$kind" = d ] && denied=1 || allowed=1 ;; esac
    done
    [ "$allowed" -eq 1 ] && [ "$denied" -eq 0 ] && return 0
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
  fi
done < <(git -c core.quotepath=false status --porcelain --untracked-files=all)

if [ ${#untracked[@]} -gt 0 ]; then
  echo "check-scope: note — file chưa được git theo dõi, nằm ngoài scope (không chặn gate):"
  printf '  ? %s\n' "${untracked[@]}"
  echo "  Nếu file nào trong số này do chính task vừa tạo ra: đưa vào scope, hoặc xoá đi."
fi

if [ ${#violations[@]} -gt 0 ]; then
  echo "check-scope: FAIL — files changed outside every scope declared in $SCOPE_DIR/:"
  printf '  - %s\n' "${violations[@]}"
  echo "Revert them, or update your $SCOPE_DIR/<MÃ-TASK>.txt if the task scope genuinely changed."
  exit 1
fi

[ "$invariant_fail" -eq 1 ] && exit 1

echo "check-scope: OK — all tracked changes within declared scope ($nfiles scope file(s))."
