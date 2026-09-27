-- P2-05 — lát menu · giá · ảnh chụp giá lúc đặt.
-- Ý định, lý do và ánh xạ I-0xx: docs/product/2-db/03-luoc-do-menu-gia.md.
-- File này thắng về tên · kiểu · ràng buộc (docs/decisions.md ADR-053 luật 2).
-- Quy ước: docs/product/2-db/01-quy-uoc-du-lieu.md (QD-XX) · 10-quy-uoc-code.md (QC-XX).
-- Không một con giá nào ở đây: giá thật ở master_plan/shop-facts.md §4.2 · §4.4.

-- ---------------------------------------------------------------------------
-- Menu hiện hành
-- ---------------------------------------------------------------------------

-- Thành phần có giá (§4.2). Giá gốc là giá CHAY (§4.6 luật 2); nhân là phụ thu.
CREATE TABLE menu_component (
  id             bigint GENERATED ALWAYS AS IDENTITY,
  name           text COLLATE "vi-x-icu" NOT NULL,
  base_price_vnd bigint NOT NULL,
  -- Phần này có nhận tuỳ chọn nhân không (§4.5 cột cuối, §4.6 luật 5 · 6).
  takes_filling  boolean NOT NULL,
  created_at     timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT menu_component_pkey PRIMARY KEY (id),
  CONSTRAINT menu_component_name_key UNIQUE (name),
  CONSTRAINT menu_component_name_not_blank_check CHECK (btrim(name) <> ''),
  CONSTRAINT menu_component_base_price_non_negative_check CHECK (base_price_vnd >= 0)
);

-- Một dòng menu (§4.9). Ngừng bán là một MỐC, không phải một lệnh xoá (QD-50).
CREATE TABLE menu_item (
  id              bigint GENERATED ALWAYS AS IDENTITY,
  name            text COLLATE "vi-x-icu" NOT NULL,
  discontinued_at timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT menu_item_pkey PRIMARY KEY (id),
  CONSTRAINT menu_item_name_key UNIQUE (name),
  CONSTRAINT menu_item_name_not_blank_check CHECK (btrim(name) <> '')
);

-- Thành phần của một suất (§4.5): bếp làm ra gì, bao nhiêu. Giá suất KHÔNG cất:
-- nó là tổng giá thành phần (§4.6 luật 1), và số phần nhận nhân đọc ra từ đây.
CREATE TABLE menu_item_component (
  id                bigint GENERATED ALWAYS AS IDENTITY,
  menu_item_id      bigint NOT NULL,
  menu_component_id bigint NOT NULL,
  quantity          integer NOT NULL,
  created_at        timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT menu_item_component_pkey PRIMARY KEY (id),
  CONSTRAINT menu_item_component_menu_item_fkey
    FOREIGN KEY (menu_item_id) REFERENCES menu_item (id),
  CONSTRAINT menu_item_component_menu_component_fkey
    FOREIGN KEY (menu_component_id) REFERENCES menu_component (id),
  CONSTRAINT menu_item_component_once_key UNIQUE (menu_item_id, menu_component_id),
  CONSTRAINT menu_item_component_quantity_positive_check CHECK (quantity > 0)
);

-- Nhóm tuỳ chọn DÙNG CHUNG (§4.4): một nhóm, nhiều suất — không khai lại mỗi suất.
CREATE TABLE option_group (
  id         bigint GENERATED ALWAYS AS IDENTITY,
  name       text COLLATE "vi-x-icu" NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT option_group_pkey PRIMARY KEY (id),
  CONSTRAINT option_group_name_key UNIQUE (name),
  CONSTRAINT option_group_name_not_blank_check CHECK (btrim(name) <> '')
);

-- Một lựa chọn trong nhóm. surcharge_vnd là phụ thu cho MỖI phần nhận nhân
-- (§4.6 luật 5): cất một lần; hệ số ×1 · ×4 · ×5 là hệ quả, không cất ở đâu.
CREATE TABLE menu_option (
  id              bigint GENERATED ALWAYS AS IDENTITY,
  option_group_id bigint NOT NULL,
  name            text COLLATE "vi-x-icu" NOT NULL,
  surcharge_vnd   bigint NOT NULL,
  created_at      timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT menu_option_pkey PRIMARY KEY (id),
  CONSTRAINT menu_option_option_group_fkey
    FOREIGN KEY (option_group_id) REFERENCES option_group (id),
  CONSTRAINT menu_option_name_in_group_key UNIQUE (option_group_id, name),
  CONSTRAINT menu_option_name_not_blank_check CHECK (btrim(name) <> ''),
  CONSTRAINT menu_option_surcharge_non_negative_check CHECK (surcharge_vnd >= 0)
);

