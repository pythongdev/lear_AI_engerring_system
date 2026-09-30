-- Scenario 3 — chủ quán đổi giá giữa buổi: đơn mới theo giá mới, đơn cũ đứng yên
-- (docs/product/0-ba/ban-hang/08-scenario.md §8, bảng *Các bước* — số bước ở đây là số ở đó).
-- Mỗi khối DO là MỘT bước ở quán, một giao dịch được COMMIT. Cần prelude.sql và s1 (bước 10 đọc lại
-- đơn của Scenario 1) trong cùng phiên. Lần đổi giá là một lần SỬA thật: trigger chụp vết (I-018).

-- 1 — 8:00, bàn 3 gọi một suất giò, nhân thịt, lượng thường; dòng khoá giá ngay lúc lượt gọi tạo.
DO $$
DECLARE t bigint := pg_temp.sc_ban('3'); s bigint; o bigint; l bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 3 — khách QR bàn 3 gửi lượt 8:00');
  INSERT INTO table_session (status, created_at) VALUES ('open', pg_temp.sc_luc('08:00')) RETURNING id INTO s;
  INSERT INTO table_session_member (table_session_id, dining_table_id, created_at)
  VALUES (s, t, pg_temp.sc_luc('08:00'));
  o := pg_temp.sc_don('qr_table', s, t, pg_temp.sc_luc('08:00'));
  l := pg_temp.sc_mon(o, 'Suất giò', 1, ARRAY['Thịt', 'Thường']);
  UPDATE sales_order SET status = 'pending_confirmation' WHERE id = o;
  INSERT INTO sc VALUES ('s3_ban', t), ('s3_phien', s), ('s3_luot_8h', o), ('s3_dong_8h', l);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('08:00'));
  RAISE NOTICE 'S3.1 phiên % bàn 3 · dòng % "Suất giò" khoá % đ lúc 08:00', s, l,
    (SELECT unit_price_vnd FROM order_line WHERE id = l);
END $$;

-- (không phải một bước của Scenario 3) Quầy duyệt, bếp làm, bưng lượt 8:00 — phiên không đóng được
-- ở bước 7 khi còn một đơn chưa Hoàn thành (I-017).
DO $$
DECLARE s bigint := pg_temp.sc_id('s3_phien'); o bigint := pg_temp.sc_id('s3_luot_8h');
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 3 — quầy duyệt lượt 8:00');
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.sc_no(o, pg_temp.sc_luc('08:02'));
  UPDATE table_session SET status = 'serving' WHERE id = s;
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('08:02'));
END $$;
DO $$
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 3 — quầy bấm mẻ lượt 8:00');
  PERFORM pg_temp.sc_me(ARRAY[pg_temp.sc_id('s3_luot_8h')], pg_temp.sc_luc('08:10'));
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('08:10'));
END $$;
DO $$
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 3 — lượt 8:00 đã ra bàn');
  PERFORM pg_temp.sc_ra(pg_temp.sc_id('s3_luot_8h'));
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('08:12'));
END $$;

-- 2 · 3 · 4 — 8:30, chủ quán nâng GIÁ GỐC (giá chay) của một cái bánh cuốn thêm 1.000đ — chiều 1,
-- đổi giá một thành phần; hai mức phụ thu không đổi. Lưu là có hiệu lực ngay; không có bảng giá
-- theo kênh nào, nên cả năm kênh đọc cùng một dòng giá.
DO $$
DECLARE mc bigint := (SELECT id FROM menu_component WHERE name = 'Bánh cuốn'); truoc bigint;
BEGIN
  SELECT base_price_vnd INTO truoc FROM menu_component WHERE id = mc;
  PERFORM pg_temp.sc_buoc('Chủ quán', 'scenario 3 — chủ quán nâng giá gốc bánh cuốn giữa buổi');
  UPDATE menu_component SET base_price_vnd = base_price_vnd + 1000 WHERE id = mc;
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('08:30'));
  RAISE NOTICE 'S3.2-4 giá gốc bánh cuốn % → % đ · phụ thu không đổi · cột giá theo kênh trong lược đồ: %',
    truoc, (SELECT base_price_vnd FROM menu_component WHERE id = mc),
    (SELECT count(*) FROM information_schema.columns
      WHERE table_schema = 'shop' AND table_name LIKE 'menu%' AND column_name LIKE '%channel%');
