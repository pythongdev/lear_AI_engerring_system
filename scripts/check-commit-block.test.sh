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

# run <repo> <transcript> → in ra exit code
run() {
  ( cd "$1" && printf '{"transcript_path":"%s","stop_hook_active":false}' "$2" \
      | "$SCRIPT" --hook >/dev/null 2>&1; echo $? )
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

if [ "$fails" -ne 0 ]; then
  echo "check-commit-block: $fails ca FAIL"; exit 1
fi
echo "check-commit-block: tất cả ca đều qua."
