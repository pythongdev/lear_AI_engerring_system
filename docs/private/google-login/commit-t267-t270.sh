#!/usr/bin/env bash
# Ghi hai commit T-267 → T-270 từ hai cây Claude dựng và kiểm 2026-11-01 trên HEAD de881a2.
# Mỗi cây chỉ chứa phần của đúng task ấy; script chỉ đổi index rồi commit, không đổi file nào trong cây làm việc.
# Thay commit-khach.sh (đã cũ: dựng trên 6b29656, T-264 đã vào).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BASE=de881a235b2719f457316edc192dc24cc54c0c6a
TREE_267=dc63ecef74599d3638322bad05ced74a083f7943
TREE_270=180185e3e6d5b229f672462366456584a514979b

[ "$(git rev-parse HEAD)" = "$BASE" ] || { echo "Dừng: HEAD đã đổi khỏi ${BASE:0:7}, không ghi gì. Nhờ Claude dựng lại." >&2; exit 1; }
for t in T-267 T-270; do
  [ -f "work/scope/$t.txt" ] || { echo "Dừng: thiếu work/scope/$t.txt, Gate 9 sẽ từ chối. Không ghi gì." >&2; exit 1; }
done
for t in "$TREE_267" "$TREE_270"; do
  git cat-file -e "$t^{tree}" || { echo "Dừng: thiếu tree $t trong .git." >&2; exit 1; }
done
# Commit hỏng giữa chừng thì trả index về HEAD để stage không bị lẫn; file không đổi.
trap 'echo "Dừng giữa chừng; đưa index về HEAD." >&2; git reset -q' ERR

git read-tree "$TREE_267"
git commit -m "T-267: khách đăng ký và đăng nhập bằng nút Google" -m "ADR-132 (chủ repo duyệt 2026-10-29): GIS ID token, BE tự kiểm RS256 qua JWKS, bảng customer_google_identity, cửa POST /customer-sessions/google.
Verified: be-check 666 test PASS, db-check PASS 39 bước, hợp đồng 0.53.0."

git read-tree "$TREE_270"
git commit -m "T-270: xác nhận Gmail khách qua thư" -m "ADR-133: Gmail tự gõ ở pending_email tới khi bấm link 24 giờ; chỉ Gmail đã xác nhận mới đăng nhập và nhận thư đặt lại.
Verified: be-check 673 test PASS, db-check PASS 40 bước, hợp đồng 0.54.0."

trap - ERR
echo
git log --oneline -3
