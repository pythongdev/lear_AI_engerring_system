-- P2-07 — lát sản xuất theo mẻ: trạm của thành phần · việc trạm (từng đơn vị) · mẻ · thứ mẻ
-- đã làm · lần chuyển phần đã làm xong của một đơn huỷ sang bàn khác.
-- Ý định, lý do và ánh xạ I-0xx/YC-xx: docs/product/2-db/05-luoc-do-san-xuat.md.
-- File này thắng về tên · kiểu · ràng buộc (docs/decisions.md ADR-053 luật 2).
-- Quy ước: docs/product/2-db/01-quy-uoc-du-lieu.md (QD-XX) · 10-quy-uoc-code.md (QC-XX).
--
-- KHÔNG có ô tổng nào ở lát này (I-019): đã gọi · còn phải làm · đã làm xong còn ở bếp · đã
-- bưng ra bàn · còn thiếu — của một bàn, một mẻ hay cả quán — đều cộng lại từ station_job.
-- "Ai bấm" chưa có cột: bảng người là của P2-08. Đơn vị bấm của mốc "đã bưng ra bàn" là S-5
-- (shop-facts §7.2, chưa hỏi) — cố ý KHÔNG có bản ghi nào cho một lần bấm ấy.

-- Đơn đã được duyệt chưa (I-004, vế tầng 1). Tự tính, không ghi tay được: trống khi đơn ở
-- Mới hoặc Chờ xác nhận — việc trạm không đứng tên được một đơn như thế.
ALTER TABLE sales_order
  ADD COLUMN id_if_approved bigint
    GENERATED ALWAYS AS (CASE WHEN status NOT IN ('new', 'pending_confirmation') THEN id END) STORED,
  ADD CONSTRAINT sales_order_id_if_approved_key UNIQUE (id_if_approved);

-- Đích của khoá ngoại ba cột ở station_job: số suất của dòng, số lượng thành phần trong suất.
ALTER TABLE order_line
  ADD CONSTRAINT order_line_id_order_quantity_key UNIQUE (id, sales_order_id, quantity);
ALTER TABLE order_line_component
  ADD CONSTRAINT order_line_component_id_line_quantity_key UNIQUE (id, order_line_id, quantity);

-- Việc của một thành phần xuống trạm nào (shop-facts §5.3 · §3): bánh cuốn xuống cả tráng lẫn
-- gấp, giò chỉ xuống gấp. Dữ liệu menu — P2-10 dựng bằng cách tra owner. Lần nổ đơn đọc bảng
-- này lúc duyệt; việc đã nổ mang trạm của chính nó, không đọc lại bảng này.
CREATE TABLE menu_component_station (
  id                bigint GENERATED ALWAYS AS IDENTITY,
  menu_component_id bigint NOT NULL,
  station_code      text NOT NULL,
  created_at        timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT menu_component_station_pkey PRIMARY KEY (id),
  CONSTRAINT menu_component_station_menu_component_fkey
    FOREIGN KEY (menu_component_id) REFERENCES menu_component (id),
  CONSTRAINT menu_component_station_once_key UNIQUE (menu_component_id, station_code),
  CONSTRAINT menu_component_station_station_code_check
    CHECK (station_code IN ('quay', 'trang_banh', 'gap_banh', 'canh', 'don_ban'))
);

