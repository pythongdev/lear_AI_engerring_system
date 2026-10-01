-- Đọc lại ba scenario ở một KẾT NỐI KHÁC, sau khi mọi bước đã COMMIT (P2-13,
-- docs/product/2-db/11-cong-chat-luong-pha-2.md §1–§3). Mỗi khối kiểm các dòng *Kết quả mong đợi*
-- của một scenario (docs/product/0-ba/ban-hang/08-scenario.md §8) bằng QUAN HỆ đọc từ database, rồi
-- in con số. Không một con giá nào ở đây (ADR-001): con số in ra được cộng tay từ
-- master_plan/shop-facts.md ở file cổng §4. Một dòng sai ⇒ RAISE EXCEPTION ⇒ db-check FAIL.
--
-- Không đọc bảng tạm nào của lúc diễn (chúng đã mất cùng phiên ấy): mọi thứ tìm lại từ dữ liệu của
-- NGÀY DIỄN — phiên của bàn 5 và bàn 3, ba đơn lẻ. Database kiểm còn giữ những gì bước trước đã
-- COMMIT (test i024 COMMIT một đơn qua dblink, có chủ ý), nên mọi phép tìm neo vào ngày ấy.

\set ON_ERROR_STOP 1
\set QUIET 1

CREATE FUNCTION pg_temp.dl_dung(p_dieu_kien boolean, p_cau text) RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
  IF p_dieu_kien IS NOT TRUE THEN RAISE EXCEPTION 'đọc lại: SAI — %', p_cau; END IF;
END $f$;
-- Ngày diễn: ngày mai của múi giờ kết nối (prelude.sql sc_ngay), và một mốc có thuộc ngày ấy không.
CREATE FUNCTION pg_temp.dl_ngay() RETURNS date LANGUAGE sql STABLE AS $f$
  SELECT (now() AT TIME ZONE current_setting('TimeZone'))::date + 1
$f$;
CREATE FUNCTION pg_temp.dl_cua_ngay(p timestamptz) RETURNS boolean LANGUAGE sql STABLE AS $f$
  SELECT (p AT TIME ZONE current_setting('TimeZone'))::date = pg_temp.dl_ngay()
$f$;
-- Phiên của một bàn trong ngày diễn: phiên có lượt gọi tạo trong ngày ấy.
CREATE FUNCTION pg_temp.dl_phien(p_ban text) RETURNS bigint LANGUAGE sql STABLE AS $f$
  SELECT DISTINCT m.table_session_id FROM table_session_member m
  JOIN dining_table t ON t.id = m.dining_table_id
  JOIN sales_order o ON o.table_session_id = m.table_session_id
  WHERE t.label = p_ban AND pg_temp.dl_cua_ngay(o.created_at)
$f$;
CREATE FUNCTION pg_temp.dl_tong(p_don bigint) RETURNS bigint LANGUAGE sql STABLE AS $f$
  SELECT coalesce(sum(line_total_vnd), 0) FROM order_line WHERE sales_order_id = p_don
$f$;
-- Các trạng thái một dòng đã đi qua, đọc từ vết cập nhật (mọi bước của lúc diễn khai lý do).
CREATE FUNCTION pg_temp.dl_duong(p_bang text, p_id bigint) RETURNS text LANGUAGE sql STABLE AS $f$
  SELECT string_agg(before_image ->> 'status' || '→' || (after_image ->> 'status'), ' ' ORDER BY revised_at, id)
  FROM record_revision
  WHERE target_table_code = p_bang AND target_row = p_id
    AND before_image ->> 'status' IS DISTINCT FROM after_image ->> 'status'
$f$;

-- ============================================================ Scenario 1
DO $$
DECLARE s bigint; n_phien int; n_hd int; b record; don bigint[]; l1 bigint; l2 bigint; l3 bigint;
        bat_dau_thu timestamptz; bep text; n_nhom int;
