# Mở trang trên iPhone cùng Wi-Fi với MacBook

Cập nhật 2026-11-16 (Claude, T-331, sau khi chạy thử trên Mac và chủ repo mở được trên iPhone).

Trang chủ quán cần đăng nhập, mà cookie đăng nhập chỉ chạy qua HTTPS. Mở bằng
`http://<IP>:3000` thì iPhone chỉ thấy trang đứng ở "Đang mở…". Vì vậy phải dùng lệnh
`make dev-iphone`: nó chạy trang qua HTTPS ở cổng **3002** (backend ở **8082**). Mọi lệnh dưới
đây chạy ở **gốc repo**. Next chỉ cho **một** dev server trên repo, nên đang chạy `make dev` thì
phải tắt trước bằng `make stop-dev`; lệnh tự báo nếu bạn quên.

## Các bước mỗi lần muốn xem trên iPhone

1. MacBook và iPhone bắt **cùng một Wi-Fi**.

2. Trên Mac, mở Terminal ở gốc repo và chạy:

   ```bash
   make dev-iphone
   ```

   Muốn chỉ định IP thì chạy `make dev-iphone IP=192.168.x.x`; không ghi thì lệnh tự đọc IP của
   Wi-Fi (`en0`).

   Dòng đầu tiên lệnh in ra là địa chỉ cần mở, ví dụ
   `Trang iPhone: https://192.168.102.4:3002/chu-quan`. Ghi lại IP trong dòng đó; IP có thể đổi
   khi Mac kết nối lại Wi-Fi. Giữ Terminal mở suốt lúc thử. Lần đầu chưa có database thì chạy
   `make setup` trước.

3. Trên iPhone, mở `https://<IP của Mac>:3002/dang-nhap` (Chrome hoặc Safari đều được).

4. Trình duyệt báo **"Kết nối của bạn không phải là kết nối riêng tư"**. Đây là bình thường: chứng
   chỉ do chính Mac tự ký. Bấm qua:
   - **Chrome:** bấm **Nâng cao** → **Tiếp tục truy cập <IP> (không an toàn)**.
   - **Safari:** bấm **Hiện chi tiết** → **truy cập trang web này** → xác nhận.

5. Đăng nhập bằng tài khoản thử của chủ quán — email và mật khẩu ở
   [tai-khoan-dev.md](tai-khoan-dev.md). Không dùng mật khẩu thật.

6. Mở `https://<IP của Mac>:3002/chu-quan`.

7. Thử xong, quay lại Terminal trên Mac và nhấn **Ctrl+C** để tắt.

## Nếu gặp sự cố

- **Ô đỏ "A tree hydrated but some attributes… didn't match"**: đây là cảnh báo của chế độ phát
  triển, không làm hỏng trang; bấm **×** để đóng rồi dùng tiếp. Thường do trình duyệt trên iPhone tự
  sửa trang (tự dịch, tự điền mật khẩu, tự biến số điện thoại thành liên kết).
- **Không có nút "Nâng cao" hay "truy cập trang web này"**: dùng cách cài chứng chỉ ở mục dưới.
- **Trang đứng ở "Đang mở…"**: mở `https://<IP>:3002/api/sessions/current`. Thấy
  `{"code":"unauthenticated"}` là server vẫn chạy, chỉ là chưa đăng nhập; không thấy gì thì kiểm
  tra Terminal trên Mac còn chạy không và IP có đúng không.
- **Mac đổi IP**: tắt bằng Ctrl+C, chạy lại `make dev-iphone`, mở bằng IP mới.

## Cách dự phòng: cài chứng chỉ để hết cảnh báo

Chỉ cần khi bước 4 không bấm qua được, hoặc không muốn thấy cảnh báo mỗi lần.

1. Trong Terminal thứ hai, ở gốc repo, chạy (thư mục này do `make dev-iphone` tạo ra):

   ```bash
   python3 -m http.server 8001 --bind 0.0.0.0 --directory .dev/iphone-public
   ```

   Thư mục này chỉ chứa chứng chỉ công khai `ca.cer`; khoá riêng không được phát ra.

2. Trên iPhone, mở **Safari** tới `http://<IP của Mac>:8001/ca.cer` và cho phép tải hồ sơ.
3. **Cài đặt → Cài đặt chung → VPN & Quản lý thiết bị** → cài hồ sơ *Banhcuon iPhone Dev CA*.
4. **Cài đặt → Cài đặt chung → Giới thiệu → Cài đặt tin cậy chứng chỉ** → bật tin cậy cho
   chứng chỉ đó.
5. Tắt server 8001 bằng Ctrl+C. Chứng chỉ có hạn 90 ngày; thử xong nên gỡ hồ sơ ở
   **VPN & Quản lý thiết bị**.

## Xem trang thiết kế tĩnh (không cần đăng nhập)

Dùng cho các file HTML thiết kế, không phải ứng dụng thật:

```bash
python3 -m http.server 8000 --bind 0.0.0.0 --directory "docs/private/prompt/menu-am-cung"
```

Trên iPhone mở `http://<IP của Mac>:8000/anh-moi.html`.
