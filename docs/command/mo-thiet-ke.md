# Mở bản thiết kế trang chủ quán

Bản thiết kế tĩnh của trang chủ quán nằm ở [docs/product/4-fe/thiet_ke/chu_quan/](../product/4-fe/thiet_ke/chu_quan/index.html): 13 trang HTML,
một trang mục lục `index.html` (T-215). Mỗi trang tự mang style: Tailwind nạp từ CDN `cdn.tailwindcss.com` cộng một khối
`<style type="text/tailwindcss">` nhúng ngay trong trang (2026-10-20), nên mở file nào cũng có giao diện, nhưng **máy cần có mạng**. Không cần chạy database,
server Go hay Next — chỉ cần trình duyệt. Mọi lệnh
dưới đây chạy ở **thư mục gốc repo**, trên macOS. Viết 2026-10-20.

## 1. Mở nhanh bằng trình duyệt mặc định
```bash
open docs/product/4-fe/thiet_ke/chu_quan/index.html        # trang mục lục, bấm sang từng trang
open docs/product/4-fe/thiet_ke/chu_quan/kho.html          # mở thẳng một trang
```
Tên file là đoạn cuối route: `tong-quan` · `tong-ket` · `san-pham` · `menu-gia` · `danh-muc` · `combo` · `topping` · `nhan-vien` ·
`giao-viec` · `nguyen-lieu` · `kho` · `khoan-chi` · `dao-tao`.

## 2. Mở bằng một trình duyệt cụ thể
```bash
open -a "Google Chrome" docs/product/4-fe/thiet_ke/chu_quan/index.html
open -a Safari docs/product/4-fe/thiet_ke/chu_quan/index.html
```

## 3. Mở qua một server nhỏ (khi cần địa chỉ `http://`)
```bash
python3 -m http.server 8090 --directory docs/product/4-fe/thiet_ke/chu_quan
# rồi mở http://localhost:8090/ — Ctrl+C để tắt
```
Cổng `8090` để không đụng `3000` (Next) và `8080` (server Go) của `make dev`.

## 4. Xem trên điện thoại thật (cùng Wi-Fi với máy)
```bash
ipconfig getifaddr en0                                       # in địa chỉ IP của máy, ví dụ 192.168.1.20
python3 -m http.server 8090 --bind 0.0.0.0 --directory docs/product/4-fe/thiet_ke/chu_quan
# trên điện thoại mở http://<địa chỉ IP ở trên>:8090/
```
Lệnh này cho mọi máy trong cùng mạng xem được thư mục thiết kế; tắt bằng Ctrl+C khi xem xong.

## 5. Xem dạng điện thoại ngay trên máy
Mở trang trong Chrome, bấm `Cmd + Option + I` rồi `Cmd + Shift + M`, chọn một máy cỡ 390px (ví dụ iPhone 14). Dưới 641px
thanh bên trái chuyển thành thanh đáy.

## 6. Mở từ VS Code
Trong khung Explorer, bấm chuột phải vào file `.html` → **Reveal in Finder**, rồi bấm đúp file đó. Hoặc mở Terminal của VS Code và chạy lệnh ở mục 1.

## 7. Nhãn tên component
Ô **Hiện tên component** ở đầu mỗi trang bật hoặc tắt các nhãn đen ghi tên khối. Bảng **Chú giải component** ở cuối trang giải thích từng tên;
danh mục khối dùng chung nằm ở `index.html`. Khi muốn sửa, chỉ tên trang và tên khối, ví dụ: *"trang Kho, `HopThoaiSuaCoLyDo` đặt cạnh
bảng"*.

