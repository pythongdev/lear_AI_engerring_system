# Hiểu database của quán và kiểm xem nó có chạy đúng không

File này trả lời hai câu: **database gồm những gì**, và **gõ lệnh nào để biết nó đang tốt**. Viết
2026-09-29; mọi output dán ở đây là output thật chạy cùng ngày trên máy phát triển, trừ mục 3.4 có
ghi rõ.

File này chỉ đường, không giữ luật. Tên bảng, cột, ràng buộc do file migration ở
[db/migrations/](../../db/migrations/) giữ; lý do của từng bảng do các file lát ở
[docs/product/2-db/](../product/2-db/) giữ; luật nghiệp vụ mà database canh do
[quality/invariants.md](../../quality/invariants.md) giữ. Hai bên lệch nhau thì bên kia đúng. Cách
bật database, vào `psql`, dùng `make`: [chay-database-tren-may.md](chay-database-tren-may.md) và
[docs/command/make.md](../command/make.md).

## 1. Database gồm những gì

### 1.1 Một máy chủ, hai database không đụng nhau

Database là PostgreSQL 17 chạy trong Docker, cấu hình ở [compose.yaml](../../compose.yaml). Trên máy
có thể có **hai** database cùng lúc, và chúng không bao giờ đụng dữ liệu của nhau:

- **Database làm việc** `banhcuon` (compose project `banhcuon`, cổng `127.0.0.1:5433`). Đây là cái
  bạn bật bằng `make up` và vào xem bằng `make psql`. Dữ liệu trong nó còn nguyên cho tới khi bạn
  `make reset`.
- **Database của bộ kiểm** (compose project `banhcuon_check`, cổng ngẫu nhiên). `./scripts/db-check.sh`
  dựng nó rỗng từ số 0, kiểm, rồi gỡ đi. Vì dựng lại từ đầu mỗi lần nên nó là bằng chứng đáng tin
  rằng các migration chạy được trên một máy sạch.

### 1.2 Hai vai, một schema

Lần đầu container khởi tạo, file [db/init/001-vai-va-schema.sql](../../db/init/001-vai-va-schema.sql)
tạo schema `shop` (mọi bảng của quán nằm ở đây) và hai vai. `shop_owner` là chủ schema, dùng để chạy
migration và để bạn vào xem. `shop_app` là vai hệ thống dùng để ghi: nó đọc, thêm, sửa được nhưng
**không xoá được** — vì dữ liệu của quán không bao giờ xoá cứng (quy ước `QD-50` ở
[01-quy-uoc-du-lieu.md](../product/2-db/01-quy-uoc-du-lieu.md)).

### 1.3 Tám migration dựng ra 31 bảng, chia thành năm lát

Các bảng được tạo bởi tám file migration, chạy theo thứ tự mốc giờ ở tên file. Mỗi nhóm bảng gọi là
một **lát**, và mỗi lát có một file giải thích vì sao bảng ấy có hình như vậy. Số bảng dưới đây đếm
ngày 2026-09-29; lát sau sẽ thêm bảng.

| Lát | Bảng chính | Giải thích ở |
|---|---|---|
| Bán hàng lõi | `dining_table`, `table_session`, `table_session_member`, `sales_order`, `order_line`, `qr_code` | [02-luoc-do-ban-hang.md](../product/2-db/02-luoc-do-ban-hang.md) |
| Menu và giá | `menu_item`, `menu_component`, `option_group`, `menu_option`, và các bảng ảnh chụp giá lúc đặt `order_line_component`, `order_line_option` | [03-luoc-do-menu-gia.md](../product/2-db/03-luoc-do-menu-gia.md) |
| Đường tiền | `bill`, `debt_collection`, `prepayment`, `prepayment_use`, `refund`, `opening_float`, `opening_float_line` | [04-luoc-do-duong-tien.md](../product/2-db/04-luoc-do-duong-tien.md) |
| Sản xuất theo mẻ | `menu_component_station`, `station_job`, `production_batch`, `production_batch_item`, `station_job_transfer` | [05-luoc-do-san-xuat.md](../product/2-db/05-luoc-do-san-xuat.md) |
| Người và vết | `person`, `counter_duty`, `paper_ledger`, `record_revision` | [06-luoc-do-nguoi-va-vet.md](../product/2-db/06-luoc-do-nguoi-va-vet.md) |

Ba migration không tạo bảng mới mà thêm cột vào bảng có sẵn (liên hệ của đơn mang đi, dấu lần gửi,
mã QR bàn). Muốn xem đúng cột và ràng buộc của một bảng: `make psql` rồi gõ `\d tên_bảng`.

### 1.4 Database tự canh luật, không chỉ chứa dữ liệu