-- Suất nào mang nhóm nào. Suất không có dòng nào ở đây thì không hiện nhóm nào
-- (§4.8 ca 12 · 13).
CREATE TABLE menu_item_option_group (
  id              bigint GENERATED ALWAYS AS IDENTITY,
  menu_item_id    bigint NOT NULL,
  option_group_id bigint NOT NULL,
  created_at      timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT menu_item_option_group_pkey PRIMARY KEY (id),
  CONSTRAINT menu_item_option_group_menu_item_fkey
    FOREIGN KEY (menu_item_id) REFERENCES menu_item (id),
  CONSTRAINT menu_item_option_group_option_group_fkey
    FOREIGN KEY (option_group_id) REFERENCES option_group (id),
  CONSTRAINT menu_item_option_group_once_key UNIQUE (menu_item_id, option_group_id)
);

-- I-010 · §4.6 luật 3, cất theo TẬP: nhóm chỉ tồn tại khi ÍT NHẤT MỘT lựa chọn
-- trong tập này được chọn. Nhóm không có dòng nào ở đây thì luôn tồn tại.
-- "Lượng nhân khi nhân ≠ Chay" = hai dòng (Thịt, Thịt + mộc nhĩ), không một
-- tham chiếu tới một lựa chọn duy nhất.
CREATE TABLE option_group_prerequisite (
  id              bigint GENERATED ALWAYS AS IDENTITY,
  option_group_id bigint NOT NULL,
  menu_option_id  bigint NOT NULL,
  created_at      timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT option_group_prerequisite_pkey PRIMARY KEY (id),
  CONSTRAINT option_group_prerequisite_option_group_fkey
    FOREIGN KEY (option_group_id) REFERENCES option_group (id),
  CONSTRAINT option_group_prerequisite_menu_option_fkey
    FOREIGN KEY (menu_option_id) REFERENCES menu_option (id),
  CONSTRAINT option_group_prerequisite_once_key UNIQUE (option_group_id, menu_option_id)
);

-- ---------------------------------------------------------------------------
-- Ảnh chụp lúc đặt (I-009 tầng 1) — đọc lại một đơn cũ không chạm menu hiện hành
-- ---------------------------------------------------------------------------

-- Dòng đơn của P2-04 nhận: món (mã gốc + tên đã chụp), giá dòng đã khoá, mốc
-- khoá giá, và số dòng ảnh chụp thành phần nó phải có.
ALTER TABLE order_line
  ADD COLUMN menu_item_id    bigint NOT NULL,
  ADD COLUMN item_name       text COLLATE "vi-x-icu" NOT NULL,
  ADD COLUMN unit_price_vnd  bigint NOT NULL,
  -- QD-22: thành tiền tự tính, không ghi tay được.
  ADD COLUMN line_total_vnd  bigint GENERATED ALWAYS AS (unit_price_vnd * quantity) STORED,
  -- Mốc khoá giá của RIÊNG dòng này: lúc tạo lượt gọi, đặt lại khi người sửa
  -- dòng (U-026, shop-facts §6.19).
  ADD COLUMN priced_at       timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN component_count integer NOT NULL,
  ADD CONSTRAINT order_line_menu_item_fkey
    FOREIGN KEY (menu_item_id) REFERENCES menu_item (id),
  ADD CONSTRAINT order_line_item_name_not_blank_check CHECK (btrim(item_name) <> ''),
  ADD CONSTRAINT order_line_unit_price_non_negative_check CHECK (unit_price_vnd >= 0),
  ADD CONSTRAINT order_line_line_total_non_negative_check CHECK (line_total_vnd >= 0),
  ADD CONSTRAINT order_line_component_count_positive_check CHECK (component_count > 0),
  -- Đích của khoá ngoại hai cột ở order_line_component.
  ADD CONSTRAINT order_line_id_component_count_key UNIQUE (id, component_count);