BEGIN
  SELECT count(DISTINCT m.table_session_id) INTO n_phien
    FROM table_session_member m JOIN dining_table t ON t.id = m.dining_table_id
    JOIN sales_order o ON o.table_session_id = m.table_session_id
   WHERE t.label = '5' AND pg_temp.dl_cua_ngay(o.created_at);
  PERFORM pg_temp.dl_dung(n_phien = 1, 'S1 — số phiên mở cho bàn 5 phải là 1, đọc ra ' || n_phien);
  s := pg_temp.dl_phien('5');
  SELECT array_agg(id ORDER BY created_at) INTO don FROM sales_order WHERE table_session_id = s;
  l1 := don[1]; l2 := don[2]; l3 := don[3];
  PERFORM pg_temp.dl_dung(cardinality(don) = 3, 'S1 — ba lượt gọi');
  PERFORM pg_temp.dl_dung(
    (SELECT array_agg(channel_code ORDER BY created_at) FROM sales_order WHERE table_session_id = s)
      = ARRAY['qr_table', 'staff_pos', 'qr_table'], 'S1 — ba lượt, hai kênh: qr_table · staff_pos · qr_table');
  SELECT count(*) INTO n_hd FROM bill WHERE table_session_id = s;
  PERFORM pg_temp.dl_dung(n_hd = 1, 'S1 — số hoá đơn / số lần thanh toán phải là 1, đọc ra ' || n_hd);
  SELECT * INTO b FROM bill WHERE table_session_id = s;
  PERFORM pg_temp.dl_dung(b.due_vnd = pg_temp.dl_tong(l1) + pg_temp.dl_tong(l2) + pg_temp.dl_tong(l3),
                          'S1 — hoá đơn bằng tổng ba lượt');
  -- Lượt 3 gửi SAU lúc phiên lần đầu sang Chờ thanh toán, và vẫn nằm trong chính hoá đơn ấy.
  SELECT min(revised_at) INTO bat_dau_thu FROM record_revision
   WHERE target_table_code = 'table_session' AND target_row = s AND after_image ->> 'status' = 'awaiting_payment';
  PERFORM pg_temp.dl_dung((SELECT created_at FROM sales_order WHERE id = l3) > bat_dau_thu,
                          'S1 — lượt 3 gửi sau khi quầy đã bắt đầu thu tiền');
  PERFORM pg_temp.dl_dung(b.cash_vnd > 0 AND b.transfer_vnd > 0 AND b.cash_vnd + b.transfer_vnd = b.due_vnd
                          AND b.debt_vnd = 0, 'S1 — hai phương thức trên một lần thu, cộng đúng số phải trả');
  -- Bếp nhận được ở lượt 1: đếm theo (thành phần, trạm), khác con số ×2 suất trên hoá đơn.
  SELECT string_agg(format('%s %s×%s', tram, coalesce(ten, 'nước chấm'), n), ' · ' ORDER BY tram, ten), count(*)
    INTO bep, n_nhom
    FROM (SELECT j.station_code tram, c.component_name ten, count(*) n
          FROM station_job j LEFT JOIN order_line_component c ON c.id = j.order_line_component_id
          WHERE j.sales_order_id = l1 GROUP BY 1, 2) x;
  PERFORM pg_temp.dl_dung(n_nhom = 6, 'S1 — lượt 1 sinh sáu việc (thành phần × trạm), đọc ra ' || n_nhom);
  PERFORM pg_temp.dl_dung(
    (SELECT count(*) FROM station_job WHERE sales_order_id = l1 AND station_code = 'trang_banh'
       AND order_line_component_id IN (SELECT id FROM order_line_component WHERE component_name = 'Bánh cuốn'))
    = (SELECT sum(x.quantity * c.quantity) FROM order_line x JOIN order_line_component c ON c.order_line_id = x.id
        WHERE x.sales_order_id = l1 AND c.component_name = 'Bánh cuốn'),
    'S1 — số bánh bếp tráng = số suất × số bánh mỗi suất (không phải số suất)');
  PERFORM pg_temp.dl_dung(NOT EXISTS (SELECT 1 FROM sales_order WHERE table_session_id = s AND status <> 'completed'),
                          'S1 — mọi đơn của phiên Hoàn thành');
  PERFORM pg_temp.dl_dung(NOT EXISTS (SELECT 1 FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
                                      WHERE o.table_session_id = s AND j.status <> 'served'),
                          'S1 — mọi việc trạm của cả ba lượt đã ra bàn');
  PERFORM pg_temp.dl_dung((SELECT is_closed FROM table_session WHERE id = s)
                          AND (SELECT cleaned_at IS NOT NULL FROM table_session_member WHERE table_session_id = s),
                          'S1 — bàn 5 trống: phiên đã đóng và đã dọn');
  RAISE NOTICE 'S1 đọc lại: 1 phiên · 1 hoá đơn % đ = lượt 1 % + lượt 2 % + lượt 3 % · tiền mặt % + chuyển khoản % · ngày bán % lúc % · người thu %',
    b.due_vnd, pg_temp.dl_tong(l1), pg_temp.dl_tong(l2), pg_temp.dl_tong(l3), b.cash_vnd, b.transfer_vnd,
    b.sale_date, to_char(b.booked_at, 'HH24:MI'), (SELECT display_name FROM person WHERE id = b.person_id);
  RAISE NOTICE 'S1 đọc lại: lượt 3 gửi % — sau lúc bắt đầu thu % · bếp lượt 1: %',
    to_char((SELECT created_at FROM sales_order WHERE id = l3), 'HH24:MI'), to_char(bat_dau_thu, 'HH24:MI'), bep;
  RAISE NOTICE 'S1 đọc lại: đường của phiên: % · lượt 1: % · lượt 2: %',
    pg_temp.dl_duong('table_session', s), pg_temp.dl_duong('sales_order', l1), pg_temp.dl_duong('sales_order', l2);
