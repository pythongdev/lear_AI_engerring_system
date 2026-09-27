-- P2-04 — lát bán hàng lõi: bàn · phiên bàn · bàn của phiên · đơn · dòng đơn.
-- Ý định, lý do và ánh xạ I-0xx/YC-xx: docs/product/2-db/02-luoc-do-ban-hang.md.
-- File này thắng về tên · kiểu · ràng buộc (docs/decisions.md ADR-053 luật 2).
-- Quy ước: docs/product/2-db/01-quy-uoc-du-lieu.md (QD-XX) · 10-quy-uoc-code.md (QC-XX).

CREATE TABLE dining_table (
  id         bigint GENERATED ALWAYS AS IDENTITY,
  label      text COLLATE "vi-x-icu" NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT dining_table_pkey PRIMARY KEY (id),
  CONSTRAINT dining_table_label_key UNIQUE (label),
  CONSTRAINT dining_table_label_not_blank_check CHECK (btrim(label) <> '')
);

CREATE TABLE table_session (
  id         bigint GENERATED ALWAYS AS IDENTITY,
  status     text NOT NULL,
  -- Tự tính, không ghi tay được: đường ghi duy nhất tới "đã đóng chưa" là status.
  is_closed  boolean GENERATED ALWAYS AS (status = 'closed') STORED,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT table_session_pkey PRIMARY KEY (id),
  CONSTRAINT table_session_status_check
    CHECK (status IN ('open', 'serving', 'awaiting_payment', 'closed')),
  -- Đích của khoá ngoại hai cột ở table_session_member.
  CONSTRAINT table_session_id_closed_key UNIQUE (id, is_closed)
);

CREATE TABLE table_session_member (
  id               bigint GENERATED ALWAYS AS IDENTITY,
  table_session_id bigint NOT NULL,
  dining_table_id  bigint NOT NULL,
  -- Bản soi của table_session.is_closed; khoá ngoại hai cột buộc hai bên bằng
  -- nhau lúc COMMIT — đóng phiên mà không cập nhật dòng này thì cả giao dịch hỏng.
  session_closed   boolean NOT NULL DEFAULT false,
  cleaned_at       timestamptz,
  created_at       timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT table_session_member_pkey PRIMARY KEY (id),
  CONSTRAINT table_session_member_session_fkey
    FOREIGN KEY (table_session_id, session_closed)
    REFERENCES table_session (id, is_closed)
    DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT table_session_member_dining_table_fkey
    FOREIGN KEY (dining_table_id) REFERENCES dining_table (id),
  CONSTRAINT table_session_member_table_once_key UNIQUE (table_session_id, dining_table_id),
  CONSTRAINT table_session_member_cleaned_after_close_check
    CHECK (cleaned_at IS NULL OR session_closed)
);

-- I-001: một bàn thuộc nhiều nhất một phiên CHƯA ĐÓNG — theo nghĩa, nên phủ cả
-- open · serving · awaiting_payment. Buộc theo bàn, không theo phiên: ghép bàn
-- (một phiên nhiều bàn) không bị chặn.
CREATE UNIQUE INDEX table_session_member_one_unpaid_session_key
  ON table_session_member (dining_table_id)
  WHERE NOT session_closed;

CREATE TABLE sales_order (
  id               bigint GENERATED ALWAYS AS IDENTITY,
  channel_code     text NOT NULL,
  status           text NOT NULL,
  table_session_id bigint,
  dining_table_id  bigint,
  created_at       timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT sales_order_pkey PRIMARY KEY (id),
  CONSTRAINT sales_order_channel_code_check
    CHECK (channel_code IN ('delivery', 'pickup', 'qr_table', 'staff_pos', 'phone_preorder')),
  CONSTRAINT sales_order_status_check
    CHECK (status IN ('new', 'pending_confirmation', 'confirmed', 'in_progress',
                      'delivering', 'completed', 'cancelled')),
  -- I-006/I-007 (một ranh giới, một cơ chế) và I-002: đơn thuộc phiên bàn KHI VÀ
  -- CHỈ KHI kênh gắn bàn; có phiên thì có bàn, và ngược lại.
  CONSTRAINT sales_order_session_iff_table_channel_check
    CHECK (    (channel_code IN ('qr_table', 'staff_pos')) = (table_session_id IS NOT NULL)
           AND (table_session_id IS NULL) = (dining_table_id IS NULL)),
  -- Bàn gửi đơn phải là một bàn của chính phiên ấy (kể cả bàn ghép vào).
  CONSTRAINT sales_order_session_table_fkey
    FOREIGN KEY (table_session_id, dining_table_id)
    REFERENCES table_session_member (table_session_id, dining_table_id)
);

CREATE TABLE order_line (
  id             bigint GENERATED ALWAYS AS IDENTITY,
  sales_order_id bigint NOT NULL,
  quantity       integer NOT NULL,
  -- YC-05: dấu "đem về" ở mức dòng; không đổi dòng thuộc đơn nào.
  is_takeaway    boolean NOT NULL DEFAULT false,
  created_at     timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT order_line_pkey PRIMARY KEY (id),
  CONSTRAINT order_line_sales_order_fkey
    FOREIGN KEY (sales_order_id) REFERENCES sales_order (id),
  CONSTRAINT order_line_quantity_positive_check CHECK (quantity > 0)
);