-- Ảnh chụp một thành phần của suất trên dòng đơn: tên, số lượng, có nhận nhân
-- không, và giá gốc đã áp. Vị trí 1…n: ba khoá ngoại hoãn tới COMMIT buộc dòng
-- đơn có ĐÚNG component_count dòng ở đây, liền nhau từ 1 — thiếu một dòng thì
-- cả giao dịch bị từ chối.
CREATE TABLE order_line_component (
  id                   bigint GENERATED ALWAYS AS IDENTITY,
  order_line_id        bigint NOT NULL,
  position             integer NOT NULL,
  -- Bản soi của order_line.component_count; khoá ngoại hai cột buộc bằng nhau.
  line_component_count integer NOT NULL,
  previous_position    integer GENERATED ALWAYS AS (NULLIF(position - 1, 0)) STORED,
  menu_component_id    bigint NOT NULL,
  component_name       text COLLATE "vi-x-icu" NOT NULL,
  quantity             integer NOT NULL,
  takes_filling        boolean NOT NULL,
  base_price_vnd       bigint NOT NULL,
  created_at           timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT order_line_component_pkey PRIMARY KEY (id),
  CONSTRAINT order_line_component_line_fkey
    FOREIGN KEY (order_line_id, line_component_count)
    REFERENCES order_line (id, component_count)
    DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT order_line_component_menu_component_fkey
    FOREIGN KEY (menu_component_id) REFERENCES menu_component (id),
  CONSTRAINT order_line_component_position_key UNIQUE (order_line_id, position),
  CONSTRAINT order_line_component_once_key UNIQUE (order_line_id, menu_component_id),
  -- Vị trí p > 1 cần vị trí p − 1: chuỗi liền, không lỗ.
  CONSTRAINT order_line_component_previous_position_fkey
    FOREIGN KEY (order_line_id, previous_position)
    REFERENCES order_line_component (order_line_id, position)
    DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT order_line_component_position_in_range_check
    CHECK (position BETWEEN 1 AND line_component_count),
  CONSTRAINT order_line_component_name_not_blank_check CHECK (btrim(component_name) <> ''),
  CONSTRAINT order_line_component_quantity_positive_check CHECK (quantity > 0),
  CONSTRAINT order_line_component_base_price_non_negative_check CHECK (base_price_vnd >= 0)
);

-- Vị trí thứ n phải có: cùng hai khoá trên, dòng đơn không thiếu ảnh chụp nào.
ALTER TABLE order_line
  ADD CONSTRAINT order_line_last_component_fkey
    FOREIGN KEY (id, component_count)
    REFERENCES order_line_component (order_line_id, position)
    DEFERRABLE INITIALLY DEFERRED;

-- Ảnh chụp một tuỳ chọn đã chọn: MÃ GỐC (khoá ngoại về lựa chọn) cạnh tên nhóm,
-- tên lựa chọn và mức phụ thu đã áp. Đổi tên hiển thị không làm gãy phép đếm.
CREATE TABLE order_line_option (
  id                bigint GENERATED ALWAYS AS IDENTITY,
  order_line_id     bigint NOT NULL,
  menu_option_id    bigint NOT NULL,
  option_group_name text COLLATE "vi-x-icu" NOT NULL,
  option_name       text COLLATE "vi-x-icu" NOT NULL,
  surcharge_vnd     bigint NOT NULL,
  created_at        timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT order_line_option_pkey PRIMARY KEY (id),
  CONSTRAINT order_line_option_order_line_fkey
    FOREIGN KEY (order_line_id) REFERENCES order_line (id),
  CONSTRAINT order_line_option_menu_option_fkey
    FOREIGN KEY (menu_option_id) REFERENCES menu_option (id),
  CONSTRAINT order_line_option_once_key UNIQUE (order_line_id, menu_option_id),
  CONSTRAINT order_line_option_group_name_not_blank_check CHECK (btrim(option_group_name) <> ''),
  CONSTRAINT order_line_option_name_not_blank_check CHECK (btrim(option_name) <> ''),
  CONSTRAINT order_line_option_surcharge_non_negative_check CHECK (surcharge_vnd >= 0)
);