-- Việc trạm, MỘT DÒNG MỘT ĐƠN VỊ: một cái bánh ở một trạm, một quả trứng, một chiếc giò, một bát
-- canh — hoặc phần nước chấm của một đơn (dòng CẤP ĐƠN: không dòng đơn, không thành phần). Việc
-- "Bánh cuốn ×6" của bảng bếp là sáu dòng cùng (thành phần đã chụp, trạm). Đơn vị là thứ một
-- mẻ chia về từng bàn (I-019 · YC-07) và thứ được đếm ≤ số đã gọi (I-020).
-- Chủ của đơn vị là đơn của nó; bàn của nó là bàn gửi đơn (sales_order.dining_table_id). Khoá
-- gom — thành phần + loại nhân + lượng nhân (03-lat-cat §3.4.6) — KHÔNG cất ở đây: nó đọc từ
-- ảnh chụp của dòng đơn (order_line_component · order_line_option), một nguồn.
CREATE TABLE station_job (
  id                      bigint GENERATED ALWAYS AS IDENTITY,
  sales_order_id          bigint NOT NULL,
  order_line_id           bigint,
  order_line_component_id bigint,
  station_code            text NOT NULL,
  -- Bản soi số suất của dòng và số lượng thành phần trong một suất; khoá ngoại nhiều cột buộc
  -- hai bản soi bằng bản gốc lúc COMMIT. Một (thành phần đã chụp, trạm) có nhiều nhất tích của
  -- hai số ấy đơn vị; phần nước chấm của một đơn, nhiều nhất một.
  line_quantity           integer,
  component_quantity      integer,
  unit_limit              integer GENERATED ALWAYS AS
    (CASE WHEN order_line_component_id IS NULL THEN 1
          ELSE line_quantity * component_quantity END) STORED,
  position                integer NOT NULL,
  status                  text NOT NULL DEFAULT 'pending',
  -- Đích và nguồn của khoá ngoại hai chiều với production_batch_item.
  id_if_made_or_served    bigint GENERATED ALWAYS AS
    (CASE WHEN status IN ('made', 'served') THEN id END) STORED,
  created_at              timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT station_job_pkey PRIMARY KEY (id),
  -- I-004 tầng 1: việc trạm chỉ đứng tên một đơn ĐÃ DUYỆT; và một đơn đã có việc không lùi
  -- về Mới / Chờ xác nhận được.
  CONSTRAINT station_job_sales_order_fkey
    FOREIGN KEY (sales_order_id) REFERENCES sales_order (id_if_approved),
  CONSTRAINT station_job_order_line_fkey
    FOREIGN KEY (order_line_id, sales_order_id, line_quantity)
    REFERENCES order_line (id, sales_order_id, quantity)
    DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT station_job_order_line_component_fkey
    FOREIGN KEY (order_line_component_id, order_line_id, component_quantity)
    REFERENCES order_line_component (id, order_line_id, quantity)
    DEFERRABLE INITIALLY DEFERRED,
  -- Dòng cấp thành phần mang đủ bốn cột; dòng nước chấm không mang cột nào.
  CONSTRAINT station_job_component_columns_check
    CHECK (num_nonnulls(order_line_id, order_line_component_id,
                        line_quantity, component_quantity) IN (0, 4)),
  CONSTRAINT station_job_station_code_check
    CHECK (station_code IN ('quay', 'trang_banh', 'gap_banh', 'canh', 'don_ban')),
  CONSTRAINT station_job_status_check CHECK (status IN ('pending', 'made', 'served')),
  -- I-020 tầng 1: đơn vị thứ p của một (thành phần đã chụp, trạm) chỉ có khi p ≤ số đã gọi.
  CONSTRAINT station_job_position_in_range_check CHECK (position BETWEEN 1 AND unit_limit),
  CONSTRAINT station_job_position_key UNIQUE (order_line_component_id, station_code, position),
  CONSTRAINT station_job_id_if_made_or_served_key UNIQUE (id_if_made_or_served)
);

-- I-020 tầng 1 cho nước chấm: mỗi đơn nhiều nhất MỘT phần (shop-facts §5.3, việc cấp đơn).
CREATE UNIQUE INDEX station_job_one_sauce_per_order_key
  ON station_job (sales_order_id)
  WHERE order_line_component_id IS NULL;

-- Mẻ: MỘT lần quầy bấm "đã làm xong" (chủ quán chốt 2026-09-01, U-017). Mẻ không mang con số
-- nào: nó làm ra đúng những đơn vị có dòng production_batch_item, và phần của từng bàn đọc từ
-- đó (YC-07). Không cất nồi hay tổ hợp nồi — máy không xếp nồi (04-yeu-cau-du-lieu §7).
-- Lùi một mẻ bấm nhầm là một MỐC trên chính mẻ, không phải lệnh xoá (QD-50): mẻ nào, lúc nào.
CREATE TABLE production_batch (
  id             bigint GENERATED ALWAYS AS IDENTITY,
  made_at        timestamptz NOT NULL DEFAULT now(),
  rolled_back_at timestamptz,
  is_rolled_back boolean GENERATED ALWAYS AS (rolled_back_at IS NOT NULL) STORED,
  created_at     timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT production_batch_pkey PRIMARY KEY (id),
  CONSTRAINT production_batch_rolled_back_after_made_check
    CHECK (rolled_back_at IS NULL OR rolled_back_at >= made_at),
  -- Đích của khoá ngoại hai cột ở production_batch_item.
  CONSTRAINT production_batch_id_rolled_back_key UNIQUE (id, is_rolled_back)
);

