-- P2-06 — lát đường tiền: hoá đơn (lần đóng một đơn vị tính tiền) · thu chia phương thức ·
-- nợ và thu nợ · hoàn tiền · khoản trả trước · tiền đầu két.
-- Ý định, lý do và ánh xạ I-0xx/YC-xx: docs/product/2-db/04-luoc-do-duong-tien.md.
-- File này thắng về tên · kiểu · ràng buộc (docs/decisions.md ADR-053 luật 2).
-- Quy ước: docs/product/2-db/01-quy-uoc-du-lieu.md (QD-XX) · 10-quy-uoc-code.md (QC-XX).
--
-- "Ai bấm" chưa có cột ở bảng nào dưới đây: bảng người là của P2-08 (chỗ trống có tên ở
-- file lát §5). Mọi bảng tiền ở đây mang booked_at + sale_date (QD-31 · QD-33): booked_at
-- mặc định là đồng hồ của database lúc ghi, sale_date là ngày lịch của nó trên một kết nối
-- đặt múi giờ của quán (QD-32). Nhập bù từ sổ giấy ghi cả hai tường minh (ADR-037).

-- Đơn vị tính tiền nào đã tới lúc phải có hoá đơn. Tự tính, không ghi tay được.
--   phiên bàn: đúng lúc nó đóng (vòng đời §5.3 — "Đã đóng" là điểm dừng hẳn);
--   đơn lẻ: là đơn không thuộc phiên nào (I-007); đơn lẻ Hoàn thành thì phải có hoá đơn.
-- Đơn lẻ Hoàn thành rồi bị huỷ (shop-facts §6.19) GIỮ hoá đơn của nó — tiền đi đường hoàn.
ALTER TABLE table_session
  ADD COLUMN id_if_closed bigint GENERATED ALWAYS AS (CASE WHEN status = 'closed' THEN id END) STORED,
  ADD CONSTRAINT table_session_id_if_closed_key UNIQUE (id_if_closed);

ALTER TABLE sales_order
  ADD COLUMN id_if_standalone bigint
    GENERATED ALWAYS AS (CASE WHEN table_session_id IS NULL THEN id END) STORED,
  ADD COLUMN id_if_completed_standalone bigint
    GENERATED ALWAYS AS (CASE WHEN table_session_id IS NULL AND status = 'completed' THEN id END) STORED,
  ADD CONSTRAINT sales_order_id_if_standalone_key UNIQUE (id_if_standalone);

