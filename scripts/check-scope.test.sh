#!/usr/bin/env bash
# Test cho Gate 3 (scripts/check-scope.sh) — mỗi task một file scope ở
# work/scope/<MÃ>.txt (T-085, docs/decisions.md ADR-063; trước đó CLAUDE.md §6,
# work/findings.md F-020).
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

same() { # same <tên ca> <mong đợi> <thực tế>
  if [ "$2" = "$3" ]; then
    echo "  ok   $1"
  else
    echo "  FAIL $1 — mong đợi '$2', nhận '$3'"; fails=$((fails + 1))
  fi
}

# newrepo <tên> — repo git tạm như repo thật: work/scope/.gitignore bỏ qua mọi
# file scope, work/scope.txt là stub chỉ-comment
newrepo() {
  local d="$TMPROOT/$1"
  mkdir -p "$d/work/scope" && git -C "$d" init -q
  git -C "$d" config user.email t@t && git -C "$d" config user.name t
  echo one > "$d/a.txt"; echo one > "$d/b.txt"
  printf '# stub\n' > "$d/work/scope.txt"
  printf '*\n!.gitignore\n' > "$d/work/scope/.gitignore"
  git -C "$d" add -A && git -C "$d" commit -qm init
  printf '%s' "$d"
}

# setscope <repo> <mã> <pattern>...
setscope() {
  local d="$1" id="$2"; shift 2
  { echo "# $id"; printf '%s\n' "$@"; } > "$d/work/scope/$id.txt"
}

run() {     # run <repo> → in ra exit code
  ( cd "$1" && "$SCRIPT" >/dev/null 2>&1; echo $? )
}
run_out() { # run_out <repo> → in ra toàn bộ output
  ( cd "$1" && "$SCRIPT" 2>&1 )
}

echo "=== check-scope.sh ==="

# 1. Nền: một file scope khớp đúng thay đổi → PASS
r="$(newrepo baseline)"; setscope "$r" T-001 "a.txt"
echo two > "$r/a.txt"
check "nền (một task, trong scope)" 0 "$(run "$r")"

# 2. Thay đổi nằm ngoài mọi file scope → FAIL, nêu đích danh
r="$(newrepo outside)"; setscope "$r" T-001 "a.txt"
echo two > "$r/b.txt"
check "ngoài scope → FAIL" 1 "$(run "$r")"
contains "nêu file ngoài scope" "- b.txt" "$(run_out "$r")"

# 3. Hai task song song, mỗi task một file: thay đổi của cả hai đều được phép, và
#    file scope của task này không bị task kia ghi đè (lý do tồn tại của T-085)
r="$(newrepo two-tasks)"; setscope "$r" T-001 "a.txt"; setscope "$r" T-002 "b.txt"
echo two > "$r/a.txt"; echo two > "$r/b.txt"
check "hai file scope, hợp của hai → PASS" 0 "$(run "$r")"

# 4. Dòng `!` chỉ có hiệu lực trong chính file của nó
r="$(newrepo deny-local)"; setscope "$r" T-001 "a.txt" "b.txt" "!b.txt"
echo two > "$r/b.txt"
check "! trong cùng file → FAIL" 1 "$(run "$r")"
setscope "$r" T-002 "b.txt"
check "task khác cho phép → PASS" 0 "$(run "$r")"

# 5. Không có file scope nào → bỏ qua như cũ
r="$(newrepo none)"
echo two > "$r/b.txt"
check "chưa khai scope → bỏ qua" 0 "$(run "$r")"
contains "nói rõ là bỏ qua" "scope not declared" "$(run_out "$r")"

# 6. File scope không hiện thành file chưa track, và không bị git thấy
r="$(newrepo ignored)"; setscope "$r" T-001 "a.txt"
same "file scope bị git bỏ qua" "" "$(git -C "$r" status --porcelain -- work/scope)"

# 7. work/scope.txt còn pattern (cách khai cũ) → FAIL, kể cả khi scope mới xanh
r="$(newrepo legacy)"; setscope "$r" T-001 "a.txt"
echo "a.txt" >> "$r/work/scope.txt"
echo two > "$r/a.txt"
check "work/scope.txt còn pattern → FAIL" 1 "$(run "$r")"
contains "chỉ đường sang cơ chế mới" "work/scope/<MÃ-TASK>.txt" "$(run_out "$r")"
r="$(newrepo legacy-noscope)"; echo "a.txt" >> "$r/work/scope.txt"
check "work/scope.txt còn pattern, chưa có scope mới → vẫn FAIL" 1 "$(run "$r")"

# 8. Một file scope bị ép vào git (`git add -f`) → FAIL (F-020)
r="$(newrepo forced)"; setscope "$r" T-001 "a.txt"
git -C "$r" add -f work/scope/T-001.txt && git -C "$r" commit -qm "bad"
check "file scope bị track → FAIL" 1 "$(run "$r")"
contains "nêu F-020" "F-020" "$(run_out "$r")"

# 9. Pattern CHẾT hay LẶP không chặn gate (ca cũ của T-047)
r="$(newrepo dead-dup)"; setscope "$r" T-001 "a.txt" "a.txt" "khong-ton-tai.md"
echo two > "$r/a.txt"
check "pattern chết/lặp không chặn gate" 0 "$(run "$r")"

# 10. --match --task: chấm theo file scope của đúng mã ấy
r="$(newrepo match)"; setscope "$r" T-001 "a.txt"; setscope "$r" T-002 "b.txt"
same "--task T-001 chấm riêng T-001" "b.txt" \
  "$(cd "$r" && "$SCRIPT" --match --task T-001 a.txt b.txt)"
same "--task không có file → hợp mọi scope" "" \
  "$(cd "$r" && "$SCRIPT" --match --task T-404 a.txt b.txt)"
same "không --task → hợp mọi scope" "c.txt" \
  "$(cd "$r" && "$SCRIPT" --match a.txt b.txt c.txt)"

if [ "$fails" -ne 0 ]; then
  echo "check-scope: $fails ca FAIL"; exit 1
fi
echo "check-scope: tất cả ca đều qua."
