#!/usr/bin/env bash
# Gate 3 — scope drift check.
#
# Compares the files changed in the working tree against the scope declared in
# work/scope.txt. Catches the failure test cannot catch: the change is correct
# but touches files the task never authorised.
#
# work/scope.txt format (one pattern per line, # starts a comment):
#   order/*        allow anything under order/
#   docs/x.md      allow exactly this file
#   !order/db.go   deny, even if an allow pattern above matches it
#
# A pattern ending in / is treated as "everything under this directory".
# Note: * matches across / (order/* also matches order/sub/a.go).
#
# No work/scope.txt, or one with no active patterns → scope not declared, skip.
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
#   ./scripts/check-scope.sh --match <path>...
# In ra những path nằm NGOÀI scope, mỗi path một dòng, rồi exit 0. Không đọc
# `git status`, không kết luận gì về trạng thái track — người gọi tự quyết.
# Có chế độ này để `check-commit-block.sh` (Gate 7) hỏi được câu "file trong khối
# commit có thuộc scope không" mà KHÔNG phải chép lại ngữ nghĩa pattern: hai bản
# so khớp sẽ trôi khỏi nhau, đúng họ lỗi work/findings.md F-001.
# Cách đọc pattern không đổi một dòng nào — Gate 3 vẫn hành xử y như trước.
#
# PHÉP CHẤM BASELINE (thêm 2026-09-07, T-047 — work/findings.md F-020, docs/
# decisions.md ADR-043): ngoài việc chấm file thay đổi có khớp scope không, Gate
# 3 (chế độ "gate", không phải --match) nay còn giữ MỘT hình bất biến của chính
# work/scope.txt: bản ĐÃ COMMIT (HEAD) chỉ được chứa comment — pattern là trạng
# thái phiên đang chạy, không bao giờ được đi vào git (CLAUDE.md §6). Vị ngữ:
#   - HEAD còn pattern MÀ cây làm việc vẫn giữ nguyên ⇒ FAIL. Đây đúng là lỗ
#     hổng F-020 mô tả: một pattern đã lọt vào một commit và không ai gỡ.
#   - HEAD còn pattern nhưng cây làm việc đã sạch (đang dọn, chưa commit) ⇒
#     không FAIL, chỉ in `note:` nhắc đưa work/scope.txt vào khối commit của
#     lượt này để xoá nợ. Đây là điểm hở duy nhất luật cho phép — dọn xong
#     trong cây là xanh ngay, không phải chờ tới sau khi commit.
#   - HEAD sạch ⇒ im lặng, không có gì để chấm.
# Đếm pattern ở HEAD dùng ĐÚNG một phép — bỏ phần từ `#`, cắt khoảng trắng, còn
# khác rỗng — như phần đọc $SCOPE_FILE ở dưới; không dựng file mẫu thứ hai để so
# (work/findings.md F-001). Cách đọc/khớp pattern của cây làm việc không đổi.

set -uo pipefail

MODE="gate"
if [ "${1:-}" = "--match" ]; then MODE="match"; shift; fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "check-scope: not a git repository, skipping"
  exit 0
}
cd "$ROOT" || exit 0

SCOPE_FILE="${SCOPE_FILE:-work/scope.txt}"

[ -f "$SCOPE_FILE" ] || {
  [ "$MODE" = "match" ] && exit 0
  echo "check-scope: no $SCOPE_FILE — scope not declared, skipping"
  exit 0
}

allow=()
deny=()
while IFS= read -r line || [ -n "$line" ]; do
  line="${line%%#*}"
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  [ -n "$line" ] || continue
  case "$line" in
    !*) pat="${line#!}"; [ "${pat%/}" != "$pat" ] && pat="${pat}*"; deny+=("$pat") ;;
    *)  pat="$line";     [ "${pat%/}" != "$pat" ] && pat="${pat}*"; allow+=("$pat") ;;
  esac
done < "$SCOPE_FILE"

