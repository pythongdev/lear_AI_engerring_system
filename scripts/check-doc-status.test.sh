#!/usr/bin/env bash
# Test cho Gate 1c (scripts/check-doc-status.sh).
#
# Chạy tay:  ./scripts/check-doc-status.test.sh
# verify.sh chạy mọi scripts/*.test.sh, nên gate cũng chạy nó khi scripts/ đổi.
#
# Bốn ca đầu là BỐN CHỖ THẬT của work/findings.md F-015, chép nguyên văn (kể cả
# chỗ bị GÓI DÒNG và chỗ KHÔNG MANG MÃ — hai chỗ mà câu awk của chính F-015 để
# lọt). Ca 5–6 là F-021. Ca 7–10 là những câu ĐÚNG phải im: một mục kể lại lịch
# sử, một câu hỏi đang mở thật, một dòng bảng vòng đời, một ignore hết hạn.

set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-doc-status.sh"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT
fails=0

newrepo() { # newrepo <tên> → in ra đường dẫn repo, đã có Unknowns + bảng vòng đời
  local d="$TMPROOT/$1"
  mkdir -p "$d/docs/product/0-ba/ban-hang" "$d/scripts" "$d/quality"
  git -C "$d" init -q
  cat > "$d/docs/product/99-unknowns.md" <<'EOF'
## Unknowns

### Đang mở

- **U-100** — câu này còn treo thật, ai đó phải hỏi chủ quán.

### Đã có lời giải

| Câu hỏi cũ | Lời giải |
|---|---|
| ~~U-005 — ai bấm xác nhận đơn trả trước~~ | POS, lúc nhận tiền |
| ~~U-019 — buổi tối đối chiếu VietQR bằng gì~~ | tin nhắn báo có |
| ~~U-022 — sửa đơn được tới trạng thái nào~~ | bất kỳ trạng thái nào |
EOF
  cat > "$d/docs/product/0-ba/ban-hang/05-vong-doi.md" <<'EOF'
### 5.2 Vòng đời ĐƠN

| Trạng thái nguồn | Sự kiện | Trạng thái đích | Ai kích hoạt |
|---|---|---|---|
| Đang thực hiện | Mọi việc đã ra tới tay khách | **Hoàn thành** | *Người đứng quầy* |
| **Hoàn thành** | Quầy huỷ một đơn đã xong | **Huỷ** | *Người đứng quầy* |
EOF
  printf '# decisions\n' > "$d/docs/decisions.md"
  : > "$d/ign.txt"
  printf '%s' "$d"
}

run() { # run <repo> → "<exit>|<stdout một dòng>"
  local out rc
  out="$(DOC_STATUS_IGNORE=ign.txt "$SCRIPT" "$1" 2>&1)"
  rc=$?
  printf '%s|%s' "$rc" "$(printf '%s' "$out" | tr '\n' ' ')"
}

check() { # check <tên ca> <exit mong đợi> <chuỗi phải có> <kết quả run>
  local name="$1" want_rc="$2" want_txt="$3" got="$4"
  local rc="${got%%|*}" out="${got#*|}"
  if [ "$rc" = "$want_rc" ] && [[ "$out" == *"$want_txt"* ]]; then
    echo "  ok   $name (exit $rc)"
  else
    echo "  FAIL $name — mong đợi exit $want_rc + \"$want_txt\", nhận exit $rc: $out"
    fails=$((fails + 1))
  fi
}

echo "[check-doc-status] F-015 — bốn chỗ thật"

# Ca 1 — chỗ §1.2: có mã U-005 (đã đóng), ngôn ngữ "chưa rõ / chưa ai trả lời"
d="$(newrepo c1)"
cat > "$d/docs/product/0-ba/ban-hang/01-actors.md" <<'EOF'
### 1.2 Người đứng quầy

- **Thu tiền lúc trao hàng** và **tự bấm xác nhận đã nhận tiền**.
  Với đơn khách **đã chọn trả trước** thì chưa rõ ai bấm xác nhận và vào lúc nào — xem
  **U-005** ở *Unknowns*, chưa ai trả lời.
EOF
check "1. §1.2 — U-005 đã đóng bị kể như còn treo" 1 "câu còn-mở nhắc tới câu hỏi ĐÃ ĐÓNG: U-005" "$(run "$d")"

# Ca 2 — chỗ §4.9: cụm CHƯA CHỐT bị XUỐNG DÒNG cắt đôi, mã ở dòng sau.
# Đây là ca mà mọi bộ lọc theo DÒNG đều mù.
d="$(newrepo c2)"
cat > "$d/docs/product/0-ba/ban-hang/04-gia.md" <<'EOF'
### 4.9 Đối soát

Ba chỗ tiền không nằm trong két mà vẫn là doanh thu. **Riêng phần VietQR thì buổi tối quán lấy gì ra đối chiếu là câu CHƯA
CHỐT** — xem **U-019**.
EOF
got="$(run "$d")"
check "2. §4.9 — cụm khoá bị GÓI DÒNG cắt đôi" 1 "ĐÃ ĐÓNG: U-019" "$got"
# và chứng minh chính chỗ ấy lọt qua một bộ lọc theo dòng
if grep -q 'CHƯA CHỐT.*U-019' "$d/docs/product/0-ba/ban-hang/04-gia.md"; then
  echo "  FAIL 2b. grep theo dòng lẽ ra phải MÙ với ca này"
  fails=$((fails + 1))
else
  echo "  ok   2b. grep theo dòng mù với ca này, gate vẫn bắt được"
fi

# Ca 3 — chỗ §6.1 dòng 7: một ô bảng, mã U-022 đã đóng + "còn mở" + "bị từ chối"
d="$(newrepo c3)"
cat > "$d/docs/product/0-ba/ban-hang/06-ngoai-le.md" <<'EOF'
### 6.1 Bảng