END $$;

-- 5 — 9:00, bàn 3 gọi thêm ĐÚNG một suất giò cùng loại; dòng mới khoá giá mới.
DO $$
DECLARE s bigint := pg_temp.sc_id('s3_phien'); t bigint := pg_temp.sc_id('s3_ban'); o bigint; l bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 3 — khách QR bàn 3 gửi lượt 9:00');
  o := pg_temp.sc_don('qr_table', s, t, pg_temp.sc_luc('09:00'));
  l := pg_temp.sc_mon(o, 'Suất giò', 1, ARRAY['Thịt', 'Thường']);
  UPDATE sales_order SET status = 'pending_confirmation' WHERE id = o;
  INSERT INTO sc VALUES ('s3_luot_9h', o), ('s3_dong_9h', l);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('09:00'));
  RAISE NOTICE 'S3.5 dòng % "Suất giò" cùng tuỳ chọn khoá % đ lúc 09:00', l,
    (SELECT unit_price_vnd FROM order_line WHERE id = l);
END $$;
DO $$
DECLARE o bigint := pg_temp.sc_id('s3_luot_9h');
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 3 — quầy duyệt lượt 9:00');
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.sc_no(o, pg_temp.sc_luc('09:02'));
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('09:02'));
END $$;
DO $$
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 3 — quầy bấm mẻ lượt 9:00');
  PERFORM pg_temp.sc_me(ARRAY[pg_temp.sc_id('s3_luot_9h')], pg_temp.sc_luc('09:08'));
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('09:08'));
END $$;
DO $$
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 3 — lượt 9:00 đã ra bàn');
  PERFORM pg_temp.sc_ra(pg_temp.sc_id('s3_luot_9h'));
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('09:10'));
END $$;

-- 6 — Quầy mở lại đơn 8:00: vẫn giá cũ, đúng tên món, đúng số bánh bếp đã làm.
DO $$
DECLARE l bigint := pg_temp.sc_id('s3_dong_8h');
BEGIN
  RAISE NOTICE 'S3.6 đọc lại dòng 8:00: "%" · % đ · % cái bánh · mốc khoá %',
    (SELECT item_name FROM order_line WHERE id = l), (SELECT unit_price_vnd FROM order_line WHERE id = l),
    (SELECT sum(x.quantity * c.quantity) FROM order_line_component c JOIN order_line x ON x.id = c.order_line_id
      WHERE c.order_line_id = l AND c.component_name = 'Bánh cuốn'),
    (SELECT to_char(priced_at, 'HH24:MI') FROM order_line WHERE id = l);
END $$;

-- 7 — Đóng phiên bàn 3: MỘT hoá đơn mang HAI mức giá cho cùng một món — kết quả đúng.
DO $$
DECLARE s bigint := pg_temp.sc_id('s3_phien'); due bigint; b bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'scenario 3 — thu tiền và đóng phiên bàn 3');
  UPDATE table_session SET status = 'awaiting_payment' WHERE id = s;
  due := pg_temp.sc_tong_phien(s);
  INSERT INTO bill (table_session_id, due_vnd, cash_vnd, booked_at, sale_date)
  VALUES (s, due, due, pg_temp.sc_luc('09:20'), pg_temp.sc_ngay()) RETURNING id INTO b;
  UPDATE table_session SET status = 'closed' WHERE id = s;
  UPDATE table_session_member SET session_closed = true WHERE table_session_id = s;
  INSERT INTO sc VALUES ('s3_hoa_don', b);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('09:20'));
  RAISE NOTICE 'S3.7 hoá đơn % của phiên bàn 3: % đ · các mức giá của "Suất giò" trên hoá đơn: %', b, due,
    (SELECT string_agg(DISTINCT l.unit_price_vnd::text, ' · ') FROM order_line l
       JOIN sales_order o ON o.id = l.sales_order_id WHERE o.table_session_id = s);
