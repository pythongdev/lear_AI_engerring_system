# Các lệnh `make` cho hệ thống trên máy

Các lệnh này nằm trong [Makefile](../../Makefile) ở gốc repo. Chúng chạy backend, frontend và database **làm việc**
trên máy phát triển (PostgreSQL 17 trong Docker, cổng `127.0.0.1:5433`). Mọi lệnh chạy ở
**thư mục gốc repo**, và Docker Desktop phải đang bật khi dùng database. Muốn biết bên trong mỗi lệnh chạy gì, đọc
[chay-database-tren-may.md](../guideline/chay-database-tren-may.md). Viết 2026-09-29; bổ sung lệnh chạy hệ thống 2026-10-20 theo phiếu T-214 của Claude.

## 1. Xem danh sách lệnh
```bash
make                  # in danh sách mọi lệnh kèm một dòng mô tả
make help             # giống hệt lệnh trên
```

## 2. Lần đầu tiên — dựng database từ số 0
```bash
make setup            # bật database + tạo bảng + nạp dữ liệu mồi, một lệnh là xong
make seed-thu         # sau make seed: thêm dữ liệu thử máy dev; đã có danh mục thì bỏ qua
make tai-khoan-dev    # bật make be ở cửa sổ khác trước; tạo tài khoản thử, đã có thì bỏ qua
make ma-qr-so-ban     # chỉ máy dev: mã QR mỗi bàn = số bàn, mở http://localhost:3000/ban/1
make psql             # vào xem
```
`make setup` chạy lần lượt `make up`, `make migrate`, `make seed`. Xong thì database có đủ bảng,
cùng menu, bàn, người theo vai lấy từ `master_plan/shop-facts.md`.

## 3. Mỗi lần mở máy
```bash
make up               # bật database đã có, dữ liệu cũ vẫn còn
make psql             # vào xem
```

## 4. Chạy toàn bộ hệ thống

Lần đầu cài thư viện frontend (Node.js theo `fe/package.json`), sau đó chạy ở gốc repo:

```bash
(cd fe && npm ci)
make dev
```

`make dev` kiểm tra Go, npm và `fe/node_modules`, chạy `setup` lần lượt bật database,
migration, seed (đã có dữ liệu thì bỏ qua seed), rồi chạy đồng thời server Go ở cổng 8080
và Next ở cổng 3000. Log có tiền tố `[be]` và `[fe]`. Mở **http://localhost:3000**:
Next chuyển nguyên header Origin của trình duyệt lên backend, nên địa chỉ mở phải khớp
`BANHCUON_ORIGIN`, không thay `localhost` bằng `127.0.0.1` khi vẫn dùng mặc định.

Ctrl+C hoặc một bên thoát sẽ tắt cả hai bên và các tiến trình con. Database vẫn chạy;
dùng `make stop` khi muốn tắt database và giữ dữ liệu. Có thể chạy riêng từng bên:

| Lệnh | Công dụng |
|---|---|
| `make dev` | Dựng database rồi chạy cả backend và frontend |
| `make be` | Chạy backend; database phải đã bật |
| `make fe` | Chạy frontend; cần cài thư viện trước |

Các giá trị mặc định dưới đây có thể ghi đè bằng `VAR=… make dev` (hoặc `make be`, `make fe`):

| Biến | Mặc định / ý nghĩa |
|---|---|
| `DB_PORT` | `5433`, cổng database trên máy; truyền cả cho Docker Compose |
| `BANHCUON_DATABASE_URL` | `postgres://shop_app:shop_app_dev@127.0.0.1:$(DB_PORT)/banhcuon?sslmode=disable`; vai và mật khẩu phát triển trong `db/init/` |
| `BANHCUON_SHOP_TZ` | `$(SHOP_TZ)`, đọc từ nguồn múi giờ đã có trong Makefile |
| `BANHCUON_ORIGIN` | `http://localhost:3000`, không có dấu `/` cuối |
| `BANHCUON_FILE_DIR` | `$(CURDIR)/.dev/files`, đường dẫn tuyệt đối tới kho tệp phát triển |
| `BANHCUON_BE_URL` | `http://127.0.0.1:8080`, địa chỉ Next dùng gọi backend |

`$(DB_PORT)`, `$(SHOP_TZ)` và `$(CURDIR)` trong bảng là cách Makefile dựng giá trị,
không phải chuỗi cần gõ vào shell. Target tự tạo kho tệp và `.dev/.gitignore` chứa `*`,
để dữ liệu trong `.dev/` không xuất hiện trong `git status`. Nếu đổi kho tệp, dùng đường dẫn tuyệt đối.

Ví dụ đổi cổng database, hoặc đổi đồng bộ cổng backend và frontend qua biến môi trường
mà server Go và Next đã hỗ trợ:

