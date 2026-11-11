#!/usr/bin/env bash
# T-320: kiểm hook bằng git commit thật trong repo tạm.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)" || exit 1
trap 'rm -rf -- "$tmp"' EXIT
repo="$tmp/repo"
mkdir -p "$repo/hooks" "$repo/scripts" "$repo/work/scope"
cp "$here/hooks/post-commit" "$repo/hooks/post-commit"
cp "$here/check-scope.sh" "$repo/scripts/check-scope.sh"
cd "$repo" || exit 1
git init -q
git config user.name Test
git config user.email test@example.test
printf 'work/scope/\n' > .gitignore
printf '# backlog\n' > work/backlog.md
printf 'nền\n' > marker
git add .gitignore work/backlog.md marker
git -c core.hooksPath=/dev/null commit -qm 'nền cho post-commit'
git config core.hooksPath "$repo/hooks"
fails=0
check() {
  local name="$1"; shift
  if "$@"; then printf '  ok   %s\n' "$name"
  else printf '  FAIL %s\n' "$name"; fails=$((fails + 1)); fi
}
commit_case() {
  printf 'thay đổi %s\n' "$1" >> marker
  git add marker
  output="$(git commit -qm "$1" 2>&1)"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    printf '  FAIL git commit thật thoát %s: %s\n' "$rc" "$output"
    fails=$((fails + 1))
  fi
}
contains() { printf '%s\n' "$output" | grep -Fq -- "$1"; }
silent() { [ -z "$output" ]; }

printf '%s\n' '- [x] T-11 đã xong' > work/backlog.md
printf 'scope\n' > work/scope/T-11.txt
printf 'scope khác\n' > work/scope/T-12.txt
commit_case 'T-11: hoàn tất task đã tick'
check 'đã tick: commit thật thoát 0, xoá đúng scope và in thông báo' \
  sh -c '[ ! -e work/scope/T-11.txt ] && [ -f work/scope/T-12.txt ]'
check 'đã tick: thông báo đúng mã' contains 'post-commit: đã xoá work/scope/T-11.txt — T-11 đã tick và vừa commit.'

printf '%s\n' '- [ ] CHAT-17 chưa xong' > work/backlog.md
printf 'scope\n' > work/scope/CHAT-17.txt
commit_case 'CHAT-17: lưu lát đầu của task'
check 'chưa tick: commit thật thoát 0 và giữ scope' test -f work/scope/CHAT-17.txt
check 'chưa tick: in lý do task nhiều commit' contains 'dòng của CHAT-17 chưa tick [x] (task nhiều commit)'
check 'chưa tick: scope mã khác còn nguyên' test -f work/scope/T-12.txt

commit_case 'ghi thay đổi không mang mã'
check 'subject không mã: commit thật thoát 0 và hook im lặng' silent
check 'subject không mã: scope khác còn nguyên' test -f work/scope/T-12.txt

commit_case 'T-99: mã không có file scope'
check 'không có file scope: commit thật thoát 0 và hook im lặng' silent
check 'không có file scope: scope khác còn nguyên' test -f work/scope/T-12.txt

git worktree add -q -b codex/P3A-07 "$tmp/nhanh phu" HEAD
commit_case 'P3A-07: nhắc gỡ worktree sau commit'
worktree_path="$(git -C "$tmp/nhanh phu" rev-parse --show-toplevel)"
printf -v quoted_path '%q' "$worktree_path"
check 'worktree: in lệnh remove, không tự chạy' contains "git worktree remove $quoted_path"
check 'worktree: in lệnh xoá nhánh, không tự chạy' contains 'git branch -D codex/P3A-07'
check 'worktree: đường dẫn và nhánh còn tồn tại' \
  sh -c 'test -d "$1" && git show-ref --verify --quiet refs/heads/codex/P3A-07' sh "$tmp/nhanh phu"

printf 'marker\n' > work/scope/L0-full.txt
commit_case 'sửa ghi chú nhỏ trong file'
check 'L0 scope phủ hết commit: in gợi ý xoá, không tự xoá' \
  contains 'post-commit: work/scope/L0-full.txt không gắn task nào và phủ hết commit này — nếu là scope của commit này thì xoá: rm work/scope/L0-full.txt'
check 'L0 scope phủ hết commit: file scope còn nguyên' test -f work/scope/L0-full.txt

printf '# không còn pattern\n' > work/scope/L0-full.txt
printf 'file-khac\n' > work/scope/L0-partial.txt
commit_case 'đổi một chữ khác trong file'
check 'L0 scope không phủ hết commit: hook im lặng' silent
check 'L0 scope không phủ hết commit: file scope còn nguyên' test -f work/scope/L0-partial.txt

printf '%s\n' '- [ ] L0-attached có dòng backlog' >> work/backlog.md
printf 'marker\n' > work/scope/L0-attached.txt
commit_case 'chỉnh một chỗ nhỏ tiếp theo'
check 'L0 scope có dòng backlog: hook im lặng' silent
check 'L0 scope có dòng backlog: file scope còn nguyên' test -f work/scope/L0-attached.txt

rm scripts/check-scope.sh
commit_case 'chỉnh ghi chú khi thiếu bộ so scope'
check 'L0 thiếu check-scope.sh: hook im lặng' silent
check 'L0 thiếu check-scope.sh: file scope còn nguyên' test -f work/scope/L0-attached.txt

if [ "$fails" -eq 0 ]; then echo 'post-commit.test: PASS'; exit 0; fi
echo "post-commit.test: FAIL — $fails ca"; exit 1
