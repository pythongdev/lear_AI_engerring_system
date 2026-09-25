# Nghiên cứu — schema `design/data_base` có phải best practice không?

> Cập nhật **2026-08-19** · Lane sở hữu: **DB** · Loại: **nghiên cứu đối chiếu ngoài repo**.
> Sự thật DB khác: [thiết kế](01-thiet-ke.md) · [luật](02-luat.md) · [hiện trạng](03-hien-trang.md) · [yêu cầu](04-yeu-cau.md).
>
> **File này KHÔNG phải nhà của sự thật nào về schema.** Nó giữ đúng một thứ chưa có ở đâu khác trong repo:
> **kết quả đối chiếu schema của dự án với tài liệu/chuẩn ngoài** (MySQL manual, Square Catalog API, các pattern
> có tên). Mọi mô tả schema ở đây là **trích để so sánh** — lệch với `code/be/migrations/` thì **code thắng**
> ([CLAUDE.md §2](../../CLAUDE.md)).
>
> **Đề xuất trong file này chưa phải quyết định.** Cái nào owner đồng ý thì mở finding/task theo §5; chưa mở thì
> nó vẫn chỉ là nghiên cứu.

**Phạm vi đối chiếu.** Yêu cầu dự án: [project_preparation/prompt-fullstack.md](../../project_preparation/prompt-fullstack.md)
(quán bánh cuốn 11 bàn, 6h–11h, 4 kênh bán, tiền mặt + VietQR tĩnh, MySQL 8.4 LTS).
Schema thật đọc từ `code/be/migrations/000001…000005 + seed.sql` **tại commit `5bd2046`**, không đọc từ `01-thiet-ke.md`.

```bash
# lệnh dựng lại nền của file này
grep -h 'CREATE TABLE' code/be/migrations/*.up.sql | wc -l     # số bảng
grep -n 'ENUM' code/be/migrations/*.up.sql                      # các enum đang chạy
grep -n 'COLLATE' code/be/migrations/*.up.sql | wc -l           # số bảng khai collation
```

---

## 0. Kết luận trong một trang

**Tổng quan: schema này ở trên mức trung bình rõ rệt cho một dự án quán nhỏ.** Bốn quyết định lớn nhất —
tiền là số nguyên, snapshot giá vào dòng đơn, hoá đơn tính trên phiên bàn, và chặn phiên trùng bằng cột sinh —
đều **trùng với cách các hệ thống thương mại thật làm**, và trùng với cách tài liệu MySQL khuyên.
Đây không phải schema "cho có".

**Nhưng "đúng chuẩn" chưa đủ để gọi là best practice**, vì có 3 chỗ lệch chuẩn ở mức làm hỏng dữ liệu thật
và 4 chỗ thiếu hẳn so với một POS tiền mặt. Xếp theo thiệt hại thật ở quán:

| # | Vấn đề | Mức | Hỏng cái gì ở quán |
|---|---|---|---|
| 1 | `qr_token` seed bằng `REPLACE(UUID(),'-','')` | 🔴 **Bảo mật** | UUIDv1 = thời gian + MAC, **đoán được**. Đoán ra token bàn 5 là đặt món ghi nợ vào hoá đơn bàn 5 |
| 2 | `utf8mb4_unicode_ci` cho **mọi** bảng | 🔴 **Dữ liệu** | MySQL manual nói thẳng: `_unicode_ci` hỗ trợ **một phần** UCA, **ảnh hưởng tiếng Việt**. Sắp xếp/so sánh tên món sai |
| 3 | Không có bảng **ca bán / két tiền mặt** | 🔴 **Tiền** | Quán thu tiền mặt mà **không có cách đối chiếu** cuối ca. Thiếu tiền không ai biết thiếu từ đâu |
| 4 | Không có **idempotency key** trên `orders` | 🟠 | Khách bấm "Đặt" 2 lần / mạng 3G timeout ⇒ 2 đơn thật, bếp làm 2 lần |
| 5 | Nhóm option **không dùng lại được** (1 nhóm ↔ 1 món) | 🟠 | Đổi phụ thu nhân = sửa 14 dòng ở 7 nhóm. Sót 1 dòng ⇒ 1 món bán sai giá, không lệnh nào đỏ |
| 6 | `depends_on_option_id` là **một** FK, không diễn tả nổi "khác Chay" | 🟠 | Luật hiện nhóm "Lượng nhân" phải nhảy sang tầng service ⇒ vỡ chính nguyên tắc "ràng buộc nằm ở DB" của [02-luat](02-luat.md) |
| 7 | Không `CHECK` quan hệ số học của tiền | 🟠 | `total` có thể ≠ `subtotal − discount` mà DB vẫn nhận. Báo cáo lệch không truy được |
| 8 | `ENUM` trạm lặp ở **3 bảng** + 1 `CHECK` | 🟡 | Thêm trạm = 4 lần `ALTER` phải nhớ hết |
| 9 | Không có bảng **outbox** cho SSE/Telegram | 🟡 | BE restart giữa lúc đẩy việc ⇒ trạm mất task, không dấu vết |
| 10 | `is_available` gánh 2 nghĩa (hết hôm nay / ngừng bán) | 🟡 | Bật lại "hết món" vô tình làm sống lại món đã bỏ menu |

**Trả lời thẳng câu hỏi:** chưa phải best practice, nhưng **khoảng cách là hữu hạn và đo được** — 3 việc ở
mục 1–3 là bắt buộc trước khi bán thật; 4–7 nên làm trước khi có dữ liệu thật (vì sau đó `ALTER` phải chạy
ngoài giờ bán); 8–10 là nợ kỹ thuật chấp nhận được.

---

## 1. Những chỗ ĐÃ đúng chuẩn — và chuẩn đó tên gì

Ghi lại phần này không phải để khen. Ghi để **session sau đừng "sửa" nhầm** những chỗ đã đúng.

### 1.1 Tiền là số nguyên VND — trùng cách Stripe làm

`base_price`, `price_delta`, `unit_price`, `line_total`, `subtotal`, `total`, `amount` đều `INT`/`INT UNSIGNED`.
Không `FLOAT`, không `DECIMAL`.

Chuẩn ngoài: cách phổ biến (Stripe dùng) là **lưu số nguyên đơn vị nhỏ nhất** — 5 USD lưu là 500 cent —
để triệt tiêu sai số làm tròn; VND và JPY là loại tiền **không có phần thập phân** nên "đơn vị nhỏ nhất"
chính là đồng, không cần nhân 100. `DECIMAL` cũng đúng nhưng ở đây không mua thêm gì.

→ **Giữ nguyên.** `price_delta` để `INT` có dấu (giảm giá option sau này) là chi tiết đã nghĩ trước.

⚠️ Một vế của luật này **chưa được gác bằng lệnh**: [02-luat §3](02-luat.md) đã viết sẵn query
`information_schema` để bắt cột tiền không phải kiểu nguyên, và ghi "thêm vào CI" — nhưng chưa có target
nào trong [Makefile](../../Makefile) gọi nó. Luật không có lệnh gác thì tự trôi.

### 1.2 Snapshot tên + giá vào `order_items` / `order_item_options`

Đây là điều kiện sống còn của lát cắt **C** trong [prompt-fullstack §5.1](../../project_preparation/prompt-fullstack.md)
("đổi giá, đơn cũ giữ nguyên giá"), và schema có đủ cột: `product_name`, `base_price`, `options_price`,
`unit_price`, `line_total`, `group_name`, `option_name`, `price_delta`.

