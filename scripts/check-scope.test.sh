#!/usr/bin/env bash
# Test cho Gate 3 (scripts/check-scope.sh) — CLAUDE.md §6, work/findings.md F-020.
#
# Chạy tay:  ./scripts/check-scope.test.sh
# verify.sh tự chạy mọi scripts/*.test.sh, nên gate cũng chạy nó khi scripts/ đổi.
#
# Mỗi ca dựng một repo git tạm để không đụng cây thật.

set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-scope.sh"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT
fails=0

check() { # check <tên ca> <mong đợi> <thực tế>
  if [ "$2" = "$3" ]; then
    echo "  ok   $1 (exit $3)"
  else
    echo "  FAIL $1 — mong đợi exit $2, nhận $3"; fails=$((fails + 1))
  fi
}

contains() { # contains <tên ca> <chuỗi mong đợi> <văn bản>
  case "$3" in
    *"$2"*) echo "  ok   $1" ;;
    *) echo "  FAIL $1 — không thấy '$2' trong output"; fails=$((fails + 1)) ;;
  esac
}

# newrepo <tên> — repo git tạm, HEAD có work/scope.txt chỉ-comment (trạng thái nền)
newrepo() {
  local d="$TMPROOT/$1"
  mkdir -p "$d/work" && git -C "$d" init -q
  git -C "$d" config user.email t@t && git -C "$d" config user.name t
  echo one > "$d/a.txt"
  printf '# scope\n' > "$d/work/scope.txt"
  git -C "$d" add -A && git -C "$d" commit -qm init
  printf '%s' "$d"
}

run() {     # run <repo> → in ra exit code
  ( cd "$1" && "$SCRIPT" >/dev/null 2>&1; echo $? )
}
run_out() { # run_out <repo> → in ra toàn bộ output
  ( cd "$1" && "$SCRIPT" 2>&1 )
}

echo "=== check-scope.sh ==="

# 1. Nền: HEAD sạch, scope hợp lệ khớp đúng thay đổi → PASS
r="$(newrepo baseline)"
echo "a.txt" >> "$r/work/scope.txt"
echo two > "$r/a.txt"
check "nền (HEAD sạch, trong scope)" 0 "$(run "$r")"

# 2. HEAD có pattern CÒN NGUYÊN trong cây → FAIL (đúng lỗ hổng F-020)
r="$(newrepo head-dirty-fail)"
echo "a.txt" >> "$r/work/scope.txt"
git -C "$r" add work/scope.txt && git -C "$r" commit -qm "bad: commit pattern"
echo two > "$r/a.txt"
check "HEAD có pattern, cây vẫn giữ → FAIL" 1 "$(run "$r")"
contains "nêu lý do F-020" "F-020" "$(run_out "$r")"

# 3. HEAD có pattern, cây làm việc ĐÃ SẠCH (đang dọn, chưa commit) → note, exit 0
r="$(newrepo head-dirty-clean)"
echo "a.txt" >> "$r/work/scope.txt"
git -C "$r" add work/scope.txt && git -C "$r" commit -qm "bad: commit pattern"
printf '# scope\n' > "$r/work/scope.txt"   # dọn sạch trong cây, chưa commit
check "HEAD nợ, cây đã sạch → note, exit 0" 0 "$(run "$r")"
contains "in ra note nhắc đưa vào khối commit" "note —" "$(run_out "$r")"

# 4. Pattern CHẾT (khớp không file nào đang đổi) không chặn gate — vẫn phải
#    dựng lại được ca cũ này sau khi thêm phép chấm baseline (không siết cách
#    khớp pattern đang chạy đúng — F-020 → Decision/Fix, luật "đừng siết nó")
r="$(newrepo dead-pattern)"
{ echo "a.txt"; echo "khong-ton-tai.md"; } >> "$r/work/scope.txt"
echo two > "$r/a.txt"
check "pattern chết không chặn gate" 0 "$(run "$r")"

# 5. Pattern LẶP (cùng một dòng khai hai lần) không chặn gate
r="$(newrepo dup-pattern)"
{ echo "a.txt"; echo "a.txt"; } >> "$r/work/scope.txt"
echo two > "$r/a.txt"
check "pattern lặp không chặn gate" 0 "$(run "$r")"

if [ "$fails" -ne 0 ]; then
  echo "check-scope: $fails ca FAIL"; exit 1
fi
echo "check-scope: tất cả ca đều qua."
