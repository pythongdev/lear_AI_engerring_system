-- Scenario 2 — ba đơn mang đi, ba kênh, không đơn nào gắn phiên bàn
-- (docs/product/0-ba/ban-hang/08-scenario.md §8, bảng *Các bước* — số bước ở đây là số ở đó).
-- Mỗi khối DO là MỘT bước ở quán, một giao dịch được COMMIT. Cần prelude.sql trong cùng phiên.
-- Số điện thoại, địa chỉ là dữ liệu diễn, không phải khách thật. Đơn A và đơn C là của CÙNG một
-- khách (cùng số điện thoại) — ca dễ gộp nhầm nhất, cố ý.

-- 1 — Đơn A, Delivery: khách tự bấm, khai số điện thoại và địa chỉ giao (hai trường bắt buộc).
DO $$
DECLARE o bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 2 — khách gửi đơn A');
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, delivery_address,
                           submission_code, created_at)
  VALUES ('delivery', 'new', 'door_delivery', '0900000201', '12 Hàng Bạc', gen_random_uuid()::text,
          pg_temp.sc_luc('07:30')) RETURNING id INTO o;
  PERFORM pg_temp.sc_mon(o, 'Suất trứng tái', 2, ARRAY['Thịt + mộc nhĩ', 'Thường']);
  UPDATE sales_order SET status = 'pending_confirmation' WHERE id = o;
  INSERT INTO sc VALUES ('s2_a', o);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:30'));
  RAISE NOTICE 'S2.1 đơn A (delivery) % · % đ · chờ duyệt', o, pg_temp.sc_tong(o);
END $$;

-- 2 — Đơn B, Pickup: khai số điện thoại và giờ hẹn lấy 8:30; chọn trả trước bằng VietQR.
DO $$
DECLARE o bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 2 — khách gửi đơn B');
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code, created_at)
  VALUES ('pickup', 'new', 'shop_pickup', '0900000202', pg_temp.sc_luc('08:30'),
          gen_random_uuid()::text, pg_temp.sc_luc('07:32')) RETURNING id INTO o;
  PERFORM pg_temp.sc_mon(o, 'Đầy đủ trứng chín', 1, ARRAY['Thịt', 'Thường']);
  UPDATE sales_order SET status = 'pending_confirmation' WHERE id = o;
  INSERT INTO sc VALUES ('s2_b', o);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:32'));
  RAISE NOTICE 'S2.2 đơn B (pickup, hẹn 08:30) % · % đ · chờ duyệt', o, pg_temp.sc_tong(o);
END $$;

-- 3 · 4 — Đơn C, hotline: quầy hỏi hai câu, khách chọn TỚI LẤY lúc 9:00 ⇒ không cần địa chỉ. Quầy
-- nhập hộ ⇒ đơn vào THẲNG Đã xác nhận. Ba đơn lẻ, không đơn nào gắn phiên bàn (I-007).
DO $$
DECLARE o bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 2 — quầy nhập đơn C từ hotline');
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code, created_at)
  VALUES ('phone_preorder', 'new', 'shop_pickup', '0900000201', pg_temp.sc_luc('09:00'),
          gen_random_uuid()::text, pg_temp.sc_luc('07:34')) RETURNING id INTO o;
  PERFORM pg_temp.sc_mon(o, 'Bánh cuốn', 3, ARRAY['Thịt', 'Nhiều nhân']);
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.sc_no(o, pg_temp.sc_luc('07:34'));
  INSERT INTO sc VALUES ('s2_c', o);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:34'));
  RAISE NOTICE 'S2.3-4 đơn C (phone_preorder, tới lấy 09:00) % · % đ · % — không qua bước duyệt',
    o, pg_temp.sc_tong(o), (SELECT status FROM sales_order WHERE id = o);
  RAISE NOTICE 'S2.4 ba đơn lẻ, số đơn gắn phiên bàn: %',
    (SELECT count(*) FROM sales_order WHERE id IN (pg_temp.sc_id('s2_a'), pg_temp.sc_id('s2_b'), o)
                                        AND table_session_id IS NOT NULL);
END $$;