| # | Tình huống | Xử lý |
|---|---|---|
| 7 | **Khách huỷ đơn** | **Ranh giới trên còn mở:** `Hoàn thành → Huỷ` hôm nay bị từ chối — **U-022** |
EOF
got="$(run "$d")"
check "3. §6.1 dòng 7 — U-022 đã đóng, ô bảng" 1 "ĐÃ ĐÓNG: U-022" "$got"
check "3b. §6.1 dòng 7 — cùng lúc phủ định một chuyển tiếp hợp lệ" 1 "HỢP LỆ: Hoàn thành → Huỷ" "$got"

# Ca 4 — chỗ §6.2: KHÔNG MANG MÃ nào. Câu awk của F-015 loại nó ngay ở vế U-XXX;
# phép C không dùng mã, nó so với bảng vòng đời §5.
d="$(newrepo c4)"
cat > "$d/docs/product/0-ba/ban-hang/06-ngoai-le.md" <<'EOF'
### 6.2 Dòng nào đã chốt

- **Đơn đã hoàn thành cần điều chỉnh** (dòng 13) — **sửa được ở bất kỳ trạng thái nào**
  (`shop-facts.md` §6.19); không cần đường `Hoàn thành → Huỷ`.
EOF
got="$(run "$d")"
check "4. §6.2 — câu KHÔNG MANG MÃ vẫn bị bắt" 1 "HỢP LỆ: Hoàn thành → Huỷ" "$got"
if printf '%s' "${got#*|}" | grep -q 'U-0'; then
  echo "  FAIL 4b. ca này lẽ ra không được bắt bằng mã U-XXX"
  fails=$((fails + 1))
else
  echo "  ok   4b. bắt được mà không cần mã U-XXX nào"
fi

echo "[check-doc-status] F-021 — bảng chỉ mục vs thân"

d="$(newrepo c5)"
cat > "$d/docs/decisions.md" <<'EOF'
| ID | Nội dung | Trạng thái | Rủi ro |
|---|---|---|---|
| GĐ-01 | Hai người cùng thao tác một bàn | **Giả định** | TRUNG BÌNH |

### GĐ-01 — ~~Hai người cùng thao tác một bàn~~

**Dòng §6:** 4 · **Trạng thái: Superseded** — đã thay bằng quy tắc
EOF
check "5. GĐ-01 — bảng nói Giả định, thân nói Superseded" 1 "còn xếp GĐ-01 là giả định ĐANG SỐNG" "$(run "$d")"

d="$(newrepo c6)"
cat > "$d/docs/decisions.md" <<'EOF'
| ID | Nội dung | Trạng thái | Rủi ro |
|---|---|---|---|
| GĐ-01 | ~~Hai người cùng thao tác một bàn~~ | **Đã thay** 2026-09-02 | ~~TRUNG BÌNH~~ |

### GĐ-01 — ~~Hai người cùng thao tác một bàn~~

**Dòng §6:** 4 · **Trạng thái: Superseded** — đã thay bằng quy tắc
EOF
check "6. GĐ-01 — hai chỗ khớp nhau ⇒ im" 0 "xanh" "$(run "$d")"

echo "[check-doc-status] những câu ĐÚNG phải im"

# Ca 7 — mục kể lại lịch sử: có ngôn ngữ còn-mở NHƯNG cũng nói lời chốt
d="$(newrepo c7)"
cat > "$d/docs/product/0-ba/ban-hang/06-ngoai-le.md" <<'EOF'
### 6.3 Ghi lại

⚠️ **Chưa viết được ngay khi tài liệu này ghi dòng trên** — **U-022** lúc ấy còn mở;
chủ quán chốt 2026-09-02, và nay bảng §5.2 có đúng dòng ấy.
EOF
check "7. mục kể lại lịch sử ⇒ im" 0 "xanh" "$(run "$d")"

# Ca 8 — một câu hỏi ĐANG MỞ thật, viết bằng đúng ngôn ngữ còn-mở
d="$(newrepo c8)"
cat > "$d/docs/product/0-ba/ban-hang/05-them.md" <<'EOF'
### 5.9 Chỗ chưa chốt

Ai bấm mốc này thì **chưa rõ** — **U-100** ở *Unknowns*, chưa ai trả lời.
EOF
check "8. câu hỏi đang mở thật ⇒ im" 0 "xanh" "$(run "$d")"

# Ca 9 — bảng vòng đời §5 tự nó có chữ "từ chối" ở ô khác, không phải phủ định
d="$(newrepo c9)"
cat > "$d/docs/product/0-ba/ban-hang/06-ngoai-le.md" <<'EOF'
### 6.1 Bảng

| # | Tình huống | Xử lý |
|---|---|---|
| 2 | **Quầy từ chối đơn QR** | `Chờ xác nhận` ⇒ `Huỷ` — dòng có sẵn ở bảng §5.2. Đơn bị từ chối **không** vào hoá đơn |
EOF
check "9. phủ định ở MỆNH ĐỀ khác chuyển tiếp ⇒ im" 0 "xanh" "$(run "$d")"

# Ca 10 — ignore hết hạn phải làm gate đỏ
d="$(newrepo c10)"
printf 'docs/product/0-ba/ban-hang/kh.md :: chuoi khong bao gio khop\n' > "$d/ign.txt"
check "10. ignore hết hạn ⇒ đỏ" 1 "IGNORE HẾT HẠN" "$(run "$d")"

echo
if [ "$fails" -eq 0 ]; then
  echo "check-doc-status.test: tất cả ca qua."
  exit 0
fi
echo "check-doc-status.test: $fails ca hỏng."
exit 1
