# Prompt — Thiết kế lại trang gọi món tại bàn (QR) thành một file HTML tĩnh

> Dán nguyên phần dưới đường kẻ vào Codex và vào Gemini. Chỉ khác nhau đúng **một dòng**: tên file
> đầu ra (mục 1). Hai bản đặt cạnh nhau để chủ repo so và chọn.

---

## 1. Việc cần làm

Bạn là nhà thiết kế giao diện di động. Trang khách gọi món tại bàn sau khi quét mã QR
(`/ban/[ma]`, code ở `fe/src/app/ban/`) **đang chạy đúng nhưng trông không đẹp**. Hãy làm **một file
HTML tĩnh, tự chứa** cho thấy trang này nên trông thế nào. Đây là **bản thiết kế để xem**, không
phải code thật: **không sửa bất cứ file nào khác** trong repo, không sửa `fe/`, không chạy migration,
không commit.

Ghi đúng một file:

- Codex: `docs/product/4-fe/thiet_ke/khach_hang/ban-qr/ban-qr-codex.html`
- Gemini: `docs/product/4-fe/thiet_ke/khach_hang/ban-qr/ban-qr-gemini.html`

Đọc trước (chỉ đọc, không sửa):

- `fe/src/app/ban/_components/phieu-khach.tsx` — khung trang, thanh gửi đơn, các thông báo.
- `fe/src/app/ban/_components/thuc-don-khach.tsx` — thẻ combo, thẻ món lẻ, tóm tắt đơn.
- `fe/src/app/ban/_components/lua-chon-truot.tsx` và `thuc-don-khach.css` — nút lựa chọn trượt, màu.
- `docs/product/4-fe/thiet_ke/khach_hang/thuc-don.html` — một bản thiết kế tĩnh khác trong repo,
  để biết khuôn file (font, Tailwind CDN, token màu).

## 2. Trang này làm gì (không được bớt, không được thêm chức năng)

Khách ngồi tại bàn, quét QR, chọn món rồi bấm **Gửi lượt gọi**. Giữ đủ các khối sau, theo thứ tự;
mỗi khối gắn `data-component="..."` đúng tên dưới đây để chủ repo chỉ ra chỗ cần sửa:

1. `MenuHeader` — tên quán nhỏ phía trên (*Bánh cuốn Bà Thanh Cao Bằng*), tiêu đề lớn **Bàn 3**,
   biểu tượng QR.
2. `MiniCartStrip` — dải dính đầu trang: nút "**n món**" (bấm thì cuộn tới tóm tắt), dãy chip
   "Tên ×n" cuộn ngang, tổng tạm tính ở phải (trống khi chưa tính xong).
3. `SearchBar` — ô "Tìm món nhanh", tìm không dấu.
4. `ComboSection` → các `ComboCard`: ảnh (chưa có ảnh thật, dùng ô giữ chỗ), tên combo, nút
   "**Chi tiết**" trượt ra thành phần (×3 Bánh cuốn, ×1 Trứng chín, ×1 Giò), các nút lựa chọn, giá,
   bộ tăng/giảm số lượng (− n ＋). Bấm ảnh là sang trang chi tiết.
5. `ProductList` → các `ProductCard`: như thẻ combo nhưng không có "Chi tiết"; giá có chữ "từ"
   khi các lựa chọn cho giá khác nhau.
6. `OrderSummary` — "Tóm tắt đơn hàng", chia nhóm **COMBO** và **MÓN LẺ**; mỗi dòng có: tên, Nhân,
   Lượng nhân, ô số lượng sửa được, giá dòng, nút xoá; dòng combo có "Chi tiết" gộp thành phần
   theo món. Cuối khối: "Tổng tạm tính …".
7. `CartBottomBar` — nút lớn cuối trang: số món (huy hiệu) · "**Gửi lượt gọi**" · tổng tiền.

**Nút lựa chọn** (đang là viên tròn viền cam có vệt sáng chạy quanh): mỗi nhóm một nút
"Tên nhóm: **lựa chọn đang chọn** ⌄", bấm thì danh sách lựa chọn trượt ra ngay trong thẻ, chọn xong
tự đóng. Nhóm hiện có:

- **Nhân**: Thịt (mặc định) · Chay.
- **Lượng nhân**: Vừa (mặc định) · Nhiều — **chỉ hiện khi Nhân = Thịt**.
- **Rau** (chỉ món Canh bánh cuốn): mặc định "Ít rau"; các lựa chọn còn lại lấy tên tuỳ ý làm
  minh hoạ, ví dụ "Nhiều rau", "Không rau".

Bạn **được** đổi cách bày (nút trượt, bảng trượt từ đáy, chip, segmented control…) miễn là giữ
đúng các nhóm, đúng luật hiện/ẩn, đúng mặc định.

## 3. Dữ liệu minh hoạ (số minh hoạ, ghi rõ trên trang là "số minh hoạ")

Giá lấy từ `master_plan/shop-facts.md` §4.3, theo ba mức Chay / Thịt vừa / Thịt nhiều:

| Combo | Thành phần | Chay | Thịt vừa | Thịt nhiều |
|---|---|---|---|---|
| Suất giò | 1 giò + 4 bánh | 21.000 | 25.000 | 29.000 |
| Đầy đủ trứng chín / tái / vàng (3 combo) | 3 bánh + 1 trứng + 1 giò | 26.000 | 30.000 | 34.000 |
| Suất trứng chín / tái / vàng (3 combo) | 1 trứng + 4 bánh | 20.000 | 25.000 | 30.000 |