-- Hoá đơn: lần đóng MỘT đơn vị tính tiền, và cũng là lần thu của lần đóng ấy. Mỗi phương
-- thức một cột (shop-facts §1 — đúng hai), nên mọi phần của một lần thu nằm trên một dòng,
-- chung một mốc (YC-19), cùng sống hoặc cùng chết (I-015 tầng 2), và tổng khớp do một điều
-- kiện kiểm giữ (I-015 · I-005 tầng 1). Nợ là cột riêng, không bao giờ nằm trong tiền đã thu.
CREATE TABLE bill (
  id                   bigint GENERATED ALWAYS AS IDENTITY,
  table_session_id     bigint,
  sales_order_id       bigint,
  -- Số phải trả lúc đóng. Bằng tổng các dòng đơn là việc của đường đóng duy nhất (tầng 3)
  -- và câu đối chiếu I-002 (P2-11) — một điều kiện kiểm không đọc được bảng khác.
  due_vnd              bigint NOT NULL,
  cash_vnd             bigint NOT NULL DEFAULT 0,
  transfer_vnd         bigint NOT NULL DEFAULT 0,
  -- Phần của khoản trả trước thành doanh thu ở lần đóng này, theo phương thức đã NHẬN.
  prepaid_cash_vnd     bigint NOT NULL DEFAULT 0,
  prepaid_transfer_vnd bigint NOT NULL DEFAULT 0,
  debt_vnd             bigint NOT NULL DEFAULT 0,
  -- YC-11: chỗ duy nhất một phiên bàn mang danh tính, và chỉ khi có nợ.
  debtor_name          text COLLATE "vi-x-icu",
  id_if_prepaid        bigint GENERATED ALWAYS AS
    (CASE WHEN prepaid_cash_vnd + prepaid_transfer_vnd > 0 THEN id END) STORED,
  booked_at            timestamptz NOT NULL DEFAULT now(),
  sale_date            date NOT NULL DEFAULT CURRENT_DATE,
  created_at           timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT bill_pkey PRIMARY KEY (id),
  -- I-014: một khoản tiền gắn với đúng MỘT đơn vị tính tiền.
  CONSTRAINT bill_one_unit_check CHECK (num_nonnulls(table_session_id, sales_order_id) = 1),
  -- I-002 vế 1 · I-007: một đơn vị tính tiền, nhiều nhất một hoá đơn — nên một lần trả nợ
  -- không ghi được thành một lần bán thứ hai của cùng phiên.
  CONSTRAINT bill_one_per_session_key UNIQUE (table_session_id),
  CONSTRAINT bill_one_per_order_key UNIQUE (sales_order_id),
  -- Chỉ phiên ĐÃ ĐÓNG mới có hoá đơn. Hoãn: đường đóng ghi hoá đơn và trạng thái phiên
  -- trong một giao dịch, theo thứ tự nào cũng được.
  CONSTRAINT bill_table_session_fkey
    FOREIGN KEY (table_session_id) REFERENCES table_session (id_if_closed)
    DEFERRABLE INITIALLY DEFERRED,
  -- Chỉ đơn LẺ mới có hoá đơn riêng; lượt gọi của phiên bàn tính vào hoá đơn của phiên.
  CONSTRAINT bill_sales_order_fkey
    FOREIGN KEY (sales_order_id) REFERENCES sales_order (id_if_standalone),
  CONSTRAINT bill_amounts_not_negative_check
    CHECK (due_vnd >= 0 AND cash_vnd >= 0 AND transfer_vnd >= 0
           AND prepaid_cash_vnd >= 0 AND prepaid_transfer_vnd >= 0 AND debt_vnd >= 0),
  -- I-015 · I-005: thu thiếu thì phần thiếu LÀ nợ; thu vượt thì không ghi được.
  CONSTRAINT bill_parts_equal_due_check
    CHECK (cash_vnd + transfer_vnd + prepaid_cash_vnd + prepaid_transfer_vnd + debt_vnd = due_vnd),
  -- I-005: nợ có chủ; YC-11: không nợ thì không hỏi tên.
  CONSTRAINT bill_debtor_iff_debt_check CHECK ((debt_vnd > 0) = (debtor_name IS NOT NULL)),
  CONSTRAINT bill_debtor_name_not_blank_check CHECK (btrim(debtor_name) <> ''),
  -- shop-facts §6.3: luồng ăn tại bàn không có nhánh trả trước.
  CONSTRAINT bill_prepaid_only_standalone_check
    CHECK (sales_order_id IS NOT NULL OR prepaid_cash_vnd + prepaid_transfer_vnd = 0),
  -- Đích của khoá ngoại nhiều cột ở prepayment_use và debt_collection.
  CONSTRAINT bill_id_order_prepaid_key
    UNIQUE (id, sales_order_id, prepaid_cash_vnd, prepaid_transfer_vnd),
  CONSTRAINT bill_id_debt_key UNIQUE (id, debt_vnd)
);

-- Phiên đã đóng / đơn lẻ Hoàn thành mà không có hoá đơn thì giao dịch không COMMIT được.
ALTER TABLE table_session
  ADD CONSTRAINT table_session_bill_fkey
    FOREIGN KEY (id_if_closed) REFERENCES bill (table_session_id)
    DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE sales_order
  ADD CONSTRAINT sales_order_bill_fkey
    FOREIGN KEY (id_if_completed_standalone) REFERENCES bill (sales_order_id)
    DEFERRABLE INITIALLY DEFERRED;