Điểm quan trọng nhất: nhiều luật của quán được **chính database từ chối** khi bị vi phạm, chứ không
chờ phần mềm phía trên nhớ kiểm. Ví dụ một bàn không thể thuộc hai phiên chưa đóng cùng lúc (`I-001`),
một khoản nợ phải có chủ (`I-005`), hai người không thể cùng đứng quầy một lúc (`YC-15`). Mỗi luật
như vậy có một file test ở [db/tests/](../../db/tests/) — dòng đầu mỗi file ghi nó canh luật nào —
và file test ấy vừa thử đường đúng, vừa cố tình làm sai để chứng minh database từ chối.

### 1.5 Dữ liệu mồi sinh ra lúc chạy

Dữ liệu mồi (bàn, mã QR, menu, thành phần, người theo vai) không nằm sẵn trong file nào.
[db/seed/seed.pl](../../db/seed/seed.pl) đọc thẳng `master_plan/shop-facts.md` rồi in ra SQL, nên
khi chủ quán đổi menu ở đó thì lần nạp sau tự theo. Chi tiết: [08-du-lieu-moi.md](../product/2-db/08-du-lieu-moi.md).

## 2. Kiểm nhanh — database làm việc có ổn không

Các lệnh dưới đây **chỉ đọc**, chạy bao nhiêu lần cũng được. Chạy ở thư mục gốc repo, sau `make up`.
Mỗi câu SQL có thể gõ trong `make psql`, hoặc chuyền thẳng vào như sau:

```bash
echo "SHOW TimeZone;" | make psql
```

### 2.1 Container có sống không

```bash
make status
```

Output tốt — cột `STATUS` có chữ `healthy`:

```text
NAME            IMAGE         ...   STATUS                    PORTS
banhcuon-db-1   postgres:17   ...   Up 10 minutes (healthy)   127.0.0.1:5433->5432/tcp
```

Không thấy dòng nào ⇒ database chưa bật, chạy `make up`. Thấy `unhealthy` ⇒ xem log bằng
`docker compose logs db | tail -30`.

### 2.2 Migration đã chạy đủ và không kẹt giữa chừng

```bash
make migrate
```

In `no change` là đã đủ. Rồi xem sổ ghi phiên bản:

```sql
SELECT version, dirty FROM public.schema_migrations;
```

```text
    version     | dirty
----------------+-------
 20260928140000 | f
```

`version` phải bằng mốc giờ của file mới nhất trong `db/migrations/` (xem bằng
`ls db/migrations | tail -1`). `dirty` phải là `f`. Nếu là `t` thì một migration đã chết giữa
chừng; cách gọn nhất ở máy phát triển là `make reset` (xoá sạch rồi dựng lại).

### 2.3 Đủ bảng, đúng múi giờ, có dữ liệu mồi, đúng quyền

```sql
-- số bảng trong schema shop — 31 vào ngày viết
SELECT count(*) AS so_bang FROM information_schema.tables
WHERE table_schema = 'shop' AND table_type = 'BASE TABLE';

-- múi giờ của kết nối — phải là Asia/Ho_Chi_Minh
SHOW TimeZone;

-- dữ liệu mồi đã nạp chưa
SELECT (SELECT count(*) FROM dining_table)                      AS ban,
       (SELECT count(*) FROM menu_item)                         AS mon,
       (SELECT count(*) FROM person)                            AS nguoi,
       (SELECT count(*) FROM qr_code WHERE replaced_at IS NULL) AS qr;

-- vai hệ thống ghi được nhưng KHÔNG xoá được
SELECT has_table_privilege('shop_app', 'shop.bill', 'DELETE') AS app_xoa_duoc,
       has_table_privilege('shop_app', 'shop.bill', 'INSERT') AS app_ghi_duoc;
```

Output thật ngày viết:

```text
 so_bang          31
 TimeZone         Asia/Ho_Chi_Minh
 ban | mon | nguoi | qr
  15 |  10 |     5 | 15
 app_xoa_duoc | app_ghi_duoc
 f            | t
```

Cách đọc: số bảng ít hơn số mong đợi ⇒ migration chưa chạy đủ (quay lại 2.2). Múi giờ khác ⇒ bạn
đang kết nối không qua `make psql` và quên đặt `PGTZ`, mọi mốc giờ đọc ra sẽ lệch. Cả bốn số dữ liệu
mồi là `0` ⇒ chưa `make seed`. `app_xoa_duoc` ra `t` ⇒ quyền bị cấp sai, đây là lỗi thật cần báo.
Các con số `15 · 10 · 5` đi theo `master_plan/shop-facts.md`; chúng đổi khi dữ kiện quán đổi, không
phải lỗi.

## 3. Kiểm đầy đủ — bộ kiểm database

### 3.1 Lệnh