## 8. Bản thiết kế phía khách
Bộ trang khách nằm ở [docs/product/4-fe/thiet_ke/khach_hang/](../product/4-fe/thiet_ke/khach_hang/index.html) (T-216, 2026-10-20): 9 trang làm cho
điện thoại trước, cùng cách tự mang style bằng Tailwind CDN nên cũng **cần mạng**. Mọi lệnh ở mục 1–6 dùng được, chỉ đổi `chu_quan` thành `khach_hang`:
```bash
open docs/product/4-fe/thiet_ke/khach_hang/index.html      # mục lục, vẽ hai luồng tại bàn và online
```
Tên file theo việc khách làm, chưa phải route thật (route do bước `P4-10` đặt): `trang-chu` · `mo-ma-qr` · `thuc-don` · `chon-mon` · `gio-hang` ·
`da-gui-luot` · `thong-tin-dat` · `da-dat` · `khong-nhan-don`. Nên xem ở cỡ điện thoại (mục 5).

## 9. Lệnh mở từng trang, kèm tiêu đề trang
Mỗi trang một dòng chú thích là **tiêu đề trang** (chữ hiện trên tab trình duyệt), rồi lệnh mở bằng Chrome và bằng Safari. Danh sách lấy từ
thư mục ngày 2026-10-20; thêm hay bớt trang thì sửa ở đây. Mở mọi trang một lần, mỗi trang một tab:
`open -a "Google Chrome" docs/product/4-fe/thiet_ke/*/*.html`.

### 9.1 Phía chủ quán
```bash
# Mục lục · Chủ quán
open -a "Google Chrome" docs/product/4-fe/thiet_ke/chu_quan/index.html
open -a Safari docs/product/4-fe/thiet_ke/chu_quan/index.html

# Tổng quan · Chủ quán
open -a "Google Chrome" docs/product/4-fe/thiet_ke/chu_quan/tong-quan.html
open -a Safari docs/product/4-fe/thiet_ke/chu_quan/tong-quan.html

# Vận hành · Chủ quán (T-219, đề xuất — trang nằm trong thư mục con van_hanh/)
open -a "Google Chrome" docs/product/4-fe/thiet_ke/chu_quan/van_hanh/van-hanh.html
open -a Safari docs/product/4-fe/thiet_ke/chu_quan/van_hanh/van-hanh.html

# Tổng kết · Chủ quán
open -a "Google Chrome" docs/product/4-fe/thiet_ke/chu_quan/tong-ket.html
open -a Safari docs/product/4-fe/thiet_ke/chu_quan/tong-ket.html

# Sản phẩm · Chủ quán
open -a "Google Chrome" docs/product/4-fe/thiet_ke/chu_quan/san-pham.html
open -a Safari docs/product/4-fe/thiet_ke/chu_quan/san-pham.html

# Menu & giá · Chủ quán
open -a "Google Chrome" docs/product/4-fe/thiet_ke/chu_quan/menu-gia.html
open -a Safari docs/product/4-fe/thiet_ke/chu_quan/menu-gia.html

# Danh mục · Chủ quán
open -a "Google Chrome" docs/product/4-fe/thiet_ke/chu_quan/danh-muc.html
open -a Safari docs/product/4-fe/thiet_ke/chu_quan/danh-muc.html

# Combo · Chủ quán
open -a "Google Chrome" docs/product/4-fe/thiet_ke/chu_quan/combo.html
open -a Safari docs/product/4-fe/thiet_ke/chu_quan/combo.html

# Topping · Chủ quán
open -a "Google Chrome" docs/product/4-fe/thiet_ke/chu_quan/topping.html
open -a Safari docs/product/4-fe/thiet_ke/chu_quan/topping.html

# Nhân viên · Chủ quán
open -a "Google Chrome" docs/product/4-fe/thiet_ke/chu_quan/nhan-vien.html
open -a Safari docs/product/4-fe/thiet_ke/chu_quan/nhan-vien.html

# Giao việc · Chủ quán
open -a "Google Chrome" docs/product/4-fe/thiet_ke/chu_quan/giao-viec.html
open -a Safari docs/product/4-fe/thiet_ke/chu_quan/giao-viec.html

# Đào tạo · Chủ quán
open -a "Google Chrome" docs/product/4-fe/thiet_ke/chu_quan/dao-tao.html
open -a Safari docs/product/4-fe/thiet_ke/chu_quan/dao-tao.html

# Nguyên liệu · Chủ quán
open -a "Google Chrome" docs/product/4-fe/thiet_ke/chu_quan/nguyen-lieu.html
open -a Safari docs/product/4-fe/thiet_ke/chu_quan/nguyen-lieu.html

# Kho · Chủ quán
open -a "Google Chrome" docs/product/4-fe/thiet_ke/chu_quan/kho.html
open -a Safari docs/product/4-fe/thiet_ke/chu_quan/kho.html

# Khoản chi · Chủ quán
open -a "Google Chrome" docs/product/4-fe/thiet_ke/chu_quan/khoan-chi.html
open -a Safari docs/product/4-fe/thiet_ke/chu_quan/khoan-chi.html
```

