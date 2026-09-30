-- Scenario 1 — khách QR tại bàn, ba lượt gọi, thu tiền một lần
-- (docs/product/0-ba/ban-hang/08-scenario.md §8, bảng *Các bước* — số bước ở đây là số ở đó).
-- Mỗi khối DO là MỘT bước ở quán, một giao dịch được COMMIT. Cần prelude.sql trong cùng phiên.
-- Không chép con giá nào: tiền đọc lại ở doc_lai.sql, cộng tay từ shop-facts ở file cổng §4.

-- 1 · 2 — Khách ngồi bàn 5 đang trống, quét QR gọi lượt đầu; phiên mở LÚC LƯỢT GỌI ĐẦU TIÊN được
-- tạo. Giá do hệ thống tính, khách không khai giá (I-013).
DO $$
DECLARE t bigint := pg_temp.sc_ban('5'); s bigint; o bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 1 — khách QR gửi lượt 1');
  INSERT INTO table_session (status, created_at) VALUES ('open', pg_temp.sc_luc('07:00')) RETURNING id INTO s;
  INSERT INTO table_session_member (table_session_id, dining_table_id, created_at)
  VALUES (s, t, pg_temp.sc_luc('07:00'));
  o := pg_temp.sc_don('qr_table', s, t, pg_temp.sc_luc('07:00'));
  PERFORM pg_temp.sc_mon(o, 'Đầy đủ trứng tái', 2, ARRAY['Thịt + mộc nhĩ', 'Nhiều nhân']);
  UPDATE sales_order SET status = 'pending_confirmation' WHERE id = o;
  INSERT INTO sc VALUES ('s1_ban', t), ('s1_phien', s), ('s1_luot1', o);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:00'));
  RAISE NOTICE 'S1.1-2 phiên % mở cho bàn 5 lúc lượt 1 tạo · lượt 1 (qr_table) chờ duyệt · tiền lượt 1 = % đ',
    s, pg_temp.sc_tong(o);
END $$;

-- 3 · 4 — Quầy duyệt lượt 1; hệ thống nổ việc xuống trạm cùng giao dịch. Trước lúc duyệt: 0 việc.
DO $$
DECLARE s bigint := pg_temp.sc_id('s1_phien'); o bigint := pg_temp.sc_id('s1_luot1'); n_truoc int;
BEGIN
  SELECT count(*) INTO n_truoc FROM station_job WHERE sales_order_id = o;
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 1 — quầy duyệt lượt 1');
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.sc_no(o, pg_temp.sc_luc('07:02'));
  UPDATE table_session SET status = 'serving' WHERE id = s;
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:02'));
  RAISE NOTICE 'S1.3-4 trước duyệt: % việc trạm · sau duyệt: % việc (đơn vị) trên % trạm',
    n_truoc, (SELECT count(*) FROM station_job WHERE sales_order_id = o),
    (SELECT count(DISTINCT station_code) FROM station_job WHERE sales_order_id = o);
END $$;

-- 5 · 6 — Bếp làm xong mẻ; quầy bấm "đã làm xong" rồi "đã ra bàn"; ba trạm bếp không bấm gì.
-- Cả sáu việc đã ra bàn ⇒ lượt 1 Hoàn thành.
DO $$
DECLARE o bigint := pg_temp.sc_id('s1_luot1'); b bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 1 — quầy bấm mẻ lượt 1');
  b := pg_temp.sc_me(ARRAY[o], pg_temp.sc_luc('07:15'));
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:15'));
  INSERT INTO sc VALUES ('s1_me1', b);
END $$;
DO $$
DECLARE o bigint := pg_temp.sc_id('s1_luot1');
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 1 — lượt 1 đã ra bàn');
  PERFORM pg_temp.sc_ra(o);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:20'));
  RAISE NOTICE 'S1.5-6 mẻ % · lượt 1: %', pg_temp.sc_id('s1_me1'),
    (SELECT status FROM sales_order WHERE id = o);
END $$;

