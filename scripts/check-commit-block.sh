#!/usr/bin/env bash
# Gate 7 — nội dung commit đã được giao chưa.
#
# CLAUDE.md §6.1 bắt mỗi turn kết thúc bằng một khối `git add` + `git commit`
# dán chạy được, cho phần việc chưa commit. §6.1 là kỷ luật; file này là cơ chế.
#
# Gọi từ gate.sh ở chế độ hook, SAU khi gate đã xanh:
#   printf '%s' "$hook_json" | ./scripts/check-commit-block.sh --hook
# Exit 2 = chặn Stop, stderr quay về cho phiên viết nốt khối commit.
#
# Ba luật giữ nó khỏi đỏ vì lý do sai:
#  1. Chỉ file **git đang theo dõi** mới tính (ADR-003). File chưa track không.
#  2. `work/scope.txt` không bao giờ tính — nó là working state, §6.1 cấm nó
#     nằm trong khối commit, nên khai scope không được biến thành lời nhắc.
#  3. Nhắc **một lần cho mỗi trạng thái cây**. Đã giao khối cho đúng trạng thái
#     này rồi thì turn sau không bị nhắc lại; sửa thêm file là trạng thái mới.
#     Dấu vết nằm ở .git/lean-ai-commit-block — trong .git nên không bao giờ bị
#     commit, không cần .gitignore, mất theo bản clone.
#
# Mọi đường lỗi exit 0. Một hook hỏng không được cướp mất phiên làm việc.

set -uo pipefail

[ "${1:-}" = "--hook" ] || exit 0   # chạy tay thì không có transcript để đọc
[ -t 0 ] && exit 0                  # stdin là terminal → không phải hook mode

input="$(cat)"
[ -n "$input" ] || exit 0

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
cd "$ROOT" || exit 0

command -v python3 >/dev/null 2>&1 || exit 0

# --- Có gì đang chờ commit không? -------------------------------------------
# Bỏ dòng '??' (chưa track) và bỏ work/scope.txt.
dirty=""
while IFS= read -r line; do
  [ -n "$line" ] || continue
  case "$line" in '??'*) continue ;; esac
  path="${line:3}"
  case "$path" in *" -> "*) path="${path##* -> }" ;; esac
  path="${path%\"}"; path="${path#\"}"
  [ "$path" = "work/scope.txt" ] && continue
  dirty="$dirty$path"$'\n'
done < <(git -c core.quotepath=false status --porcelain 2>/dev/null)

[ -n "$dirty" ] || exit 0

# --- Turn này đã có khối commit chưa? ---------------------------------------
# Đọc transcript, lấy mọi text của assistant SAU tin nhắn người dùng cuối cùng
# (tool_result cũng mang role user — không tính là tin nhắn người dùng).
has_block="$(printf '%s' "$input" | python3 -c '
import json, sys

def out(v):
    print(v); sys.exit(0)

try:
    hook = json.load(sys.stdin)
    path = hook.get("transcript_path") or ""
    with open(path, encoding="utf-8") as fh:
        entries = []
        for raw in fh:
            raw = raw.strip()
            if not raw:
                continue
            try:
                entries.append(json.loads(raw))
            except ValueError:
                continue
except Exception:
    out("skip")

def blocks(e):
    c = (e.get("message") or {}).get("content")
    if isinstance(c, str):
        return [{"type": "text", "text": c}]
    return c if isinstance(c, list) else []

start = 0
for i, e in enumerate(entries):
    if e.get("type") != "user":
        continue
    if any(b.get("type") == "tool_result" for b in blocks(e) if isinstance(b, dict)):
        continue          # kết quả tool, không phải người dùng nói
    start = i

text = []
for e in entries[start:]:
    if e.get("type") != "assistant":
        continue
    for b in blocks(e):
        if isinstance(b, dict) and b.get("type") == "text":
            text.append(b.get("text") or "")

out("yes" if "git commit -m" in "\n".join(text) else "no")
' 2>/dev/null)"

[ "$has_block" = "skip" ] && exit 0

# --- Trạng thái cây này đã được nhắc / đã được giao khối chưa? ---------------
STAMP=".git/lean-ai-commit-block"
state="$(
  { git -c core.quotepath=false status --porcelain 2>/dev/null; git diff HEAD 2>/dev/null; } |
  { command -v shasum >/dev/null 2>&1 && shasum || cksum; }
)"
state="${state%% *}"

if [ "$has_block" = "yes" ]; then
  printf '%s\n' "$state" > "$STAMP" 2>/dev/null
  exit 0
fi

if [ -f "$STAMP" ] && [ "$(cat "$STAMP" 2>/dev/null)" = "$state" ]; then
  exit 0   # đã giao khối cho đúng trạng thái này ở turn trước
fi

printf '%s\n' "$state" > "$STAMP" 2>/dev/null

{
  echo "commit-block: turn này chưa giao nội dung commit (CLAUDE.md §6.1)."
  echo "Đang có thay đổi git theo dõi mà chưa commit:"
  printf '%s' "$dirty" | sed 's/^/  /'
  echo "Kết thúc báo cáo bằng một khối dán chạy được ngay — liệt kê từng file,"
  echo "không 'git add -A', không có work/scope.txt trong đó:"
  echo
  echo '  ```bash'
  echo '  git add <từng file của task này>'
  echo '  git commit -m "T-XXX: đã đổi gì" -m "Vì sao. Verified: ..."'
  echo '  ```'
} >&2
exit 2