| Món lẻ | Chay | Thịt vừa | Thịt nhiều |
|---|---|---|---|
| Bánh cuốn (1 cái) | 3.000 | 4.000 | 5.000 |
| Bánh trứng chín / tái / vàng (1 quả) | 8.000 | 9.000 | 10.000 |
| Giò (không nhận nhân) | 9.000 | 9.000 | 9.000 |
| Canh bánh cuốn (luôn nằm **cuối** danh sách món lẻ) | 0 | 0 | 0 |

Tiền viết kiểu `30.000 ₫`. Canh 0 đồng hiện `0 ₫`, không viết "Miễn phí" (đó là chữ chưa ai chốt).
Giỏ mẫu cho trạng thái "có món": 1 Đầy đủ trứng chín (Thịt, Vừa) · 2 Suất giò (Thịt, Nhiều) ·
2 Bánh cuốn Chay · 2 Canh bánh cuốn (Ít rau) — tổng 30.000 + 58.000 + 6.000 + 0 = **94.000 ₫**.

**Không được tự nghĩ ra luật kinh doanh**: không thêm giảm giá, phí, khuyến mãi, thanh toán, tích
điểm, ước lượng thời gian chờ, món không có trong bảng trên. Mọi chữ hiện cho khách viết tiếng Việt.

## 4. Các trạng thái phải xem được

Đặt một thanh chọn trạng thái nhỏ **ở ngoài khung điện thoại** (không phải một phần thiết kế) để
chuyển giữa:

1. **Giỏ trống** — nút gửi mờ, dải giỏ "0 món".
2. **Có món, đang tính giá** — giá dòng "Đang tính…", tổng trống, nút gửi mờ.
3. **Có món, đã tính xong** — giỏ mẫu ở mục 3, nút gửi bật.
4. **Đang gửi** — nút "Đang gửi…", cả form khoá.
5. **Đã gửi** — thông báo "Đã gửi lượt gọi · tổng 94.000 ₫", giỏ về trống.
6. **Lỗi mạng khi gửi** — thông báo lỗi, nút đổi thành "Gửi lại".
7. **Mã QR hết hạn** — cả trang chỉ còn câu "Bạn vui lòng quét lại mã trên bàn." (thiết kế cho
   nó trông tử tế, có thể thêm biểu tượng).
8. **Không tìm thấy món** — ô tìm có chữ, danh sách hiện "Không có món nào khớp."

Trong trang, tăng/giảm số lượng, mở "Chi tiết", mở nút lựa chọn, ô tìm phải bấm được thật bằng
JavaScript thuần (không cần tính đúng giá — chỉ cần trông đúng).

## 5. Vì sao bản hiện tại trông chưa đẹp (điều chủ repo thấy — hãy sửa, không bắt buộc theo cách nào)

- Chữ quá nhỏ: nhiều chỗ 10–11px, khó đọc trên điện thoại ở quán.
- Tóm tắt đơn là bảng 6 cột chật, phải cuộn ngang trên máy hẹp.
- Thẻ món: nửa phải căn phải hết, ảnh giữ chỗ chỉ là một biểu tượng xám, nhìn rời rạc.
- Nút lựa chọn có viền sáng chạy liên tục — gây rối khi có nhiều thẻ.
- Placeholder ô tìm dùng emoji 🔍; tổng tiền xuất hiện ở ba nơi nhưng không rõ chỗ nào là chính.
- Nút gửi nằm cuối trang, không dính đáy màn hình — khách phải cuộn hết mới thấy.
- Thiếu thứ bậc: tiêu đề nhóm "COMBO" / "MÓN LẺ" nhỏ, mờ, không tách bạch.

## 6. Ràng buộc kỹ thuật của file

- Một file `.html` duy nhất, mở thẳng bằng trình duyệt, không build. Được dùng
  `https://cdn.tailwindcss.com/3.4.16` và font Google *Be Vietnam Pro*; không thư viện nào khác,
  không ảnh từ mạng (ảnh giữ chỗ vẽ bằng CSS hoặc SVG nội tuyến).
- Khung điện thoại rộng 390px ở giữa màn hình máy tính; dưới 480px thì chiếm cả màn hình, lề 16px,
  không cuộn ngang trang.
- Có **chế độ sáng và tối** (nút chuyển ở thanh trạng thái bên ngoài). Màu đặt thành biến CSS trên
  `:root`. Có thể giữ màu cam hiện tại (`#EA6A0C` sáng / `#FF7A1A` tối) hoặc đề xuất màu khác —
  nếu đổi, nói lý do.
- Vùng bấm tối thiểu 44×44px; chữ thân tối thiểu 14px; tương phản đạt WCAG AA; tôn trọng
  `prefers-reduced-motion`.
- `<title>`: "Gọi món tại bàn".

## 7. Báo cáo khi xong

Trả lời bằng tiếng Việt, văn xuôi ngắn: file đã ghi ở đâu, bạn đổi những gì so với bản đang chạy
và vì sao (theo từng khối `data-component`), chỗ nào bạn chưa chắc hoặc cần chủ repo chọn. Không
dán lại nội dung HTML vào câu trả lời.