-- 7 · 8 · 9 — Lượt 2: quầy đặt hộ, vào THẲNG Đã xác nhận, vào CHÍNH phiên của bàn 5; nổ, làm, ra.
DO $$
DECLARE s bigint := pg_temp.sc_id('s1_phien'); t bigint := pg_temp.sc_id('s1_ban'); o bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 1 — quầy đặt hộ lượt 2');
  o := pg_temp.sc_don('staff_pos', s, t, pg_temp.sc_luc('07:25'));
  PERFORM pg_temp.sc_mon(o, 'Suất giò', 1, ARRAY['Thịt', 'Thường']);
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.sc_no(o, pg_temp.sc_luc('07:25'));
  INSERT INTO sc VALUES ('s1_luot2', o);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:25'));
  RAISE NOTICE 'S1.7-8 lượt 2 (staff_pos) vào phiên % · % đ · số phiên chưa đóng của bàn 5: %', s,
    pg_temp.sc_tong(o),
    (SELECT count(*) FROM table_session_member WHERE dining_table_id = t AND NOT session_closed);
END $$;
DO $$
DECLARE o bigint := pg_temp.sc_id('s1_luot2');
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 1 — quầy bấm mẻ lượt 2');
  PERFORM pg_temp.sc_me(ARRAY[o], pg_temp.sc_luc('07:35'));
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:35'));
END $$;
DO $$
DECLARE o bigint := pg_temp.sc_id('s1_luot2');
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 1 — lượt 2 đã ra bàn');
  PERFORM pg_temp.sc_ra(o);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:37'));
  RAISE NOTICE 'S1.9 lượt 2: %', (SELECT status FROM sales_order WHERE id = o);
END $$;

-- 10 — Khách xin tính tiền: tổng CẢ phiên; phiên sang Chờ thanh toán; bàn 5 chưa trống.
DO $$
DECLARE s bigint := pg_temp.sc_id('s1_phien'); t bigint := pg_temp.sc_id('s1_ban');
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 1 — khách xin tính tiền');
  UPDATE table_session SET status = 'awaiting_payment' WHERE id = s;
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:45'));
  RAISE NOTICE 'S1.10 tổng phiên % đ · phiên % · bàn 5 còn thuộc phiên chưa đóng: %',
    pg_temp.sc_tong_phien(s), (SELECT status FROM table_session WHERE id = s),
    (SELECT count(*) > 0 FROM table_session_member WHERE dining_table_id = t AND NOT session_closed);

  -- Cái sai đắt thứ hai của scenario: bàn 5 bị coi là trống ⇒ khách sau mở phiên mới trên nó.
  BEGIN
    INSERT INTO table_session (status) VALUES ('open') RETURNING id INTO s;
    INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s, t);
    RAISE EXCEPTION 'S1.10: database KHÔNG chặn phiên thứ hai của bàn 5 lúc Chờ thanh toán';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'S1.10 ✗ phiên thứ hai trên bàn 5 lúc Chờ thanh toán bị từ chối (I-001): %', SQLERRM;
  END;
END $$;

-- 11 · 12 — Lượt 3, gọi thêm SAU khi quầy đã bắt đầu thu tiền: phiên quay về Đang phục vụ; quầy
-- duyệt, bếp làm, hai mốc — bước này không được bỏ (I-017).
DO $$
DECLARE s bigint := pg_temp.sc_id('s1_phien'); t bigint := pg_temp.sc_id('s1_ban'); o bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 1 — khách QR gửi lượt 3 khi đang thu tiền');
  o := pg_temp.sc_don('qr_table', s, t, pg_temp.sc_luc('07:47'));
  PERFORM pg_temp.sc_mon(o, 'Bánh cuốn', 1, ARRAY['Chay']);
  UPDATE sales_order SET status = 'pending_confirmation' WHERE id = o;
  UPDATE table_session SET status = 'serving' WHERE id = s;
  INSERT INTO sc VALUES ('s1_luot3', o);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:47'));
  RAISE NOTICE 'S1.11 lượt 3 (qr_table) vào phiên % · % đ · phiên quay về %', s, pg_temp.sc_tong(o),
    (SELECT status FROM table_session WHERE id = s);