END $$;

-- ============================================================ Scenario 2
DO $$
DECLARE a bigint; b bigint; c bigint; ba record; bb record; bc record; p record; n_don int;
BEGIN
  SELECT id INTO STRICT a FROM sales_order WHERE channel_code = 'delivery' AND pg_temp.dl_cua_ngay(created_at);
  SELECT id INTO STRICT b FROM sales_order WHERE channel_code = 'pickup' AND pg_temp.dl_cua_ngay(created_at);
  SELECT id INTO STRICT c FROM sales_order WHERE channel_code = 'phone_preorder' AND pg_temp.dl_cua_ngay(created_at);
  SELECT count(*) INTO n_don FROM sales_order WHERE table_session_id IS NULL AND pg_temp.dl_cua_ngay(created_at);
  PERFORM pg_temp.dl_dung(n_don = 3, 'S2 — ba đơn, không đơn nào gắn phiên bàn');
  SELECT * INTO STRICT ba FROM bill WHERE sales_order_id = a;
  SELECT * INTO STRICT bb FROM bill WHERE sales_order_id = b;
  SELECT * INTO STRICT bc FROM bill WHERE sales_order_id = c;
  PERFORM pg_temp.dl_dung((SELECT customer_phone FROM sales_order WHERE id = a)
                          = (SELECT customer_phone FROM sales_order WHERE id = c) AND ba.id <> bc.id,
                          'S2 — đơn A và C cùng khách mà hai đơn vị thanh toán');
  PERFORM pg_temp.dl_dung(ba.due_vnd = pg_temp.dl_tong(a) AND bb.due_vnd = pg_temp.dl_tong(b)
                          AND bc.due_vnd = pg_temp.dl_tong(c), 'S2 — mỗi hoá đơn bằng tổng đơn của nó');
  PERFORM pg_temp.dl_dung(NOT EXISTS (SELECT 1 FROM sales_order WHERE id IN (a, b, c) AND status <> 'completed'),
                          'S2 — ba đơn Hoàn thành');
  PERFORM pg_temp.dl_dung(pg_temp.dl_duong('sales_order', c) NOT LIKE '%pending_confirmation%'
                          AND pg_temp.dl_duong('sales_order', c) LIKE 'new→confirmed%',
                          'S2 — đơn C: Mới → thẳng Đã xác nhận');
  PERFORM pg_temp.dl_dung((SELECT array_agg(DISTINCT target_row) FROM record_revision
                            WHERE target_table_code = 'sales_order' AND after_image ->> 'status' = 'delivering'
                              AND target_row IN (a, b, c))
                          = ARRAY[a], 'S2 — chỉ đơn A có Đang giao');
  PERFORM pg_temp.dl_dung((SELECT count(*) FROM station_job WHERE sales_order_id IN (a, b, c)
                            AND order_line_id IS NULL) = 3
                          AND (SELECT count(DISTINCT sales_order_id) FROM station_job
                                WHERE sales_order_id IN (a, b, c) AND order_line_id IS NULL) = 3,
                          'S2 — ba việc nước chấm, mỗi đơn một');
  PERFORM pg_temp.dl_dung(NOT EXISTS (SELECT 1 FROM station_job WHERE sales_order_id IN (a, b, c) AND status <> 'served'),
                          'S2 — Hoàn thành khi mọi việc đã ra (đã trao)');
  SELECT * INTO STRICT p FROM prepayment WHERE sales_order_id = b;
  PERFORM pg_temp.dl_dung(p.booked_at > (SELECT created_at FROM sales_order WHERE id = b)
                          AND p.transfer_vnd + p.cash_vnd = bb.due_vnd
                          AND bb.cash_vnd + bb.transfer_vnd = 0 AND bb.prepaid_transfer_vnd = bb.due_vnd,
                          'S2 — đơn B: nhận tiền sau lúc gửi, trả trước đủ, lúc trao không thu lại');
  PERFORM pg_temp.dl_dung(ba.person_id <> bc.person_id, 'S2 — đơn A thu tại chỗ khách bởi người đi giao, C tại quầy');
  PERFORM pg_temp.dl_dung(NOT EXISTS (SELECT 1 FROM sales_order WHERE id IN (a, b, c) AND dining_table_id IS NOT NULL),
                          'S2 — không bước dọn bàn nào: không đơn nào có bàn');
  RAISE NOTICE 'S2 đọc lại: 3 đơn vị thanh toán · A % đ (tiền mặt, người thu %) · B % đ (trả trước chuyển khoản nhận % — hoá đơn lúc %) · C % đ (tiền mặt, %) · tổng % đ',
    ba.due_vnd, (SELECT display_name FROM person WHERE id = ba.person_id), bb.due_vnd,
    to_char(p.booked_at, 'HH24:MI'), to_char(bb.booked_at, 'HH24:MI'), bc.due_vnd,
    (SELECT display_name FROM person WHERE id = bc.person_id), ba.due_vnd + bb.due_vnd + bc.due_vnd;
  RAISE NOTICE 'S2 đọc lại: đường A: % · B: % · C: %', pg_temp.dl_duong('sales_order', a),
    pg_temp.dl_duong('sales_order', b), pg_temp.dl_duong('sales_order', c);