-- Một thứ một mẻ đã làm ra. made_for_station_job_id: đơn vị mẻ làm cho, lúc bấm — không đổi
-- (vai shop_app không sửa được cột ấy). station_job_id: chủ HIỆN TẠI của thứ đã làm — đổi khi
-- đơn chủ bị huỷ và quầy chọn bàn nhận (U-033), và chỉ đổi được kèm một vết ở
-- station_job_transfer.
CREATE TABLE production_batch_item (
  id                         bigint GENERATED ALWAYS AS IDENTITY,
  production_batch_id        bigint NOT NULL,
  made_for_station_job_id    bigint NOT NULL,
  station_job_id             bigint NOT NULL,
  -- Bản soi production_batch.is_rolled_back: lùi mẻ mà sót một thứ ⇒ không COMMIT được.
  batch_rolled_back          boolean NOT NULL DEFAULT false,
  live_station_job_id        bigint GENERATED ALWAYS AS
    (CASE WHEN NOT batch_rolled_back THEN station_job_id END) STORED,
  transferred_station_job_id bigint GENERATED ALWAYS AS
    (CASE WHEN station_job_id <> made_for_station_job_id THEN station_job_id END) STORED,
  created_at                 timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT production_batch_item_pkey PRIMARY KEY (id),
  -- I-020 tầng 2, đường lùi: mọi thứ của một mẻ cùng lùi, hoặc không thứ nào.
  CONSTRAINT production_batch_item_batch_fkey
    FOREIGN KEY (production_batch_id, batch_rolled_back)
    REFERENCES production_batch (id, is_rolled_back)
    DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT production_batch_item_made_for_station_job_fkey
    FOREIGN KEY (made_for_station_job_id) REFERENCES station_job (id),
  CONSTRAINT production_batch_item_station_job_fkey
    FOREIGN KEY (station_job_id) REFERENCES station_job (id),
  CONSTRAINT production_batch_item_once_key UNIQUE (production_batch_id, made_for_station_job_id),
  -- Một đơn vị giữ nhiều nhất MỘT thứ đã làm còn hiệu lực.
  CONSTRAINT production_batch_item_live_key UNIQUE (live_station_job_id),
  -- Thứ đã làm còn hiệu lực ⇒ đơn vị giữ nó đang "đã làm xong" hoặc "đã ra bàn".
  CONSTRAINT production_batch_item_live_station_job_fkey
    FOREIGN KEY (live_station_job_id) REFERENCES station_job (id_if_made_or_served)
    DEFERRABLE INITIALLY DEFERRED
);

-- Chiều ngược: đơn vị "đã làm xong" hoặc "đã ra bàn" ⇒ giữ đúng một thứ đã làm còn hiệu lực.
-- Cùng khoá trên, một lần bấm mẻ và một lần lùi mẻ là MỘT giao dịch (I-020 tầng 2).
ALTER TABLE station_job
  ADD CONSTRAINT station_job_made_in_batch_fkey
    FOREIGN KEY (id_if_made_or_served) REFERENCES production_batch_item (live_station_job_id)
    DEFERRABLE INITIALLY DEFERRED;

-- Lần chuyển thứ đã làm xong của một đơn bị huỷ sang một đơn vị đang chờ của bàn khác (chủ quán
-- chốt 2026-09-06, U-033: "tính vào bàn khác, pos sẽ cập nhật bánh này đem ra cho bàn nào").
-- Là vết: thứ nào, chủ cũ, chủ mới, lúc nào. Bàn nhận có đang chờ ĐÚNG thứ ấy không là quyết
-- định của người (I-004 tầng 4): không ràng buộc nào so khoá gom hai bên — câu đối chiếu bắt.
CREATE TABLE station_job_transfer (
  id                       bigint GENERATED ALWAYS AS IDENTITY,
  production_batch_item_id bigint NOT NULL,
  from_station_job_id      bigint NOT NULL,
  to_station_job_id        bigint NOT NULL,
  transferred_at           timestamptz NOT NULL DEFAULT now(),
  created_at               timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT station_job_transfer_pkey PRIMARY KEY (id),
  CONSTRAINT station_job_transfer_production_batch_item_fkey
    FOREIGN KEY (production_batch_item_id) REFERENCES production_batch_item (id),
  CONSTRAINT station_job_transfer_from_station_job_fkey
    FOREIGN KEY (from_station_job_id) REFERENCES station_job (id),
  CONSTRAINT station_job_transfer_to_station_job_fkey
    FOREIGN KEY (to_station_job_id) REFERENCES station_job (id),
  CONSTRAINT station_job_transfer_changes_owner_check
    CHECK (from_station_job_id <> to_station_job_id),
  -- Đích của khoá ngoại hai cột ở production_batch_item.
  CONSTRAINT station_job_transfer_item_to_key UNIQUE (production_batch_item_id, to_station_job_id)
);

-- Thứ đã làm đổi chủ ⇒ có một lần chuyển ghi đúng thứ ấy và đúng chủ mới (I-004 tầng 4: máy
-- không ngăn quầy chọn nhầm bàn, máy giữ vết).
ALTER TABLE production_batch_item
  ADD CONSTRAINT production_batch_item_transfer_fkey
    FOREIGN KEY (id, transferred_station_job_id)
    REFERENCES station_job_transfer (production_batch_item_id, to_station_job_id)
    DEFERRABLE INITIALLY DEFERRED;

-- Mẻ làm cho ai lúc bấm là vết, không sửa được; chủ hiện tại và bản soi lùi mẻ thì sửa được.
REVOKE UPDATE ON production_batch_item FROM shop_app;
GRANT UPDATE (station_job_id, batch_rolled_back) ON production_batch_item TO shop_app;
