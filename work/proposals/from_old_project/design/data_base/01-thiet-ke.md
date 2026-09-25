# 01 — Thiết kế Database

> Cập nhật **2026-08-19** · Lane sở hữu: **DB** · Dời từ `step.md` Bước 2 (`git log --follow`).
> Sự thật DB khác: [luật](02-luat.md) · [hiện trạng](03-hien-trang.md) · [yêu cầu khi làm việc](04-yeu-cau.md).

**File này giữ *ý định thiết kế*, không giữ schema đang chạy.** Schema thật ở
[code/be/migrations/](../../code/be/migrations/) — SQL dưới đây là bản viết gọn cho người đọc lần đầu,
có chỗ **cố ý khác** file thật (rõ nhất: `open_key` ở mục 2.3). **Lệch ⇒ code thắng**
([CLAUDE.md §2](../../CLAUDE.md)): mở finding, đừng sửa `.sql` cho khớp chữ ở đây.

Đọc schema đang chạy:

```bash
grep -h 'CREATE TABLE' code/be/migrations/*.up.sql          # danh sách bảng
mysql "$DSN" -e 'SHOW CREATE TABLE table_sessions\G'   # bảng thật sau mọi migration
```

---

## 2.1 Sơ đồ quan hệ

```
categories ──n products ──n product_option_groups ──n product_options
                  │
                  └──n product_components      (thành phần combo)
                  └──n product_stations        (món này đi qua trạm nào)

tables ──n table_sessions ──n orders ──n order_items ──n order_item_options
                    │            │
                    │            ├──n order_tasks   (việc cho từng trạm)
                    │            └──n order_status_history
                    │
                    └──n payments n──┘   ← payments gắn vào MỘT trong hai:
                                            table_session_id  (ăn tại bàn)
                                            order_id          (ship / pickup)

staff        store_settings
```