-- 5 · 7 — Quầy duyệt đơn A và đơn B; hệ thống nổ việc (đơn C đã nổ lúc nhập). Mỗi đơn đúng một
-- việc nước chấm, gói riêng.
DO $$
DECLARE a bigint := pg_temp.sc_id('s2_a'); b bigint := pg_temp.sc_id('s2_b');
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 2 — quầy duyệt đơn A và B');
  UPDATE sales_order SET status = 'confirmed' WHERE id IN (a, b);
  PERFORM pg_temp.sc_no(a, pg_temp.sc_luc('07:36'));
  PERFORM pg_temp.sc_no(b, pg_temp.sc_luc('07:36'));
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:36'));
  RAISE NOTICE 'S2.5-7 A · B đã duyệt · việc nước chấm mỗi đơn: %',
    (SELECT string_agg(format('%s=%s', x.ten, (SELECT count(*) FROM station_job j
                                              WHERE j.sales_order_id = x.id AND j.order_line_id IS NULL)),
                       ' ' ORDER BY x.ten)
     FROM sc x WHERE x.ten IN ('s2_a', 's2_b', 's2_c'));
END $$;

-- 6 — Quầy NHẬN tiền trả trước của đơn B rồi mới bấm "đã nhận tiền" — không bấm lúc khách chọn.
DO $$
DECLARE b bigint := pg_temp.sc_id('s2_b'); p bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 2 — nhận tiền trả trước đơn B');
  INSERT INTO prepayment (sales_order_id, transfer_vnd, booked_at, sale_date)
  VALUES (b, pg_temp.sc_tong(b), pg_temp.sc_luc('07:40'), pg_temp.sc_ngay()) RETURNING id INTO p;
  INSERT INTO sc VALUES ('s2_b_tra_truoc', p);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:40'));
  RAISE NOTICE 'S2.6 trả trước % của đơn B: % đ chuyển khoản, nhận lúc 07:40 (đơn gửi lúc 07:32)',
    p, pg_temp.sc_tong(b);
END $$;

-- 8 — Bếp làm xong mẻ; quầy bấm "đã làm xong" ⇒ việc của CẢ BA đơn sang "đã làm xong, còn ở bếp".
-- Một mẻ, ba đơn.
DO $$
DECLARE m bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 2 — quầy bấm mẻ cho ba đơn');
  m := pg_temp.sc_me(ARRAY[pg_temp.sc_id('s2_a'), pg_temp.sc_id('s2_b'), pg_temp.sc_id('s2_c')],
                     pg_temp.sc_luc('07:50'));
  INSERT INTO sc VALUES ('s2_me', m);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('07:50'));
  RAISE NOTICE 'S2.8 mẻ % làm ra % đơn vị của % đơn · việc còn chờ của ba đơn: %', m,
    (SELECT count(*) FROM production_batch_item WHERE production_batch_id = m),
    (SELECT count(DISTINCT j.sales_order_id) FROM production_batch_item i
       JOIN station_job j ON j.id = i.station_job_id WHERE i.production_batch_id = m),
    (SELECT count(*) FROM station_job
      WHERE sales_order_id IN (pg_temp.sc_id('s2_a'), pg_temp.sc_id('s2_b'), pg_temp.sc_id('s2_c'))
        AND status = 'pending');
END $$;

-- 9 — Nhân viên đóng gói từng đơn: không có bản ghi nào — không đơn nào có bước bưng ra bàn.

-- 10 — Đơn A rời quán ⇒ Đang giao: quầy biết đơn nào còn trên đường, ai cầm tiền chưa về.
DO $$
DECLARE a bigint := pg_temp.sc_id('s2_a');
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 2 — đơn A rời quán');
  UPDATE sales_order SET status = 'delivering' WHERE id = a;
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('08:00'));
  RAISE NOTICE 'S2.10 đơn A: %', (SELECT status FROM sales_order WHERE id = a);
END $$;

