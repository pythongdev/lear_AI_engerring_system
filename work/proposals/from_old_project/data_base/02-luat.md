# 02 — Luật Database (MySQL 8.4 LTS)

> Cập nhật **2026-08-19** · Lane sở hữu: **DB** · Dời từ `quality/01-database.md` (`git log --follow`).
> Sự thật DB khác: [thiết kế](01-thiet-ke.md) · [hiện trạng](03-hien-trang.md) · [yêu cầu khi làm việc](04-yeu-cau.md).
> Ngoài thư mục này: [quality/04-devops.md](../../quality/04-devops.md) (backup, CI).

File này định nghĩa **"đúng" nghĩa là gì** ở tầng DB — thước đo, không phải ảnh chụp.
Hệ thống *hiện* có gì thì đọc [03-hien-trang.md](03-hien-trang.md) và `code/be/migrations/`.

DB là tầng cuối cùng còn giữ được dữ liệu đúng khi BE có bug. Mọi ràng buộc quan trọng phải nằm ở đây, không chỉ ở Go.

---

## 1. Bốn quy tắc bất di bất dịch

Nhà gốc: [01-thiet-ke.md mục 2.6](01-thiet-ke.md#26-bốn-quy-tắc-phải-nhớ). Nhắc lại ở đây vì vi phạm là hỏng dữ liệu thật:

1. **`utf8mb4_unicode_ci` cho mọi bảng.** `utf8` (3 byte) làm hỏng tiếng Việt và emoji.
2. **Migration chỉ thêm mới.** Đổi cột → tạo file `000004_...` mới. Tuyệt đối không sửa file đã chạy trên production.
3. **InnoDB cho mọi bảng.** Cần transaction và foreign key.
4. **Snapshot giá + tên món vào `order_items`.** Tăng giá không được làm sai đơn cũ và báo cáo doanh thu.

---

## 2. Ràng buộc phải nằm ở DB

Nguyên tắc: **nếu dữ liệu sai làm hỏng tiền hoặc hỏng nghiệp vụ, DB phải từ chối nó.**

| Ràng buộc | Bảng | Vì sao |
|-----------|------|--------|
| `UNIQUE` trên cột sinh `open_key` | `table_sessions` | Chặn 2 phiên **chưa thanh toán xong** cùng lúc trên 1 bàn — lỗi thu thiếu tiền |
| `UNIQUE(code)` | `orders` | Mã đơn tra cứu phải duy nhất |
| `UNIQUE(slug)` | `products` | FE route theo slug |
| `UNIQUE(token)` | `tables` | Token QR trùng = khách bàn này gọi vào bàn kia |
| `CHECK (quantity > 0)` | `order_items`, `order_tasks` | Số lượng 0 hoặc âm là dữ liệu rác |
| `CHECK (unit_price >= 0)`, `CHECK (total >= 0)` | `order_items`, `orders`, `payments` | Chặn giá âm |
| `FOREIGN KEY` đầy đủ | tất cả bảng con | Xoá món còn đơn tham chiếu = báo cáo vỡ |
| `NOT NULL` mặc định | tất cả | Chỉ cho `NULL` khi thật sự "chưa biết" |

Cột sinh chặn 2 phiên chưa thanh toán xong trên 1 bàn — **chép nguyên văn từ
[000004_fix_open_key.up.sql](../../code/be/migrations/000004_fix_open_key.up.sql)**, đây là bản duy nhất đang chạy:

```sql
-- table_sessions
open_key BIGINT UNSIGNED
  GENERATED ALWAYS AS (IF(status IN ('open','billing'), table_id, NULL)) STORED,
UNIQUE KEY uq_session_one_open (open_key)
```

Phiên `closed`/`cancelled` → `open_key = NULL` → MySQL cho phép nhiều `NULL` trùng nhau.
Phiên `open` hoặc `billing` → chỉ một dòng cho mỗi bàn.

⚠️ Điều kiện phải là `status IN ('open','billing')`, **không phải** `status = 'open'` hay
`closed_at IS NULL`. Bàn đang `billing` là bàn **còn nợ tiền** — bỏ nó ra khỏi điều kiện thì
đúng lúc quầy tính tiền, ràng buộc nhả ra và khách gọi thêm sẽ rơi vào hoá đơn thứ hai
(lỗi F-01, đã vá 2026-08-10). Thêm giá trị mới vào `ENUM status` thì hỏi lại câu đó rồi mới sửa `IN (...)`.

---

## 3. Tiền luôn là số nguyên

```sql
unit_price  INT UNSIGNED NOT NULL,   -- đơn vị: đồng
total       INT UNSIGNED NOT NULL,
```

Không bao giờ `FLOAT`, `DOUBLE`. `DECIMAL` cũng không cần — VNĐ không có phần thập phân trong quán ăn sáng.

Ở Go: `int64`. Ở TypeScript: `number` (an toàn tới 9 triệu tỷ, thừa sức).

**Cách kiểm tra tự động** — thêm vào CI, chạy trên DB sau migration:

```sql
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND (column_name LIKE '%price%' OR column_name LIKE '%total%'
       OR column_name LIKE '%amount%' OR column_name LIKE '%fee%')
  AND data_type NOT IN ('int', 'bigint', 'smallint');
```

Query trả về dòng nào là CI đỏ.

---

## 4. Migration — kỷ luật và cách test

### Quy tắc đặt tên

```
code/be/migrations/
  000001_menu.up.sql          000001_menu.down.sql
  000002_tables_staff.up.sql  000002_tables_staff.down.sql
  000003_orders.up.sql        000003_orders.down.sql
```

**Mọi file `.up.sql` phải có `.down.sql` tương ứng.** Kể cả khi bạn nghĩ sẽ không bao giờ rollback — file `.down` là thứ chứng minh bạn hiểu migration của mình làm gì.

### Test migration trong CI

Chạy trên DB rỗng, ba bước:

```bash
migrate -path code/be/migrations -database "$DSN" up      # lên hết
migrate -path code/be/migrations -database "$DSN" down -all  # xuống hết
migrate -path code/be/migrations -database "$DSN" up      # lên lại
```

Bắt được: `.down.sql` viết sai, thứ tự drop foreign key sai, migration không idempotent.

### Test seed

```bash
migrate ... up && mysql "$DB" < code/be/migrations/seed.sql
mysql "$DB" -e "SELECT COUNT(*) FROM products" | grep -q 8
```

`step.md` tuần 1 yêu cầu "`SELECT` ra đủ 8 món" — biến câu đó thành assert trong CI.

### Migration trên production

1. **Chạy trên staging trước** (staging = DB restore từ backup production, xem [04-devops.md](../../quality/04-devops.md)).
2. Backup ngay trước khi chạy: `./deploy/backup.sh`.
3. Chạy ngoài giờ bán — quán mở 6h–10h, nên deploy sau 11h.
4. Migration thêm cột vào bảng lớn (`orders`, `order_items`) → dùng `ALGORITHM=INPLACE` để không khoá bảng.

---

## 5. Index — kiểm tra sau tuần 4

Khi đã có dữ liệu thật (vài trăm đơn), chạy `EXPLAIN` cho các query nóng:

| Query | Dùng ở | Index cần |
|-------|--------|-----------|
| Menu đầy đủ | `GET /api/v1/products` | `products(is_available, category_id)` |
| Phiên bàn đang mở | POS quầy, polling liên tục | `table_sessions(closed_at, table_id)` |
| Việc theo trạm | Màn hình trạm, polling liên tục | `order_tasks(station, status, created_at)` |
| Tra cứu đơn theo mã | `GET /api/v1/orders/:code` | `UNIQUE(code)` — đã có |
| Báo cáo ngày | `GET /admin/reports/daily` | `orders(created_at, status)` |

```sql
EXPLAIN SELECT ... ;
```

Thấy `type: ALL` (full table scan) trên bảng có > 1000 dòng là thiếu index. Ba query polling (phiên bàn, việc theo trạm) chạy vài giây một lần trên 5 tablet — thiếu index ở đây là CPU VPS cháy vào giờ cao điểm.

---

## 6. Backup — không restore được thì không phải backup

`step.md` mục 6.7 đã có cron `mysqldump`. Bổ sung ba việc:

### a. Kiểm tra file backup ngay sau khi tạo

Thêm vào `deploy/backup.sh`:

```bash
gzip -t "$DIR/$FILE.gz" || { echo "BACKUP HỎNG: $FILE" >&2; exit 1; }

SIZE=$(stat -f%z "$DIR/$FILE.gz" 2>/dev/null || stat -c%s "$DIR/$FILE.gz")
[ "$SIZE" -gt 10240 ] || { echo "BACKUP QUÁ NHỎ ($SIZE bytes) — nghi DB rỗng" >&2; exit 1; }
```

File backup 200 byte nghĩa là `mysqldump` lỗi nhưng vẫn tạo file. Không check thì 6 tháng sau mới biết.

### b. Diễn tập restore — mỗi tháng một lần, làm thật

```bash
# Trên máy cá nhân, KHÔNG phải trên VPS
docker run --name restore-test -e MYSQL_ROOT_PASSWORD=test -d mysql:8.4
gunzip < backup-2026-08-01.sql.gz | docker exec -i restore-test mysql -uroot -ptest banhcuon

# Đối chiếu
docker exec restore-test mysql -uroot -ptest banhcuon \
  -e "SELECT COUNT(*) FROM orders; SELECT SUM(total) FROM orders WHERE DATE(created_at)='2026-07-31';"
```

So số này với sổ giấy của quán. Khớp thì backup dùng được.

### c. Backup phải rời khỏi VPS

Backup nằm cùng VPS với dữ liệu gốc thì **không phải backup** — VPS chết là mất cả hai. Mỗi tháng tải một bản về máy cá nhân, hoặc `rclone` lên Google Drive.

---

## 7. Bẫy thường gặp

| Lỗi | Hậu quả | Cách tránh |
|-----|---------|------------|
| Sửa file migration đã chạy production | DB dev và prod khác nhau, không ai biết | Chỉ thêm file mới |
| `FLOAT` cho tiền | 3000 + 3000 = 5999.999 | `INT UNSIGNED`, đơn vị đồng |
| Không có `.down.sql` | Deploy hỏng, không rollback được | CI kiểm tra mọi `.up` có `.down` |
| Không snapshot giá vào `order_items` | Tăng giá → đơn cũ + báo cáo sai | Copy `name`, `unit_price` vào `order_items` |
| Không chặn 2 phiên mở/1 bàn | Hoá đơn tách đôi, thu thiếu | Cột sinh `open_key` + `UNIQUE` |
| Xoá cứng món (`DELETE FROM products`) | Đơn cũ mất tên món | Cột `is_active`, không `DELETE` |
| Backup không kiểm tra | Phát hiện hỏng đúng lúc cần | `gzip -t` + check size + diễn tập restore |
| `utf8` thay vì `utf8mb4` | Lỗi tiếng Việt | `utf8mb4_unicode_ci` mọi bảng |

---

## Checklist DB — chạy trước mỗi lần merge

- [ ] Migration mới có cả `.up.sql` và `.down.sql`
- [ ] `make db-test` xanh (up → down → up → seed → assert 8 món)
- [ ] Cột tiền là `INT UNSIGNED`, không phải float
- [ ] Bảng mới dùng `InnoDB` + `utf8mb4_unicode_ci`
- [ ] Có `FOREIGN KEY` tới bảng cha
- [ ] Query mới đã chạy `EXPLAIN`, không có `type: ALL` trên bảng lớn
