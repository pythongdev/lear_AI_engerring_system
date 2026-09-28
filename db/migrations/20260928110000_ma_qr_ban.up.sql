-- T-114 — mã QR của bàn (I-023, YC-24), thêm vào lát bán hàng lõi.
-- Ý định, lý do và ánh xạ: docs/product/2-db/02-luoc-do-ban-hang.md §2 hàng I-023.
-- File này thắng về tên · kiểu · ràng buộc (docs/decisions.md ADR-053 luật 2).
-- Quy ước: docs/product/2-db/01-quy-uoc-du-lieu.md (QD-XX) · 10-quy-uoc-code.md (QC-XX).

-- Mọi mã từng cấp cho một bàn — mã hiện hành (replaced_at trống) và mọi mã đã thay. Không
-- dòng nào bị xoá (QD-50), nên khoá duy nhất trên `code` giữ "một mã, một bàn" suốt đời mã.
-- Một dòng mới cho một bàn đã có mã LÀ một lần đổi: bàn nào (dining_table_id), lúc nào
-- (issued_at). "Ai đổi" chờ bảng người của P2-08 — chỗ trống có tên ở file lát §5.
CREATE TABLE qr_code (
  id              bigint GENERATED ALWAYS AS IDENTITY,
  dining_table_id bigint NOT NULL,
  code            text NOT NULL,
  issued_at       timestamptz NOT NULL,
  replaced_at     timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT qr_code_pkey PRIMARY KEY (id),
  CONSTRAINT qr_code_dining_table_fkey
    FOREIGN KEY (dining_table_id) REFERENCES dining_table (id),
  -- I-023 "một mã chỉ tới nhiều nhất một bàn, kể cả mã đã thay".
  CONSTRAINT qr_code_code_key UNIQUE (code),
  CONSTRAINT qr_code_code_not_blank_check CHECK (btrim(code) <> ''),
  CONSTRAINT qr_code_replaced_after_issued_check
    CHECK (replaced_at IS NULL OR replaced_at >= issued_at),
  -- Đích của khoá ngoại hai cột ở sales_order: mã và bàn của nó đi cùng nhau.
  CONSTRAINT qr_code_id_table_key UNIQUE (id, dining_table_id)
);

-- I-023 "một bàn có nhiều nhất một mã hiện hành".
CREATE UNIQUE INDEX qr_code_one_current_per_table_key
  ON qr_code (dining_table_id)
  WHERE replaced_at IS NULL;

-- Lượt gọi QR mang mã nào. Có khi và chỉ khi kênh là qr_table; và bàn của lượt gọi phải là
-- bàn mà mã chỉ tới — một cột bàn không thể nói khác cột mã. Tra bàn TỪ mã, và nhận mã
-- đang hiện hành tại mốc tạo, là việc của cửa tạo lượt gọi (tầng 3, pha 3): khoá ngoại này
-- trỏ tới dòng mã, không tới "mã hiện hành", để lượt gọi tạo trước lần đổi giữ nguyên mã cũ.
ALTER TABLE sales_order
  ADD COLUMN qr_code_id bigint;

ALTER TABLE sales_order
  ADD CONSTRAINT sales_order_qr_code_iff_qr_channel_check
    CHECK ((channel_code = 'qr_table') = (qr_code_id IS NOT NULL)),
  ADD CONSTRAINT sales_order_qr_code_table_fkey
    FOREIGN KEY (qr_code_id, dining_table_id) REFERENCES qr_code (id, dining_table_id);

-- Đúng MỘT cửa sinh và đổi mã (I-023 "không đoán được", tầng 3). Mã là 32 ký tự hex lấy từ
-- sha256 của một UUID ngẫu nhiên (nguồn ngẫu nhiên mạnh của PostgreSQL): không chứa số bàn,
-- thứ tự hay giờ sinh, và không phần nào cố định. Thay mã hiện hành (nếu có) và cấp mã mới
-- trong cùng một lệnh — mã cũ hết hiện hành đúng mốc mã mới bắt đầu. Không chạm phiên bàn.
-- Ai được gọi cửa này (chỉ chủ quán, U-062) là quyền theo vai của pha 3.
CREATE FUNCTION qr_code_issue(p_dining_table_id bigint) RETURNS bigint
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
DECLARE new_id bigint;
BEGIN
  UPDATE qr_code SET replaced_at = now()
   WHERE dining_table_id = p_dining_table_id AND replaced_at IS NULL;
  INSERT INTO qr_code (dining_table_id, code, issued_at)
  VALUES (p_dining_table_id,
          left(encode(sha256(convert_to(gen_random_uuid()::text, 'UTF8')), 'hex'), 32),
          now())
  RETURNING id INTO new_id;
  RETURN new_id;
END $$;

-- Vai ghi của hệ thống không có đường thứ hai vào bảng mã: chỉ đọc, và gọi cửa trên.
REVOKE INSERT, UPDATE ON qr_code FROM shop_app;
REVOKE ALL ON FUNCTION qr_code_issue(bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION qr_code_issue(bigint) TO shop_app;
