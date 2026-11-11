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

# 11. Phân loại theo đúng dòng task, không theo chữ nhắc hoặc tiền tố mã.
r="$(newrepo list-status)"
cat > "$r/work/backlog.md" <<'EOF'
## In Progress
- [x] T-001 đã tick nhưng chưa commit
- [ ] T-999 nhắc T-555 trong chữ, không phải dòng của T-555
## Done
- [x] T-0010 mã dài hơn
EOF
setscope "$r" T-001 "a.txt"
setscope "$r" T-0010 "a.txt"
setscope "$r" T-555 "a.txt"
setscope "$r" T-777 "a.txt"
same "--list: active tick, orphan, unknown; nhắc chữ và tiền tố không khớp" \
  "$(printf 'active\tT-001\norphan\tT-0010\nunknown\tT-555\nunknown\tT-777')" \
  "$(cd "$r" && "$SCRIPT" --list)"
same "--list thoát 0" 0 "$(cd "$r" && "$SCRIPT" --list >/dev/null; echo $?)"

# 12. Scope orphan không cứu file track; active tick và unknown vẫn cứu.
r="$(newrepo orphan-gate)"
mkdir -p "$r/be"; echo one > "$r/be/x.go"
git -C "$r" add be/x.go && git -C "$r" commit -qm be
setscope "$r" T-001 "a.txt"
setscope "$r" T-002 "be/"
cat > "$r/work/backlog.md" <<'EOF'
## In Progress
- [ ] T-001 đang làm
## Done
- [x] T-002 đã xong
EOF
echo two > "$r/be/x.go"
check "orphan be/ không cứu be/x.go đã track" 1 "$(run "$r")"
contains "orphan gate nêu file" "- be/x.go" "$(run_out "$r")"
contains "orphan gate nêu mã và cách sửa" "khớp scope của T-002; đang làm thì đưa T-002 về In Progress" "$(run_out "$r")"
contains "orphan gate báo số bị bỏ qua" "1 file scope của việc không ở In Progress bị bỏ qua" "$(run_out "$r")"
same "--match --task orphan vẫn nhận be/x.go" "" \
  "$(cd "$r" && "$SCRIPT" --match --task T-002 be/x.go)"
same "--match mã không có file lùi về active + unknown" "be/x.go" \
  "$(cd "$r" && "$SCRIPT" --match --task T-404 be/x.go)"
same "--match không task bỏ orphan" "be/x.go" \
  "$(cd "$r" && "$SCRIPT" --match be/x.go)"
cat > "$r/work/backlog.md" <<'EOF'
## In Progress
- [ ] T-001 đang làm
- [x] T-002 đã tick nhưng chưa commit
EOF
check "scope của việc tick trong In Progress vẫn cứu file" 0 "$(run "$r")"
contains "OK chỉ đếm active" "(2 scope file(s))" "$(run_out "$r")"
cat > "$r/work/backlog.md" <<'EOF'
## In Progress
- [ ] T-001 đang làm
EOF
check "scope unknown cứu file" 0 "$(run "$r")"
contains "unknown có note nêu mã" "mã chưa có dòng trong work/backlog.md: T-002" "$(run_out "$r")"

# 13. Chỉ orphan thì Gate 3 vẫn báo chưa khai, song nhắc orphan.
r="$(newrepo only-orphan)"; setscope "$r" T-001 "a.txt"
printf '## Done\n- [x] T-001 đã xong\n' > "$r/work/backlog.md"
contains "chỉ orphan: scope not declared" "scope not declared" "$(run_out "$r")"
contains "chỉ orphan: vẫn có note" "1 file scope của việc không ở In Progress" "$(run_out "$r")"

# 14. Hiệu năng là một phần của hợp đồng hook: cây chính đo 2026-11-11 có 250
# scope và backlog 690 KB/4 400 dòng, bản đọc backlog mỗi scope mất 8,5 giây.
# pre-commit gọi --match --task theo từng mã; 250 lần như vậy sẽ quá nửa giờ.
# Ngưỡng SECONDS rộng để máy chậm không gây test chập chờn.
r="$(newrepo many-scopes)"
{
  echo '## In Progress'
  for i in $(seq 1 2500); do
    if [ "$i" -le 100 ]; then
      printf -- '- [ ] T-%03d đang làm\n' "$i"
    else
      printf -- '- [ ] P-%04d việc khác\n' "$i"
    fi
  done
  echo '## Done'
  for i in $(seq 1 2500); do
    if [ "$i" -le 100 ]; then
      printf -- '- [x] T-%03d đã xong\n' "$((i + 100))"
    else
      printf -- '- [x] D-%04d việc khác\n' "$i"
    fi
  done
} > "$r/work/backlog.md"
for i in $(seq 1 300); do
  setscope "$r" "$(printf 'T-%03d' "$i")" 'a.txt'
done
start=$SECONDS
list_out="$(cd "$r" && "$SCRIPT" --list)"
elapsed=$((SECONDS - start))
same "300 scope, backlog 5 002 dòng: --list đủ 300" 300 "$(printf '%s\n' "$list_out" | grep -c .)"
if [ "$elapsed" -le 5 ]; then echo "  ok   300 scope: --list trong 5 giây (${elapsed}s)"
else echo "  FAIL 300 scope: --list mất ${elapsed}s > 5s"; fails=$((fails + 1)); fi
start=$SECONDS
match_out="$(cd "$r" && "$SCRIPT" --match --task T-001 a.txt b.txt)"
elapsed=$((SECONDS - start))
same "300 scope: --match --task chấm đúng file" "b.txt" "$match_out"
if [ "$elapsed" -le 2 ]; then echo "  ok   300 scope: --match --task trong 2 giây (${elapsed}s)"
else echo "  FAIL 300 scope: --match --task mất ${elapsed}s > 2s"; fails=$((fails + 1)); fi

if [ "$fails" -ne 0 ]; then
  echo "check-scope: $fails ca FAIL"; exit 1
fi
echo "check-scope: tất cả ca đều qua."
