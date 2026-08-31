#!/usr/bin/env bash
# Cài hook git của repo này vào bản clone hiện tại.
#
#   ./scripts/install-hooks.sh          cài
#   ./scripts/install-hooks.sh --check  chỉ hỏi "đã cài chưa" (exit 1 nếu chưa)
#
# VÌ SAO PHẢI CÓ FILE NÀY (docs/decisions.md ADR-010):
# `.git/` không đi theo `git clone`, nên một hook đặt trong `.git/hooks/` chỉ bảo
# vệ đúng một máy — đúng cái bẫy work/backlog.md T-025 nêu tên. Cách duy nhất để
# hook sống trong repo là commit nó (scripts/hooks/) rồi trỏ `core.hooksPath` vào
# đó. `core.hooksPath` là config **local**, nên mỗi bản clone vẫn phải chạy lệnh
# này một lần — không có cách nào bắt buộc, chỉ có cách nói ra: brief.sh nhắc ở
# mỗi phiên (CLAUDE.md §7.1), và CLAUDE.md §6.2 viết ra lệnh này.
#
# Lưu ý người cài phải biết: `core.hooksPath` THAY THẾ `.git/hooks/`, không cộng
# thêm. Hook thật (không phải file .sample) đang nằm ở đó sẽ ngừng chạy, nên
# script nêu tên chúng ra trước khi đổi.

set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "install-hooks: không phải repo git." >&2
  exit 1
}
cd "$ROOT" || exit 1

WANT="scripts/hooks"
current="$(git config --local --get core.hooksPath 2>/dev/null || true)"

if [ "${1:-}" = "--check" ]; then
  [ "$current" = "$WANT" ] || exit 1
  [ -x "$WANT/commit-msg" ] || exit 1
  exit 0
fi

[ -d "$WANT" ] || { echo "install-hooks: thiếu thư mục $WANT" >&2; exit 1; }

if [ -n "$current" ] && [ "$current" != "$WANT" ]; then
  printf 'install-hooks: core.hooksPath đang trỏ vào "%s". Ghi đè thành "%s".\n' \
    "$current" "$WANT"
fi

# Hook thật đang nằm trong .git/hooks sẽ ngừng chạy sau khi đổi — nêu tên ra.
if [ -d .git/hooks ]; then
  live="$(find .git/hooks -maxdepth 1 -type f ! -name '*.sample' -print 2>/dev/null)"
  if [ -n "$live" ]; then
    printf 'install-hooks: CẢNH BÁO — core.hooksPath thay thế .git/hooks/, không cộng thêm.\n'
    printf '  Các hook sau sẽ ngừng chạy:\n'
    printf '%s\n' "$live" | sed 's/^/    /'
  fi
fi

chmod +x "$WANT"/* 2>/dev/null

git config --local core.hooksPath "$WANT" || {
  echo "install-hooks: không đặt được core.hooksPath." >&2
  exit 1
}

printf 'install-hooks: core.hooksPath = %s\n' "$(git config --local --get core.hooksPath)"
for h in "$WANT"/*; do
  [ -f "$h" ] || continue
  case "$h" in *.md) continue ;; esac
  printf '  %-28s %s\n' "${h#"$WANT"/}" "$([ -x "$h" ] && echo 'sẵn sàng' || echo 'CHƯA có quyền chạy')"
done
printf 'Đường thoát cho một lần commit:  git commit --no-verify\n'
exit 0