-- Thu nợ: đúng một lần, thu đủ khoản nợ (YC-02 hai trạng thái "chưa thu · đã thu"), mốc
-- riêng (YC-10). Không phải một hoá đơn: doanh thu của bữa ăn đã nằm ở hoá đơn ghi nợ.
CREATE TABLE debt_collection (
  id           bigint GENERATED ALWAYS AS IDENTITY,
  bill_id      bigint NOT NULL,
  -- Bản soi số nợ của hoá đơn; khoá ngoại hai cột buộc nó bằng bản gốc.
  debt_vnd     bigint NOT NULL,
  cash_vnd     bigint NOT NULL DEFAULT 0,
  transfer_vnd bigint NOT NULL DEFAULT 0,
  booked_at    timestamptz NOT NULL DEFAULT now(),
  sale_date    date NOT NULL DEFAULT CURRENT_DATE,
  created_at   timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT debt_collection_pkey PRIMARY KEY (id),
  CONSTRAINT debt_collection_bill_fkey
    FOREIGN KEY (bill_id, debt_vnd) REFERENCES bill (id, debt_vnd),
  CONSTRAINT debt_collection_one_per_debt_key UNIQUE (bill_id),
  CONSTRAINT debt_collection_amounts_check
    CHECK (debt_vnd > 0 AND cash_vnd >= 0 AND transfer_vnd >= 0
           AND cash_vnd + transfer_vnd = debt_vnd)
);

-- Khoản trả trước: tiền quán NHẬN trước khi đơn lẻ đóng (shop-facts §6.3 · §6.26). booked_at
-- là lúc nhận tiền — nó đặt khoản này vào dòng "trả trước nhận trong ngày" của đối soát,
-- KHÔNG vào doanh thu; doanh thu của đơn đi qua hoá đơn của chính đơn ấy (YC-23).
CREATE TABLE prepayment (
  id             bigint GENERATED ALWAYS AS IDENTITY,
  sales_order_id bigint NOT NULL,
  cash_vnd       bigint NOT NULL DEFAULT 0,
  transfer_vnd   bigint NOT NULL DEFAULT 0,
  booked_at      timestamptz NOT NULL DEFAULT now(),
  sale_date      date NOT NULL DEFAULT CURRENT_DATE,
  created_at     timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT prepayment_pkey PRIMARY KEY (id),
  CONSTRAINT prepayment_sales_order_fkey
    FOREIGN KEY (sales_order_id) REFERENCES sales_order (id_if_standalone),
  CONSTRAINT prepayment_one_per_order_key UNIQUE (sales_order_id),
  CONSTRAINT prepayment_amounts_check
    CHECK (cash_vnd >= 0 AND transfer_vnd >= 0 AND cash_vnd + transfer_vnd > 0),
  CONSTRAINT prepayment_id_order_key UNIQUE (id, sales_order_id),
  CONSTRAINT prepayment_id_order_amounts_key UNIQUE (id, sales_order_id, cash_vnd, transfer_vnd)
);

