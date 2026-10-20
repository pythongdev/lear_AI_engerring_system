# Mở bản thiết kế trang chủ quán

Bản thiết kế tĩnh của trang chủ quán nằm ở [docs/product/4-fe/thiet_ke/chu_quan/](../product/4-fe/thiet_ke/chu_quan/index.html): 13 trang HTML,
một trang mục lục `index.html` và một `styles.css` chung (T-215). Không cần chạy database, server Go hay Next — chỉ cần trình duyệt. Mọi lệnh
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