END $$;
DO $$
DECLARE o bigint := pg_temp.sc_id('s1_luot3');
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 1 — quầy duyệt lượt 3');
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.sc_no(o, pg_temp.sc_luc('07:48'));
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:48'));
END $$;
DO $$
DECLARE o bigint := pg_temp.sc_id('s1_luot3');
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 1 — quầy bấm mẻ lượt 3');
  PERFORM pg_temp.sc_me(ARRAY[o], pg_temp.sc_luc('07:55'));
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:55'));
END $$;
DO $$
DECLARE o bigint := pg_temp.sc_id('s1_luot3');
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 1 — lượt 3 đã ra bàn');
  PERFORM pg_temp.sc_ra(o);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:57'));
  RAISE NOTICE 'S1.12 lượt 3: %', (SELECT status FROM sales_order WHERE id = o);
END $$;

-- 13 · 14 · 15 — Tính lại tổng của CÙNG một hoá đơn; khách trả hai phương thức (số tiền mặt là
-- của scenario, phần còn lại chuyển khoản); đóng phiên — hoá đơn, phiên, mọi bàn của phiên cùng
-- một giao dịch (I-017).
DO $$
DECLARE s bigint := pg_temp.sc_id('s1_phien'); due bigint; b bigint; tien_mat bigint := 60000;
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 1 — thu tiền và đóng phiên');
  UPDATE table_session SET status = 'awaiting_payment' WHERE id = s;
  due := pg_temp.sc_tong_phien(s);
  INSERT INTO bill (table_session_id, due_vnd, cash_vnd, transfer_vnd, booked_at, sale_date)
  VALUES (s, due, tien_mat, due - tien_mat, pg_temp.sc_luc('08:00'), pg_temp.sc_ngay())
  RETURNING id INTO b;
  UPDATE table_session SET status = 'closed' WHERE id = s;
  UPDATE table_session_member SET session_closed = true WHERE table_session_id = s;
  INSERT INTO sc VALUES ('s1_hoa_don', b);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('08:00'));
  RAISE NOTICE 'S1.13-15 hoá đơn % của phiên % · phải trả % = tiền mặt % + chuyển khoản % · phiên %',
    b, s, due, tien_mat, due - tien_mat, (SELECT status FROM table_session WHERE id = s);
END $$;

-- Cái sai đắt nhất của scenario: lượt 3 bị tách ra hoá đơn thứ hai.
DO $$
DECLARE s bigint := pg_temp.sc_id('s1_phien');
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 1 — thử hoá đơn thứ hai');
  INSERT INTO bill (table_session_id, due_vnd, cash_vnd, booked_at, sale_date)
  VALUES (s, 0, 0, pg_temp.sc_luc('08:01'), pg_temp.sc_ngay());
  RAISE EXCEPTION 'S1.13: database KHÔNG chặn hoá đơn thứ hai của một phiên';
EXCEPTION WHEN unique_violation THEN
  RAISE NOTICE 'S1.13 ✗ hoá đơn thứ hai của phiên bị từ chối (I-002): %', SQLERRM;
END $$;

-- 16 · 17 — Phiên đóng ⇒ bàn cần dọn; người canh & dọn xác nhận đã dọn ⇒ bàn 5 trống.
DO $$
DECLARE s bigint := pg_temp.sc_id('s1_phien'); t bigint := pg_temp.sc_id('s1_ban');
BEGIN
  PERFORM pg_temp.sc_buoc('Người canh & dọn', 'scenario 1 — bàn 5 đã dọn');
  UPDATE table_session_member SET cleaned_at = pg_temp.sc_luc('08:05') WHERE table_session_id = s;
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('08:05'));
  RAISE NOTICE 'S1.16-17 bàn 5: phiên đã đóng %, đã dọn lúc % ⇒ không thuộc phiên chưa đóng nào: %',
    (SELECT is_closed FROM table_session WHERE id = s),
    (SELECT to_char(cleaned_at, 'HH24:MI') FROM table_session_member WHERE table_session_id = s),
    NOT EXISTS (SELECT 1 FROM table_session_member WHERE dining_table_id = t AND NOT session_closed);
END $$;