# --- Phép chấm baseline: bản ĐÃ COMMIT của $SCOPE_FILE chỉ được chứa comment --
# Chạy TRƯỚC early-exit "scope not declared" ở dưới, vì ca cần bắt đúng là: cây
# làm việc đã sạch (nên allow/deny rỗng) nhưng HEAD vẫn còn nợ pattern cũ. Không
# chạy ở chế độ --match (Gate 7b tự có luật riêng cho work/scope.txt).
baseline_fail=0
if [ "$MODE" = "gate" ]; then
  head_content="$(git show "HEAD:$SCOPE_FILE" 2>/dev/null || true)"
  if [ -n "$head_content" ]; then
    head_dirty=0
    while IFS= read -r hline || [ -n "$hline" ]; do
      hline="${hline%%#*}"
      hline="${hline#"${hline%%[![:space:]]*}"}"
      hline="${hline%"${hline##*[![:space:]]}"}"
      [ -n "$hline" ] && head_dirty=1
    done <<< "$head_content"

    if [ "$head_dirty" -eq 1 ]; then
      if [ ${#allow[@]} -gt 0 ] || [ ${#deny[@]} -gt 0 ]; then
        echo "check-scope: FAIL — bản đã commit (HEAD) của $SCOPE_FILE còn mang pattern, và cây"
        echo "  làm việc vẫn giữ nguyên. Bản đã commit chỉ được chứa comment (CLAUDE.md §6 ·"
        echo "  work/findings.md F-020). Gỡ pattern khỏi $SCOPE_FILE trong cây làm việc, rồi đưa"
        echo "  file vào khối commit của lượt này."
        baseline_fail=1
      else
        echo "check-scope: note — $SCOPE_FILE ở HEAD còn nợ pattern cũ (đã commit), nhưng cây làm"
        echo "  việc đã sạch. Đưa $SCOPE_FILE vào khối commit của lượt này để xoá nợ"
        echo "  (work/findings.md F-020)."
      fi
    fi
  fi
fi

if [ ${#allow[@]} -eq 0 ] && [ ${#deny[@]} -eq 0 ]; then
  [ "$MODE" = "match" ] && exit 0
  echo "check-scope: $SCOPE_FILE has no patterns — scope not declared, skipping"
  [ "$baseline_fail" -eq 1 ] && exit 1
  exit 0
fi

matches() {
  local path="$1"; shift
  local pat
  for pat in "$@"; do
    # shellcheck disable=SC2254 # pattern must stay unquoted to glob
    case "$path" in $pat) return 0 ;; esac
  done
  return 1
}

# --- Chế độ --match: chấm một danh sách path do người gọi đưa, rồi thôi --------
if [ "$MODE" = "match" ]; then
  for path in "$@"; do
    [ -n "$path" ] || continue
    # `work/scope.txt` được miễn ở đây vì lý do khác Gate 3: người gọi (Gate 7)
    # có luật riêng cho nó (§6.1 cấm nó nằm trong khối commit), và luật đó nói
    # "kêu", không phải "ngoài scope". Trả nó về sẽ thành hai lời nhắc chồng nhau.
    [ "$path" = "$SCOPE_FILE" ] && continue
    if [ ${#deny[@]} -gt 0 ] && matches "$path" "${deny[@]}"; then
      printf '%s\n' "$path"
    elif [ ${#allow[@]} -eq 0 ] || ! matches "$path" "${allow[@]}"; then
      printf '%s\n' "$path"
    fi
  done
  exit 0
fi

violations=()
untracked=()
while IFS= read -r line; do
  [ -n "$line" ] || continue
  status="${line:0:2}"
  path="${line:3}"
  case "$path" in *" -> "*) path="${path##* -> }" ;; esac
  [ -n "$path" ] || continue

  # File khai báo scope không bao giờ nằm trong scope nó khai báo (2026-08-30).
  # Khai báo scope là việc BẮT BUỘC của mọi task L1+ (CLAUDE.md §3.4), nên nếu
  # tính nó là vi phạm thì mọi task khai báo đúng luật đều mở màn bằng một Gate 3
  # đỏ — và lối thoát duy nhất là tự liệt kê `work/scope.txt` vào chính nó, thứ
  # đã đi thẳng vào hai commit (T-016). Đỏ vì lý do sai dạy người ta bỏ qua gate
  # (ADR-003); `check-commit-block.sh` đã miễn trừ file này vì cùng lý do.
  [ "$path" = "$SCOPE_FILE" ] && continue

  reason=""
  if [ ${#deny[@]} -gt 0 ] && matches "$path" "${deny[@]}"; then
    reason="$path (matches a ! deny pattern)"
  elif [ ${#allow[@]} -eq 0 ] || ! matches "$path" "${allow[@]}"; then
    reason="$path"
  fi
  [ -n "$reason" ] || continue

  if [ "$status" = "??" ]; then
    untracked+=("$reason")
  else
    violations+=("$reason")
  fi
done < <(git -c core.quotepath=false status --porcelain --untracked-files=all)

if [ ${#untracked[@]} -gt 0 ]; then
  echo "check-scope: note — file chưa được git theo dõi, nằm ngoài scope (không chặn gate):"
  printf '  ? %s\n' "${untracked[@]}"
  echo "  Nếu file nào trong số này do chính task vừa tạo ra: đưa vào scope, hoặc xoá đi."
fi

if [ ${#violations[@]} -gt 0 ]; then
  echo "check-scope: FAIL — files changed outside the scope declared in $SCOPE_FILE:"
  printf '  - %s\n' "${violations[@]}"
  echo "Revert them, or update $SCOPE_FILE if the task scope genuinely changed."
  exit 1
fi

if [ "$baseline_fail" -eq 1 ]; then
  exit 1
fi

echo "check-scope: OK — all tracked changes within declared scope."
