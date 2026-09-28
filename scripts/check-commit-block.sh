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
#  2. File scope không bao giờ tính — work/scope/<MÃ>.txt bị git bỏ qua (T-085,
#     ADR-063), nên khai scope không bao giờ biến thành lời nhắc.
#  3. Nhắc **một lần cho mỗi trạng thái cây**. Đã giao khối cho đúng trạng thái
#     này rồi thì turn sau không bị nhắc lại; sửa thêm file là trạng thái mới.
#     Dấu vết nằm ở .git/lean-ai-commit-block — trong .git nên không bao giờ bị
#     commit, không cần .gitignore, mất theo bản clone.
#
# Mọi đường lỗi exit 0. Một hook hỏng không được cướp mất phiên làm việc.
#
# GATE 7b (thêm 2026-08-31, T-016 — work/findings.md F-009, docs/decisions.md
# ADR-006): ngoài câu "turn này có giao khối commit không", Gate 7 nay hỏi thêm
# **trong khối đó có gì**. Ba thứ bị nêu tên:
#   1. file trong `git add …` nằm ngoài scope đã khai (chấm bằng
#      `check-scope.sh --match` — ngữ nghĩa pattern chỉ có một chủ);
#   2. `git add -A` / `git add .` — CLAUDE.md §6.1 cấm, và đây là cái đã nuốt
#      1096 dòng vào commit `0b3a337`;
#   3. một file scope `work/scope/<x>.txt` trong khối (đổi 2026-09-27, T-085 —
#      ADR-063; trước đó luật này chấm pattern trong work/scope.txt, T-047 ·
#      ADR-043). File scope là trạng thái phiên, không bao giờ đi vào git (F-020).
#
# CHẤM THEO TASK TRONG SUBJECT (T-085, ADR-063): mã ở đầu subject của mọi
# `git commit -m "<MÃ>: …"` trong turn chọn file scope để chấm — work/scope/<MÃ>.txt.
# Nhờ vậy task đã Done vẫn được chấm lúc giao khối, vì file scope nay chỉ bị xoá
# sau khi task đã commit. Không mã nào có file scope ⇒ chấm theo hợp mọi file scope.
# Nó chấm **danh sách file người ta vừa cố ý chọn**, không chấm cây làm việc, nên
# ADR-003 không bị lật: trạng thái track không tham gia vào kết luận.
# Scope chưa khai ⇒ im lặng: không có gì để đối chiếu, và đoán thì tệ hơn im.

set -uo pipefail

[ "${1:-}" = "--hook" ] || exit 0   # chạy tay thì không có transcript để đọc
[ -t 0 ] && exit 0                  # stdin là terminal → không phải hook mode

input="$(cat)"
[ -n "$input" ] || exit 0

HERE="$(cd "$(dirname "$0")" && pwd)"

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
cd "$ROOT" || exit 0

command -v python3 >/dev/null 2>&1 || exit 0

# --- Có gì đang chờ commit không? -------------------------------------------
# Bỏ dòng '??' (chưa track). File scope bị git bỏ qua nên không hiện ở đây.
dirty=""
while IFS= read -r line; do
  [ -n "$line" ] || continue
  case "$line" in '??'*) continue ;; esac
  path="${line:3}"
  case "$path" in *" -> "*) path="${path##* -> }" ;; esac
  path="${path%\"}"; path="${path#\"}"
  dirty="$dirty$path"$'\n'
done < <(git -c core.quotepath=false status --porcelain 2>/dev/null)

[ -n "$dirty" ] || exit 0

# --- Turn này đã có khối commit chưa? ---------------------------------------
# Đọc transcript, lấy mọi text của assistant SAU tin nhắn người dùng cuối cùng
# (tool_result cũng mang role user — không tính là tin nhắn người dùng).
raw="$(printf '%s' "$input" | python3 -c '
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

joined = "\n".join(text)
if "git commit -m" not in joined:
    out("no")

# Khối có rồi — trả thêm mọi dòng `git add …` để Gate 7b chấm nội dung khối.
# CLAUDE.md §6.1 đòi liệt kê TỪNG file, nên một khối thật gần như luôn phải nối
# dòng bằng `\`. Gộp các dòng nối lại TRƯỚC khi tìm `git add`, nếu không thì
# (1) `\` bị đọc thành một path tên `\` và cổng kêu một file không tồn tại, và
# (2) — chỗ đắt hơn nhiều — mọi file từ dòng thứ hai trở đi KHÔNG bắt đầu bằng
# `git add ` nên không được Gate 7b chấm lấy một lần: cổng im lặng đúng vào khối
# dài, thứ nó sinh ra để canh (F-009). Xem work/findings.md F-039.
lines = []
for line in joined.splitlines():
    if lines and lines[-1].rstrip().endswith("\\"):
        lines[-1] = lines[-1].rstrip()[:-1].rstrip() + " " + line.strip()
    else:
        lines.append(line)

print("yes")
# Mã task ở đầu subject của mọi `git commit -m "<MÃ>: …"` — Gate 7b dùng nó để
# chọn file scope work/scope/<MÃ>.txt (T-085, ADR-063).
import re
for m in re.finditer(r"git commit -m [\"\x27]([A-Z][A-Z0-9]*-[0-9]+):", joined):
    print("TASK " + m.group(1))
for line in lines:
    t = line.strip().lstrip("$").strip()
    if t.startswith("git add "):
        print("ADD " + t[8:].strip())
sys.exit(0)
' 2>/dev/null)"

has_block="$(printf '%s\n' "$raw" | head -n 1)"
add_lines="$(printf '%s\n' "$raw" | sed -n 's/^ADD //p')"
block_tasks="$(printf '%s\n' "$raw" | sed -n 's/^TASK //p' | sort -u)"

