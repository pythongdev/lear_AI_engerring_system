#!/usr/bin/env bash
# Test cho Gate 1b (scripts/check-links.sh).
#
# Chạy tay:  ./scripts/check-links.test.sh
# verify.sh tự chạy mọi scripts/*.test.sh, nên gate cũng chạy nó khi scripts/ đổi.
#
# Mỗi ca dựng một repo git tạm để không đụng cây thật.

set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-links.sh"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT
fails=0

newrepo() { # newrepo <tên> → in ra đường dẫn repo
  local d="$TMPROOT/$1"
  mkdir -p "$d/docs" "$d/work" "$d/quality" "$d/scripts"
  git -C "$d" init -q
  git -C "$d" config user.email t@t
  git -C "$d" config user.name t
  echo "# ok" > "$d/CLAUDE.md"
  echo "# quality" > "$d/quality/review-gate.md"
  : > "$d/ign.txt"
  printf '%s' "$d"
}

commit() { git -C "$1" add -A >/dev/null 2>&1 && git -C "$1" commit -qm t >/dev/null 2>&1; }

run() { # run <repo> → in "<exit>|<stdout một dòng>"
  local out rc
  out="$(CHECK_LINKS_IGNORE=ign.txt "$SCRIPT" "$1" 2>&1)"
  rc=$?
  printf '%s|%s' "$rc" "$(printf '%s' "$out" | tr '\n' ' ')"
}

check() { # check <tên ca> <exit mong đợi> <chuỗi phải có trong output> <kết quả run>
  local name="$1" want_rc="$2" want_txt="$3" got="$4"
  local rc="${got%%|*}" out="${got#*|}"
  if [ "$rc" = "$want_rc" ] && [[ "$out" == *"$want_txt"* ]]; then
    echo "  ok   $name (exit $rc)"
  else
    echo "  FAIL $name — mong đợi exit $want_rc + \"$want_txt\", nhận exit $rc: $out"
    fails=$((fails + 1))
  fi
}

echo "[test] check-links.sh"

# 1 — không có link chết
r="$(newrepo clean)"
printf 'Xem `quality/review-gate.md` để biết cách chấm.\n' > "$r/docs/a.md"
commit "$r"
check "repo sạch" 0 "OK" "$(run "$r")"

# 2 — tài liệu chỉ đường trỏ vào đường không tồn tại
r="$(newrepo dead)"
printf 'Nhà thật của schema là [design](design/db/01.md).\n' > "$r/docs/a.md"
commit "$r"
check "link chết trong docs/" 1 "docs/a.md :: design/db/01.md" "$(run "$r")"

# 3 — sổ ghi chép lịch sử: work/ trích dẫn đường đã chết là bằng chứng, không phải lỗi
r="$(newrepo logbook)"
printf 'F-007: `design/db/01.md` không tồn tại — đó chính là lỗi được ghi.\n' > "$r/work/findings.md"
commit "$r"
check "work/ không bị chấm" 0 "OK" "$(run "$r")"

# 4 — đường dẫn trong khối ``` là ví dụ, không phải pointer
r="$(newrepo fenced)"
{ printf 'Ví dụ khai báo scope:\n\n```text\n'; printf 'order/pricing.go\ndocs/x.md\n'; printf '```\n'; } > "$r/docs/a.md"
commit "$r"
check "khối code không bị chấm" 0 "OK" "$(run "$r")"

# 5 — có dòng ignore thì không chặn
r="$(newrepo ignored)"
printf 'Nhà thật của schema là [design](design/db/01.md).\n' > "$r/docs/a.md"
printf 'docs/a.md :: design/db/01.md   # T-999\n' > "$r/ign.txt"
commit "$r"
check "ignore có chủ" 0 "OK" "$(run "$r")"

# 6 — ignore hết hạn: đường dẫn nay mở được → gate đỏ cho tới khi gỡ dòng đó
r="$(newrepo stale)"
mkdir -p "$r/design/db"
printf 'x\n' > "$r/design/db/01.md"
printf 'Nhà thật của schema là [design](design/db/01.md).\n' > "$r/docs/a.md"
printf 'docs/a.md :: design/db/01.md   # T-999\n' > "$r/ign.txt"
commit "$r"
check "ignore hết hạn" 1 "hết hạn" "$(run "$r")"

# 7 — đường dẫn tương đối tính theo thư mục của file đang chấm
r="$(newrepo relative)"
printf 'Xem [CLAUDE.md](../CLAUDE.md).\n' > "$r/docs/a.md"
commit "$r"
check "đường dẫn tương đối" 0 "OK" "$(run "$r")"

# 8 — file .md chưa track chỉ được ghi chú, không chặn gate (ADR-003)
r="$(newrepo untracked)"
printf 'Xem `quality/review-gate.md`.\n' > "$r/docs/a.md"
commit "$r"
printf 'Bản nháp trỏ [đi đâu đó](design/db/01.md).\n' > "$r/docs/nhap.md"
check "file chưa track chỉ ghi chú" 0 "note" "$(run "$r")"

if [ "$fails" -ne 0 ]; then
  echo "check-links.test: FAIL ($fails ca)"
  exit 1
fi
echo "check-links.test: OK"
