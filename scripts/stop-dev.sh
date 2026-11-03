#!/usr/bin/env bash
# Dừng server đang nghe TCP của đúng repo, kể cả make be / make fe chạy riêng.
set -euo pipefail
repo_dir=$(cd "$(dirname "$0")/.." && pwd -P)
command -v lsof >/dev/null || { echo 'Thiếu lsof để tìm server dev.' >&2; exit 1; }
stopped=0
for pid in $(lsof -nP -tiTCP -sTCP:LISTEN | sort -u); do
  cwd=$(lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p') || continue
  case "$cwd" in
    "$repo_dir/be"|"$repo_dir/fe") ;;
    *) continue ;;
  esac
  cmd=$(ps -p "$pid" -o comm=) || continue
  case "$cwd:$cmd" in
    "$repo_dir/be:"*/server|"$repo_dir/fe:"next-server*) ;;
    *) continue ;;
  esac
  kill -TERM "$pid"
  echo "Đã gửi lệnh dừng server dev PID $pid."
  stopped=1
done
if [ "$stopped" = 0 ]; then
  echo 'Không có server dev của repo đang chạy.'
fi