```bash
./scripts/db-check.sh
```

Đây là phép kiểm có giá trị bằng chứng. Nó **không đụng** database làm việc: tự dựng một database
rỗng riêng, chạy mọi migration từ số 0, chạy mọi phép kiểm, rồi gỡ đi. Mất khoảng 15 giây. Docker
phải đang bật; nếu không, nó báo `FAIL` chứ không lặng lẽ bỏ qua.

Đừng chạy hai lần `db-check` cùng lúc (ví dụ hai phiên làm việc song song): hai lần ấy dùng chung
một tên project nên sẽ gỡ database của nhau và báo đỏ giả — đây là finding `F-045` đang mở ở
[work/findings.md](../../work/findings.md).

### 3.2 Nó kiểm bốn thứ

1. **Quy ước dữ liệu và quy ước code**: mọi khối SQL nằm dưới một tiêu đề `### QD-XX` hay `### QC-XX`
   trong `docs/product/2-db/` được lấy thẳng từ tài liệu ra chạy, và phải trả **0 dòng** (mỗi dòng
   trả về là một chỗ vi phạm). Thêm bốn phép kiểm mà một câu SQL không viết nổi: mã kênh và mã trạm
   khớp `shop-facts.md` (`QD-02`), ngày bán khớp mốc giờ (`QD-31`), múi giờ kết nối (`QD-32`), tập
   trạng thái khớp tài liệu (`QD-40`).
2. **Từng file ở `db/tests/`**, mỗi file trong một giao dịch rồi huỷ (`ROLLBACK`), nên không để lại
   dữ liệu.
3. **Dữ liệu mồi** dựng được từ `shop-facts.md`.
4. **Các ca giá** ở `shop-facts.md` §4.8 tính lại khớp từng đồng.

### 3.3 Đọc output

Dòng cuối là kết luận. Output thật ngày viết:

```text
PASS dữ liệu mồi — 15 bàn · 15 mã QR hiện hành · 6 thành phần · 10 dòng menu · 2 nhóm tuỳ chọn · 10 trạm của thành phần
PASS §4.8 ca giá
     ca 1 khớp: Bánh cuốn ×1 [Chay] ⇒ 3000đ
     ...
     §4.8: 13 / 13 ca khớp từng đồng
db-check: PASS — 27 khối kiểm tài liệu, 4 phép kiểm dạng lệnh, 26 file test, dữ liệu mồi + §4.8
```

Các dòng thụt vào dạng `NOTICE: ... bị từ chối (...)` **không phải lỗi**. Đó là file test kể lại
việc nó cố làm sai và database đã chặn đúng, ví dụ:

```text
PASS db/tests/yc15_counter_duty_by_time.sql
     NOTICE:  YC-15 bị từ chối (A vào quầy lúc B đang đứng): conflicting key value violates exclusion constraint "counter_duty_one_at_a_time_excl"
```

Lỗi thật trông như `FAIL db/tests/...` hoặc `FAIL QD-XX (sql) — N dòng:` kèm các dòng vi phạm, và
dòng cuối là `db-check: FAIL`. Muốn lọc nhanh chỉ kết luận:

```bash
./scripts/db-check.sh 2>&1 | grep -E '^(PASS|FAIL|NOTE|db-check)'
```

### 3.4 Tự tay thử một luật (tuỳ chọn)

Muốn tận mắt thấy database từ chối, gõ trong `make psql`. Cả hai khối đều bọc trong
`BEGIN … ROLLBACK` nên không để lại gì. **Mục này chưa chạy thử lúc viết**; câu báo lỗi mong đợi lấy
từ output của bộ kiểm cho cùng loại ràng buộc.

```sql
-- trạng thái ngoài vòng đời: mong đợi lỗi "violates check constraint"
BEGIN;
INSERT INTO table_session (status) VALUES ('dang_an');
ROLLBACK;

-- vai hệ thống xoá dữ liệu: mong đợi lỗi "permission denied for table person"
BEGIN;
SET ROLE shop_app;
DELETE FROM person;
ROLLBACK;
```

Đường chắc hơn để thử một luật là đọc file test tương ứng ở `db/tests/` rồi chạy `db-check`.

## 4. Kiểm cả repo

```bash
./scripts/gate.sh
```

Cổng chung của repo. Khi thay đổi chạm phía database, nó tự gọi `db-check.sh` ở bước build và test,
cùng các kiểm tra khác (phạm vi, link, trạng thái tài liệu). Mọi dòng `PASS` và không dòng `FAIL`
nào là xong. Một dòng `SKIP` nghĩa là bước ấy **không chạy**, không phải đã qua.

## 5. Chọn lệnh nào