END $$;

-- ============================================================ Scenario 3
DO $$
DECLARE s bigint; l_cu record; l_moi record; hd record; chenh bigint; so_banh bigint; mc bigint;
        s1_l1 record; banh_anh_chup bigint; banh_menu int;
BEGIN
  s := pg_temp.dl_phien('3');
  SELECT l.* INTO STRICT l_cu FROM order_line l JOIN sales_order o ON o.id = l.sales_order_id
   WHERE o.table_session_id = s ORDER BY l.priced_at LIMIT 1;
  SELECT l.* INTO STRICT l_moi FROM order_line l JOIN sales_order o ON o.id = l.sales_order_id
   WHERE o.table_session_id = s ORDER BY l.priced_at DESC LIMIT 1;
  PERFORM pg_temp.dl_dung(l_cu.id <> l_moi.id AND l_cu.menu_item_id = l_moi.menu_item_id,
                          'S3 — hai dòng cùng món');
  PERFORM pg_temp.dl_dung(
    (SELECT array_agg(menu_option_id ORDER BY menu_option_id) FROM order_line_option WHERE order_line_id = l_cu.id)
    = (SELECT array_agg(menu_option_id ORDER BY menu_option_id) FROM order_line_option WHERE order_line_id = l_moi.id),
    'S3 — hai dòng cùng tuỳ chọn');
  -- Phần chênh phải bằng đúng lần đổi giá gốc × số bánh của một suất — đọc cả hai từ database.
  SELECT id INTO mc FROM menu_component WHERE name = 'Bánh cuốn';
  SELECT (after_image ->> 'base_price_vnd')::bigint - (before_image ->> 'base_price_vnd')::bigint INTO STRICT chenh
    FROM record_revision WHERE target_table_code = 'menu_component' AND target_row = mc
     AND pg_temp.dl_cua_ngay(revised_at);
  SELECT sum(quantity) INTO so_banh FROM order_line_component WHERE order_line_id = l_cu.id AND menu_component_id = mc;
  PERFORM pg_temp.dl_dung(chenh > 0 AND l_moi.unit_price_vnd - l_cu.unit_price_vnd = so_banh * chenh,
                          'S3 — dòng 9:00 đắt hơn dòng 8:00 đúng (số bánh × phần tăng giá gốc)');
  PERFORM pg_temp.dl_dung(l_cu.priced_at < (SELECT revised_at FROM record_revision
                                             WHERE target_table_code = 'menu_component' AND target_row = mc
                                               AND pg_temp.dl_cua_ngay(revised_at))
                          AND l_moi.priced_at > (SELECT revised_at FROM record_revision
                                                  WHERE target_table_code = 'menu_component' AND target_row = mc
                                               AND pg_temp.dl_cua_ngay(revised_at)),
                          'S3 — một dòng khoá trước lần đổi, một dòng sau');
  SELECT * INTO STRICT hd FROM bill WHERE table_session_id = s;
  PERFORM pg_temp.dl_dung(hd.due_vnd = l_cu.line_total_vnd + l_moi.line_total_vnd,
                          'S3 — một hoá đơn bằng hai dòng, hai mức giá');
  PERFORM pg_temp.dl_dung((SELECT discontinued_at IS NOT NULL FROM menu_item WHERE id = l_cu.menu_item_id)
                          AND l_cu.item_name = (SELECT name FROM menu_item WHERE id = l_cu.menu_item_id),
                          'S3 — món đã ngừng bán, dòng cũ vẫn đúng tên');
  -- Đơn Scenario 1 sau khi thành phần combo đổi: ảnh chụp, không phải menu hiện hành.
  SELECT l.* INTO STRICT s1_l1 FROM order_line l JOIN sales_order o ON o.id = l.sales_order_id
   WHERE o.table_session_id = pg_temp.dl_phien('5') ORDER BY l.priced_at LIMIT 1;
  SELECT sum(s1_l1.quantity * c.quantity) INTO banh_anh_chup FROM order_line_component c
   WHERE c.order_line_id = s1_l1.id AND c.menu_component_id = mc;
  SELECT ic.quantity INTO banh_menu FROM menu_item_component ic
   WHERE ic.menu_item_id = s1_l1.menu_item_id AND ic.menu_component_id = mc;
  PERFORM pg_temp.dl_dung(banh_anh_chup <> s1_l1.quantity * banh_menu,
                          'S3 — đơn S1 đọc số bánh từ ảnh chụp, khác menu hiện hành');
  PERFORM pg_temp.dl_dung(EXISTS (SELECT 1 FROM record_revision r JOIN person p ON p.id = r.person_id
                                  WHERE r.target_table_code = 'menu_item_component' AND p.is_owner
                                    AND pg_temp.dl_cua_ngay(r.revised_at)
                                    AND btrim(r.reason) <> ''),
                          'S3 — đổi thành phần giữa buổi xảy ra được, có vết người và lý do');
  PERFORM pg_temp.dl_dung(NOT EXISTS (SELECT 1 FROM bill x WHERE x.sale_date = pg_temp.dl_ngay() AND x.due_vnd <> coalesce(
      (SELECT sum(l.line_total_vnd) FROM order_line l JOIN sales_order o ON o.id = l.sales_order_id
        WHERE o.id = x.sales_order_id OR o.table_session_id = x.table_session_id), 0)),
    'S3 — sau mọi lần đổi menu, mỗi hoá đơn của ngày vẫn bằng tổng dòng của nó');
  RAISE NOTICE 'S3 đọc lại: dòng 8:00 % đ · dòng 9:00 % đ · chênh % = % bánh × % · hoá đơn bàn 3 % đ · món "%" ngừng bán lúc %',
    l_cu.unit_price_vnd, l_moi.unit_price_vnd, l_moi.unit_price_vnd - l_cu.unit_price_vnd, so_banh, chenh,
    hd.due_vnd, l_cu.item_name, to_char((SELECT discontinued_at FROM menu_item WHERE id = l_cu.menu_item_id), 'HH24:MI');
  RAISE NOTICE 'S3 đọc lại: đơn S1 lượt 1 % đ · % cái bánh theo ảnh chụp (menu hiện hành: % cái/suất × % suất)',
    s1_l1.line_total_vnd, banh_anh_chup, banh_menu, s1_l1.quantity;
