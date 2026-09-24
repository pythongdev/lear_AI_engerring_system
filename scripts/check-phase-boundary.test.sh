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

# 1 — SQL trong vùng PHA 2 là đầu ra hợp lệ → sạch.
# Ca này có từ trước P2-02, lúc vùng pha 2 hoàn toàn không bị chấm. Từ
# 2026-09-24 vùng ấy CÓ bị chấm, chỉ là bộ mẫu của nó không có SQL — nên ca này
# nay chứng minh một điều MẠNH HƠN: cổng đọc file ấy và cố ý im lặng.
r="$(newrepo clean)"
mkdir -p "$r/docs/product/2-db"
printf 'CREATE TABLE orders (id BIGINT);\n' > "$r/docs/product/2-db/schema.md"
check "SQL trong vùng pha 2 KHÔNG bị chấm" 0 "" "$(run "$r")"

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

# ===== VÙNG PHA 2 — thêm 2026-09-24 bởi P2-02 ==============================
# Hai bộ mẫu, hai vùng: pha 2 PHẢI viết SQL (ADR-049 · ADR-050), nên vùng ấy
# đỏ với endpoint và route mà im lặng với SQL. Không có nhóm ca này thì lần sửa
# sau rất dễ gộp hai vùng về một bộ mẫu, và cái gộp ấy im lặng ở cả hai chiều.
PHASE2="docs/product/2-db"

# 11 — pha 2 đặt tên endpoint (pha 3) → đỏ
r="$(newrepo p2_api)"
printf 'Đường ghi duy nhất là POST /api/orders.\n' > "$r/$PHASE2/02-luoc-do.md"
check "pha 2: endpoint bị bắt" 1 "pha 2 đang đặt tên" "$(run "$r")"

# 12 — HỒI QUY F-041 trong vùng pha 2: endpoint KHÔNG mở đầu bằng '/' vẫn phải
# bị bắt. Đây là ca mà một mẫu chỉ đòi '/api/' sẽ im hoàn toàn.
r="$(newrepo p2_api_noslash)"
printf 'POST   staff/debts/:id/collect   thu nợ\n' > "$r/$PHASE2/04-duong-tien.md"
check "pha 2: endpoint KHÔNG có / mở đầu bị bắt (F-041)" 1 "pha 2 đang đặt tên" "$(run "$r")"

# 13 — pha 2 đặt tên component / route (pha 4) → đỏ
r="$(newrepo p2_fe)"
printf 'Màn Nợ dùng <DebtList /> để hiển thị.\n' > "$r/$PHASE2/04-duong-tien.md"
check "pha 2: component bị bắt" 1 "pha 2 đang đặt tên" "$(run "$r")"

# 14 — CA QUAN TRỌNG NHẤT CỦA NHÓM: SQL có chữ DELETE không được kêu oan.
# Mẫu endpoint của vùng pha 1 nhận 'DELETE' + khoảng trắng + chữ, nên nếu vùng
# pha 2 dùng chung mẫu ấy thì MỌI lát lược đồ có khoá ngoại sẽ đỏ. Ca này là
# thứ duy nhất chặn việc "dọn cho gọn" bằng cách gộp hai mẫu.
r="$(newrepo p2_sql_delete)"
cat > "$r/$PHASE2/02-luoc-do.md" <<'EOF'
Khoá ngoại của dòng đơn khai ON DELETE CASCADE về đơn của nó.
Dọn bản nháp: DELETE FROM order_draft WHERE created_at < now();
Ràng buộc kiểm dùng CHECK (so_luong <> 0).
EOF
check "pha 2: SQL có DELETE không bị kêu oan" 0 "" "$(run "$r")"

# 15 — file CHƯA TRACK trong vùng pha 2 cũng bị chấm
r="$(newrepo p2_untracked)"
printf 'GET /api/reports/debts trả về danh sách.\n' > "$r/$PHASE2/nhap.md"
check "pha 2: file chưa track vẫn bị chấm" 1 "pha 2 đang đặt tên" "$(run "$r")"

# 16 — văn xuôi pha 2 nói về đường ghi KHÔNG bị kêu oan.
# Đây đúng là câu ADR-050 dặn pha 2 viết THAY CHO một endpoint.
r="$(newrepo p2_prose)"
cat > "$r/$PHASE2/02-luoc-do.md" <<'EOF'
Đường ghi tới ô này phải là MỘT, và lược đồ không mở đường thứ hai.
Con số tổng phải đọc ra được bằng một phép cộng từ chi tiết.
EOF
check "pha 2: văn xuôi 'một đường ghi' không bị kêu oan" 0 "" "$(run "$r")"

# 17 — hai vùng cùng vi phạm trong một lượt → đỏ, và output nêu CẢ HAI
r="$(newrepo both)"
printf 'CREATE TABLE orders (id BIGINT);\n' > "$r/$PHASE1/01-ranh-gioi.md"
printf 'POST /api/orders tạo đơn.\n' > "$r/$PHASE2/02-luoc-do.md"
got="$(run "$r")"
check "hai vùng cùng vi phạm: nêu pha 1" 1 "pha 1 đang đặt tên" "$got"
check "hai vùng cùng vi phạm: nêu pha 2" 1 "pha 2 đang đặt tên" "$got"

if [ "$fails" -ne 0 ]; then
  echo "check-phase-boundary.test: FAIL ($fails ca)"
  exit 1
fi
echo "check-phase-boundary.test: OK"