[ "$has_block" = "skip" ] && exit 0

# --- Gate 7b — trong khối commit có gì? -------------------------------------
# Căn cứ là **danh sách file vừa được cố ý chọn**: các dòng `git add …` của khối,
# cộng index thật nếu có ai đã `git add` trong phiên. Không hỏi git file này có
# đang được theo dõi không — nên ADR-003 không bị đụng tới.
# is_scope_file <path> — file scope của một task (work/scope/<x>.txt).
is_scope_file() {
  case "$1" in work/scope/*.txt) return 0 ;; esac
  return 1
}

cand=""        # path ứng viên, mỗi dòng một cái
bad_form=""    # dạng lệnh quét cả cây, CLAUDE.md §6.1 cấm
scope_in_block=""

while IFS= read -r a; do
  [ -n "$a" ] || continue
  a="${a%%#*}"                        # comment cuối dòng
  a="${a%%&&*}"; a="${a%%;*}"         # chỉ phần của chính lệnh `git add`
  for tok in $a; do
    case "$tok" in
      -A|--all|-u|--update|.|./|'*')  bad_form="$bad_form$tok " ; continue ;;
      -*|'<'*)                        continue ;;   # cờ khác, và chỗ điền mẫu
      '\\')                          continue ;;   # nối dòng shell (F-039)
    esac
    tok="${tok%\"}"; tok="${tok#\"}"
    tok="${tok%\'}"; tok="${tok#\'}"
    [ -n "$tok" ] || continue
    is_scope_file "$tok" && scope_in_block="$scope_in_block$tok "
    cand="$cand$tok"$'\n'
  done
done <<EOF
$add_lines
EOF

while IFS= read -r f; do
  [ -n "$f" ] || continue
  is_scope_file "$f" && scope_in_block="$scope_in_block$f "
  cand="$cand$f"$'\n'
done < <(git -c core.quotepath=false diff --cached --name-only 2>/dev/null)

paths=()
while IFS= read -r x; do
  [ -n "$x" ] && paths+=("$x")
done < <(printf '%s' "$cand" | sort -u)

outside=""
if [ ${#paths[@]} -gt 0 ] && [ -x "$HERE/check-scope.sh" ]; then
  # Ngữ nghĩa pattern chỉ có MỘT chủ (check-scope.sh). Scope chưa khai ⇒ nó in
  # rỗng, và im lặng là đúng: không có gì để đối chiếu.
  task_args=()
  while IFS= read -r t; do
    [ -n "$t" ] && task_args+=(--task "$t")
  done <<EOF
$block_tasks
EOF
  outside="$("$HERE/check-scope.sh" --match ${task_args[@]+"${task_args[@]}"} "${paths[@]}" 2>/dev/null)"
fi

warn=""
if [ -n "$outside" ] || [ -n "$bad_form" ] || [ -n "$scope_in_block" ]; then
  warn="commit-block: khối commit của turn này nhặt thứ nằm ngoài việc được giao"
  warn="$warn"$'\n'"(CLAUDE.md §6.1 · work/findings.md F-009 · docs/decisions.md ADR-006):"
  [ -n "$outside" ] && warn="$warn"$'\n'"  ngoài scope đã khai ở work/scope/${block_tasks:+ của $(printf '%s' "$block_tasks" | tr '\n' ' ')}:"$'\n'"$(
      printf '%s\n' "$outside" | sed 's/^/    - /')"
  [ -n "$bad_form" ] && warn="$warn"$'\n'"  dạng quét cả cây, §6.1 cấm: git add ${bad_form% }"
  [ -n "$scope_in_block" ] && warn="$warn"$'\n'"  file scope trong khối: ${scope_in_block% } — file scope là trạng thái phiên,"$'\n'"  không bao giờ đi vào commit (§6 · F-020). Bỏ nó khỏi khối."
  warn="$warn"$'\n'"Viết lại khối: liệt kê từng file của task này, không hơn. Nếu task thật sự cần"
  warn="$warn"$'\n'"chạm những file trên thì cập nhật work/scope/<MÃ>.txt và nói rõ trong báo cáo (§3.4)."
fi

# --- Trạng thái cây này đã được nhắc / đã được giao khối chưa? ---------------
STAMP=".git/lean-ai-commit-block"
state="$(
  { git -c core.quotepath=false status --porcelain 2>/dev/null; git diff HEAD 2>/dev/null; } |
  { command -v shasum >/dev/null 2>&1 && shasum || cksum; }
)"
state="${state%% *}"

if [ "$has_block" = "yes" ]; then
  # Luật 3 (đầu file) áp cho cả Gate 7b: nhắc nhiều nhất MỘT lần cho mỗi trạng
  # thái cây. Đọc dấu cũ trước, đóng dấu mới ngay — kể cả khi sắp kêu — nên một
  # cảnh báo không bao giờ khoá được phiên, chỉ xin viết lại khối đúng một lần.
  prev=""
  [ -f "$STAMP" ] && prev="$(cat "$STAMP" 2>/dev/null)"
  printf '%s\n' "$state" > "$STAMP" 2>/dev/null
  [ -n "$warn" ] || exit 0
  [ "$prev" = "$state" ] && exit 0
  printf '%s\n' "$warn" >&2
  exit 2
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
  echo "không 'git add -A', không có file scope work/scope/<MÃ>.txt trong đó:"
  echo
  echo '  ```bash'
  echo '  git add <từng file của task này>'
  echo '  git commit -m "T-XXX: đã đổi gì" -m "Vì sao. Verified: ..."'
  echo '  ```'
  [ -n "$warn" ] && { echo; printf '%s\n' "$warn"; }
} >&2
exit 2