END $$;
DO $$
DECLARE s bigint := pg_temp.sc_id('s3_phien');
BEGIN
  PERFORM pg_temp.sc_buoc('Người canh & dọn', 'scenario 3 — bàn 3 đã dọn');
  UPDATE table_session_member SET cleaned_at = pg_temp.sc_luc('09:25') WHERE table_session_id = s;
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('09:25'));
END $$;

-- 8 — 10:00, chủ quán ngừng bán suất giò: một MỐC, không xoá dòng menu (QD-50). Đơn 8:00 vẫn đúng
-- tên, đúng giá. "Không kênh nào đặt mới được" là cửa tạo lượt gọi của pha 3 (I-009 vế ngừng bán,
-- tầng 3) — database không chặn, câu đối chiếu I-009/4 gọi tên.
DO $$
DECLARE l bigint := pg_temp.sc_id('s3_dong_8h');
BEGIN
  PERFORM pg_temp.sc_buoc('Chủ quán', 'scenario 3 — chủ quán ngừng bán suất giò');
  UPDATE menu_item SET discontinued_at = pg_temp.sc_luc('10:00') WHERE name = 'Suất giò';
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('10:00'));
  RAISE NOTICE 'S3.8 "Suất giò" ngừng bán lúc % · dòng 8:00 vẫn đọc "%" · % đ',
    (SELECT to_char(discontinued_at, 'HH24:MI') FROM menu_item WHERE name = 'Suất giò'),
    (SELECT item_name FROM order_line WHERE id = l), (SELECT unit_price_vnd FROM order_line WHERE id = l);
END $$;

-- 9 — Chủ quán sửa THÀNH PHẦN combo "Đầy đủ" (trứng tái — món Scenario 1 đã gọi) bớt một cái bánh:
-- chiều thứ tư. Luật "chờ hết buổi" là luật cho người: máy nhắc (pha 4) rồi VẪN cho lưu, và để vết.
DO $$
DECLARE mic bigint; truoc int;
BEGIN
  SELECT ic.id, ic.quantity INTO mic, truoc FROM menu_item_component ic
    JOIN menu_item i ON i.id = ic.menu_item_id JOIN menu_component c ON c.id = ic.menu_component_id
   WHERE i.name = 'Đầy đủ trứng tái' AND c.name = 'Bánh cuốn';
  PERFORM pg_temp.sc_buoc('Chủ quán', 'scenario 3 — chủ quán bớt một cái bánh của combo giữa buổi');
  UPDATE menu_item_component SET quantity = quantity - 1 WHERE id = mic;
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('10:05'));
  INSERT INTO sc VALUES ('s3_thanh_phan', mic);
  RAISE NOTICE 'S3.9 combo "Đầy đủ trứng tái": bánh cuốn % → % cái/suất · vết: %', truoc,
    (SELECT quantity FROM menu_item_component WHERE id = mic),
    (SELECT format('%s sửa lúc %s, lý do "%s"', p.display_name, to_char(r.revised_at, 'HH24:MI'), r.reason)
       FROM record_revision r JOIN person p ON p.id = r.person_id
      WHERE r.target_table_code = 'menu_item_component' AND r.target_row = mic);
END $$;

-- 10 — Mở lại đơn của Scenario 1 sau khi thành phần đã đổi: tiền và số bánh đọc từ ảnh chụp lúc đặt.
DO $$
DECLARE o bigint := pg_temp.sc_id('s1_luot1');
BEGIN
  RAISE NOTICE 'S3.10 đọc lại lượt 1 của Scenario 1: % đ · % cái bánh (menu hiện hành: % cái/suất)',
    pg_temp.sc_tong(o),
    (SELECT sum(l.quantity * c.quantity) FROM order_line l JOIN order_line_component c ON c.order_line_id = l.id
      WHERE l.sales_order_id = o AND c.component_name = 'Bánh cuốn'),
    (SELECT quantity FROM menu_item_component WHERE id = pg_temp.sc_id('s3_thanh_phan'));
END $$;
