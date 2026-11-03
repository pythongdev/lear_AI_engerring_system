#!/usr/bin/env bash
# Ghi ba commit T-264 → T-267 → T-270 từ ba cây Claude đã dựng và kiểm 2026-10-30.
#
# Mỗi cây = HEAD 6b29656 + đúng phần của task ấy, KHÔNG có T-248 hay task nào khác; models.go và
# schema.ts sinh lại trên chính cây đó. Kiểm trong worktree ../lean_wt/khach-commits:
#   T-264: be-check PASS (642 test), db-check PASS 38 bước, Gate 3/1c–1h PASS
#   T-267: be-check PASS (666 test), db-check PASS 39 bước, hợp đồng 0.53.0
#   T-270: be-check PASS (673 test), db-check PASS 40 bước, hợp đồng 0.54.0
# Còn đỏ ở cả ba, đã đỏ sẵn ở HEAD: Gate 1b (docs/private/prompt/profile-gemini.md trỏ tới file
# chưa commit) và khach-qr.test.tsx:162.
#
# Script chỉ đổi index (git read-tree) rồi commit; không đổi file nào trong cây làm việc. Sau khi
# chạy, `git status` còn lại đúng phần của các task khác (T-248, T-271, T-272, …).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BASE=6b296565bb16194af1292dd6d2458a12952e4db2
TREE_264=b45ffca37a3c0111f239458717a50a9650bf0178
TREE_267=e778d9334d466b5a7295fda1cd8e0b1ce3ad39d5
TREE_270=8993ede167b83a641a8ebd8c3c2ec7969e4efe8f

if [ "$(git rev-parse HEAD)" != "$BASE" ]; then
  echo "Dừng: HEAD đã đổi khỏi ${BASE:0:7}. Ba cây dựng trên HEAD ấy — nhờ Claude dựng lại." >&2
  exit 1
fi
for t in "$TREE_264" "$TREE_267" "$TREE_270"; do
  git cat-file -e "$t^{tree}" || { echo "Dừng: thiếu tree $t trong .git." >&2; exit 1; }
done

git read-tree "$TREE_264"
git commit -m "T-264: backend đăng nhập số điện thoại · Gmail và cửa khách" -m "ADR-131 lát b: gói dinhdanh, miền khach (đăng ký, đăng nhập, phiên, thông tin giao, lịch sử đơn, đặt lại mật khẩu), lớp quyền khach, vết khách người sửa rỗng.
Verified: be-check PASS, db-check PASS 38 bước trên cây không có T-248."

git read-tree "$TREE_267"
git commit -m "T-267: khách đăng ký và đăng nhập bằng nút Google" -m "ADR-132 (chủ repo duyệt 2026-10-29): GIS ID token, BE tự kiểm RS256 qua JWKS, bảng customer_google_identity, cửa POST /customer-sessions/google.
Verified: be-check PASS, db-check PASS 39 bước, hợp đồng 0.53.0."

git read-tree "$TREE_270"
git commit -m "T-270: xác nhận Gmail khách qua thư" -m "ADR-133: Gmail tự gõ ở pending_email tới khi bấm link 24 giờ; chỉ Gmail đã xác nhận mới đăng nhập và nhận thư đặt lại.
Verified: be-check PASS, db-check PASS 40 bước, hợp đồng 0.54.0."

echo
git log --oneline -4
echo
echo "Xong. Phần còn lại trong git status là của task khác."