-- 11 — Người đi giao trao hàng, thu tiền tại chỗ khách, bấm "đã giao" và "đã thu tiền" cùng lúc ⇒
-- đơn A Hoàn thành, hoá đơn mang tên người đi giao (POS khai tên — U-057; tên ở đây là tên diễn,
-- như ngày mẫu của P2-11). Việc trạm sang "đã ra bàn" ở mốc TRAO; ai bấm và lúc nào của mốc ấy với
-- đơn giao tận nơi là S-6 — chỗ dừng đã có tên, không phải câu trả lời.
DO $$
DECLARE a bigint := pg_temp.sc_id('s2_a'); b bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 2 — đơn A đã giao, đã thu tiền');
  PERFORM pg_temp.sc_ra(a);
  INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, person_id, booked_at, sale_date)
  VALUES (a, pg_temp.sc_tong(a), pg_temp.sc_tong(a), pg_temp.sc_nguoi('Người gấp bánh'),
          pg_temp.sc_luc('08:20'), pg_temp.sc_ngay()) RETURNING id INTO b;
  INSERT INTO sc VALUES ('s2_a_hoa_don', b);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('08:20'));
  RAISE NOTICE 'S2.11 đơn A: % · hoá đơn % tiền mặt % đ, người thu: %', (SELECT status FROM sales_order WHERE id = a),
    b, pg_temp.sc_tong(a), (SELECT p.display_name FROM bill x JOIN person p ON p.id = x.person_id WHERE x.id = b);
END $$;

-- 12 — Đơn B: khách tới lấy 8:30, quầy trao hàng ⇒ Hoàn thành. Tiền đã nhận ở bước 6 nên KHÔNG
-- thu lại: hoá đơn dùng khoản trả trước, và mắt chuỗi số dư ghi phần đã dùng (YC-23).
DO $$
DECLARE o bigint := pg_temp.sc_id('s2_b'); p bigint := pg_temp.sc_id('s2_b_tra_truoc'); b bigint;
        due bigint := pg_temp.sc_tong(pg_temp.sc_id('s2_b'));
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 2 — trao đơn B');
  PERFORM pg_temp.sc_ra(o);
  INSERT INTO bill (sales_order_id, due_vnd, prepaid_transfer_vnd, booked_at, sale_date)
  VALUES (o, due, due, pg_temp.sc_luc('08:30'), pg_temp.sc_ngay()) RETURNING id INTO b;
  INSERT INTO prepayment_use (prepayment_id, sales_order_id, use_no, cash_before_vnd,
                              transfer_before_vnd, take_transfer_vnd, bill_id)
  VALUES (p, o, 1, 0, due, due, b);
  INSERT INTO sc VALUES ('s2_b_hoa_don', b);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('08:30'));
  RAISE NOTICE 'S2.12 đơn B: % · hoá đơn %: tiền mặt % · chuyển khoản % · từ trả trước %',
    (SELECT status FROM sales_order WHERE id = o), b,
    (SELECT cash_vnd FROM bill WHERE id = b), (SELECT transfer_vnd FROM bill WHERE id = b),
    (SELECT prepaid_cash_vnd + prepaid_transfer_vnd FROM bill WHERE id = b);
END $$;

-- Cái sai của bước 12: thu tiền đơn B lần nữa lúc trao hàng.
DO $$
DECLARE o bigint := pg_temp.sc_id('s2_b');
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 2 — thử thu đơn B lần hai');
  INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, booked_at, sale_date)
  VALUES (o, pg_temp.sc_tong(o), pg_temp.sc_tong(o), pg_temp.sc_luc('08:31'), pg_temp.sc_ngay());
  RAISE EXCEPTION 'S2.12: database KHÔNG chặn lần thu thứ hai của đơn B';
EXCEPTION WHEN unique_violation THEN
  RAISE NOTICE 'S2.12 ✗ lần thu thứ hai của đơn B bị từ chối (I-007: một đơn lẻ, một hoá đơn): %', SQLERRM;
END $$;

-- 13 · 14 — Đơn C: khách tới lấy 9:00, quầy trao hàng và thu tiền tại quầy ⇒ Hoàn thành; không qua
-- Đang giao. Không đơn nào có bước dọn bàn.
DO $$
DECLARE o bigint := pg_temp.sc_id('s2_c'); b bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 2 — trao đơn C, thu tại quầy');
  PERFORM pg_temp.sc_ra(o);
  INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, booked_at, sale_date)
  VALUES (o, pg_temp.sc_tong(o), pg_temp.sc_tong(o), pg_temp.sc_luc('09:00'), pg_temp.sc_ngay())
  RETURNING id INTO b;
  INSERT INTO sc VALUES ('s2_c_hoa_don', b);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('09:00'));
  RAISE NOTICE 'S2.13-14 đơn C: % · hoá đơn % tiền mặt % đ', (SELECT status FROM sales_order WHERE id = o),
    b, pg_temp.sc_tong(o);
END $$;