END $$;

-- Tiền của cả ba scenario, cộng từ hoá đơn — so với phép cộng tay ở file cổng §4.
SELECT format('TIỀN ba scenario: S1 %s · S2 %s · S3 %s · cộng %s đ',
  (SELECT due_vnd FROM bill WHERE table_session_id = pg_temp.dl_phien('5')),
  (SELECT sum(due_vnd) FROM bill WHERE sales_order_id IS NOT NULL AND sale_date = pg_temp.dl_ngay()),
  (SELECT due_vnd FROM bill WHERE table_session_id = pg_temp.dl_phien('3')),
  (SELECT sum(due_vnd) FROM bill WHERE sale_date = pg_temp.dl_ngay()));

-- S4 — kết nối này không có bảng tạm/hàm của lượt ghi. Các số mong đợi viết tay
-- từ dữ liệu diễn ở s4_ngay_quan_tri.sql; không dùng tổng vừa đọc làm đáp số.
DO $$
DECLARE v record; mua numeric; dung numeric; hieu numeric; rec record;
BEGIN
  PERFORM pg_temp.dl_dung((SELECT count(*) = 1 AND bool_and(purchase_unit IS NULL)
    FROM supply_item WHERE name = 'Hàng thêm S4 (dữ liệu diễn)'), 'S4.1 tên mới, đơn vị trống');
  RAISE NOTICE 'S4.1 đọc lại: một thứ mới, đơn vị trống';

  FOR v IN SELECT * FROM (VALUES
    (2, 'Gạo', -1, 10::numeric, 7::numeric),
    (3, 'Gạo', 0, 2::numeric, 6::numeric),
    (4, 'Hàng thêm S4 (dữ liệu diễn)', 0, 4::numeric, 1::numeric)
  ) x(buoc, ten, lech, mua, dung) LOOP
    PERFORM pg_temp.dl_dung((SELECT count(*) = 2
      AND sum(e.entered_measure) FILTER (WHERE e.kind_code = 'purchased') = v.mua
      AND sum(e.entered_measure) FILTER (WHERE e.kind_code = 'used') = v.dung
      AND bool_and(p.display_name = 'Chủ quán' AND e.created_at IS NOT NULL)
      FROM supply_day_entry e JOIN supply_item i ON i.id = e.supply_item_id
      JOIN person p ON p.id = e.person_id
      WHERE i.name = v.ten AND e.entry_date = pg_temp.dl_ngay() + v.lech),
      format('S4.%s cặp số ngày và người nhập', v.buoc));
    RAISE NOTICE 'S4.% đọc lại: % mua %, dùng %, Chủ quán nhập, có lúc ghi', v.buoc, v.ten, v.mua, v.dung;
  END LOOP;
  -- Một lần quét cộng từ con số ngày, không lọc lần mua cuối hay đặt lại tổng.
  SELECT sum(e.entered_measure) FILTER (WHERE e.kind_code = 'purchased'),
         sum(e.entered_measure) FILTER (WHERE e.kind_code = 'used') INTO mua, dung
  FROM supply_day_entry e JOIN supply_item i ON i.id = e.supply_item_id WHERE i.name = 'Gạo';
  hieu := mua - dung;
  PERFORM pg_temp.dl_dung(mua = 12 AND dung = 13 AND hieu = -1, 'S4 tổng Gạo 12, 13, -1');
  RAISE NOTICE 'S4 tổng Gạo: mua % · dùng % · hiệu số % (âm được đọc)', mua, dung, hieu;

  PERFORM pg_temp.dl_dung((SELECT count(*) = 1 AND bool_and(a.cancelled_at IS NULL
      AND p.display_name = 'Chủ quán' AND a.created_at IS NOT NULL)
    FROM attendance_day a JOIN person w ON w.id = a.worker_person_id JOIN person p ON p.id = a.person_id
    WHERE w.display_name = 'Người đứng quầy' AND a.work_date = pg_temp.dl_ngay()), 'S4.5 ô còn hiệu lực');
  RAISE NOTICE 'S4.5 đọc lại: Người đứng quầy có đi làm, Chủ quán tick';
  SELECT x.*, p.display_name AS nguoi_tick, c.display_name AS nguoi_huy INTO STRICT rec
    FROM attendance_day x JOIN person w ON w.id = x.worker_person_id
    JOIN person p ON p.id = x.person_id JOIN person c ON c.id = x.cancelled_by_person_id
    WHERE w.display_name = 'Người canh & dọn' AND x.work_date = pg_temp.dl_ngay();
  PERFORM pg_temp.dl_dung(rec.nguoi_tick = 'Chủ quán' AND rec.created_at IS NOT NULL,
    'S4.6 ô tick nhầm vẫn đọc được người và lúc tick');
  RAISE NOTICE 'S4.6 đọc lại: ô Người canh & dọn vẫn còn, Chủ quán tick';
  PERFORM pg_temp.dl_dung(rec.nguoi_huy = 'Chủ quán' AND rec.cancelled_at >= rec.created_at
    AND rec.cancel_note = 'Tick nhầm người (dữ liệu diễn)', 'S4.7 ai huỷ, lúc huỷ, ghi chú');
  RAISE NOTICE 'S4.7 đọc lại: người huỷ % · ghi chú %', rec.nguoi_huy, rec.cancel_note;

  SELECT x.*, w.display_name AS nguoi_nhan, p.display_name AS nguoi_ghi,
    c.display_name AS nguoi_duyet INTO STRICT rec FROM staff_advance x
    JOIN person w ON w.id = x.worker_person_id JOIN person p ON p.id = x.person_id
    JOIN person c ON c.id = x.approver_person_id WHERE x.paid_date = pg_temp.dl_ngay();
  PERFORM pg_temp.dl_dung(rec.amount_vnd = 100000 AND rec.nguoi_nhan = 'Người đứng quầy'
    AND rec.nguoi_duyet = 'Chủ quán' AND rec.nguoi_ghi = 'Chủ quán' AND rec.created_at IS NOT NULL,
    'S4.8 tạm ứng và người duyệt');
  RAISE NOTICE 'S4.8 đọc lại: tạm ứng % đ · người duyệt %', rec.amount_vnd, rec.nguoi_duyet;
  SELECT x.*, w.display_name AS nguoi_nhan, p.display_name AS nguoi_ghi INTO STRICT rec
    FROM holiday_bonus x JOIN person w ON w.id = x.worker_person_id JOIN person p ON p.id = x.person_id
    WHERE x.paid_date = pg_temp.dl_ngay();
  PERFORM pg_temp.dl_dung(rec.amount_vnd = 50000 AND rec.nguoi_nhan = 'Người canh & dọn'
    AND rec.nguoi_ghi = 'Chủ quán' AND rec.created_at IS NOT NULL, 'S4.9 khoản thưởng');
  RAISE NOTICE 'S4.9 đọc lại: thưởng % đ · người ghi %', rec.amount_vnd, rec.nguoi_ghi;
END $$;