> **Lưu ý về `payments`:** đơn `delivery` và `pickup` **không có** `table_session`, nên `payments` phải gắn được trực tiếp vào `orders`. Bảng có cả hai cột, đều `NULL` được, và một `CHECK` bắt buộc đúng một cột khác `NULL` — xem mục [2.4](#24-migration-3--đơn-hàng-việc-theo-trạm-thanh-toán). Báo cáo doanh thu vì thế phải cộng từ cả hai nguồn.

## 2.2 Migration 1 — Menu

`code/be/migrations/000001_menu.up.sql`:

```sql
CREATE TABLE categories (
  id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name        VARCHAR(120) NOT NULL,
  slug        VARCHAR(140) NOT NULL UNIQUE,
  sort_order  INT NOT NULL DEFAULT 0,
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE products (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  category_id   BIGINT UNSIGNED NOT NULL,
  name          VARCHAR(200) NOT NULL,
  slug          VARCHAR(220) NOT NULL UNIQUE,
  description   TEXT,
  image_url     VARCHAR(500),
  base_price    INT UNSIGNED NOT NULL,          -- VND. Với món có nhân: đây là GIÁ CHAY
  unit          VARCHAR(30) NOT NULL DEFAULT 'suất',  -- 'suất', 'chiếc'
  is_combo      BOOLEAN NOT NULL DEFAULT FALSE,
  is_available  BOOLEAN NOT NULL DEFAULT TRUE,
  is_featured   BOOLEAN NOT NULL DEFAULT FALSE,
  sort_order    INT NOT NULL DEFAULT 0,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(id),
  INDEX idx_products_category (category_id, is_available, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Nhóm tuỳ chọn: "Nhân", "Lượng nhân"
CREATE TABLE product_option_groups (
  id           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  product_id   BIGINT UNSIGNED NOT NULL,
  name         VARCHAR(120) NOT NULL,
  code         VARCHAR(40)  NOT NULL,          -- 'nhan', 'luong_nhan'
  min_select   TINYINT UNSIGNED NOT NULL DEFAULT 1,
  max_select   TINYINT UNSIGNED NOT NULL DEFAULT 1,
  -- Nhóm này chỉ hiện khi option dưới đây được chọn (NULL = luôn hiện).
  -- Dùng cho luật: "Lượng nhân" chỉ hiện khi Nhân != Chay.
  depends_on_option_id BIGINT UNSIGNED NULL,
  sort_order   INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_optgroup_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  UNIQUE KEY uq_optgroup_product_code (product_id, code),
  INDEX idx_optgroup_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE product_options (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  group_id      BIGINT UNSIGNED NOT NULL,
  name          VARCHAR(120) NOT NULL,          -- 'Chay', 'Thịt', 'Thịt + mộc nhĩ'
  code          VARCHAR(40)  NOT NULL,          -- 'chay', 'thit', 'thit_mocnhi'
  price_delta   INT NOT NULL DEFAULT 0,
  is_default    BOOLEAN NOT NULL DEFAULT FALSE,
  is_available  BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order    INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_option_group FOREIGN KEY (group_id) REFERENCES product_option_groups(id) ON DELETE CASCADE,
  UNIQUE KEY uq_option_group_code (group_id, code),
  INDEX idx_option_group (group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE product_option_groups
  ADD CONSTRAINT fk_optgroup_depends
  FOREIGN KEY (depends_on_option_id) REFERENCES product_options(id) ON DELETE SET NULL;

-- Thành phần combo: "Đầy đủ chín" = 3 bánh cuốn + 1 trứng chín + 1 giò
CREATE TABLE product_components (
  id                    BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  combo_product_id      BIGINT UNSIGNED NOT NULL,
  component_product_id  BIGINT UNSIGNED NOT NULL,
  quantity              SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  -- Thành phần này có nhận tuỳ chọn nhân của combo không?
  -- 3 bánh cuốn + 1 trứng = TRUE. Giò = FALSE.
  inherits_options      BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order            INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_comp_combo     FOREIGN KEY (combo_product_id)     REFERENCES products(id) ON DELETE CASCADE,
  CONSTRAINT fk_comp_component FOREIGN KEY (component_product_id) REFERENCES products(id),
  INDEX idx_comp_combo (combo_product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Món này đi qua những trạm nào, theo thứ tự nào
CREATE TABLE product_stations (
  id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  product_id  BIGINT UNSIGNED NOT NULL,
  station     ENUM('quay','trang_banh','gap_banh','canh','don_ban') NOT NULL,
  step_order  TINYINT UNSIGNED NOT NULL DEFAULT 1,
  CONSTRAINT fk_prodstation_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  UNIQUE KEY uq_prodstation (product_id, station)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## 2.3 Migration 2 — Bàn, phiên bàn, nhân viên

`code/be/migrations/000002_tables_staff.up.sql`:

```sql
CREATE TABLE tables (
  id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name        VARCHAR(40) NOT NULL UNIQUE,     -- 'Bàn 1', 'Bàn 2', 'Vỉa hè 1'
  qr_token    CHAR(32) NOT NULL UNIQUE,        -- random, KHÔNG phải số bàn
  seats       TINYINT UNSIGNED NOT NULL DEFAULT 4,
  status      ENUM('free','occupied','needs_cleaning') NOT NULL DEFAULT 'free',
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order  INT NOT NULL DEFAULT 0,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE staff (
  id             BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  username       VARCHAR(80) NOT NULL UNIQUE,
  password_hash  VARCHAR(255) NOT NULL,        -- bcrypt
  full_name      VARCHAR(150) NOT NULL,
  role           ENUM('owner','quay','trang_banh','gap_banh','canh','don_ban') NOT NULL,
  pin_code       CHAR(60),                     -- bcrypt của mã PIN 4 số, đăng nhập nhanh trên tablet
  is_active      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Phiên bàn = 1 lượt khách ngồi = 1 hoá đơn, gom nhiều lượt gọi món
CREATE TABLE table_sessions (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  table_id        BIGINT UNSIGNED NOT NULL,
  code            VARCHAR(24) NOT NULL UNIQUE,   -- 'B05-260810-01'
  status          ENUM('open','billing','closed','cancelled') NOT NULL DEFAULT 'open',
  guest_count     TINYINT UNSIGNED NOT NULL DEFAULT 1,
  subtotal        INT UNSIGNED NOT NULL DEFAULT 0,   -- cache, tính lại mỗi lần thêm đơn
  discount        INT UNSIGNED NOT NULL DEFAULT 0,
  total           INT UNSIGNED NOT NULL DEFAULT 0,
  opened_by       BIGINT UNSIGNED,               -- NULL nếu khách tự quét QR mở phiên
  closed_by       BIGINT UNSIGNED,
  opened_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  closed_at       TIMESTAMP NULL,
  CONSTRAINT fk_session_table  FOREIGN KEY (table_id)  REFERENCES tables(id),
  CONSTRAINT fk_session_opener FOREIGN KEY (opened_by) REFERENCES staff(id),
  CONSTRAINT fk_session_closer FOREIGN KEY (closed_by) REFERENCES staff(id),
  INDEX idx_session_table_status (table_id, status),
  INDEX idx_session_opened (opened_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Mỗi bàn chỉ được có TỐI ĐA 1 phiên CHƯA THANH TOÁN XONG.
-- MySQL không có partial unique index, nên dùng cột sinh (generated column).
-- Phải tính cả 'billing', KHÔNG chỉ 'open' — xem cảnh báo bên dưới.
ALTER TABLE table_sessions
  ADD COLUMN open_key BIGINT UNSIGNED
    GENERATED ALWAYS AS (IF(status IN ('open','billing'), table_id, NULL)) STORED,
  ADD UNIQUE KEY uq_session_one_open (open_key);
```

> Cột `open_key` là mẹo quan trọng: nó khiến **database tự chặn** việc mở 2 phiên trên cùng một bàn. Nếu chỉ kiểm tra bằng code Go, hai nhân viên bấm cùng lúc sẽ tạo ra 2 phiên và hoá đơn sẽ bị tách đôi.

> ⚠️ **Vì sao phải là `IN ('open','billing')` chứ không phải `= 'open'`:**
> `status` có 4 giá trị. Nếu cột sinh chỉ nhìn `'open'`, thì ngay khi quầy bấm thu tiền (`open → billing`), `open_key` thành `NULL` và **ràng buộc UNIQUE nhả ra** — mở được phiên thứ hai trên đúng bàn đó.
>
> Kịch bản thật: 7h30, quầy đang tính tiền bàn 5. Khách bàn 5 quét QR gọi thêm một suất → hệ thống mở phiên mới → suất đó rơi vào hoá đơn thứ hai mà không ai để ý → **thu thiếu tiền**, đúng lỗi mà `open_key` sinh ra để chống.

**Quy tắc nghiệp vụ đi kèm:** bàn đang `billing` thì **khoá gọi thêm món**. FE bàn hiện *"Quầy đang tính tiền — muốn gọi thêm xin báo nhân viên"*. Nếu khách vẫn muốn gọi tiếp, quầy đưa phiên `billing → open` trở lại rồi mới gọi. Không có đường nào khác để thêm món vào phiên đang thanh toán.

Test bắt buộc: mở phiên bàn 5 → chuyển `billing` → thử mở phiên thứ hai trên bàn 5 → phải lỗi duplicate key.
Đã viết: `TestOpenKeyChanPhienThuHaiKhiBanDangBilling` trong
[code/be/internal/store/session_openkey_integration_test.go](../../code/be/internal/store/session_openkey_integration_test.go)
— chạy bằng `make test-int TEST_DB_DSN=…`.

> **Trong repo thật**, `open_key` được tạo *inline* ở [000002](../../code/be/migrations/000002_tables_staff.up.sql) với
> bản cũ (`= 'open'`, có lỗi), rồi vá bằng [000004_fix_open_key](../../code/be/migrations/000004_fix_open_key.up.sql).
> Đoạn `ALTER` ở trên là cách viết gọn cho người đọc lần đầu — muốn biết schema đang chạy thì đọc 000004.

## 2.4 Migration 3 — Đơn hàng, việc theo trạm, thanh toán

`code/be/migrations/000003_orders.up.sql`:

```sql
CREATE TABLE orders (
  id                BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  code              VARCHAR(24) NOT NULL UNIQUE,   -- 'BC260810-0007'
  channel           ENUM('web','qr_table','staff_pos') NOT NULL,
  fulfillment       ENUM('delivery','pickup','dine_in') NOT NULL,

  -- Ăn tại bàn
  table_session_id  BIGINT UNSIGNED NULL,
  created_by_staff  BIGINT UNSIGNED NULL,          -- NULL nếu khách tự đặt

  -- Ship / pickup
  customer_name     VARCHAR(150),
  customer_phone    VARCHAR(20),
  address_line      VARCHAR(500),
  pickup_at         DATETIME NULL,                 -- giờ hẹn lấy, phải trong 06:00–11:00

  note              TEXT,
  status            ENUM('pending','confirmed','preparing','ready','served',
                         'delivering','completed','cancelled') NOT NULL DEFAULT 'pending',
  subtotal          INT UNSIGNED NOT NULL,
  shipping_fee      INT UNSIGNED NOT NULL DEFAULT 0,
  discount          INT UNSIGNED NOT NULL DEFAULT 0,
  total             INT UNSIGNED NOT NULL,
  cancel_reason     VARCHAR(300),
  created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_order_session FOREIGN KEY (table_session_id) REFERENCES table_sessions(id),
  CONSTRAINT fk_order_staff   FOREIGN KEY (created_by_staff) REFERENCES staff(id),

  -- Đơn tại bàn BẮT BUỘC có phiên bàn; đơn ship BẮT BUỘC có SĐT
  CONSTRAINT chk_order_dinein
    CHECK ( (fulfillment = 'dine_in' AND table_session_id IS NOT NULL)
         OR (fulfillment <> 'dine_in' AND customer_phone IS NOT NULL) ),

  INDEX idx_orders_status_created (status, created_at),
  INDEX idx_orders_session (table_session_id),
  INDEX idx_orders_phone (customer_phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE order_items (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  order_id        BIGINT UNSIGNED NOT NULL,
  product_id      BIGINT UNSIGNED,
  product_name    VARCHAR(200)  NOT NULL,        -- SNAPSHOT
  is_combo        BOOLEAN NOT NULL DEFAULT FALSE,
  base_price      INT UNSIGNED  NOT NULL,        -- SNAPSHOT
  options_price   INT UNSIGNED  NOT NULL DEFAULT 0,
  unit_price      INT UNSIGNED  NOT NULL,        -- base_price + options_price
  quantity        SMALLINT UNSIGNED NOT NULL,
  line_total      INT UNSIGNED  NOT NULL,        -- unit_price * quantity
  note            VARCHAR(300),                  -- 'ít hành', 'không rau'
  CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  INDEX idx_items_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE order_item_options (
  id             BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  order_item_id  BIGINT UNSIGNED NOT NULL,
  group_name     VARCHAR(120) NOT NULL,          -- SNAPSHOT 'Nhân'
  option_name    VARCHAR(120) NOT NULL,          -- SNAPSHOT 'Thịt + mộc nhĩ'
  price_delta    INT NOT NULL DEFAULT 0,         -- SNAPSHOT
  CONSTRAINT fk_itemopt_item FOREIGN KEY (order_item_id) REFERENCES order_items(id) ON DELETE CASCADE,
  INDEX idx_itemopt_item (order_item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Việc của từng trạm. Combo được "nổ" thành nhiều task theo product_components.
CREATE TABLE order_tasks (
  id             BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  order_id       BIGINT UNSIGNED NOT NULL,
  order_item_id  BIGINT UNSIGNED NULL,           -- NULL với task cấp đơn (vd: lấy canh)
  station        ENUM('quay','trang_banh','gap_banh','canh','don_ban') NOT NULL,
  step_order     TINYINT UNSIGNED NOT NULL DEFAULT 1,
  label          VARCHAR(300) NOT NULL,          -- 'Bánh cuốn × 3 — thịt+mộc nhĩ, nhiều nhân'
  quantity       SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  status         ENUM('todo','doing','done','cancelled') NOT NULL DEFAULT 'todo',
  assigned_to    BIGINT UNSIGNED NULL,
  started_at     TIMESTAMP NULL,
  done_at        TIMESTAMP NULL,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_task_order    FOREIGN KEY (order_id)      REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_task_item     FOREIGN KEY (order_item_id) REFERENCES order_items(id) ON DELETE CASCADE,
  CONSTRAINT fk_task_assignee FOREIGN KEY (assigned_to)   REFERENCES staff(id),
  INDEX idx_task_station_status (station, status, created_at),
  INDEX idx_task_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE payments (
  id                BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  order_id          BIGINT UNSIGNED NULL,        -- thanh toán cho đơn ship/pickup
  table_session_id  BIGINT UNSIGNED NULL,        -- thanh toán cho phiên bàn
  method            ENUM('cash','bank_transfer') NOT NULL,
  amount            INT UNSIGNED NOT NULL,
  status            ENUM('pending','paid','failed','refunded') NOT NULL DEFAULT 'pending',
  reference         VARCHAR(120),                -- nội dung chuyển khoản
  received_by       BIGINT UNSIGNED NULL,
  paid_at           TIMESTAMP NULL,
  created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pay_order    FOREIGN KEY (order_id)         REFERENCES orders(id),
  CONSTRAINT fk_pay_session  FOREIGN KEY (table_session_id) REFERENCES table_sessions(id),
  CONSTRAINT fk_pay_staff    FOREIGN KEY (received_by)      REFERENCES staff(id),
  -- đúng MỘT trong hai phải khác NULL
  CONSTRAINT chk_pay_target CHECK (
    (order_id IS NOT NULL) + (table_session_id IS NOT NULL) = 1
  ),
  INDEX idx_pay_session (table_session_id),
  INDEX idx_pay_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE order_status_history (
  id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  order_id    BIGINT UNSIGNED NOT NULL,
  from_status VARCHAR(20),
  to_status   VARCHAR(20) NOT NULL,
  changed_by  BIGINT UNSIGNED NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_history_order FOREIGN KEY (order_id)   REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_history_staff FOREIGN KEY (changed_by) REFERENCES staff(id),
  INDEX idx_history_order (order_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE store_settings (
  id                  TINYINT UNSIGNED PRIMARY KEY DEFAULT 1,
  store_name          VARCHAR(200) NOT NULL DEFAULT 'Bánh cuốn Bà Thanh Cao Bằng',
  hotline             VARCHAR(20),
  address             VARCHAR(500),
  logo_url            VARCHAR(500),
  is_accepting_orders BOOLEAN NOT NULL DEFAULT TRUE,   -- nút tạm dừng thủ công
  open_time           TIME NOT NULL DEFAULT '06:00:00',
  close_time          TIME NOT NULL DEFAULT '11:00:00',
  min_order_amount    INT UNSIGNED NOT NULL DEFAULT 0,
  default_ship_fee    INT UNSIGNED NOT NULL DEFAULT 0, -- quán đang MIỄN PHÍ SHIP
  free_ship_threshold INT UNSIGNED NOT NULL DEFAULT 0, -- 0 = không dùng ngưỡng
  bank_name           VARCHAR(120),
  bank_account_no     VARCHAR(40),
  bank_account_name   VARCHAR(150),
  updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT chk_settings_singleton CHECK (id = 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## 2.5 Dữ liệu seed — menu thật của quán

`code/be/migrations/seed.sql`:

```sql
INSERT INTO categories (id, name, slug, sort_order) VALUES
  (1, 'Bánh cuốn', 'banh-cuon', 1),
  (2, 'Ăn kèm',    'an-kem',    2),
  (3, 'Combo',     'combo',     3);

-- base_price = GIÁ CHAY. Nhân và lượng nhân cộng thêm bằng option.
INSERT INTO products (id, category_id, name, slug, base_price, unit, is_combo, sort_order) VALUES
  (1, 1, 'Bánh cuốn',  'banh-cuon',   3000, 'suất',  FALSE, 1),
  (2, 1, 'Trứng chín', 'trung-chin',  8000, 'suất',  FALSE, 2),
  (3, 1, 'Trứng tái',  'trung-tai',   8000, 'suất',  FALSE, 3),
  (4, 1, 'Trứng vàng', 'trung-vang',  8000, 'suất',  FALSE, 4),
  (5, 2, 'Giò',        'gio',         9000, 'chiếc', FALSE, 1),
  -- Combo: 3 bánh cuốn + 1 trứng + 1 giò.
  -- base_price = giá CHAY = 3×3.000 + 8.000 + 9.000 = 26.000
  -- + nhân (4 phần × 1.000)      = 30.000  ← khớp giá lẻ
  -- + nhiều nhân (4 phần × 1.000) = 34.000
  (6, 3, 'Đầy đủ trứng chín', 'day-du-trung-chin', 26000, 'suất', TRUE, 1),
  (7, 3, 'Đầy đủ trứng tái',  'day-du-trung-tai',  26000, 'suất', TRUE, 2),
  (8, 3, 'Đầy đủ trứng vàng', 'day-du-trung-vang', 26000, 'suất', TRUE, 3);

-- Thành phần combo
INSERT INTO product_components (combo_product_id, component_product_id, quantity, inherits_options, sort_order) VALUES
  (6, 1, 3, TRUE,  1), (6, 2, 1, TRUE,  2), (6, 5, 1, FALSE, 3),
  (7, 1, 3, TRUE,  1), (7, 3, 1, TRUE,  2), (7, 5, 1, FALSE, 3),
  (8, 1, 3, TRUE,  1), (8, 4, 1, TRUE,  2), (8, 5, 1, FALSE, 3);

-- Nhóm "Nhân" cho món lẻ (bánh cuốn + 3 loại trứng): phụ thu 1.000
INSERT INTO product_option_groups (id, product_id, name, code, min_select, max_select, sort_order) VALUES
  (1, 1, 'Nhân', 'nhan', 1, 1, 1),
  (2, 2, 'Nhân', 'nhan', 1, 1, 1),
  (3, 3, 'Nhân', 'nhan', 1, 1, 1),
  (4, 4, 'Nhân', 'nhan', 1, 1, 1),
  -- Combo: phụ thu ×4 vì có 4 phần nhận nhân
  (5, 6, 'Nhân', 'nhan', 1, 1, 1),
  (6, 7, 'Nhân', 'nhan', 1, 1, 1),
  (7, 8, 'Nhân', 'nhan', 1, 1, 1);

INSERT INTO product_options (id, group_id, name, code, price_delta, is_default, sort_order) VALUES
  -- món lẻ: +1.000
  (1,  1, 'Chay',            'chay',        0,    TRUE,  1),
  (2,  1, 'Thịt',            'thit',        1000, FALSE, 2),
  (3,  1, 'Thịt + mộc nhĩ',  'thit_mocnhi', 1000, FALSE, 3),
  (4,  2, 'Chay',            'chay',        0,    TRUE,  1),
  (5,  2, 'Thịt',            'thit',        1000, FALSE, 2),
  (6,  2, 'Thịt + mộc nhĩ',  'thit_mocnhi', 1000, FALSE, 3),
  (7,  3, 'Chay',            'chay',        0,    TRUE,  1),
  (8,  3, 'Thịt',            'thit',        1000, FALSE, 2),
  (9,  3, 'Thịt + mộc nhĩ',  'thit_mocnhi', 1000, FALSE, 3),
  (10, 4, 'Chay',            'chay',        0,    TRUE,  1),
  (11, 4, 'Thịt',            'thit',        1000, FALSE, 2),
  (12, 4, 'Thịt + mộc nhĩ',  'thit_mocnhi', 1000, FALSE, 3),
  -- combo: +4.000 (4 phần)
  (13, 5, 'Chay',            'chay',        0,    FALSE, 1),
  (14, 5, 'Thịt',            'thit',        4000, TRUE,  2),
  (15, 5, 'Thịt + mộc nhĩ',  'thit_mocnhi', 4000, FALSE, 3),
  (16, 6, 'Chay',            'chay',        0,    FALSE, 1),
  (17, 6, 'Thịt',            'thit',        4000, TRUE,  2),
  (18, 6, 'Thịt + mộc nhĩ',  'thit_mocnhi', 4000, FALSE, 3),
  (19, 7, 'Chay',            'chay',        0,    FALSE, 1),
  (20, 7, 'Thịt',            'thit',        4000, TRUE,  2),
  (21, 7, 'Thịt + mộc nhĩ',  'thit_mocnhi', 4000, FALSE, 3);

-- Nhóm "Lượng nhân" — CHỈ hiện khi đã chọn Thịt (không hiện khi Chay).
-- depends_on_option_id trỏ tới option 'Thịt' của cùng món.
-- (Với 'Thịt + mộc nhĩ' cần thêm luật ở tầng service — xem mục 3.3.)
INSERT INTO product_option_groups (id, product_id, name, code, min_select, max_select, depends_on_option_id, sort_order) VALUES
  (8,  1, 'Lượng nhân', 'luong_nhan', 1, 1, 2,  2),
  (9,  2, 'Lượng nhân', 'luong_nhan', 1, 1, 5,  2),
  (10, 3, 'Lượng nhân', 'luong_nhan', 1, 1, 8,  2),
  (11, 4, 'Lượng nhân', 'luong_nhan', 1, 1, 11, 2),
  (12, 6, 'Lượng nhân', 'luong_nhan', 1, 1, 14, 2),
  (13, 7, 'Lượng nhân', 'luong_nhan', 1, 1, 17, 2),
  (14, 8, 'Lượng nhân', 'luong_nhan', 1, 1, 20, 2);

INSERT INTO product_options (group_id, name, code, price_delta, is_default, sort_order) VALUES
  (8,  'Thường',     'thuong', 0,    TRUE,  1), (8,  'Nhiều nhân', 'nhieu', 1000, FALSE, 2),
  (9,  'Thường',     'thuong', 0,    TRUE,  1), (9,  'Nhiều nhân', 'nhieu', 1000, FALSE, 2),
  (10, 'Thường',     'thuong', 0,    TRUE,  1), (10, 'Nhiều nhân', 'nhieu', 1000, FALSE, 2),
  (11, 'Thường',     'thuong', 0,    TRUE,  1), (11, 'Nhiều nhân', 'nhieu', 1000, FALSE, 2),
  (12, 'Thường',     'thuong', 0,    TRUE,  1), (12, 'Nhiều nhân', 'nhieu', 4000, FALSE, 2),
  (13, 'Thường',     'thuong', 0,    TRUE,  1), (13, 'Nhiều nhân', 'nhieu', 4000, FALSE, 2),
  (14, 'Thường',     'thuong', 0,    TRUE,  1), (14, 'Nhiều nhân', 'nhieu', 4000, FALSE, 2);

-- Định tuyến trạm
INSERT INTO product_stations (product_id, station, step_order) VALUES
  (1, 'trang_banh', 1), (1, 'gap_banh', 2),
  (2, 'trang_banh', 1), (2, 'gap_banh', 2),
  (3, 'trang_banh', 1), (3, 'gap_banh', 2),
  (4, 'trang_banh', 1), (4, 'gap_banh', 2),
  (5, 'gap_banh',   1);                       -- giò: chỉ cắt & xếp đĩa

-- Thông tin quán. Số tài khoản ngân hàng điền sau ở Admin › Cài đặt.
INSERT INTO store_settings
  (id, store_name, hotline, address, open_time, close_time,
   default_ship_fee, free_ship_threshold, min_order_amount)
VALUES
  (1, 'Bánh cuốn Bà Thanh Cao Bằng', '0382688666', '14B6 ngõ 332',
   '06:00:00', '11:00:00', 0, 0, 0);   -- ship miễn phí

-- 11 bàn. qr_token phải RANDOM — dùng lệnh create-tables ở mục 3.6 để sinh.
INSERT INTO tables (name, qr_token, seats, sort_order) VALUES
  ('Bàn 1',  REPLACE(UUID(), '-', ''), 4, 1),
  ('Bàn 2',  REPLACE(UUID(), '-', ''), 4, 2),
  ('Bàn 3',  REPLACE(UUID(), '-', ''), 4, 3),
  ('Bàn 4',  REPLACE(UUID(), '-', ''), 4, 4),
  ('Bàn 5',  REPLACE(UUID(), '-', ''), 4, 5),
  ('Bàn 6',  REPLACE(UUID(), '-', ''), 4, 6),
  ('Bàn 7',  REPLACE(UUID(), '-', ''), 4, 7),
  ('Bàn 8',  REPLACE(UUID(), '-', ''), 4, 8),
  ('Bàn 9',  REPLACE(UUID(), '-', ''), 4, 9),
  ('Bàn 10', REPLACE(UUID(), '-', ''), 4, 10),
  ('Bàn 11', REPLACE(UUID(), '-', ''), 4, 11);
```

## 2.6 Bốn quy tắc phải nhớ

1. **Tiền lưu bằng `INT` (VND), tuyệt đối không `FLOAT`.** Với giá 3.000đ–34.000đ thì `INT` thừa sức.
2. **`utf8mb4_unicode_ci`** cho mọi bảng — `utf8` (3 byte) sẽ lỗi tiếng Việt và emoji.
3. **Snapshot tên + giá vào `order_items` / `order_item_options`.** Tăng giá bánh cuốn từ 3k lên 4k mà không snapshot → toàn bộ đơn cũ hiện sai giá, báo cáo doanh thu sai theo.
4. **Migration chỉ thêm mới.** Muốn đổi cột → tạo file `000004_...` mới, không sửa file đã chạy.

Bốn quy tắc này còn được nhắc ở [02-luat.md §1](02-luat.md) kèm lý do vi phạm sẽ hỏng cái gì.
