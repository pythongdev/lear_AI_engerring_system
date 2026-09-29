# Chạy database trên máy và vào xem bên trong

Hướng dẫn này dành cho người muốn **tận mắt xem** database của quán: dựng nó bằng Docker, tạo
bảng, nạp dữ liệu mồi, rồi vào trong container để tra. Viết 2026-09-29, chạy thử đủ các bước trên
máy phát triển cùng ngày.

File này chỉ đường, không giữ luật. Cấu hình database do [compose.yaml](../../compose.yaml) giữ,
quy ước chạy do [10-quy-uoc-code.md](../product/2-db/10-quy-uoc-code.md) giữ (`QC-02`, `QC-03`,
`QC-05`, `QC-06`). Hai chỗ đó lệch với file này thì hai chỗ đó đúng.

## Cần có trước

Máy cần có Docker Desktop **đang bật** (lệnh `docker info` chạy không báo lỗi) và có `perl` (macOS
có sẵn). Mọi lệnh dưới đây chạy ở **thư mục gốc repo**.

## Bước 1 — Bật database

```bash
docker compose up -d --wait db
```

Lệnh này dựng container PostgreSQL 17 tên `banhcuon-db-1`, mở cổng `127.0.0.1:5433`, và chờ tới
khi database sẵn sàng mới trả về. Ở lần dựng **đầu tiên**, nó chạy
[db/init/001-vai-va-schema.sql](../../db/init/001-vai-va-schema.sql) để tạo hai vai `shop_owner`
(chủ lược đồ), `shop_app` (vai hệ thống dùng để ghi, không xoá được) và schema `shop`. Lúc này
database mới có khung, chưa có bảng nào.

## Bước 2 — Tạo bảng

```bash
docker compose run --rm migrate
```

Lệnh này chạy mọi file migration trong [db/migrations/](../../db/migrations/) theo thứ tự mốc giờ
ở tên file. Mỗi file in ra một dòng như `20260927120000/u ban_hang_loi (6ms)`. Chạy xong, schema
`shop` có đủ các bảng (31 bảng vào ngày viết). Chạy lại lần nữa không hại gì: công cụ nhớ file nào
đã chạy và bỏ qua.

## Bước 3 — Nạp dữ liệu mồi

```bash
perl db/seed/seed.pl | docker compose exec -T -e PGTZ=Asia/Ho_Chi_Minh db \
  psql -X -q -v ON_ERROR_STOP=1 -U shop_owner -d banhcuon
```

[db/seed/seed.pl](../../db/seed/seed.pl) đọc menu, bàn và người từ `master_plan/shop-facts.md`,
in ra SQL; dấu `|` chuyền SQL ấy vào `psql` bên trong container. Kết quả là database có dòng menu,
bàn kèm mã QR, thành phần, người theo vai và chủ quán. Múi giờ `Asia/Ho_Chi_Minh` lấy từ
`master_plan/shop-facts.md` §1 — mọi kết nối phải đặt múi giờ tường minh (`QC-06`).

Chỉ chạy bước này **một lần** cho mỗi database mới. Chạy lần hai sẽ báo lỗi trùng tên và không
nạp gì thêm (cả khối nằm trong một giao dịch, lỗi là huỷ hết). Muốn nạp lại từ đầu thì xem mục
*Xoá sạch để dựng lại* ở cuối.

## Bước 4 — Vào trong container để xem

```bash
docker compose exec -e PGTZ=Asia/Ho_Chi_Minh db psql -U shop_owner -d banhcuon
```

Lệnh này mở `psql` ngay bên trong container. Dấu nhắc đổi thành `banhcuon=#`. Không cần gõ `shop.`
trước tên bảng, vì vai `shop_owner` đã đặt sẵn đường tìm vào schema `shop`.

Mấy lệnh hay dùng khi đã vào trong:

```sql
\dt                          -- liệt kê mọi bảng
\d menu_item                 -- cột, kiểu, ràng buộc, trigger của một bảng
\x auto                      -- tự xoay kết quả thành dọc khi bảng quá rộng
SELECT * FROM menu_item;     -- các dòng menu
SELECT * FROM dining_table;  -- các bàn
SELECT * FROM person;        -- người theo vai và chủ quán
\q                           -- thoát
```

Muốn vào một shell thường của container (không vào thẳng `psql`) thì dùng:

```bash
docker compose exec db bash
```

## Xem bằng giao diện đồ hoạ (tuỳ chọn)

TablePlus, DBeaver hay pgAdmin đều được. Tạo một kết nối PostgreSQL với các thông số sau:

```text
Host      127.0.0.1
Port      5433        (không phải 5432 — máy phát triển đã có PostgreSQL khác giữ cổng đó)
Database  banhcuon
User      shop_owner
Password  shop_owner_dev
```

Mật khẩu này chỉ dành cho máy phát triển, không dùng ở đâu khác.

## Tắt database

```bash
docker compose stop db
```

Tắt nhưng **giữ dữ liệu**. Lần sau chỉ cần chạy lại Bước 1 rồi nhảy thẳng tới Bước 4.

## Xoá sạch để dựng lại

```bash
docker compose rm -sfv db
```

Lệnh này dừng container và **xoá luôn dữ liệu**. Sau đó làm lại từ Bước 1 tới Bước 4.

## Những điều nên biết

**Cảnh báo "Found orphan containers".** Lúc chạy Bước 2, Docker có thể in cảnh báo về các container
như `banhcuon-be-1`, `banhcuon-mysql-1`. Đó là container của một dự án cũ trùng tên project
`banhcuon`, không liên quan tới database này và không ảnh hưởng gì. Chỉ thêm `--remove-orphans`
vào lệnh khi chắc chắn không còn dùng chúng.

**Bộ kiểm không đụng tới database này.** `./scripts/db-check.sh` luôn dựng một database **riêng**,
rỗng (project `banhcuon_check`, cổng ngẫu nhiên), kiểm xong thì gỡ đi. Database bạn xem ở đây là
database làm việc `banhcuon`, dữ liệu trong nó vẫn còn nguyên sau khi bộ kiểm chạy.

**Migration mới.** Khi có file migration mới trong [db/migrations/](../../db/migrations/), chỉ cần
chạy lại Bước 2 — không phải xoá database.