Mở máy muốn biết database làm việc còn ổn: mục 2 (`make status`, rồi vài câu SQL ở 2.2–2.3). Vừa
sửa hay thêm migration, test, hay dữ liệu mồi: `./scripts/db-check.sh`, vì chỉ nó dựng lại từ số 0.
Trước khi giao một thay đổi: `./scripts/gate.sh`. Muốn tận mắt xem một vòng bán: mục 6.

## 6. Mô phỏng một vòng bán tại bàn

Hệ thống **chưa có** lệnh "đặt món" hay "thanh toán": database chỉ chứa dữ liệu và chặn cái sai,
còn phần làm việc — nhận đơn, tính giá, chia việc xuống bếp, đóng phiên — là việc của pha 3
(backend), chưa mở. Kịch bản [mo-phong-mot-vong-ban-tai-ban.sql](mo-phong-mot-vong-ban-tai-ban.sql)
gõ tay thay cho phần ấy, để xem cả vòng chạy trên database thật:

1. khách ngồi bàn 5 quét QR gọi 2 suất — đơn chờ quầy duyệt;
2. quầy duyệt, đơn nổ thành việc ở từng trạm bếp;
3. khách nhờ quầy gọi thêm 1 giò — vào **chính** phiên ấy, không cần duyệt;
4. bếp làm hai mẻ, quầy bấm "đã làm xong";
5. quầy bấm "đã ra bàn", hai đơn sang Hoàn thành;
6. quầy tính tiền cả phiên, in hoá đơn tạm;
7. khách trả một phần tiền mặt, phần còn lại chuyển khoản; quầy đóng phiên;
8. dọn bàn, bàn 5 nhận khách mới.

Dọc đường nó cố tình làm sai bốn lần — cho bếp làm đơn chưa duyệt, mở phiên thứ hai cho bàn đang
có khách, ghi thu vượt số phải trả, đóng phiên thiếu hoá đơn — và in ra câu database từ chối.

Chạy trên database làm việc (cần `make setup` trước):

```bash
make psql < docs/guideline/mo-phong-mot-vong-ban-tai-ban.sql
```

Cả kịch bản nằm trong `BEGIN … ROLLBACK`, nên chạy xong database **không đổi gì** và chạy lại bao
nhiêu lần cũng được; chỉ các số thứ tự (`id`) nhảy lên, không hại gì. Đoạn output thật chạy
2026-09-29 trên một database dựng riêng từ dữ liệu mồi:

```text
NOTICE:  1. Khách ngồi bàn 5, quét QR, gọi món
NOTICE:     + 2 × Đầy đủ trứng chín [Thịt · Thường] — 30000 đ/suất
NOTICE:     ✗ bị chặn — đơn chưa duyệt không xuống bếp được (I-004): ... "station_job_sales_order_fkey"
NOTICE:  2. Quầy duyệt đơn 3; hệ thống nổ đơn xuống các trạm
NOTICE:     bếp: canh: chờ 1 · xong 0 · ra bàn 0 | gap_banh: chờ 10 · xong 0 · ra bàn 0 | trang_banh: chờ 8 · ...
...
NOTICE:  6. Quầy tính tiền cả phiên: 69000 đ — phiên sang Chờ thanh toán (bàn vẫn bận)
 don |   kenh    |        mon        |   tuy_chon    | sl | don_gia | thanh_tien
   3 | qr_table  | Đầy đủ trứng chín | Thịt · Thường |  2 |   30000 |      60000
   4 | staff_pos | Giò bán rời       |               |  1 |    9000 |       9000
NOTICE:  7. Khách trả 20000 đ tiền mặt + 49000 đ chuyển khoản; quầy đóng phiên
NOTICE:     ✗ bị chặn — tiền thu phải khớp số phải trả (I-015): ... "bill_parts_equal_due_check"
NOTICE:     ✗ bị chặn — phiên đã đóng phải có hoá đơn: ... "table_session_bill_fkey"
...
 hoa_don | phai_tra | tien_mat | chuyen_khoan | no |  ngay_ban  |  luc  |    nguoi_thu
       2 |    69000 |    20000 |        49000 |  0 | 2026-09-29 | 23:03 | Người đứng quầy
Xong mô phỏng — ROLLBACK: database trở lại như trước khi chạy.
```

Con số tiền đi theo menu trong `master_plan/shop-facts.md`, nên đổi khi menu đổi. Kịch bản
**không** quyết luật nào mới: các hàm `pg_temp.*` trong nó đứng thay cho cửa của pha 3, phép tính
giá chép từ `db/seed/seed.pl`. Một chỗ nó chỉ tạm chọn để đi tiếp: bấm "đã ra bàn" theo mẻ hay
theo bàn là **S-5** ở `master_plan/shop-facts.md` §7.2, còn chờ chủ quán; ở đây bấm cả bàn một lần.
