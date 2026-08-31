#!/usr/bin/env bash
# Test cho Gate 7 (scripts/check-commit-block.sh) — CLAUDE.md §6.1.
#
# Chạy tay:  ./scripts/check-commit-block.test.sh
# verify.sh tự chạy mọi scripts/*.test.sh, nên gate cũng chạy nó khi scripts/ đổi.
#
# Mỗi ca dựng một repo git tạm để không đụng cây thật.

set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-commit-block.sh"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT
fails=0

# transcript <file> <case>  — case: none | block | prev-turn
transcript() {
  python3 - "$1" "$2" <<'PY'
import json, sys
path, case = sys.argv[1], sys.argv[2]
BLOCK = 'Xong.\n```bash\ngit add a.txt\ngit commit -m "T-999: x" -m "vì sao"\n```'
def user(t="làm đi"): return {"type": "user", "message": {"role": "user", "content": t}}
def tool(): return {"type": "user", "message": {"role": "user",
        "content": [{"type": "tool_result", "content": "ok"}]}}
def asst(t): return {"type": "assistant", "message": {"role": "assistant",
        "content": [{"type": "text", "text": t}]}}
rows = []
if case == "prev-turn":
    rows += [user(), asst(BLOCK), user("giờ đổi tiếp")]
else:
    rows += [user()]
rows += [asst("đang làm"), tool()]
rows += [asst(BLOCK if case == "block" else "Xong rồi nhé.")]
with open(path, "w", encoding="utf-8") as fh:
    for r in rows:
        fh.write(json.dumps(r, ensure_ascii=False) + "\n")
PY
}

# transcript_add <file> <dòng "git add …">  — khối commit với add line tự chọn
transcript_add() {
  python3 - "$1" "$2" <<'PY'
import json, sys
path, addline = sys.argv[1], sys.argv[2]
BLOCK = 'Xong.\n```bash\n%s\ngit commit -m "T-999: x" -m "vì sao"\n```' % addline
def user(t="làm đi"): return {"type": "user", "message": {"role": "user", "content": t}}
def asst(t): return {"type": "assistant", "message": {"role": "assistant",
        "content": [{"type": "text", "text": t}]}}
with open(path, "w", encoding="utf-8") as fh:
    for r in [user(), asst(BLOCK)]:
        fh.write(json.dumps(r, ensure_ascii=False) + "\n")
PY
}

# setscope <repo> <pattern>...  — ghi work/scope.txt của repo tạm
setscope() {
  local d="$1"; shift
  { echo "# scope"; printf '%s\n' "$@"; } > "$d/work/scope.txt"
}

# run <repo> <transcript> → in ra exit code
run() {
  ( cd "$1" && printf '{"transcript_path":"%s","stop_hook_active":false}' "$2" \
      | "$SCRIPT" --hook >/dev/null 2>&1; echo $? )
}

# run_err <repo> <transcript> → in ra stderr
run_err() {
  ( cd "$1" && printf '{"transcript_path":"%s","stop_hook_active":false}' "$2" \
      | "$SCRIPT" --hook 2>&1 >/dev/null )
}

newrepo() {
  local d="$TMPROOT/$1"
  mkdir -p "$d" && git -C "$d" init -q
  git -C "$d" config user.email t@t && git -C "$d" config user.name t
  mkdir -p "$d/work"
  echo one > "$d/a.txt"; echo "# scope" > "$d/work/scope.txt"
  git -C "$d" add -A && git -C "$d" commit -qm init
  printf '%s' "$d"
}

check() { # check <tên ca> <mong đợi> <thực tế>
  if [ "$2" = "$3" ]; then
    echo "  ok   $1 (exit $3)"
  else
    echo "  FAIL $1 — mong đợi exit $2, nhận $3"; fails=$((fails + 1))
  fi
}

echo "=== check-commit-block.sh ==="

# 1. cây sạch → không nhắc
r="$(newrepo clean)"; t="$r/tr.jsonl"; transcript "$t" none
check "cây sạch" 0 "$(run "$r" "$t")"

# 2. file tracked đổi, turn không có khối → chặn
r="$(newrepo dirty)"; t="$r/tr.jsonl"; transcript "$t" none
echo two > "$r/a.txt"
check "thiếu khối commit" 2 "$(run "$r" "$t")"

# 3. turn có khối → cho qua, và ghi dấu
r="$(newrepo withblock)"; t="$r/tr.jsonl"; transcript "$t" block
echo two > "$r/a.txt"
check "có khối commit" 0 "$(run "$r" "$t")"
if [ -f "$r/.git/lean-ai-commit-block" ]; then
  echo "  ok   dấu vết nằm trong .git/"
else
  echo "  FAIL không ghi .git/lean-ai-commit-block"; fails=$((fails + 1))
fi

# 4. chỉ work/scope.txt đổi → không nhắc (§6.1: nó không nằm trong khối)
r="$(newrepo scopeonly)"; t="$r/tr.jsonl"; transcript "$t" none
echo "docs/x.md" >> "$r/work/scope.txt"
check "chỉ scope.txt" 0 "$(run "$r" "$t")"

# 5. chỉ file chưa track → không nhắc (ADR-003)
r="$(newrepo untracked)"; t="$r/tr.jsonl"; transcript "$t" none
echo x > "$r/nhap.txt"
check "chỉ file chưa track" 0 "$(run "$r" "$t")"

# 6. cùng trạng thái, lần thứ hai → không nhắc lại
r="$(newrepo twice)"; t="$r/tr.jsonl"; transcript "$t" none
echo two > "$r/a.txt"
check "nhắc lần 1" 2 "$(run "$r" "$t")"
check "nhắc lần 2 cùng trạng thái" 0 "$(run "$r" "$t")"
echo three > "$r/a.txt"
check "trạng thái mới thì nhắc lại" 2 "$(run "$r" "$t")"