→ **Giữ nguyên**, nhưng xem [§2.6](#26-order_item_options-thiếu-khoá-ngoại-về-option-gốc) — snapshot đang
làm **mất đường về ID gốc** ở bảng option.

### 1.3 `open_key` — cột sinh + `UNIQUE`, đúng bài MySQL

MySQL/MariaDB **không có partial index** (`CREATE UNIQUE INDEX … WHERE …` như PostgreSQL). Cách chính thống
để mô phỏng là **cột sinh trả `NULL` cho các hàng muốn loại trừ**, rồi `UNIQUE` lên cột đó — vì MySQL cho
nhiều `NULL` trùng nhau trong unique index. Đây đúng là mẹo mà cộng đồng dùng cho soft delete, và
[000004](../../code/be/migrations/000004_fix_open_key.up.sql) dùng đúng nó.

Chi tiết làm đúng hơn số đông: điều kiện là `status IN ('open','billing')` chứ không phải `= 'open'`
(vá [F-01](../../finding.md#f-01)). Việc **đặt tên đúng ngữ nghĩa** — "bàn còn nợ tiền" — thay vì bám theo
một giá trị enum, là thứ ngăn lỗi tái phát khi enum mọc thêm giá trị.

📌 **Một điểm có thể tốt hơn: `STORED` → `VIRTUAL`.**
Khuyến nghị chung của MySQL là **bắt đầu bằng `VIRTUAL`**, chỉ dùng `STORED` khi biểu thức đắt và đọc nhiều
hơn ghi rất nhiều; `VIRTUAL` không làm phình clustered index, thêm cột `VIRTUAL` gần như tức thì (metadata),
và **thêm/bỏ secondary index trên cột `VIRTUAL` là thao tác in-place**. Biểu thức ở đây là một `IF()` trên
2 cột — rẻ nhất có thể.

Chính [000004](../../code/be/migrations/000004_fix_open_key.up.sql) đã tự ghi cái giá phải trả của `STORED`:
*"biểu thức của cột sinh STORED không sửa tại chỗ được → bỏ index + cột rồi tạo lại"*, và cảnh báo
`ALGORITHM=COPY` khoá bảng. Với `VIRTUAL`, lần vá F-01 thứ hai (nếu enum `status` mọc thêm giá trị) sẽ rẻ hơn.

> Chưa đủ cớ để đổi ngay: `table_sessions` là bảng nhỏ (≈ vài chục hàng/ngày), và đổi bây giờ là thêm
> migration thứ 6 cho một thứ đang chạy đúng. Ghi lại để **lần sau phải đụng `open_key` thì đổi luôn**.

### 1.4 `payments` gắn vào đúng một đích — pattern có tên: **exclusive arc**

```sql
CHECK ((order_id IS NOT NULL) + (table_session_id IS NOT NULL) = 1)
```

Đây là **exclusive arc** (một dạng polymorphic association giữ được FK thật), không phải hack. Ưu điểm so với
kiểu `target_type`/`target_id` của Rails: **giữ được khoá ngoại thật**, nên DB vẫn chặn được `order_id` rác.
Nhược điểm cũng được ghi nhận: nhiều cột `NULL`, và mọi query phải nhớ cộng từ **hai** nguồn.

→ **Giữ nguyên.** [01-thiet-ke §2.1](01-thiet-ke.md) và [03-hien-trang](03-hien-trang.md) đều đã cảnh báo
"báo cáo doanh thu phải cộng từ cả hai nguồn" — đúng chỗ phải cảnh báo.

### 1.5 Hình dạng option/modifier trùng Square Catalog API

Square — hệ POS thương mại lớn — mô hình hoá đúng 3 tầng: **item → modifier list → modifier**, và
*"khi bán, tổng giá = giá món cơ bản + giá của từng modifier được chọn"*. Dự án dùng
`products → product_option_groups → product_options` với `price_delta` cộng dồn: **cùng một hình dạng**.

Việc để `base_price` = **giá CHAY** rồi cộng phụ thu, thay vì tạo 3 sản phẩm "Bánh cuốn chay / thịt / thịt nhiều",
cũng là lựa chọn đúng — nó giữ menu 8 món thay vì 24 món và giữ báo cáo gộp được theo món.

→ **Giữ hình dạng**, nhưng xem [§2.4](#24-nhóm-option-không-dùng-lại-được--chỗ-lệch-square-rõ-nhất): chỗ
lệch không phải hình dạng mà là **quan hệ 1:N thay vì N:N**.

### 1.6 Ràng buộc nghiệp vụ đẩy xuống DB, không chỉ nằm ở Go

`chk_order_dinein`, `chk_order_channel_fulfillment`, `chk_pay_target`, `chk_items_qty`, `chk_tasks_qty`,
`chk_settings_singleton`, `fk_items_product` RESTRICT.

Đặc biệt `chk_items_qty CHECK (quantity > 0)`: nhận ra `UNSIGNED` chặn âm nhưng **không chặn 0** là loại chi
tiết thường bị bỏ sót. Và chọn `RESTRICT` thay vì `CASCADE` cho `fk_items_product` — vì `CASCADE` ở đây là
**xoá món kéo mất dữ liệu tiền** — là quyết định đúng, có ghi lý do ngay trong migration.

→ **Giữ nguyên.** Đây là phần mạnh nhất của schema.

### 1.7 Múi giờ: `+07:00` cố định là lựa chọn đúng, không phải lười

[deploy/docker-compose.yml:23](../../deploy/docker-compose.yml) đặt `--default-time-zone=+07:00` thay vì
`Asia/Ho_Chi_Minh`. Nhìn thì có vẻ ẩu, nhưng Việt Nam **không có DST từ 1975**, nên offset cố định là
tương đương *và* không phụ thuộc vào bảng timezone của MySQL (thứ phải nạp thủ công bằng
`mysql_tzinfo_to_sql`, và thiếu thì `CONVERT_TZ()` âm thầm trả `NULL`).

→ **Giữ nguyên**, nhưng xem [§4.4](#44-test_db_dsn-thiếu-loc--lệch-7-tiếng-chỉ-trong-test).

---

## 2. Những chỗ LỆCH chuẩn — xếp theo thiệt hại

### 2.1 🔴 `qr_token` sinh bằng `UUID()` — token đoán được

[seed.sql:123-133](../../code/be/migrations/seed.sql) sinh token bàn bằng:

```sql
('Bàn 1',  REPLACE(UUID(), '-', ''), 4, 1),
```

`UUID()` của MySQL trả **UUID version 1**: thời gian + MAC address của máy, **không phải số ngẫu nhiên**.
Tài liệu MySQL nói thẳng: *"Although UUID() values are intended to be unique, they are not necessarily
unguessable or unpredictable. If unpredictability is required, UUID values should be generated some other way."*

11 bàn được seed **trong cùng một câu lệnh, cách nhau vài chục micro giây** ⇒ 11 token chỉ khác nhau ở vài
ký tự cuối của phần timestamp, và **cùng chung 12 ký tự MAC**. Ai có 1 token (chỉ cần ngồi ăn một lần và
nhìn URL trên điện thoại) là **suy ra được cả 10 token còn lại**.

Hậu quả đúng bằng thứ [01-thiet-ke §2.3](01-thiet-ke.md) đã sợ khi chọn `CHAR(32)` random thay vì số bàn:
gọi món ghi nợ vào hoá đơn bàn khác, và xem được `GET t/:token/bill` của bàn khác.

> Nghịch lý đáng ghi: [01-thiet-ke §2.5](01-thiet-ke.md) **có** dòng comment `-- qr_token phải RANDOM — dùng
> lệnh create-tables ở mục 3.6 để sinh`. Tức là đã biết. Nhưng file `.sql` vẫn để `UUID()` như đường mặc
> định, và đường mặc định là đường sẽ được chạy. **Cảnh báo bằng comment không phải là ràng buộc.**

**Cách sửa đề xuất** — MySQL 8 có sẵn hàm CSPRNG:

```sql
-- seed.sql: 16 byte ngẫu nhiên mã hoá hex = 32 ký tự, đúng CHAR(32)
('Bàn 1', LOWER(HEX(RANDOM_BYTES(16))), 4, 1),
```

`RANDOM_BYTES()` là bộ sinh **ngẫu nhiên an toàn mật mã** của MySQL, đúng chỗ dùng cho token bảo mật.
Kèm theo: cột nên là `CHAR(32) CHARACTER SET ascii COLLATE ascii_bin` (xem [§2.2](#22--utf8mb4_unicode_ci--mysql-nói-thẳng-là-ảnh-hưởng-tiếng-việt)).

**Thêm một lớp nữa** (rẻ, nên làm cùng lúc): nếu token lộ thì phải **đổi được** mà không phải sửa DB bằng
tay — thêm `qr_token_rotated_at` và một lệnh admin `POST admin/tables/:id/rotate-qr`. Không có đường xoay
token thì lộ một lần là hỏng vĩnh viễn.

### 2.2 🔴 `utf8mb4_unicode_ci` — MySQL nói thẳng là ảnh hưởng tiếng Việt

Cả 16 bảng + `--collation-server` đều dùng `utf8mb4_unicode_ci`, và [02-luat §1](02-luat.md) nâng nó lên
thành **"quy tắc bất di bất dịch"** với lý do *"`utf8` (3 byte) làm hỏng tiếng Việt và emoji"*.

**Nửa đầu của lý do đúng, kết luận thì lệch.** Cần tách hai thứ bị gộp làm một:

| | Bộ ký tự (charset) | Cách so sánh/sắp xếp (collation) |
|---|---|---|
| Vấn đề | `utf8` 3 byte làm hỏng emoji | `_unicode_ci` hỗ trợ UCA **một phần** |
| Dự án chọn | `utf8mb4` ✅ **đúng** | `utf8mb4_unicode_ci` ❌ **lệch** |

`utf8mb4` là quyết định đúng và không bàn lại. Nhưng collation thì tài liệu MySQL 8.4 cảnh báo trực tiếp:

> *"The `_xxx_unicode_ci` collations have only partial support for the Unicode Collation Algorithm. Some
> characters are not supported, and combining marks are not fully supported. **This affects languages such
> as Vietnamese**, Yoruba, and Navajo."*

`utf8mb4_unicode_ci` bám **UCA 4.0.0** (2003). Mặc định của MySQL 8 là `utf8mb4_0900_ai_ci` — **UCA 9.0.0**,
nhanh hơn, và MySQL 8 còn có **collation riêng cho tiếng Việt**: `utf8mb4_vi_0900_ai_ci`.

Cái gì hỏng ở quán, cụ thể:

- **Sắp xếp menu theo tên sai thứ tự tiếng Việt** — `ORDER BY name` ở Admin › Sản phẩm, và ở FE nếu sort theo
  tên. `ă â đ ê ô ơ ư` là **chữ cái riêng** trong bảng chữ cái tiếng Việt, không phải "a có dấu".
- **Rủi ro `UNIQUE` va nhau ngoài ý muốn.** `_ci` (và `_ai_ci`) coi nhiều chữ khác nhau là bằng nhau ⇒
  `UNIQUE(slug)`, `UNIQUE(code)`, `UNIQUE(username)`, `UNIQUE(qr_token)`, `UNIQUE(tables.name)` đang chạy
  dưới luật so sánh **lỏng hơn ta tưởng**. Với cột định danh, luật đúng là **so từng byte**.

**Cách sửa đề xuất** — chia cột theo *vai trò*, không dùng một collation cho tất cả:

| Loại cột | Ví dụ | Collation nên dùng | Vì sao |
|---|---|---|---|
| Văn bản người đọc | `products.name`, `description`, `staff.full_name`, `label` | `utf8mb4_vi_0900_ai_ci` | sắp xếp đúng tiếng Việt; `_ai` cho phép tìm "banh cuon" ra "bánh cuốn" — **là tính năng ở đây** |
| Định danh máy đọc | `slug`, `orders.code`, `table_sessions.code`, `qr_token`, `username` | `ascii_bin` (hoặc `utf8mb4_bin`) | so từng byte, không nhầm; index gọn hơn nhiều |
| Hash | `password_hash`, `pin_hash` | `ascii_bin` | bcrypt là ASCII, **phân biệt hoa/thường bắt buộc** |

> ⚠️ **Cột hash đang là mối nguy im lặng.** `pin_hash CHAR(60)` và `password_hash VARCHAR(255)` đang nằm dưới
> `utf8mb4_unicode_ci` = **case-insensitive**. So sánh hash bằng SQL (`WHERE pin_hash = ?`) dưới collation
> `_ci` là làm yếu hash. Code Go hiện so bằng `bcrypt.CompareHashAndPassword` nên chưa lộ, nhưng cột vẫn
> là **cái bẫy đặt sẵn** cho session sau viết một câu `WHERE`.

**Đây là việc phải làm SỚM.** `ALTER TABLE … CONVERT TO CHARACTER SET` là **rebuild bảng + rebuild mọi index**.
Bảng còn trống thì gần như miễn phí; có 6 tháng đơn hàng rồi thì phải chạy sau 11h và có backup. Chi phí của
việc hoãn tăng theo thời gian — đây là loại quyết định **rẻ nhất lúc này**.

### 2.3 🔴 Thiếu hẳn khái niệm **ca bán / két tiền mặt**

Quán này thu **tiền mặt tại quầy** ([prompt-fullstack §3.1](../../project_preparation/prompt-fullstack.md)).
Schema có `payments.method='cash'` và `received_by` — tức là **ghi được từng lần thu**. Nhưng không có bảng nào
trả lời được câu hỏi mà chủ quán hỏi lúc 11h05 mỗi ngày:

> *"Trong két đang có 2.340.000đ. Có đúng không?"*

Trong POS thương mại, việc này có tên và có hình dạng cố định: **cash drawer session / shift / Z-report** —
mở ca ghi **số tiền đầu ca** (float), cuối ca **đếm tiền thật** rồi đối chiếu với tổng `cash` hệ thống ghi
nhận, chênh lệch ghi lại thành **over/short** theo từng người. Đúng ý nghĩa của nó: *"chữ ký tạo ra trách
nhiệm"* — chênh lệch không quy được về một ca và một người thì không ai chịu trách nhiệm.

Không có bảng này thì hệ quả không phải "báo cáo hơi thiếu", mà là: **thiếu 200k không có cách nào biết
thiếu từ ca nào, giờ nào, người nào** — và `GET admin/reports/daily` sẽ luôn báo "đủ", vì nó cộng lại đúng
những gì hệ thống tự ghi.

**Cách sửa đề xuất** — một bảng, khoảng 10 cột, và một FK trên `payments`:

```sql
CREATE TABLE cash_shifts (
  id             BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  business_date  DATE NOT NULL,                    -- ngày bán, không phải created_at
  opened_by      BIGINT UNSIGNED NOT NULL,
  closed_by      BIGINT UNSIGNED NULL,
  opening_float  INT UNSIGNED NOT NULL DEFAULT 0,  -- tiền lẻ đầu ca
  counted_cash   INT UNSIGNED NULL,                -- ĐẾM TAY cuối ca
  expected_cash  INT UNSIGNED NULL,                -- opening_float + SUM(payments cash)
  variance       INT NULL,                         -- counted - expected, CÓ DẤU
  note           VARCHAR(300),
  opened_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  closed_at      TIMESTAMP NULL,
  -- mỗi ngày tối đa 1 ca CHƯA đóng (cùng mẹo open_key ở 1.3)
  open_key       DATE GENERATED ALWAYS AS (IF(closed_at IS NULL, business_date, NULL)) VIRTUAL,
  UNIQUE KEY uq_shift_one_open (open_key)
);
ALTER TABLE payments ADD COLUMN cash_shift_id BIGINT UNSIGNED NULL, ADD FOREIGN KEY …;
```

Hai chi tiết quan trọng: `variance` phải **có dấu** (thiếu tiền là số âm — đây là chỗ `INT UNSIGNED` sẽ giấu
mất sự thật), và `counted_cash` phải là **số người đếm nhập vào**, tuyệt đối không được để hệ thống tự điền —
tự điền thì nó luôn khớp và bảng này thành vô nghĩa.

> Đây là **task, không phải finding** theo [CLAUDE.md §7](../../CLAUDE.md) (chạy hết kế hoạch hiện tại thì
> dòng này vẫn còn ⇒ … thực ra **vẫn còn**, vì `step.md` không có bước nào sinh ra nó). Ranh giới ở đây mờ:
> nó là **lỗ hổng phạm vi**, nên nhà đúng của nó là [00-scope](../../project_preparation/00-scope.md) trước,
> rồi mới tới task DB. Owner chốt trước.

### 2.4 🟠 Nhóm option không dùng lại được — chỗ lệch Square rõ nhất

```sql
product_option_groups (product_id BIGINT UNSIGNED NOT NULL, …)   -- 1 nhóm thuộc ĐÚNG 1 món
```

Square làm ngược lại: modifier list là **đối tượng độc lập**, gán cho nhiều item qua
`CatalogItem.modifier_list_info` — quan hệ **N:N**, và Square còn có hẳn endpoint
`UpdateItemModifierLists` cho tình huống *"nhiều item cần gán lại cùng một modifier list"*.

Cái giá phải trả trong repo này đọc được ngay ở [seed.sql](../../code/be/migrations/seed.sql): nhóm **"Nhân"**
được khai **7 lần** (id 1–7), nhóm **"Lượng nhân"** khai **7 lần** (id 8–14), và **28 dòng option** lặp
cùng một `price_delta`.

Chuyện sẽ xảy ra: chủ quán tăng phụ thu nhân từ 1.000 → 1.500đ. Việc đó là **`UPDATE` 8 dòng
`product_options` ở 4 nhóm khác nhau** (món lẻ), cộng 6 dòng nữa cho combo (mà combo là ×4 nên thành 6.000).
Sót một dòng ⇒ **một món bán sai giá**. Không test nào đỏ, không log nào kêu — sai giá **là dữ liệu hợp lệ**.

**Cách sửa đề xuất** — tách bảng nối, giữ nguyên `product_options`:

```sql
-- option_groups: bỏ product_id, thành nhóm dùng chung ('Nhân', 'Lượng nhân')
CREATE TABLE product_option_group_links (
  product_id  BIGINT UNSIGNED NOT NULL,
  group_id    BIGINT UNSIGNED NOT NULL,
  price_scale TINYINT UNSIGNED NOT NULL DEFAULT 1,  -- combo = 4 (4 phần nhận nhân)
  sort_order  INT NOT NULL DEFAULT 0,
  PRIMARY KEY (product_id, group_id)
);
```

`price_scale` là chỗ hay nhất của cách này: nó **biến "combo phụ thu ×4" từ dữ liệu chép tay thành một con
số có tên**. Hiện tại "×4" chỉ tồn tại dưới dạng **comment trong seed** (`-- combo: +4.000 (4 phần)`) và các
số 4000 gõ tay — tức là quy tắc giá của quán đang **không được ghi ở đâu cả** dưới dạng máy đọc được. Với
`price_scale`, đổi phụ thu nhân là `UPDATE` **đúng 1 dòng**, combo tự đúng theo.

> **Đánh đổi phải nói rõ:** cách này khiến giá không còn đọc thẳng ra được bằng một `SELECT` đơn, và
> **hàm tính giá ở BE phải nhân thêm `price_scale`** — tức là đụng [ràng buộc §4.1](../../project_preparation/prompt-fullstack.md)
> ("giá tính ở backend, một hàm duy nhất"). Đây là lý do chính đáng để **hoãn**: nếu quán không định đổi giá
> trong 6 tháng tới thì 28 dòng seed lặp là rẻ hơn một migration + sửa hàm tính giá. Nhưng phải hoãn **có ý
> thức**, và phải có test *"đổi `price_delta` của nhân ⇒ cả 8 món đổi giá theo"* để lần đổi giá thật không sót.

### 2.5 🟠 `depends_on_option_id` không diễn tả nổi "khác Chay"

```sql
depends_on_option_id BIGINT UNSIGNED NULL   -- nhóm này chỉ hiện khi option KIA được chọn
```

Một cột ⇒ phụ thuộc vào **đúng một** option. Nhưng luật thật của quán là:
*"Lượng nhân hiện khi nhân **≠ Chay**"* — tức phụ thuộc vào **tập** {`thit`, `thit_mocnhi`}.

Chính [seed.sql:78-80](../../code/be/migrations/seed.sql) đã phải viết ra chỗ hụt này bằng comment:

> ```
> -- depends_on_option_id trỏ tới option 'Thịt' của cùng món (gợi ý cho FE).
> -- Luật đầy đủ "chỉ áp dụng khi nhân != chay" nằm ở service/pricing.go,
> -- vì nhóm này phải hiện với CẢ 'Thịt' lẫn 'Thịt + mộc nhĩ'.
> ```
>
> Hai chữ **"gợi ý cho FE"** là chỗ đáng lo nhất: một cột trong DB tự nhận mình chỉ là gợi ý. Và đường dẫn
> `service/pricing.go` trong comment **không còn tồn tại** sau lần chuyển sang module-first
> (commit `9b4b883`) — file thật là [code/be/internal/menu/pricing.go](../../code/be/internal/menu/pricing.go).
> Con trỏ duy nhất từ dữ liệu tới nửa luật còn lại đang trỏ vào chỗ trống.

Đây không phải lỗi nhỏ về tiện dụng, nó **vỡ đúng nguyên tắc mở đầu của [02-luat](02-luat.md)**:
*"DB là tầng cuối cùng còn giữ được dữ liệu đúng khi BE có bug. Mọi ràng buộc quan trọng phải nằm ở đây,
không chỉ ở Go."* Và luật bị đẩy lên Go ở đây chính là luật mà
[prompt-fullstack §4.6](../../project_preparation/prompt-fullstack.md) gọi là **vi phạm phải làm lại**:
*"Chọn `Chay` + `Nhiều nhân` phải bị TỪ CHỐI"*.

Kết quả: dữ liệu định nghĩa **một nửa** luật (Thịt → hiện), nửa còn lại (Thịt + mộc nhĩ → cũng hiện) sống
trong code. Ai sửa seed mà không đọc code Go sẽ thấy `depends_on_option_id` trỏ tới `thit` và tưởng đó là
toàn bộ luật.

**Cách sửa đề xuất** — bảng phụ thuộc N:N, ngữ nghĩa **ANY**:

```sql
CREATE TABLE option_group_dependencies (
  group_id            BIGINT UNSIGNED NOT NULL,   -- nhóm 'Lượng nhân'
  required_option_id  BIGINT UNSIGNED NOT NULL,   -- 'thit' HOẶC 'thit_mocnhi'
  PRIMARY KEY (group_id, required_option_id)
);
-- nhóm hiện khi ÍT NHẤT MỘT required_option được chọn; không có dòng nào = luôn hiện
```

Cách này còn trả lời trước câu hỏi sẽ đến: quán thêm loại nhân thứ 4 (ví dụ "Thịt + nấm") thì chỉ thêm
**một dòng**, không phải sửa code Go.

**Rẻ hơn nếu chưa muốn đổi schema:** ít nhất viết **một test** đóng đinh cả hai vế —
`(chay, nhieu)` bị từ chối **và** `(thit_mocnhi, nhieu)` được chấp nhận. Hiện luật này chỉ được bảo vệ bằng
một dòng comment trong file `.sql`.

### 2.6 🟠 `order_item_options` thiếu khoá ngoại về option gốc

`order_items` giữ cả hai: `product_id` (FK, thêm ở [000005](../../code/be/migrations/000005_order_constraints.up.sql))
**và** snapshot `product_name`. Đúng bài — snapshot cho hoá đơn, FK cho phân tích.

`order_item_options` thì **chỉ có snapshot**: `group_name`, `option_name`, `price_delta`. Không `option_id`,
không `group_id`.

Hậu quả: câu hỏi *"tháng này bao nhiêu suất chọn thịt + mộc nhĩ?"* phải trả lời bằng
`WHERE option_name = 'Thịt + mộc nhĩ'` — **so chuỗi**. Chủ quán đổi tên hiển thị thành *"Thịt + mộc nhĩ (đặc
biệt)"* là báo cáo **gãy làm đôi** đúng ngày đổi tên, và không ai nhận ra vì cả hai nửa đều ra số hợp lý.

**Cách sửa đề xuất** (một migration, bảng còn trống nên rẻ):

```sql
ALTER TABLE order_item_options
  ADD COLUMN option_id BIGINT UNSIGNED NULL AFTER order_item_id,
  ADD CONSTRAINT fk_itemopt_option FOREIGN KEY (option_id) REFERENCES product_options(id);
```

`NULL`-able + `RESTRICT`, đúng cùng lý lẽ đã dùng cho `fk_items_product`: snapshot vẫn tự đứng được, FK chỉ
để chặn rác và mở đường cho báo cáo.

### 2.7 🟠 Không `CHECK` quan hệ số học giữa các cột tiền

Schema có `CHECK (quantity > 0)` nhưng **không** có ràng buộc nào bắt các cột tiền phải cộng đúng:

| Bảng | Bất biến chưa được gác |
|---|---|
| `order_items` | `unit_price = base_price + options_price` |
| `order_items` | `line_total = unit_price * quantity` |
| `orders` | `total = subtotal + shipping_fee − discount` |
| `orders` | `discount <= subtotal` |
| `table_sessions` | `total = subtotal − discount` |
| `table_sessions` | `subtotal = SUM(orders.total)` của phiên *(cái này CHECK không làm được)* |

Đây là mâu thuẫn nội bộ đáng nói: [02-luat §2](02-luat.md) tuyên bố *"nếu dữ liệu sai làm hỏng tiền hoặc
hỏng nghiệp vụ, DB phải từ chối nó"* — mà **những cột trực tiếp là tiền** lại đang không được từ chối gì.
Một bug làm tròn hay một lần quên cập nhật `subtotal` sẽ nằm im trong DB, và `GET admin/reports/daily` sẽ
cộng nó vào doanh thu như dữ liệu thật.

**Cách sửa đề xuất** — MySQL 8.0.16+ **thực thi** `CHECK` thật (trước đó chỉ phân tích rồi bỏ qua), nên
những dòng này có tác dụng ngay:

```sql
ALTER TABLE order_items
  ADD CONSTRAINT chk_items_unit  CHECK (unit_price = base_price + options_price),
  ADD CONSTRAINT chk_items_line  CHECK (line_total = unit_price * quantity);

ALTER TABLE orders
  ADD CONSTRAINT chk_orders_total CHECK (total = subtotal + shipping_fee - discount),
  ADD CONSTRAINT chk_orders_disc  CHECK (discount <= subtotal);
```

**Mạnh hơn nữa:** biến `line_total` thành **cột sinh** — thì nó không thể sai, thay vì chỉ bị từ chối khi sai:

```sql
line_total INT UNSIGNED GENERATED ALWAYS AS (unit_price * quantity) STORED
```

> Ở đây `STORED` là **đúng** (khác [§1.3](#13-open_key--cột-sinh--unique-đúng-bài-mysql)): giá trị này nằm
> trên hoá đơn, cần đọc lại y nguyên nhiều năm sau, và không bao giờ đổi biểu thức.

Ràng buộc `subtotal = SUM(orders.total)` thì `CHECK` không diễn tả được (đa bảng). Nó thuộc về **transaction
ở BE** + **một query đối soát chạy trong CI/cron**:

```sql
SELECT s.id, s.subtotal, SUM(o.total)
FROM table_sessions s JOIN orders o ON o.table_session_id = s.id
WHERE o.status <> 'cancelled'
GROUP BY s.id HAVING s.subtotal <> SUM(o.total);   -- ra dòng nào là có tiền sai
```

### 2.8 🟡 `ENUM` trạm lặp ở 3 nơi + 1 `CHECK`

[prompt-fullstack §3.5](../../project_preparation/prompt-fullstack.md) đã tự ghi nhận:
*"Enum trạm dùng chung ở `product_stations.station`, `order_tasks.station`, `staff.role`"* — nhưng "dùng
chung" ở đây là **chép giống nhau**, không phải chia sẻ. MySQL không có kiểu enum dùng chung như PostgreSQL.

Thêm một trạm (ví dụ `pha_nuoc`) = **3 lần `ALTER TABLE … MODIFY COLUMN`**, cộng lần thứ 4 nếu chạm
`chk_order_channel_fulfillment`. Sót một là dữ liệu vào được bảng này, bị chặn ở bảng kia.

Cân bằng lại cho công bằng: `ENUM` **không phải luôn sai**. Nó gọn (1 byte), tự có ràng buộc, và trong
MySQL 8 **thêm giá trị vào CUỐI danh sách** là thao tác rẻ (không đổi kích thước lưu trữ khi ≤ 255 giá trị).
Nhược điểm thật của `ENUM` là: không gắn được **metadata** (tên hiển thị, thứ tự, màu), sửa/đổi thứ tự thì
đắt, và một số ORM/tool hiểu nhầm vì nó lưu số nhưng lộ ra chuỗi.

Ở dự án này, **`station` chính là loại cần metadata**: [prompt-fullstack §3.7](../../project_preparation/prompt-fullstack.md)
yêu cầu màn hình trạm có tên tiếng Việt cỡ ≥ 24px và màu theo thời gian chờ. Nghĩa là *"tên hiển thị của
trạm"* và *"ngưỡng vàng/đỏ"* **đang phải sống ở FE bằng chữ gõ tay**, trong khi nhà đúng của chúng là một
bảng `stations` (`code`, `name`, `sort_order`, `warn_after_sec`, `alert_after_sec`).

→ **Chưa cần đổi ngay** (5 trạm là danh sách đóng, quán không thêm trạm mỗi tuần). Ghi lại để khi FE làm màn
hình trạm thì **cân nhắc bảng `stations` trước khi gõ tên trạm vào TypeScript**.

`orders.status` (8 giá trị), `order_tasks.status`, `payments.status` thì `ENUM` là lựa chọn tốt — giữ nguyên.

### 2.9 🟡 `is_available` gánh hai nghĩa khác nhau

`products` có `is_available`, **không có** `is_active`. Nhưng hai khái niệm này khác nhau:

| | Ý nghĩa | Ai bật/tắt | Tần suất |
|---|---|---|---|
| "Hết món hôm nay" | tạm hết nguyên liệu, mai bán lại | nhân viên quầy, giữa giờ bán | vài lần/tuần |
| "Ngừng bán" | bỏ khỏi menu, đơn cũ vẫn phải đọc được | chủ quán | vài lần/năm |

Gộp vào một cột ⇒ sáng mai nhân viên bật lại "hết món" là **món đã bỏ menu sống lại** trên web khách.

Ngoài ra đây là chỗ **tài liệu đang mô tả một cột không tồn tại**: [02-luat §7](02-luat.md) ghi *"Cột
`is_active`, không `DELETE`"*, và [000005](../../code/be/migrations/000005_order_constraints.up.sql) có comment
*"món ngừng bán dùng `is_active`"* — nhưng `products` chỉ có `is_available`. Xem [§4.1](#41-tài-liệu-nhắc-tên-cột-không-tồn-tại).

**Cách sửa đề xuất:** thêm `is_active BOOLEAN NOT NULL DEFAULT TRUE` (soft delete thật), giữ `is_available`
cho "hết hôm nay". Menu khách lọc `is_active = TRUE`; badge "Hết" bật theo `is_available = FALSE`.

### 2.10 🟡 Không có bảng outbox — SSE và Telegram là hai lần "ghi đôi"

Hai chỗ trong hệ thống có **dual-write**: (a) tạo `order_tasks` + đẩy sự kiện SSE xuống màn hình trạm,
(b) tạo `orders` + gửi Telegram cho chủ quán. Cả hai đều là "ghi DB xong rồi gửi đi nơi khác" — nếu tiến
trình chết giữa hai bước, DB đúng còn thông báo mất, **không để lại dấu vết nào**.

Pattern chuẩn tên là **transactional outbox**: ghi sự kiện vào **một bảng trong cùng transaction** với dữ
liệu nghiệp vụ, rồi một tiến trình riêng đọc bảng đó và gửi đi. Đảm bảo là **at-least-once** (có thể gửi
trùng, không bao giờ mất) — nên bên nhận phải chịu được trùng.

**Giảm nhẹ đã có sẵn:** [prompt-fullstack §4.9](../../project_preparation/prompt-fullstack.md) bắt màn hình
trạm `refetch` mỗi 20 giây, nên SSE mất sự kiện thì **20 giây sau tự khớp lại**. Đây là thiết kế tốt và
**đúng là lý do chính đáng để chưa cần outbox cho SSE**.

Nhưng **Telegram thì không có lưới an toàn tương đương** — chủ quán không "refetch" được. Đơn ship về lúc
6h50 mà thông báo rơi mất thì không ai biết cho tới khi khách gọi hotline hỏi.

**Cách sửa đề xuất (bản nhỏ nhất, không cần outbox đầy đủ):** thêm cột trạng thái thông báo trên `orders` —
`notified_at TIMESTAMP NULL` + `notify_attempts TINYINT` — rồi một job quét
`WHERE notified_at IS NULL AND created_at > NOW() - INTERVAL 1 HOUR` gửi lại. Một cột, một cron, và đủ để
"đơn không ai biết" trở thành **truy được**.

---

## 3. Những thứ POS thật có mà schema chưa có

Không phải cái nào cũng cần — quán 11 bàn không cần bằng chuỗi 50 cửa hàng. Xếp theo **có nên làm không**:

| Thiếu | Nên làm? | Vì sao |
|---|---|---|
| **Ca bán / két tiền mặt** ([§2.3](#23--thiếu-hẳn-khái-niệm-ca-bán--két-tiền-mặt)) | 🔴 **Có, trước khi bán thật** | Quán thu tiền mặt. Không đối chiếu được = không kiểm soát được tiền |
| **Idempotency key trên `orders`** ([§3.1](#31-idempotency--chống-đơn-trùng-do-mạng)) | 🔴 **Có** | Khách dùng 3G, bấm 2 lần là chuyện thường ngày |
| **Huỷ dòng / void item sau khi bếp đã nhận** | 🟠 Có | `orders.status='cancelled'` huỷ **cả đơn**. Khách đổi ý 1 trong 3 suất thì không có đường ghi |
| **Hoàn tiền có gốc** | 🟠 Có, rẻ | `payments.status` có `'refunded'` nhưng **không có** `parent_payment_id`. Hoàn một phần không ghi nổi |
| **Tách hoá đơn (split bill)** | 🟡 Có thể bỏ | Quán bánh cuốn sáng, khách trả chung. `payments` đã cho **nhiều dòng/phiên** nên trả góp mặt+CK đã làm được |
| **Khuyến mãi / giảm giá có nguồn** | 🟡 Sau | `discount` là số trần, không biết vì sao giảm. Chưa có chương trình KM thì chưa cần |
| **`business_date` tách khỏi `created_at`** | 🟠 Có | Quán bán 6h–11h nên `DATE(created_at)` tình cờ đúng — nhưng đó là **may**, không phải thiết kế |
| **Bảng `stations`** ([§2.8](#28--enum-trạm-lặp-ở-3-nơi--1-check)) | 🟡 Sau | Khi FE làm màn hình trạm |
| **Outbox** ([§2.10](#210--không-có-bảng-outbox--sse-và-telegram-là-hai-lần-ghi-đôi)) | 🟡 Bản nhỏ | Chỉ cho Telegram |
| **Kiểm kho / nguyên liệu** | ⬜ **Không** | Nút "Tạm dừng nhận đơn" đã đủ. Kho là dự án khác |
| **Khách hàng / loyalty** | ⬜ **Không** | Ngoài [00-scope](../../project_preparation/00-scope.md). `customer_phone` trần là đủ |
| **Multi-tenant / nhiều chi nhánh** | ⬜ **Không** | Một quán. Thêm `branch_id` bây giờ là YAGNI thuần |

### 3.1 Idempotency — chống đơn trùng do mạng

Cách chuẩn: client sinh **một UUID cho mỗi hành động logic** (một lần bấm "Đặt hàng"), gửi kèm request;
server đặt **`UNIQUE` trên khoá đó** và khi trùng thì trả lại kết quả cũ thay vì tạo mới. Điểm cốt lõi:
**dựa vào `UNIQUE` của DB, không dựa vào "kiểm tra rồi mới insert"** ở tầng code — vì check-then-insert
thua race condition.

Hai đường vào của dự án này đều dễ dính: khách ngồi quán quét QR dùng 3G yếu (`POST t/:token/orders`), và
nhân viên bấm trên tablet lúc đông (`POST staff/sessions/:id/orders`).

```sql
ALTER TABLE orders
  ADD COLUMN idempotency_key CHAR(36) NULL,
  ADD UNIQUE KEY uq_orders_idem (idempotency_key);   -- NULL trùng nhau được → đơn cũ không vướng
```

Một cột, một index. `NULL` được phép trùng nên không cần backfill dữ liệu cũ — chính là mẹo ở
[§1.3](#13-open_key--cột-sinh--unique-đúng-bài-mysql) dùng lại lần nữa.

> Chuẩn đầy đủ còn khuyên lưu **hash của request body** cùng khoá, để bắt trường hợp client dùng lại khoá
> cho nội dung khác. Ở quy mô này có thể bỏ, nhưng nếu bỏ thì phải biết là mình đang bỏ.

### 3.2 `business_date` — chỗ đang đúng nhờ may mắn

Báo cáo ngày hiện sẽ viết `WHERE DATE(created_at) = ?`. Với quán mở 6h–11h thì **luôn đúng**, vì không có
đơn nào vắt qua nửa đêm.

Nhưng nó đúng vì **giờ bán**, không vì thiết kế. Hai thứ làm nó sai mà không báo:
quán bán thêm ca tối, hoặc một lần đổi `--default-time-zone`. Và `DATE(created_at)` là **hàm bọc quanh cột**
⇒ MySQL **không dùng được index** trên `created_at` ⇒ full scan bảng `orders`.

Cách chuẩn của POS là tách **ngày bán** khỏi **thời điểm ghi**. Rẻ nhất, dùng lại đúng công cụ đã có trong repo:

```sql
ALTER TABLE orders
  ADD COLUMN business_date DATE GENERATED ALWAYS AS (DATE(created_at)) STORED,
  ADD INDEX idx_orders_bizdate (business_date, status);
```

Vừa đặt tên đúng cho khái niệm, vừa **giải luôn** cái index mà [03-hien-trang](03-hien-trang.md) đang liệt
kê trong mục "Chưa có" (*"Index cho báo cáo doanh thu — sẽ quét bảng"*). Sau này đổi giờ bán thì sửa **biểu
thức**, không sửa mọi câu query.

---

## 4. Tài liệu lệch code — phát hiện lúc đối chiếu

Bốn chỗ dưới đây phát hiện được **chỉ vì** nghiên cứu này đọc `.sql` thay vì đọc `01-thiet-ke.md`.
Đúng luật [CLAUDE.md §2](../../CLAUDE.md): **code thắng**, chữ ở tài liệu là bug phải sửa.

### 4.1 Tài liệu nhắc tên cột không tồn tại

`products` **không có** `is_active`. Nhưng:

- [02-luat §7](02-luat.md): *"Xoá cứng món … → Cột `is_active`, không `DELETE`"*
- [000005_order_constraints.up.sql](../../code/be/migrations/000005_order_constraints.up.sql): *"món ngừng bán dùng `is_active`, không `DELETE`"*
- [03-hien-trang](03-hien-trang.md) chép lại y nguyên câu đó

Ba nơi cùng nhắc một cột không có. Đây đúng là thứ [CLAUDE.md §2.1](../../CLAUDE.md) cảnh báo: **chép rồi trôi**.
Sửa cách nào phụ thuộc [§2.9](#29--is_available-gánh-hai-nghĩa-khác-nhau) — thêm cột thật, hay sửa chữ thành
`is_available`. **Thêm cột là đúng hơn**, vì hai khái niệm thật sự khác nhau.

```bash
# lệnh chứng minh
grep -n 'is_active' code/be/migrations/000001_menu.up.sql   # không ra dòng nào trong CREATE TABLE products
grep -rn 'is_active' design/data_base/ code/be/migrations/000005_order_constraints.up.sql
```

### 4.2 `01-thiet-ke.md` gọi cột là `pin_code`, migration đặt tên `pin_hash`

[01-thiet-ke §2.3](01-thiet-ke.md) ghi `pin_code CHAR(60)`; [000002:18](../../code/be/migrations/000002_tables_staff.up.sql)
là `pin_hash CHAR(60)`. **Code đúng hơn** — tên `pin_hash` nói thật rằng đây là bcrypt chứ không phải PIN trần.

```bash
grep -n 'pin_' code/be/migrations/000002_tables_staff.up.sql design/data_base/01-thiet-ke.md
```

### 4.3 `03-hien-trang.md` nói "chưa có seed `tables`" — nhưng seed.sql có 11 bàn

[03-hien-trang mục "Chưa có"](03-hien-trang.md) ghi: *"**Seed `tables`** — chưa có bàn nào, chưa sinh `qr_token`"*.
Thực tế [seed.sql:122-133](../../code/be/migrations/seed.sql) insert đủ 11 bàn kèm `qr_token`.

Chỗ này **nguy hơn một lỗi chính tả**, vì nó che mất [§2.1](#21--qr_token-sinh-bằng-uuid--token-đoán-được):
ai đọc tài liệu sẽ tưởng token chưa sinh nên chưa cần lo, trong khi seed **đang sinh token yếu**. Ngược lại,
*"Seed `staff` — chưa có tài khoản chủ quán"* thì **đúng**: `grep -c 'INSERT INTO staff' seed.sql` = 0.

```bash
sed -n '120,133p' code/be/migrations/seed.sql        # 11 bàn có thật
grep -c 'INSERT INTO staff' code/be/migrations/seed.sql   # 0 — vế này của tài liệu đúng
```

### 4.4 `TEST_DB_DSN` thiếu `loc=` — lệch 7 tiếng chỉ trong test

| Nơi | DSN |
|---|---|
| [.env.example:9](../../.env.example) | `…?parseTime=true&charset=utf8mb4&loc=Asia%2FHo_Chi_Minh` ✅ |
| [code/be/internal/platform/testdb/testdb.go:7](../../code/be/internal/platform/testdb/testdb.go) | `…?parseTime=true&charset=utf8mb4` ❌ **thiếu `loc`** |

`go-sql-driver/mysql` mặc định `loc=UTC`. Server chạy `--default-time-zone=+07:00` ⇒ cùng một hàng
`TIMESTAMP`, production đọc ra `06:30 +07`, test đọc ra `06:30 UTC`. **Lệch đúng 7 tiếng** — đúng con số mà
[prompt-fullstack §4.7](../../project_preparation/prompt-fullstack.md) cảnh báo.

Chưa cháy vì chưa có test nào so mốc thời gian tuyệt đối. Nhưng test **đầu tiên** kiểm luật "6h–11h" sẽ đỏ
(hoặc tệ hơn: **xanh nhầm**) mà không ai đoán được vì sao.

Sửa: thêm `&loc=Asia%2FHo_Chi_Minh` vào dòng ví dụ trong `testdb.go` và vào `TEST_DB_DSN` mẫu ở
[Makefile](../../Makefile).

---

## 5. Đề xuất — chưa vào sổ finding

**Chưa ghi dòng nào vào [finding.md](../../finding.md).** Lý do: file đó đang **bẩn** (`git status` ⇒ ` M finding.md`)
từ session khác, và [CLAUDE.md §11](../../CLAUDE.md) cấm chạm việc chưa commit của lane khác. ID cao nhất
hiện tại là **F-70**, nên các mã dưới đây là **dự kiến**, owner chốt rồi mới đánh số thật.

### Nên thành FINDING (đang sai ngay bây giờ)

| Dự kiến | Lane | Mức | Mệnh đề sai | Lệnh chứng minh |
|---|---|---|---|---|
| F-71 | DB | 🔴 | `seed.sql` sinh `qr_token` bằng `UUID()` (UUIDv1, đoán được) trong khi thiết kế yêu cầu random | `grep -n 'UUID()' code/be/migrations/seed.sql` |
| F-72 | DB | 🔴 | `utf8mb4_unicode_ci` (UCA 4.0.0) chỉ hỗ trợ **một phần** UCA, MySQL manual nêu đích danh tiếng Việt; cột hash + cột định danh đang chạy dưới collation `_ci` | `grep -c 'utf8mb4_unicode_ci' code/be/migrations/*.up.sql` |
| F-73 | DB | 🟠 | 3 tài liệu + 1 migration nhắc cột `products.is_active` không tồn tại | `grep -n 'is_active' code/be/migrations/000001_menu.up.sql` |
| F-74 | DB | 🟠 | `03-hien-trang` ghi "chưa seed `tables`" nhưng `seed.sql` insert 11 bàn | `sed -n '120,133p' code/be/migrations/seed.sql` |
| F-75 | DB | 🟠 | `01-thiet-ke` ghi `pin_code`, migration là `pin_hash` | `grep -n 'pin_' code/be/migrations/000002_tables_staff.up.sql` |
| F-76 | BE | 🟠 | `TEST_DB_DSN` mẫu thiếu `loc=` ⇒ test đọc TIMESTAMP lệch 7 tiếng so với production | `grep -n 'TEST_DB_DSN' code/be/internal/platform/testdb/testdb.go Makefile` |
| F-77 | DB | 🟠 | Luật "Lượng nhân hiện khi nhân ≠ Chay" chỉ được mô tả **một nửa** trong dữ liệu; nửa còn lại là comment, và comment trỏ tới `service/pricing.go` **không tồn tại** | `sed -n '78,80p' code/be/migrations/seed.sql` rồi `ls code/be/internal/menu/pricing.go` |
| F-78 | DB | 🟡 | [02-luat §3](02-luat.md) khai query CI chặn cột tiền kiểu float, nhưng không target `make` nào gọi | `grep -n 'information_schema' Makefile` → 0 hit |

### Nên thành TASK (chưa tới lượt xây, không phải lỗi)

| Dự kiến | Lane | Việc | Đầu ra kiểm chứng được |
|---|---|---|---|
| T-a | DB | Thêm `orders.idempotency_key` + `UNIQUE` | test: gửi 2 lần cùng key ⇒ 1 hàng `orders` |
| T-b | DB | Thêm `order_item_options.option_id` (FK, NULL, RESTRICT) | `SHOW CREATE TABLE order_item_options` có `fk_itemopt_option` |
| T-c | DB | Thêm 4 `CHECK` số học tiền + `line_total` thành cột sinh | test: `INSERT` với `line_total` sai ⇒ lỗi |
| T-d | DB | Thêm `products.is_active`, đổi mọi query menu sang lọc 2 cột | test: `is_active=FALSE` ⇒ biến mất khỏi `GET /products` |
| T-e | DB | Chuyển collation theo vai trò cột ([§2.2](#22--utf8mb4_unicode_ci--mysql-nói-thẳng-là-ảnh-hưởng-tiếng-việt)) | `information_schema.columns` ⇒ 0 cột định danh còn `_ci` |
| T-f | DB | Đổi seed `qr_token` sang `HEX(RANDOM_BYTES(16))` + lệnh xoay token | `SELECT qr_token FROM tables` ⇒ 11 giá trị không chung tiền tố |
| T-g | BA | Chốt phạm vi **ca bán / két tiền mặt** vào [00-scope](../../project_preparation/00-scope.md) | mục mới trong 00-scope + câu trả lời của owner |
| T-h | DB | *(sau T-g)* Bảng `cash_shifts` + `payments.cash_shift_id` | test: đóng ca lệch tiền ⇒ `variance` âm ghi lại được |
| T-i | DB | `orders.business_date` cột sinh + index | `EXPLAIN` báo cáo ngày ⇒ không còn `type: ALL` |
| T-j | BE | `orders.notified_at` + job gửi lại Telegram | test: gửi lỗi lần 1 ⇒ lần quét sau gửi lại |
| T-k | DB | *(hoãn có ý thức)* Nhóm option dùng chung + `price_scale` | test: đổi 1 `price_delta` ⇒ cả 8 món đổi giá |

**Thứ tự đề nghị:** F-71 → F-72/T-e/T-f (làm một lượt, khi bảng còn trống) → T-a → T-g/T-h → phần còn lại.
Lý do thứ tự này: ba việc đầu **rẻ đúng lúc này và đắt dần theo từng ngày có dữ liệu thật**, vì
`CONVERT TO CHARACTER SET` là rebuild bảng.

---

## 6. Nguồn

Trích để đối chiếu, không phải để trang trí — mỗi nguồn gắn với đúng một mục ở trên.

| Mục | Nguồn |
|---|---|
| [§2.2](#22--utf8mb4_unicode_ci--mysql-nói-thẳng-là-ảnh-hưởng-tiếng-việt) collation, cảnh báo tiếng Việt | [MySQL 8.4 — Unicode Character Sets](https://dev.mysql.com/doc/refman/8.4/en/charset-unicode-sets.html) · [MySQL 8.4 — Character Sets and Collations](https://dev.mysql.com/doc/refman/8.4/en/charset-mysql.html) · [MySQL blog — Migrating from older collations](https://dev.mysql.com/blog-archive/mysql-8-0-collations-migrating-from-older-collations/) · [PlanetScale — Charsets and collations](https://planetscale.com/blog/mysql-charsets-collations) |
| [§2.1](#21--qr_token-sinh-bằng-uuid--token-đoán-được) `UUID()` không unpredictable | [MySQL — Miscellaneous Functions (UUID)](https://dev.mysql.com/doc/refman/5.7/en/miscellaneous-functions.html) · [Generating v4 UUIDs in MySQL](https://emmer.dev/blog/generating-v4-uuids-in-mysql/) · [RANDOM_BYTES()](https://oneuptime.com/blog/post/2026-03-31-mysql-mysql-random-bytes-function/view) |
| [§1.3](#13-open_key--cột-sinh--unique-đúng-bài-mysql) partial index bằng cột sinh | [PHP Architect — Unique index patterns for soft deletes](https://www.phparch.com/2026/02/advanced-unique-index-patterns-for-soft-deletes-mysql-and-postgresql/) · [Dealing with MySQL nulls and unique constraint](https://www.aleksandra.codes/mysql-nulls) |
| [§1.3](#13-open_key--cột-sinh--unique-đúng-bài-mysql) VIRTUAL vs STORED | [MySQL — Secondary Indexes and Generated Columns](https://dev.mysql.com/doc/refman/8.4/en/create-table-secondary-indexes.html) · [Kris Köhntopp — Generated columns and virtual indexes](https://blog.koehntopp.info/2020/09/07/mysql-generated-columns-and-virtual-indexes.html) |
| [§1.1](#11-tiền-là-số-nguyên-vnd--trùng-cách-stripe-làm) tiền số nguyên | [Storing currency values: data types, caveats, best practices](https://cardinalby.github.io/blog/post/best-practices/storing-currency-values-data-types/) · [DECIMAL or BIGINT?](https://dev.tldrlss.com/en/article/2026/02/how-to-store-the-currency-in-the-database/) |
| [§1.4](#14-payments-gắn-vào-đúng-một-đích--pattern-có-tên-exclusive-arc) exclusive arc | [Hashrocket — Modeling polymorphic associations](https://hashrocket.com/blog/posts/modeling-polymorphic-associations-in-a-relational-database) · [DoltHub — Choosing a schema for polymorphic data](https://www.dolthub.com/blog/2024-06-25-polymorphic-associations/) |
| [§1.5](#15-hình-dạng-optionmodifier-trùng-square-catalog-api) · [§2.4](#24-nhóm-option-không-dùng-lại-được--chỗ-lệch-square-rõ-nhất) modifier list | [Square — Enable Item Customization with Modifiers](https://developer.squareup.com/docs/catalog-api/enable-modifiers-on-items) · [Square — Design a Catalog](https://developer.squareup.com/docs/catalog-api/design-a-catalog) |
| [§2.3](#23--thiếu-hẳn-khái-niệm-ca-bán--két-tiền-mặt) ca bán / két tiền | [Lavu — Restaurant daily cash reconciliation](https://lavu.com/how-to-set-up-restaurant-daily-cash-reconciliation/) · [NRS — Cash drawer reconciliation](https://nrsplus.com/blog/cash-drawer-reconciliation/) · [Lightspeed Restaurant — Cash drawer reports](https://resto-support.lightspeedhq.com/hc/en-us/articles/226306687-Creating-Cash-Drawer-reports) · [Microsoft Dynamics 365 Commerce — Shift and drawer management](https://learn.microsoft.com/en-us/dynamics365/commerce/shift-drawer-management) |
| [§3.1](#31-idempotency--chống-đơn-trùng-do-mạng) idempotency | [Zuplo — Implementing idempotency keys in REST APIs](https://zuplo.com/learning-center/implementing-idempotency-keys-in-rest-apis-a-complete-guide) · [Luca Palmieri — An in-depth introduction to idempotency](https://lpalmieri.com/posts/idempotency/) |
| [§2.10](#210--không-có-bảng-outbox--sse-và-telegram-là-hai-lần-ghi-đôi) outbox | [AWS Prescriptive Guidance — Transactional outbox](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/transactional-outbox.html) · [Milan Jovanović — Implementing the outbox pattern](https://milanjovanovic.tech/blog/implementing-the-outbox-pattern) |
| [§2.8](#28--enum-trạm-lặp-ở-3-nơi--1-check) ENUM vs lookup | [Avoid ENUM when you should use a lookup table](https://oneuptime.com/blog/post/2026-03-31-mysql-avoid-using-enum-use-lookup-table-in-mysql/view) · [MySQL ENUM vs CHECK vs lookup](https://ivanluminaria.com/en/posts/mysql/enum-mysql-semplifica-o-complica/) |
| [§1.7](#17-múi-giờ-0700-cố-định-là-lựa-chọn-đúng-không-phải-lười) TIMESTAMP vs DATETIME | [PlanetScale — Datetimes versus timestamps in MySQL](https://planetscale.com/blog/datetimes-vs-timestamps-in-mysql) · [MySQL Bug #119944 — Year 2038](https://bugs.mysql.com/bug.php?id=119944) |