-- Vết hoàn tiền (YC-01): bao nhiêu · cho lượt bán nào · lúc nào · lý do · trả lại bằng gì.
-- Hai loại, đọc ra từ cột nào có mặt — không bao giờ cả hai:
--   bill_id       hoàn cho một lần bán ĐÃ ĐÓNG — trừ doanh thu ngày hoàn (shop-facts §6.4);
--   prepayment_id trả lại khoản trả trước chưa thành doanh thu — KHÔNG trừ doanh thu ngày
--                 nào (ADR-059 điểm 5, suy ra).
-- Một dòng một phương thức trả lại; lần hoàn trả bằng hai phương thức là hai dòng.
CREATE TABLE refund (
  id                      bigint GENERATED ALWAYS AS IDENTITY,
  bill_id                 bigint,
  prepayment_id           bigint,
  amount_vnd              bigint NOT NULL,
  -- Trả lại bằng gì (shop-facts §6.4, U-044).
  method_code             text NOT NULL,
  -- Với hoàn cho lần bán đã đóng: khoản bị hoàn đã thu bằng gì — để đọc ra hoàn CHÉO (I-021).
  source_method_code      text,
  reason                  text COLLATE "vi-x-icu" NOT NULL,
  id_if_prepayment_return bigint
    GENERATED ALWAYS AS (CASE WHEN prepayment_id IS NOT NULL THEN id END) STORED,
  booked_at               timestamptz NOT NULL DEFAULT now(),
  sale_date               date NOT NULL DEFAULT CURRENT_DATE,
  created_at              timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT refund_pkey PRIMARY KEY (id),
  CONSTRAINT refund_one_target_check CHECK (num_nonnulls(bill_id, prepayment_id) = 1),
  CONSTRAINT refund_bill_fkey FOREIGN KEY (bill_id) REFERENCES bill (id),
  CONSTRAINT refund_prepayment_fkey FOREIGN KEY (prepayment_id) REFERENCES prepayment (id),
  CONSTRAINT refund_amount_positive_check CHECK (amount_vnd > 0),
  CONSTRAINT refund_method_code_check CHECK (method_code IN ('cash', 'transfer')),
  CONSTRAINT refund_source_method_code_check CHECK (source_method_code IN ('cash', 'transfer')),
  CONSTRAINT refund_source_iff_bill_check
    CHECK ((source_method_code IS NOT NULL) = (bill_id IS NOT NULL)),
  -- YC-01: lý do là thứ duy nhất thay được luật (shop-facts §6.4) — trắng cũng là thiếu.
  CONSTRAINT refund_reason_not_blank_check CHECK (btrim(reason) <> ''),
  CONSTRAINT refund_id_prepayment_amount_key UNIQUE (id, prepayment_id, amount_vnd)
);

-- Mỗi lần dùng một khoản trả trước — vào hoá đơn của đơn, hoặc trả lại — là một mắt của
-- một CHUỖI số dư theo từng phương thức đã nhận. Mắt 1 bắt đầu đúng bằng số đã nhận; mắt n
-- bắt đầu đúng bằng số dư sau mắt n-1; số dư không âm. Nên "đã thành doanh thu + đã trả lại
-- ≤ đã nhận" (YC-23 · I-014) là ràng buộc thật, không phải một phép cộng qua nhiều dòng.
CREATE TABLE prepayment_use (
  id                  bigint GENERATED ALWAYS AS IDENTITY,
  prepayment_id       bigint NOT NULL,
  sales_order_id      bigint NOT NULL,
  use_no              integer NOT NULL,
  cash_before_vnd     bigint NOT NULL,
  transfer_before_vnd bigint NOT NULL,
  take_cash_vnd       bigint NOT NULL DEFAULT 0,
  take_transfer_vnd   bigint NOT NULL DEFAULT 0,
  cash_after_vnd      bigint GENERATED ALWAYS AS (cash_before_vnd - take_cash_vnd) STORED,
  transfer_after_vnd  bigint GENERATED ALWAYS AS (transfer_before_vnd - take_transfer_vnd) STORED,
  take_vnd            bigint GENERATED ALWAYS AS (take_cash_vnd + take_transfer_vnd) STORED,
  first_prepayment_id bigint GENERATED ALWAYS AS (CASE WHEN use_no = 1 THEN prepayment_id END) STORED,
  previous_use_no     integer GENERATED ALWAYS AS (CASE WHEN use_no > 1 THEN use_no - 1 END) STORED,
  bill_id             bigint,
  refund_id           bigint,
  created_at          timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT prepayment_use_pkey PRIMARY KEY (id),
  CONSTRAINT prepayment_use_prepayment_fkey
    FOREIGN KEY (prepayment_id, sales_order_id) REFERENCES prepayment (id, sales_order_id),
  CONSTRAINT prepayment_use_first_fkey
    FOREIGN KEY (first_prepayment_id, sales_order_id, cash_before_vnd, transfer_before_vnd)
    REFERENCES prepayment (id, sales_order_id, cash_vnd, transfer_vnd),
  CONSTRAINT prepayment_use_previous_fkey
    FOREIGN KEY (prepayment_id, previous_use_no, cash_before_vnd, transfer_before_vnd)
    REFERENCES prepayment_use (prepayment_id, use_no, cash_after_vnd, transfer_after_vnd),
  CONSTRAINT prepayment_use_no_key UNIQUE (prepayment_id, use_no),
  CONSTRAINT prepayment_use_chain_key
    UNIQUE (prepayment_id, use_no, cash_after_vnd, transfer_after_vnd),
  CONSTRAINT prepayment_use_no_positive_check CHECK (use_no >= 1),
  CONSTRAINT prepayment_use_take_check
    CHECK (take_cash_vnd >= 0 AND take_transfer_vnd >= 0 AND take_vnd > 0),
  -- Không dùng quá số còn lại.
  CONSTRAINT prepayment_use_balance_check
    CHECK (cash_before_vnd >= 0 AND transfer_before_vnd >= 0
           AND cash_after_vnd >= 0 AND transfer_after_vnd >= 0),
  CONSTRAINT prepayment_use_one_target_check CHECK (num_nonnulls(bill_id, refund_id) = 1),
  -- Vào hoá đơn: đúng hoá đơn của chính đơn ấy, đúng số hoá đơn ghi là "trả trước".
  CONSTRAINT prepayment_use_bill_fkey
    FOREIGN KEY (bill_id, sales_order_id, take_cash_vnd, take_transfer_vnd)
    REFERENCES bill (id, sales_order_id, prepaid_cash_vnd, prepaid_transfer_vnd),
  -- Trả lại: đúng lần hoàn loại "trả lại trả trước" của chính khoản ấy, đúng số tiền.
  CONSTRAINT prepayment_use_refund_fkey
    FOREIGN KEY (refund_id, prepayment_id, take_vnd)
    REFERENCES refund (id, prepayment_id, amount_vnd),
  CONSTRAINT prepayment_use_one_per_bill_key UNIQUE (bill_id),
  CONSTRAINT prepayment_use_one_per_refund_key UNIQUE (refund_id)
);