# 7. khối nằm ở turn TRƯỚC thì không tính cho turn này
r="$(newrepo prevturn)"; t="$r/tr.jsonl"; transcript "$t" prev-turn
echo two > "$r/a.txt"
check "khối ở turn trước" 2 "$(run "$r" "$t")"

# 8. mọi đường lỗi đều exit 0
r="$(newrepo errors)"; t="$r/tr.jsonl"; transcript "$t" none
echo two > "$r/a.txt"
check "transcript không tồn tại" 0 "$(run "$r" "$r/khong-co.jsonl")"
check "không phải hook mode" 0 \
  "$( cd "$r" && printf '{}' | "$SCRIPT" >/dev/null 2>&1; echo $? )"
check "stdin rỗng" 0 \
  "$( cd "$r" && printf '' | "$SCRIPT" --hook >/dev/null 2>&1; echo $? )"

# --- Gate 7b — trong khối commit có gì? (T-016 · F-009 · ADR-006) -----------
# Bảng ca A1–A8 là Acceptance viết trong work/backlog.md → Chi tiết T-016.
echo "--- Gate 7b: nội dung khối commit ---"

contains() { # contains <tên ca> <chuỗi mong đợi> <văn bản>
  case "$3" in
    *"$2"*) echo "  ok   $1" ;;
    *) echo "  FAIL $1 — không thấy '$2' trong stderr"; fails=$((fails + 1)) ;;
  esac
}

# A1. khối liệt kê file NGOÀI scope → kêu, và nêu đích danh
r="$(newrepo a1)"; t="$r/tr.jsonl"; setscope "$r" "a.txt"
transcript_add "$t" "git add a.txt docs/x.md"
echo two > "$r/a.txt"
check "A1 file ngoài scope" 2 "$(run "$r" "$t")"
rm -f "$r/.git/lean-ai-commit-block"
contains "A1 nêu đích danh docs/x.md" "docs/x.md" "$(run_err "$r" "$t")"

# A2. khối chỉ liệt kê file TRONG scope → im
r="$(newrepo a2)"; t="$r/tr.jsonl"; setscope "$r" "a.txt"
transcript_add "$t" "git add a.txt"
echo two > "$r/a.txt"
check "A2 file trong scope" 0 "$(run "$r" "$t")"

# A3. `git add -A` / `git add .` → kêu (CLAUDE.md §6.1 cấm đích danh hai dạng này)
r="$(newrepo a3)"; t="$r/tr.jsonl"; setscope "$r" "a.txt"
transcript_add "$t" "git add -A"
echo two > "$r/a.txt"
check "A3 git add -A" 2 "$(run "$r" "$t")"
r="$(newrepo a3b)"; t="$r/tr.jsonl"; setscope "$r" "a.txt"
transcript_add "$t" "git add ."
echo two > "$r/a.txt"
check "A3 git add ." 2 "$(run "$r" "$t")"

# A4. khối liệt kê work/scope.txt → kêu (§6: pattern không đi vào commit)
r="$(newrepo a4)"; t="$r/tr.jsonl"; setscope "$r" "a.txt" "work/"
transcript_add "$t" "git add a.txt work/scope.txt"
echo two > "$r/a.txt"
check "A4 work/scope.txt trong khối" 2 "$(run "$r" "$t")"

# A5. scope CHƯA khai → im, dù khối nhặt gì: không có gì để đối chiếu, và đoán
#     thì tệ hơn im (newrepo để scope chỉ có một dòng comment)
r="$(newrepo a5)"; t="$r/tr.jsonl"
transcript_add "$t" "git add a.txt docs/x.md"
echo two > "$r/a.txt"
check "A5 scope chưa khai" 0 "$(run "$r" "$t")"

# A6. cùng trạng thái cây → chỉ kêu một lần, nên không khoá được phiên
r="$(newrepo a6)"; t="$r/tr.jsonl"; setscope "$r" "a.txt"
transcript_add "$t" "git add a.txt docs/x.md"
echo two > "$r/a.txt"
check "A6 kêu lần 1" 2 "$(run "$r" "$t")"
check "A6 lần 2 cùng trạng thái thì im" 0 "$(run "$r" "$t")"

# A7. index thật (git diff --cached) có file ngoài scope → cũng bị nêu
r="$(newrepo a7)"; t="$r/tr.jsonl"; setscope "$r" "a.txt"
transcript_add "$t" "git add a.txt"
echo two > "$r/a.txt"
mkdir -p "$r/docs"; echo x > "$r/docs/y.md"; git -C "$r" add docs/y.md
check "A7 index ngoài scope" 2 "$(run "$r" "$t")"
rm -f "$r/.git/lean-ai-commit-block"
contains "A7 nêu đích danh docs/y.md" "docs/y.md" "$(run_err "$r" "$t")"

# A8. file CHƯA TRACK nhưng nằm trong scope → im. ADR-003 không bị lật: căn cứ
#     ở đây là scope, trạng thái track không tham gia vào kết luận.
r="$(newrepo a8)"; t="$r/tr.jsonl"; setscope "$r" "a.txt" "nhap.txt"
transcript_add "$t" "git add a.txt nhap.txt"
echo two > "$r/a.txt"; echo x > "$r/nhap.txt"
check "A8 file chưa track nhưng trong scope" 0 "$(run "$r" "$t")"

if [ "$fails" -ne 0 ]; then
  echo "check-commit-block: $fails ca FAIL"; exit 1
fi
echo "check-commit-block: tất cả ca đều qua."
