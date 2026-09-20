#!/usr/bin/env bash
# Test cho Gate 1d (scripts/check-phase-boundary.sh).
#
# Chạy tay:  ./scripts/check-phase-boundary.test.sh
# verify.sh tự chạy mọi scripts/*.test.sh, nên gate cũng chạy nó khi scripts/ đổi.
#
# Mỗi ca dựng một repo git tạm để không đụng cây thật. Script cần chạy với cwd
# là gốc repo (nó không nhận tham số đường dẫn), nên run() cd vào đó trước khi gọi.

set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-phase-boundary.sh"
PHASE1="docs/product/1-system-design"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT
fails=0

newrepo() { # newrepo <tên> → in ra đường dẫn repo
  # Commit ban đầu có SẴN một file rỗng trong pha 1, để ca "sửa file đã track,
  # chưa commit" có cái để git diff --name-only HEAD nhìn thấy — đúng hình dạng
  # thật của gate.sh: nó chấm lúc thay đổi còn NẰM TRONG working tree, trước khi
  # commit (CLAUDE.md §6.1).
  local d="$TMPROOT/$1"
  mkdir -p "$d/$PHASE1" "$d/scripts" "$d/docs/product/2-db"
  git -C "$d" init -q
  git -C "$d" config user.email t@t
  git -C "$d" config user.name t
  echo "# ok" > "$d/CLAUDE.md"
  : > "$d/$PHASE1/01-ranh-gioi.md"
  git -C "$d" add -A >/dev/null 2>&1 && git -C "$d" commit -qm init >/dev/null 2>&1
  printf '%s' "$d"
}

run() { # run <repo> → in "<exit>|<stdout một dòng>"
  local out rc
  out="$(cd "$1" && "$SCRIPT" 2>&1)"
  rc=$?
  printf '%s|%s' "$rc" "$(printf '%s' "$out" | tr '\n' ' ')"
}

check() { # check <tên ca> <exit mong đợi> <chuỗi phải có trong output, hoặc "" nếu output rỗng> <kết quả run>
  local name="$1" want_rc="$2" want_txt="$3" got="$4"
  local rc="${got%%|*}" out="${got#*|}"
  if [ "$rc" = "$want_rc" ] && { [ -z "$want_txt" ] || [[ "$out" == *"$want_txt"* ]]; }; then
    echo "  ok   $name (exit $rc)"
  else
    echo "  FAIL $name — mong đợi exit $want_rc + \"$want_txt\", nhận exit $rc: $out"
    fails=$((fails + 1))
  fi
}

echo "[test] check-phase-boundary.sh"

# 1 — không có gì đổi trong pha 1 → sạch
r="$(newrepo clean)"
mkdir -p "$r/docs/product/2-db"
printf 'CREATE TABLE orders (id BIGINT);\n' > "$r/docs/product/2-db/schema.md"
check "đổi ngoài pha 1 không bị chấm" 0 "" "$(run "$r")"

# 2 — pha 1 đổi (chưa commit), không có mẫu vi phạm → sạch
r="$(newrepo ok)"
printf 'Hệ thống ghi nhận đơn hàng và gửi tới bếp.\n' > "$r/$PHASE1/01-ranh-gioi.md"
check "pha 1 sạch" 0 "" "$(run "$r")"

# 3 — pha 1 đặt tên bảng (pha 2), file đã track, thay đổi CHƯA COMMIT
r="$(newrepo db)"
printf 'CREATE TABLE orders (id BIGINT, status VARCHAR(20));\n' > "$r/$PHASE1/01-ranh-gioi.md"
check "CREATE TABLE bị bắt" 1 "pha 1 đang đặt tên" "$(run "$r")"

# 4 — pha 1 đặt tên endpoint (pha 3), file đã track, thay đổi CHƯA COMMIT
r="$(newrepo api)"
printf 'Máy trạm gọi POST /api/orders để tạo đơn.\n' > "$r/$PHASE1/01-ranh-gioi.md"
check "endpoint bị bắt" 1 "pha 1 đang đặt tên" "$(run "$r")"

# 5 — pha 1 đặt tên component (pha 4), file đã track, thay đổi CHƯA COMMIT
r="$(newrepo fe)"
printf 'Màn hình dùng <OrderCard /> để hiển thị.\n' > "$r/$PHASE1/01-ranh-gioi.md"
check "component bị bắt" 1 "pha 1 đang đặt tên" "$(run "$r")"

# 6 — file CHƯA TRACK trong pha 1 cũng bị chấm (không chỉ file đã commit)
r="$(newrepo untracked)"
printf 'DELETE /api/orders/1 xoá đơn.\n' > "$r/$PHASE1/nhap.md"
check "file chưa track trong pha 1 vẫn bị chấm" 1 "pha 1 đang đặt tên" "$(run "$r")"

# 7 — dòng đã khai trong ignore thì không chặn
r="$(newrepo ignored)"
printf 'CREATE TABLE orders (id BIGINT);\n' > "$r/$PHASE1/01-ranh-gioi.md"
printf '# T-999 — trích dẫn ví dụ cố ý\nCREATE TABLE orders\n' > "$r/scripts/check-phase-boundary.ignore"
check "ignore có chủ" 0 "" "$(run "$r")"

# 8 — file pha 1 không phải .md (vd script mẫu) không bị chấm
r="$(newrepo nonmd)"
printf 'CREATE TABLE orders (id BIGINT);\n' > "$r/$PHASE1/schema.sql"
check "file không phải .md bị bỏ qua" 0 "" "$(run "$r")"

# 9 — HỒI QUY F-041: endpoint KHÔNG mở đầu bằng '/' vẫn phải bị bắt.
# Đầu vào là nguyên văn bốn dòng hợp đồng nợ từng sống ở architecture.md §12.2
# (xoá ở T-079, 2026-09-20). Mẫu cũ đòi '/' ngay sau động từ nên im hoàn toàn
# trên cả bốn dòng; không có ca này thì lần nới sau lại khép lại.
r="$(newrepo api_noslash)"
cat > "$r/$PHASE1/01-ranh-gioi.md" <<'EOF'
POST   staff/sessions/:id/close      body có { paid, debtor, debt_amount } khi thu thiếu
GET    staff/debts?status=open       danh sách nợ chưa thu — màn Nợ ở POS
POST   staff/debts/:id/collect       thu nợ; ghi vết người đang trực quay
GET    staff/reports/debts?date=     nợ ghi trong ngày · nợ thu trong ngày
EOF
check "endpoint KHÔNG có / mở đầu bị bắt (F-041)" 1 "pha 1 đang đặt tên" "$(run "$r")"

# 10 — và mẫu nới KHÔNG được kêu oan văn xuôi thường của pha 1.
r="$(newrepo prose)"
printf 'Quầy DUYỆT đơn trước khi bếp làm; không trạm nào bấm gì.\nMột lần thu chia được hai phương thức.\n' > "$r/$PHASE1/01-ranh-gioi.md"
check "văn xuôi pha 1 không bị kêu oan" 0 "" "$(run "$r")"

if [ "$fails" -ne 0 ]; then
  echo "check-phase-boundary.test: FAIL ($fails ca)"
  exit 1
fi
echo "check-phase-boundary.test: OK"
