# Tài khoản thử trên máy phát triển

Các tài khoản dưới đây chỉ có trong database **làm việc** trên máy phát triển (`make up`, cổng
`127.0.0.1:5433`) và **chỉ để thử**. Mật khẩu ở đây là mật khẩu máy phát triển, giống mật khẩu trong
[compose.yaml](../../compose.yaml): không dùng chúng ở bất kỳ nơi nào khác. Tạo ngày 2026-10-20.

Đăng nhập ở **http://localhost:3000/dang-nhap** sau khi đã chạy `make dev` (xem mục *Chạy toàn bộ hệ
thống* ở [make.md](make.md)). Mở bằng `localhost`, không mở bằng `127.0.0.1`, vì backend chặn lệnh
ghi đến từ origin khác.

| Tên đăng nhập | Mật khẩu | Vai | Gắn với người | Màn vào |
|---|---|---|---|---|
| `chu` | `chuquan123` | chủ quán (`owner`) | Chủ quán (dev) | `/chu-quan` |
| `quay` | `quay1234` | đứng quầy (`quay`) | Người đứng quầy | `/quay` |
| `trang` | `trang1234` | tráng bánh (`trang_banh`) | Người tráng bánh | `/tram` |
| `gap` | `gap12345` | gấp bánh (`gap_banh`) | Người gấp bánh | `/tram` |
| `canh` | `canh1234` | canh và dọn (`canh_don_ban`) | Người canh & dọn | `/tram` |

Bốn tài khoản theo vai được gắn vào bốn người có sẵn trong dữ liệu mồi, nên lịch sử chấm công,
giao việc và đào tạo của những người đó hiện ra đúng tên. Database dựng trước 2026-10-23 có thể còn hai
tài khoản cũ là `chuquan` và `nguoila`, tạo trong những lần thử trước; mật khẩu của chúng không được ghi
lại ở đâu, nên hãy dùng bảng trên. Sau `make reset` thì hai tài khoản ấy mất hẳn.

## Dựng lại database cùng dữ liệu thử (cập nhật 2026-10-23, T-236)

`make reset` xoá hết dữ liệu, kể cả các tài khoản này. Thứ tự dựng lại đầy đủ:

```bash
make reset        # xoá database
make setup        # bật database, tạo bảng, nạp dữ liệu mồi (món, giá, bàn, người theo vai, nguyên liệu, loại chi)
make seed-thu     # nạp dữ liệu thử cho các mục của trang chủ quán (danh mục, combo, giao việc, đào tạo,
                  # khoản chi, sổ nguyên liệu, chấm công) — không phải sự thật của quán
```

`make seed-thu` cần dữ liệu mồi bản hiện nay: database dựng bằng `seed.pl` cũ (chưa có loại chi) sẽ dừng ở
*"thiếu loại chi từ make seed"* và không ghi gì — khi ấy làm lại từ `make reset`. Việc giao, đào tạo và
ngày công thử gắn vào **Người đứng quầy** (người đầu tiên không phải chủ quán), nên đăng nhập `quay` sẽ thấy
chúng. Lệnh này không tạo tài khoản và không tạo đơn bán; thứ tự giữa nó và bước tạo tài khoản dưới đây
không quan trọng.

## Tạo lại tài khoản

Ở gốc repo, bật backend trong một cửa sổ:

```bash
make be
```

Trong cửa sổ khác, cũng ở gốc repo:

```bash
make tai-khoan-dev
```

Chạy lại an toàn: tài khoản có cùng tên đăng nhập sẽ được bỏ qua, không đổi mật khẩu hay vai.
Lệnh lấy bốn người không phải chủ quán, sắp theo id, rồi lần lượt gắn với `quay`, `trang`, `gap`,
`canh`; tên hiển thị lấy từ database. Nếu số người không phải chủ quán khác 4, lệnh dừng và báo rõ.
Cuối lệnh có bảng tên đăng nhập và trạng thái tạo mới hoặc bỏ qua.
