# Các lệnh `make` cho database trên máy

Các lệnh này nằm trong [Makefile](../../Makefile) ở gốc repo. Chúng lo cho database **làm việc**
trên máy phát triển (PostgreSQL 17 trong Docker, cổng `127.0.0.1:5433`). Mọi lệnh chạy ở
**thư mục gốc repo**, và Docker Desktop phải đang bật. Muốn biết bên trong mỗi lệnh chạy gì, đọc
[chay-database-tren-may.md](../guideline/chay-database-tren-may.md). Viết 2026-09-29.

## 1. Xem danh sách lệnh
```bash
make                  # in danh sách mọi lệnh kèm một dòng mô tả
make help             # giống hệt lệnh trên
```

## 2. Lần đầu tiên — dựng database từ số 0
```bash
make setup            # bật database + tạo bảng + nạp dữ liệu mồi, một lệnh là xong
make psql             # vào xem
```
`make setup` chạy lần lượt `make up`, `make migrate`, `make seed`. Xong thì database có đủ bảng,
cùng menu, bàn, người theo vai lấy từ `master_plan/shop-facts.md`.

## 3. Mỗi lần mở máy
```bash
make up               # bật database đã có, dữ liệu cũ vẫn còn
make psql             # vào xem
```

## 4. Từng bước riêng lẻ
```bash
make up               # bật database, chờ tới khi sẵn sàng mới trả về
make migrate          # chạy các migration CHƯA chạy ở db/migrations/ — file đã chạy thì bỏ qua
make seed             # nạp dữ liệu mồi — tự bỏ qua nếu database đã có dữ liệu
```
Khi có file migration mới (ai đó vừa thêm vào `db/migrations/`), chỉ cần `make migrate`, không
phải xoá database.

## 5. Vào bên trong container
```bash
make psql             # mở psql trong container, đã đặt múi giờ của quán
make shell            # mở shell bash trong container (không vào thẳng psql)
```
Các lệnh hay dùng khi đã ở trong `psql` — không cần gõ `shop.` trước tên bảng:
```sql
\dt                          -- liệt kê mọi bảng
\d menu_item                 -- cột, kiểu, ràng buộc, trigger của một bảng
\x auto                      -- tự xoay kết quả thành dọc khi bảng quá rộng
SELECT * FROM menu_item;     -- các dòng menu
SELECT * FROM dining_table;  -- các bàn
SELECT * FROM person;        -- người theo vai và chủ quán
\q                           -- thoát psql
```

## 6. Kiểm tra và tắt
```bash
make status           # xem container database có đang chạy không (cột STATUS ghi "healthy" là tốt)
make stop             # tắt database, GIỮ dữ liệu — lần sau make up là có lại
```

## 7. Xoá sạch và dựng lại
```bash
make reset            # XOÁ HẾT dữ liệu, rồi tự chạy make setup
```
Dùng khi dữ liệu đã bị sửa lung tung lúc thử và bạn muốn quay về trạng thái sạch ban đầu. Lệnh
này không hỏi lại, và dữ liệu đã xoá thì không lấy lại được.

## 8. Khi gặp lỗi
```bash
docker info           # báo lỗi ⇒ Docker Desktop chưa bật; bật lên rồi chạy lại
make status           # không thấy banhcuon-db-1 ⇒ database chưa bật; chạy make up
```
- **`make seed` báo "đã có dữ liệu — bỏ qua"**: không phải lỗi. Muốn nạp lại từ đầu thì
  `make reset`.
- **Cảnh báo "Found orphan containers (banhcuon-be-1 …)"**: đó là container của một dự án cũ
  trùng tên project, không ảnh hưởng gì. Có thể bỏ qua.
- **"Không đọc được múi giờ ở master_plan/shop-facts.md"**: dòng `| Múi giờ |` trong file đó
  bị đổi hình; `make psql` và `make seed` dừng lại thay vì chạy sai múi giờ.

## 9. Không nằm trong `make`
```bash
./scripts/db-check.sh # bộ kiểm database — dựng database RIÊNG, kiểm xong gỡ đi
./scripts/gate.sh     # toàn bộ cổng kiểm của repo
```
Hai lệnh này không đụng tới database làm việc: dữ liệu bạn xem bằng `make psql` vẫn còn nguyên
sau khi chúng chạy.