### 9.2 Phía khách
```bash
# Thiết kế khách hàng · Bánh cuốn Bà Thanh Cao Bằng
open -a "Google Chrome" docs/product/4-fe/thiet_ke/khach_hang/index.html
open -a Safari docs/product/4-fe/thiet_ke/khach_hang/index.html

# Bánh cuốn Bà Thanh Cao Bằng (trang chủ)
open -a "Google Chrome" docs/product/4-fe/thiet_ke/khach_hang/trang-chu.html
open -a Safari docs/product/4-fe/thiet_ke/khach_hang/trang-chu.html

# Mở mã QR · Bánh cuốn Bà Thanh Cao Bằng
open -a "Google Chrome" docs/product/4-fe/thiet_ke/khach_hang/mo-ma-qr.html
open -a Safari docs/product/4-fe/thiet_ke/khach_hang/mo-ma-qr.html

# Thực đơn · Bánh cuốn Bà Thanh Cao Bằng
open -a "Google Chrome" docs/product/4-fe/thiet_ke/khach_hang/thuc-don.html
open -a Safari docs/product/4-fe/thiet_ke/khach_hang/thuc-don.html

# Chọn món · Bánh cuốn Bà Thanh Cao Bằng
open -a "Google Chrome" docs/product/4-fe/thiet_ke/khach_hang/chon-mon.html
open -a Safari docs/product/4-fe/thiet_ke/khach_hang/chon-mon.html

# Giỏ hàng · Bánh cuốn Bà Thanh Cao Bằng
open -a "Google Chrome" docs/product/4-fe/thiet_ke/khach_hang/gio-hang.html
open -a Safari docs/product/4-fe/thiet_ke/khach_hang/gio-hang.html

# Đã gửi lượt · Bánh cuốn Bà Thanh Cao Bằng
open -a "Google Chrome" docs/product/4-fe/thiet_ke/khach_hang/da-gui-luot.html
open -a Safari docs/product/4-fe/thiet_ke/khach_hang/da-gui-luot.html

# Thông tin đặt đơn · Bánh cuốn Bà Thanh Cao Bằng
open -a "Google Chrome" docs/product/4-fe/thiet_ke/khach_hang/thong-tin-dat.html
open -a Safari docs/product/4-fe/thiet_ke/khach_hang/thong-tin-dat.html

# Đã đặt đơn · Bánh cuốn Bà Thanh Cao Bằng
open -a "Google Chrome" docs/product/4-fe/thiet_ke/khach_hang/da-dat.html
open -a Safari docs/product/4-fe/thiet_ke/khach_hang/da-dat.html

# Không nhận đơn · Bánh cuốn Bà Thanh Cao Bằng
open -a "Google Chrome" docs/product/4-fe/thiet_ke/khach_hang/khong-nhan-don.html
open -a Safari docs/product/4-fe/thiet_ke/khach_hang/khong-nhan-don.html
```
