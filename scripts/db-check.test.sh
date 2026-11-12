#!/usr/bin/env bash
# Test hàm chọn project rác và dấu giữ của db-check, không cần Docker.
# Nạp đúng định nghĩa từ db-check.sh để phép kiểm không trôi khỏi code chạy thật.
set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/db-check.sh"
eval "$(sed -n '/^db_check_stale_pid() {$/,/^}$/p' "$SCRIPT")"
eval "$(sed -n '/^db_check_kept() {$/,/^}$/p' "$SCRIPT")"
if ! declare -F db_check_stale_pid >/dev/null || ! declare -F db_check_kept >/dev/null; then
  echo "db-check: FAIL — không nạp được hàm chọn project và dấu giữ"
  exit 1
fi

fails=0
check_pid() { # check_pid <tên project> <PID mong đợi>
  local name="$1" expected="$2" actual
  if actual="$(db_check_stale_pid "$name")" && [ "$actual" = "$expected" ]; then
    echo "  ok   $name → PID $actual"
  else
    echo "  FAIL $name — mong PID $expected, nhận '$actual'"
    fails=$((fails + 1))
  fi
}
check_reject() { # check_reject <tên project>
  local name="$1" actual
  if actual="$(db_check_stale_pid "$name")"; then
    echo "  FAIL $name — không được nhận PID '$actual'"
    fails=$((fails + 1))
  else
    echo "  ok   $name → từ chối"
  fi
}
check_kept() { # check_kept <tên ca> <project> <thư mục dấu> <exit mong đợi>
  local name="$1" project="$2" dir="$3" expected="$4" actual
  if db_check_kept "$project" "$dir"; then actual=0; else actual=1; fi
  if [ "$actual" = "$expected" ]; then
    echo "  ok   $name (exit $actual)"
  else
    echo "  FAIL $name — mong exit $expected, nhận $actual"
    fails=$((fails + 1))
  fi
}

echo "=== db-check.sh: chọn project rác ==="
check_pid banhcuon_check_123_be_1700000000_42 123
check_pid banhcuon_check_123_1700000000_42 123
check_pid banhcuon_check_123 123
check_reject banhcuon
check_reject banhcuon_check
check_reject banhcuon_check_0_1_2
check_reject banhcuon_check_abc

echo "=== db-check.sh: dấu giữ ==="
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT
kept_dir="$TMPROOT/lean-ai-kept-db"
mkdir -p "$kept_dir"
project=banhcuon_check_123_be_1700000000_42
check_kept "chưa có dấu" "$project" "$kept_dir" 1
: > "$kept_dir/${project}_khac"
check_kept "tên khác có cùng tiền tố" "$project" "$kept_dir" 1
: > "$kept_dir/$project"
check_kept "đúng tên có dấu" "$project" "$kept_dir" 0
check_kept "tên khác không có dấu" "${project}_nua" "$kept_dir" 1

if [ "$fails" -ne 0 ]; then
  echo "db-check: $fails ca FAIL"
  exit 1
fi
echo "db-check: tất cả ca đều qua."