```bash
DB_PORT=5434 make dev
BANHCUON_ADDR=:9090 BANHCUON_BE_URL=http://127.0.0.1:9090 \
  PORT=3001 BANHCUON_ORIGIN=http://localhost:3001 make dev
```

Với ví dụ thứ hai, mở `http://localhost:3001`. Nếu cổng giao diện bận và Next chọn cổng khác,
hãy dừng rồi đặt lại `PORT` và `BANHCUON_ORIGIN` cho khớp.

Không có tài khoản chủ quán được tạo tự động. Muốn đăng nhập, chạy một lần lệnh
`khoitao-chu-quan` trong mục **Khởi tạo chủ quán và cấu hình đăng nhập** cuối trang,
với cùng `BANHCUON_DATABASE_URL` và `BANHCUON_SHOP_TZ` như `make be`.
Mật khẩu đọc từ stdin; không ghi vào file.

## 5. Từng bước riêng lẻ
```bash
make up               # bật database, chờ tới khi sẵn sàng mới trả về
make migrate          # chạy các migration CHƯA chạy ở db/migrations/ — file đã chạy thì bỏ qua
make seed             # nạp dữ liệu mồi — tự bỏ qua nếu database đã có dữ liệu
```
Khi có file migration mới (ai đó vừa thêm vào `db/migrations/`), chỉ cần `make migrate`, không
phải xoá database.

## 6. Vào bên trong container
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

## 7. Kiểm tra và tắt
```bash
make status           # xem container database có đang chạy không (cột STATUS ghi "healthy" là tốt)
make stop             # tắt database, GIỮ dữ liệu — lần sau make up là có lại
```

## 8. Xoá sạch và dựng lại
```bash
make reset            # XOÁ HẾT dữ liệu, rồi tự chạy make setup
```
Dùng khi dữ liệu đã bị sửa lung tung lúc thử và bạn muốn quay về trạng thái sạch ban đầu. Lệnh
này không hỏi lại, và dữ liệu đã xoá thì không lấy lại được.

## 9. Khi gặp lỗi
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

## 10. Xem hợp đồng API bằng Swagger UI
```bash
make swagger          # bật Swagger UI — mở http://127.0.0.1:8081/docs/
make swagger-stop     # tắt
```
Trang đọc thẳng [openapi.yaml](../product/3-be/openapi.yaml) — hợp đồng API, nơi duy nhất ghi đường
gọi và mã lỗi. Sửa file đó rồi tải lại trang là thấy, không cần bật lại. Trang chỉ để **xem và gọi
thử**; muốn đổi hợp đồng thì sửa file theo luật ở
[01-hop-dong-api.md](../product/3-be/01-hop-dong-api.md). Viết 2026-10-13.

Nút **Try it out** gửi request qua chính cổng 8081, rồi được chuyển sang server Go ở cổng `8080`
của máy, nên phải bật server trước (database đang chạy, vai `shop_app`):
```bash
make be
```
`make be` dựng các biến môi trường như mục **Chạy toàn bộ hệ thống** ở trên.
Cửa cần quyền đòi header `X-Person-Id`: bấm **Authorize**, điền số `person_id` lấy từ `GET /people`.
Server chưa bật thì Try it out trả `502 Bad Gateway` — không phải lỗi của hợp đồng. Đổi cổng:
`SWAGGER_PORT=9000 make swagger`; server Go ở chỗ khác: `BE_UPSTREAM=host.docker.internal:9090 make swagger`.

## 11. Không nằm trong `make`
```bash
./scripts/db-check.sh # bộ kiểm database — dựng database RIÊNG, kiểm xong gỡ đi
./scripts/gate.sh     # toàn bộ cổng kiểm của repo
```
Hai lệnh này không đụng tới database làm việc: dữ liệu bạn xem bằng `make psql` vẫn còn nguyên
sau khi chúng chạy.

### Khởi tạo chủ quán và cấu hình đăng nhập (T-190)

Server cần `BANHCUON_DATABASE_URL` (vai shop_app), `BANHCUON_SHOP_TZ` và
`BANHCUON_ORIGIN` (origin giao diện, không dấu `/` cuối). SMTP và đường suy giảm
được mô tả ở [hợp đồng API](../product/3-be/01-hop-dong-api.md).
Từ P3A-04 server cần thêm `BANHCUON_FILE_DIR` — thư mục kho tệp hướng dẫn, phải tồn tại và
ghi được; sao lưu database **không** chứa tệp, sao lưu thư mục này riêng.

Chạy lệnh ở thư mục `be/`; mật khẩu đọc một dòng từ stdin, không có cờ mật khẩu:

```sh
go run ./cmd/khoitao-chu-quan -username chuquan -email chuquan@example.com -display-name 'Chủ quán'
```

Cấp stdin từ nguồn bí mật của môi trường triển khai. Lệnh dùng cùng DSN và múi giờ
như server, tạo người có cờ chủ quán và tài khoản vai owner trong cùng giao dịch.


make reset && make setup && make seed-thu