-- Hoá đơn ghi "trả trước" / lần trả lại khoản trả trước mà không có mắt chuỗi tương ứng
-- thì giao dịch không COMMIT được.
ALTER TABLE bill
  ADD CONSTRAINT bill_prepayment_use_fkey
    FOREIGN KEY (id_if_prepaid) REFERENCES prepayment_use (bill_id)
    DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE refund
  ADD CONSTRAINT refund_prepayment_use_fkey
    FOREIGN KEY (id_if_prepayment_return) REFERENCES prepayment_use (refund_id)
    DEFERRABLE INITIALLY DEFERRED;

-- Tiền đầu két (I-021, shop-facts §8.5): mỗi ngày bán đúng MỘT, ở bảng riêng — không bao giờ
-- nằm trong tập tiền đã thu. Con số của ngày là TỔNG các dòng mệnh giá (U-038: máy giữ bảng
-- mệnh giá và hiện tổng) — cộng lại từ chi tiết, không có ô tổng thứ hai.
CREATE TABLE opening_float (
  id         bigint GENERATED ALWAYS AS IDENTITY,
  sale_date  date NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT opening_float_pkey PRIMARY KEY (id),
  CONSTRAINT opening_float_one_per_day_key UNIQUE (sale_date)
);

CREATE TABLE opening_float_line (
  id                bigint GENERATED ALWAYS AS IDENTITY,
  opening_float_id  bigint NOT NULL,
  denomination_vnd  bigint NOT NULL,
  amount_vnd        bigint NOT NULL,
  created_at        timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT opening_float_line_pkey PRIMARY KEY (id),
  CONSTRAINT opening_float_line_opening_float_fkey
    FOREIGN KEY (opening_float_id) REFERENCES opening_float (id),
  CONSTRAINT opening_float_line_one_per_denomination_key
    UNIQUE (opening_float_id, denomination_vnd),
  -- Một dòng là một xấp tiền cùng mệnh giá: số tiền là bội của mệnh giá.
  CONSTRAINT opening_float_line_amount_check
    CHECK (denomination_vnd > 0 AND amount_vnd >= 0 AND amount_vnd % denomination_vnd = 0)
);
