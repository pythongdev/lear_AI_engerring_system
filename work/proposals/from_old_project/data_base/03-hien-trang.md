# 03 — Hiện trạng Database

> Cập nhật **2026-08-19** · Lane sở hữu: **DB** · Dời từ `status/01-database.md` (`git log --follow`).
> Nguồn sự thật: [code/be/migrations/](../../code/be/migrations/) — **code thắng file này khi lệch** ([CLAUDE.md §2](../../CLAUDE.md)).
> Sự thật DB khác: [thiết kế](01-thiet-ke.md) · [luật](02-luat.md) · [yêu cầu khi làm việc](04-yeu-cau.md).

**Tóm tắt: đây là phần hoàn thiện nhất của project (~90%).** Toàn bộ mô hình dữ liệu
cho cả 4 luồng (web, QR bàn, POS, bếp) đã dựng xong và chạy được, kể cả những bảng mà
backend chưa hề dùng tới.

## Đã có

### 5 migration, đủ cặp up/down

| File | Bảng | Dòng |
|------|------|------|
| [000001_menu.up.sql](../../code/be/migrations/000001_menu.up.sql) | `categories`, `products`, `product_option_groups`, `product_options`, `product_components`, `product_stations` | 81 |
| [000002_tables_staff.up.sql](../../code/be/migrations/000002_tables_staff.up.sql) | `tables`, `staff`, `table_sessions` | 45 |
| [000003_orders.up.sql](../../code/be/migrations/000003_orders.up.sql) | `orders`, `order_items`, `order_item_options`, `order_tasks`, `payments`, `order_status_history`, `store_settings` | 129 |
| [000004_fix_open_key.up.sql](../../code/be/migrations/000004_fix_open_key.up.sql) | *(không thêm bảng)* — vá [F-01](../../finding.md#f-01): `open_key` tính cả `billing` | 30 |
| [000005_order_constraints.up.sql](../../code/be/migrations/000005_order_constraints.up.sql) | *(không thêm bảng)* — siết ràng buộc đơn, đóng [F-45](../../finding.md#f-45) [F-46](../../finding.md#f-46) [F-47](../../finding.md#f-47) | 31 |

**Tổng 16 bảng** (`grep -h 'CREATE TABLE' code/be/migrations/*.up.sql | wc -l`).
Tất cả `ENGINE=InnoDB`, `utf8mb4_unicode_ci`.

> Migration `000004` **drop rồi tạo lại** cột sinh, vì biểu thức của cột `STORED` không sửa
> tại chỗ được. Bảng còn trống nên rebuild không tốn gì — nhưng khi đã có dữ liệu thật,
> `ALTER` này khoá bảng (`ALGORITHM=COPY`), **phải chạy ngoài giờ bán 6h–11h**.

### Ràng buộc đã đẩy xuống tầng DB (đúng nguyên tắc "chặn trước")

| Ràng buộc | Ở đâu | Chặn được gì |
|---|---|---|
| `open_key` generated column + `UNIQUE uq_session_one_open` | [000004](../../code/be/migrations/000004_fix_open_key.up.sql) *(thay bản cũ ở [000002:38](../../code/be/migrations/000002_tables_staff.up.sql#L38))* | **Mỗi bàn tối đa 1 phiên chưa thanh toán xong** (`open` **hoặc** `billing`) — chặn race hai máy cùng mở phiên một bàn, và chặn cả việc gọi thêm món lúc quầy đang tính tiền |
| `chk_order_dinein` | [000003:24-27](../../code/be/migrations/000003_orders.up.sql#L24-L27) | Đơn `dine_in` bắt buộc có `table_session_id`; đơn ship/pickup bắt buộc có `customer_phone` |
| `chk_pay_target` | [000003:93-95](../../code/be/migrations/000003_orders.up.sql#L93-L95) | Một payment trỏ **đúng một** đích: hoặc `order_id`, hoặc `table_session_id` |
| `chk_settings_singleton` | [000003:128](../../code/be/migrations/000003_orders.up.sql#L128) | `store_settings` chỉ có duy nhất hàng `id = 1` |
| `UNIQUE uq_optgroup_product_code`, `uq_option_group_code` | migration 1 | Không trùng mã nhóm/option trong cùng món |
| `chk_items_qty`, `chk_tasks_qty` | [000005](../../code/be/migrations/000005_order_constraints.up.sql) | `quantity > 0` ở `order_items` + `order_tasks` — `UNSIGNED` chỉ chặn âm, không chặn 0 |
| `chk_order_channel_fulfillment` | [000005](../../code/be/migrations/000005_order_constraints.up.sql) | Chỉ 4 tổ hợp `channel`×`fulfillment` hợp lệ theo [00-scope §2](../../project_preparation/00-scope.md) — chặn tổ hợp vô nghĩa kiểu `(qr_table, delivery)` |
| `fk_items_product` (RESTRICT) | [000005](../../code/be/migrations/000005_order_constraints.up.sql) | `order_items.product_id` rác — món ngừng bán dùng `is_active`, không `DELETE`, nên FK không cản nghiệp vụ |

### Tiền là số nguyên ở mọi nơi
`base_price`, `price_delta`, `subtotal`, `unit_price`, `line_total`, `total`, `amount`
đều là `INT` / `INT UNSIGNED`, đơn vị VND. **Không có `FLOAT`/`DECIMAL` nào.**
`price_delta` cố ý để `INT` có dấu để sau này giảm giá option được.

### Cột snapshot đã có sẵn
`order_items` giữ `product_name`, `base_price`, `options_price`, `unit_price`, `line_total`;
`order_item_options` giữ `group_name`, `option_name`, `price_delta`.
→ Tăng giá menu sau này **không làm sai đơn cũ và báo cáo doanh thu**.
(Lưu ý: bảng đã có cột, nhưng **code ghi vào chưa được viết** — xem [03-hien-trang.md](../backend/03-hien-trang.md).)

### Seed thực đơn thật — [seed.sql](../../code/be/migrations/seed.sql) (133 dòng)

- 3 danh mục, 8 món, ID cố định (`id = 7` là combo đầy đủ tái).
- `product_components`: combo → 3 bánh cuốn + 1 trứng + 1 giò.
- 2 nhóm option (`nhan`, `luong_nhan`) gắn cho từng món, kèm `price_delta`.
- `product_stations`: món nào chạy qua trạm nào (`quay`/`trang_banh`/`gap_banh`/`canh`/`don_ban`).
- 1 hàng `store_settings` (giờ mở 06:00–11:00).

Giá không hardcode trong Go — đổi giá là sửa `base_price`/`price_delta` ở file này.

## Chưa có

| Việc | Ảnh hưởng |
|------|-----------|
| **Seed `staff`** — chưa có tài khoản chủ quán nào | Không đăng nhập được ngay cả khi API auth viết xong. Cần 1 hàng `owner` với `password_hash` bcrypt. |
| **Seed `tables`** — chưa có bàn nào, chưa sinh `qr_token` | Luồng QR chưa test được đầu-cuối |
| **Index cho báo cáo doanh thu** | `GET /admin/reports/daily` sẽ quét bảng. Hiện `idx_pay_created (created_at)` có rồi, có thể đủ cho quy mô quán — đo trước khi thêm |
| **Diễn tập `down` → `up` → seed** | [quality/04-devops.md](../../quality/04-devops.md) yêu cầu chạy được vòng này trong CI; chưa có ai chạy thật |
| **Backup + thử restore** | [02-luat.md §6](02-luat.md) yêu cầu "backup phải restore được". Chưa có script `mysqldump`, chưa từng restore thử |

## Rủi ro cần theo dõi

1. **`order_tasks.status` có cả `waiting` lẫn `todo`** — DB cho phép, chưa code nào định nghĩa
   khi nào dùng `waiting`. [F-06](../../finding.md#f-06) đã có phương án chốt (đơn `qr_table` sinh
   task ở `waiting`, quầy duyệt thì chuyển cả lô sang `todo`) nhưng **chưa được chốt chính thức**.
   Phải xong trước khi viết luồng nổ combo — đây là loại lệch không test nào bắt được,
   vì cả hai cách hiểu đều chạy.
2. **`orders.status` có 8 giá trị** nhưng chưa có bảng chuyển trạng thái hợp lệ ở đâu cả
   ([F-07](../../finding.md#f-07)). `order_status_history` ghi lại được lịch sử, nhưng **không chặn**
   bước nhảy sai (ví dụ `pending → completed` bỏ qua bếp). Luật này sẽ phải nằm ở tầng service.
3. **Múi giờ**: MySQL đã set `--default-time-zone=+07:00` trong compose và `TZ` trong container.
   Đúng rồi, nhưng nếu sau này chạy MySQL ngoài Docker thì phải set lại thủ công.
