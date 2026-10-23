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

Bật backend bằng `make be` ở một cửa sổ, rồi chạy khối dưới ở gốc repo, trong một cửa sổ khác. Mật khẩu chủ quán đi qua stdin, đúng như
lệnh gốc yêu cầu. Bốn người theo vai mang `person_id` 1…4 theo dữ liệu mồi hiện nay (người 5 là *Chủ quán*
của dữ liệu mồi; lệnh khởi tạo dưới đây thêm một người chủ quán nữa, *Chủ quán (dev)*); nếu dữ liệu mồi
đổi thì kiểm lại bằng `make psql` → `SELECT id, display_name FROM person;`.

```bash
echo 'chuquan123' | (cd be && BANHCUON_DATABASE_URL="postgres://shop_app:shop_app_dev@127.0.0.1:5433/banhcuon?sslmode=disable" \
  BANHCUON_SHOP_TZ="$(grep -m1 '^| Múi giờ |' master_plan/shop-facts.md | grep -o '`[^`]*`' | head -1 | tr -d '`')" \
  go run ./cmd/khoitao-chu-quan -username chu -email chu@quan.test -display-name 'Chủ quán (dev)')

B=http://127.0.0.1:8080; H='content-type: application/json'; J=$(mktemp)
curl -s -c "$J" -H "$H" -d '{"username":"chu","password":"chuquan123"}' $B/sessions >/dev/null
for row in "quay|Người đứng quầy|quay1234|quay|1" "trang|Người tráng bánh|trang1234|trang_banh|2" \
           "gap|Người gấp bánh|gap12345|gap_banh|3" "canh|Người canh & dọn|canh1234|canh_don_ban|4"; do
  IFS='|' read u n pw role pid <<<"$row"
  id=$(curl -s -H "$H" -d "{\"username\":\"$u\",\"email\":\"$u@quan.test\",\"display_name\":\"$n\",\"password\":\"$pw\"}" \
       $B/accounts | grep -oE '"account_id":[0-9]+' | cut -d: -f2)
  curl -s -b "$J" -H "$H" -d "{\"role_code\":\"$role\",\"person_id\":$pid}" $B/accounts/$id/approval; echo
done
rm -f "$J"
```

Mỗi dòng in ra phải có `"status":"hoat_dong"`. Nếu không, tài khoản đó đã có sẵn, hoặc `person_id`
không còn đúng.
