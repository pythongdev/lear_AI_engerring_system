-- Ngày bán mẫu ĐÚNG của bộ chứng minh (P2-11, docs/product/2-db/09-doi-chieu-bat-bien.md §3).
-- scripts/db-check.sh chạy file này trên dữ liệu mồi, trong một giao dịch không bao giờ COMMIT, rồi
-- chạy cả bộ đối chiếu: mọi câu phải ra 0 dòng — một câu xanh vì chưa có đơn nào không chứng minh
-- nó không đỏ nhầm. Mỗi file lỗi bên cạnh cài MỘT chỗ sai lên trên ngày này.
--
-- Các hàm pg_temp.bc_* ĐỨNG THAY những cửa mà pha 3 sẽ viết (tạo lượt gọi, nổ đơn, bấm mẻ, đóng
-- phiên) — chúng không phải các cửa ấy và không quyết luật nào mới; thứ tự trạng thái theo
-- 05-vong-doi.md §5, phép tính giá theo db/seed/seed.pl --price-cases. Ngày bán là NGÀY MAI của
-- múi giờ kết nối, để mọi mốc của ngày đứng sau lúc dựng dữ liệu mồi. Mọi lần sửa khai lý do, nên
-- mỗi lần chuyển trạng thái để lại vết (I-016 có dữ liệu thật để đọc).

-- Mốc hh:mm của ngày bán mẫu (d = 0) hay ngày sau nó (d = 1), theo múi giờ của kết nối (QD-32).
CREATE FUNCTION pg_temp.bc_luc(p_gio text, p_d integer DEFAULT 0) RETURNS timestamptz
LANGUAGE sql STABLE AS $f$
  SELECT ((now() AT TIME ZONE current_setting('TimeZone'))::date + 1 + p_d + p_gio::time)
         AT TIME ZONE current_setting('TimeZone')
$f$;
CREATE FUNCTION pg_temp.bc_ngay(p_d integer DEFAULT 0) RETURNS date LANGUAGE sql STABLE AS $f$
  SELECT (now() AT TIME ZONE current_setting('TimeZone'))::date + 1 + p_d
$f$;
CREATE FUNCTION pg_temp.bc_nguoi(p_ten text) RETURNS bigint LANGUAGE sql STABLE AS $f$
  SELECT id FROM person WHERE display_name = p_ten
$f$;
CREATE FUNCTION pg_temp.bc_ban(p_so text) RETURNS bigint LANGUAGE sql STABLE AS $f$
  SELECT id FROM dining_table WHERE label = p_so
$f$;

-- Lỗi cài cần một lần đổi KHÔNG vết: từ T-138 (chế độ nghiêm, ADR-092) database từ chối lần sửa không
-- khai lý do, nên lỗi cài tắt đúng các trigger vết của một bảng — dữ liệu mà một đường vượt database
-- (chủ lược đồ sửa tay) để lại, thứ bộ đối chiếu vẫn phải thấy. Lỗi cài bật lại ngay sau lần đổi lén:
-- QD-52 kêu khi một trigger vết còn tắt. ALTER TABLE không chạy khi bảng còn sự kiện ràng buộc hoãn,
-- nên chấm hết chúng trước (trạng thái lúc ấy phải đứng được, như lúc COMMIT).
CREATE FUNCTION pg_temp.bc_vet(p_bang text, p_bat boolean) RETURNS void LANGUAGE plpgsql AS $f$
DECLARE t text;
BEGIN
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  FOR t IN SELECT tgname FROM pg_trigger
           WHERE tgrelid = p_bang::regclass AND NOT tgisinternal
             AND tgfoid IN ('record_revision_capture'::regproc, 'record_revision_capture_added_line'::regproc)
  LOOP
    EXECUTE format('ALTER TABLE %I %s TRIGGER %I', p_bang, CASE WHEN p_bat THEN 'ENABLE' ELSE 'DISABLE' END, t);
  END LOOP;
END $f$;

-- Giá một suất (shop-facts §4.6 luật 1 · 5), NULL khi tổ hợp không hợp lệ (luật 3).
CREATE FUNCTION pg_temp.bc_gia(it bigint, sel bigint[]) RETURNS bigint LANGUAGE plpgsql AS $f$
DECLARE bad int; base bigint; n_fill bigint; sur bigint;
BEGIN
  SELECT count(*) INTO bad FROM menu_option o
   WHERE o.id = ANY (sel)
     AND (NOT EXISTS (SELECT 1 FROM menu_item_option_group m
                       WHERE m.menu_item_id = it AND m.option_group_id = o.option_group_id)
          OR (EXISTS (SELECT 1 FROM option_group_prerequisite p WHERE p.option_group_id = o.option_group_id)
              AND NOT EXISTS (SELECT 1 FROM option_group_prerequisite p
                               WHERE p.option_group_id = o.option_group_id AND p.menu_option_id = ANY (sel))));
  IF bad > 0 THEN RETURN NULL; END IF;
  SELECT sum(mic.quantity * c.base_price_vnd), coalesce(sum(mic.quantity) FILTER (WHERE c.takes_filling), 0)
    INTO base, n_fill
    FROM menu_item_component mic JOIN menu_component c ON c.id = mic.menu_component_id
   WHERE mic.menu_item_id = it;
  SELECT coalesce(sum(surcharge_vnd), 0) INTO sur FROM menu_option WHERE id = ANY (sel);
  RETURN base + n_fill * sur;
END $f$;

-- Tạo một đơn (lượt gọi) với dấu lần gửi mới. Kênh gắn bàn: phiên + bàn (+ mã QR hiện hành).
CREATE FUNCTION pg_temp.bc_don(p_kenh text, p_phien bigint, p_ban bigint, p_luc timestamptz)
RETURNS bigint LANGUAGE plpgsql AS $f$
DECLARE o bigint;
BEGIN
  INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, qr_code_id,
                           submission_code, created_at)
  VALUES (p_kenh, 'new', p_phien, p_ban,
          CASE WHEN p_kenh = 'qr_table' THEN
            (SELECT id FROM qr_code WHERE dining_table_id = p_ban AND replaced_at IS NULL) END,
          gen_random_uuid()::text, p_luc)
  RETURNING id INTO o;
  RETURN o;
END $f$;

-- Gọi một món: dòng đơn + ảnh chụp thành phần và tuỳ chọn, giá và mốc khoá tại lúc gọi (I-009).
CREATE FUNCTION pg_temp.bc_mon(p_don bigint, p_mon text, p_so integer, p_tc text[])
RETURNS bigint LANGUAGE plpgsql AS $f$
DECLARE it bigint; sel bigint[]; price bigint; n integer; l bigint;
        luc timestamptz := (SELECT created_at FROM sales_order WHERE id = p_don);
BEGIN
  SELECT id INTO STRICT it FROM menu_item WHERE name = p_mon;
  SELECT coalesce(array_agg(id), '{}') INTO sel FROM menu_option WHERE name = ANY (p_tc);
  price := pg_temp.bc_gia(it, sel);
  IF price IS NULL THEN RAISE EXCEPTION 'ngày mẫu: tổ hợp không hợp lệ % %', p_mon, p_tc; END IF;
  SELECT count(*) INTO n FROM menu_item_component WHERE menu_item_id = it;
  INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd,
                          component_count, priced_at, created_at)
  VALUES (p_don, p_so, it, p_mon, price, n, luc, luc) RETURNING id INTO l;
  INSERT INTO order_line_component (order_line_id, position, line_component_count, menu_component_id,
                                    component_name, quantity, takes_filling, base_price_vnd)
  SELECT l, row_number() OVER (ORDER BY ic.id), n, ic.menu_component_id, mc.name, ic.quantity,
         mc.takes_filling, mc.base_price_vnd
  FROM menu_item_component ic JOIN menu_component mc ON mc.id = ic.menu_component_id
  WHERE ic.menu_item_id = it;
  INSERT INTO order_line_option (order_line_id, menu_option_id, option_group_name, option_name, surcharge_vnd)
  SELECT l, o.id, g.name, o.name, o.surcharge_vnd
  FROM menu_option o JOIN option_group g ON g.id = o.option_group_id WHERE o.id = ANY (sel);
  RETURN l;
END $f$;

-- Đã xác nhận → Đang thực hiện, và mọi việc trạm của đơn, cùng giao dịch (I-004).
CREATE FUNCTION pg_temp.bc_no(p_don bigint) RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
  UPDATE sales_order SET status = 'in_progress' WHERE id = p_don;
  INSERT INTO station_job (sales_order_id, order_line_id, order_line_component_id, station_code,
                           line_quantity, component_quantity, position)
  SELECT p_don, l.id, c.id, s.station_code, l.quantity, c.quantity, g.p
  FROM order_line l
  JOIN order_line_component c ON c.order_line_id = l.id
  JOIN menu_component_station s ON s.menu_component_id = c.menu_component_id
  CROSS JOIN LATERAL generate_series(1, l.quantity * c.quantity) AS g(p)
  WHERE l.sales_order_id = p_don;
  INSERT INTO station_job (sales_order_id, station_code, position) VALUES (p_don, 'canh', 1);
END $f$;

-- Một mẻ làm ra đúng các đơn vị đã nêu (quầy bấm "đã làm xong").
CREATE FUNCTION pg_temp.bc_me(p_viec bigint[]) RETURNS bigint LANGUAGE plpgsql AS $f$
DECLARE b bigint;
BEGIN
  INSERT INTO production_batch DEFAULT VALUES RETURNING id INTO b;
  INSERT INTO production_batch_item (production_batch_id, made_for_station_job_id, station_job_id)
  SELECT b, id, id FROM station_job WHERE id = ANY (p_viec);
  UPDATE station_job SET status = 'made' WHERE id = ANY (p_viec);
  RETURN b;
END $f$;

-- Làm hết việc còn chờ của một đơn trong một mẻ, rồi bưng ra bàn mọi thứ đã làm.
CREATE FUNCTION pg_temp.bc_lam_het(p_don bigint) RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
  PERFORM pg_temp.bc_me(ARRAY(SELECT id FROM station_job WHERE sales_order_id = p_don AND status = 'pending'));
  UPDATE station_job SET status = 'served' WHERE sales_order_id = p_don AND status = 'made';
END $f$;

-- Tổng các dòng của một đơn / của một phiên (đơn chưa huỷ).
CREATE FUNCTION pg_temp.bc_tong(p_don bigint) RETURNS bigint LANGUAGE sql STABLE AS $f$
  SELECT coalesce(sum(line_total_vnd), 0) FROM order_line WHERE sales_order_id = p_don
$f$;
CREATE FUNCTION pg_temp.bc_tong_phien(p_phien bigint) RETURNS bigint LANGUAGE sql STABLE AS $f$
  SELECT coalesce(sum(l.line_total_vnd), 0) FROM order_line l JOIN sales_order o ON o.id = l.sales_order_id
  WHERE o.table_session_id = p_phien AND o.status <> 'cancelled'
$f$;

-- Mở phiên cho một hay nhiều bàn (ghép bàn: một phiên nhiều bàn).
CREATE FUNCTION pg_temp.bc_phien(p_ban bigint[]) RETURNS bigint LANGUAGE plpgsql AS $f$
DECLARE s bigint;
BEGIN
  INSERT INTO table_session (status) VALUES ('open') RETURNING id INTO s;
  INSERT INTO table_session_member (table_session_id, dining_table_id) SELECT s, unnest(p_ban);
  RETURN s;
END $f$;

-- Tính tiền và đóng phiên, cùng giao dịch (I-017): hoá đơn + phiên + mọi bàn của phiên.
CREATE FUNCTION pg_temp.bc_dong(p_phien bigint, p_luc timestamptz, p_mat bigint, p_ck bigint,
                                p_no bigint DEFAULT 0, p_nguoi_no text DEFAULT NULL)
RETURNS bigint LANGUAGE plpgsql AS $f$
DECLARE b bigint;
BEGIN
  UPDATE table_session SET status = 'awaiting_payment' WHERE id = p_phien;
  INSERT INTO bill (table_session_id, due_vnd, cash_vnd, transfer_vnd, debt_vnd, debtor_name,
                    booked_at, sale_date)
  VALUES (p_phien, pg_temp.bc_tong_phien(p_phien), p_mat, p_ck, p_no, p_nguoi_no, p_luc,
          (p_luc AT TIME ZONE current_setting('TimeZone'))::date)
  RETURNING id INTO b;
  UPDATE table_session SET status = 'closed' WHERE id = p_phien;
  UPDATE table_session_member SET session_closed = true WHERE table_session_id = p_phien;
  RETURN b;
END $f$;

CREATE TEMP TABLE bc (ten text PRIMARY KEY, id bigint NOT NULL);

DO $$
DECLARE a bigint := pg_temp.bc_nguoi('Người đứng quầy');
        chu bigint := pg_temp.bc_nguoi('Chủ quán');
        giao bigint := pg_temp.bc_nguoi('Người gấp bánh');
        s bigint; s2 bigint; s7 bigint; s8 bigint; o bigint; o2 bigint; o7 bigint; o8 bigint;
        b bigint; p bigint; r bigint; due bigint; f bigint; it bigint; v_cho bigint; v_nhan bigint;
BEGIN
  PERFORM set_config('shop.revision_reason', 'ngày bán mẫu của bộ chứng minh P2-11', true);

  -- Chủ quán đổi mã QR của bàn 2 trước giờ mở cửa (U-062); mã cũ hết hiện hành ngay.
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  PERFORM qr_code_issue(pg_temp.bc_ban('2'));

  -- Người đứng quầy vào ca cả buổi, khai tiền đầu két (I-021: một con số, ngoài tiền đã thu).
  PERFORM set_config('shop.actor_person_id', a::text, true);
  INSERT INTO counter_duty (person_id, started_at, ended_at)
  VALUES (a, pg_temp.bc_luc('05:30'), pg_temp.bc_luc('11:30')),
         (a, pg_temp.bc_luc('06:00', 1), pg_temp.bc_luc('07:00', 1));
  INSERT INTO opening_float (sale_date) VALUES (pg_temp.bc_ngay()) RETURNING id INTO f;
  INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd)
  VALUES (f, 10000, 200000), (f, 5000, 100000);

  -- Bàn 5: QR gọi → quầy duyệt → nổ; quầy gọi thêm hộ; làm, bưng, tính tiền chia hai phương thức.
  s := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('5')]);
  o := pg_temp.bc_don('qr_table', s, pg_temp.bc_ban('5'), pg_temp.bc_luc('07:00'));
  PERFORM pg_temp.bc_mon(o, 'Đầy đủ trứng chín', 2, ARRAY['Thịt', 'Thường']);
  UPDATE sales_order SET status = 'pending_confirmation' WHERE id = o;
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.bc_no(o);
  UPDATE table_session SET status = 'serving' WHERE id = s;
  o2 := pg_temp.bc_don('staff_pos', s, pg_temp.bc_ban('5'), pg_temp.bc_luc('07:10'));
  PERFORM pg_temp.bc_mon(o2, 'Giò bán rời', 1, ARRAY[]::text[]);
  UPDATE sales_order SET status = 'confirmed' WHERE id = o2;
  PERFORM pg_temp.bc_no(o2);
  PERFORM pg_temp.bc_lam_het(o); PERFORM pg_temp.bc_lam_het(o2);
  UPDATE sales_order SET status = 'completed' WHERE id IN (o, o2);
  due := pg_temp.bc_tong_phien(s);
  b := pg_temp.bc_dong(s, pg_temp.bc_luc('07:40'), 20000, due - 20000);
  UPDATE table_session_member SET cleaned_at = pg_temp.bc_luc('07:45') WHERE table_session_id = s;
  INSERT INTO bc VALUES ('phien_5', s), ('don_5_qr', o), ('don_5_pos', o2), ('hoa_don_5', b);

  -- Bàn 3 + 4 ghép một phiên; mỗi bàn gọi một lượt; khách không đủ tiền ⇒ quán cho nợ (I-005).
  s2 := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('3'), pg_temp.bc_ban('4')]);
  o := pg_temp.bc_don('qr_table', s2, pg_temp.bc_ban('3'), pg_temp.bc_luc('08:00'));
  PERFORM pg_temp.bc_mon(o, 'Suất trứng tái', 1, ARRAY['Chay']);
  UPDATE sales_order SET status = 'pending_confirmation' WHERE id = o;
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.bc_no(o);
  UPDATE table_session SET status = 'serving' WHERE id = s2;
  o2 := pg_temp.bc_don('staff_pos', s2, pg_temp.bc_ban('4'), pg_temp.bc_luc('08:05'));
  PERFORM pg_temp.bc_mon(o2, 'Bánh cuốn', 2, ARRAY['Thịt + mộc nhĩ', 'Nhiều nhân']);
  UPDATE sales_order SET status = 'confirmed' WHERE id = o2;
  PERFORM pg_temp.bc_no(o2);
  PERFORM pg_temp.bc_lam_het(o); PERFORM pg_temp.bc_lam_het(o2);
  UPDATE sales_order SET status = 'completed' WHERE id IN (o, o2);
  due := pg_temp.bc_tong_phien(s2);
  b := pg_temp.bc_dong(s2, pg_temp.bc_luc('08:40'), 10000, 0, due - 10000, 'Anh Tư xóm trên');
  UPDATE table_session_member SET cleaned_at = pg_temp.bc_luc('08:45') WHERE table_session_id = s2;
  -- Sáng hôm sau khách trả nợ bằng chuyển khoản (YC-02 · YC-10: mốc riêng, không phải lần bán mới).
  INSERT INTO debt_collection (bill_id, debt_vnd, transfer_vnd, booked_at, sale_date)
  VALUES (b, due - 10000, due - 10000, pg_temp.bc_luc('06:30', 1), pg_temp.bc_ngay(1));
  INSERT INTO bc VALUES ('phien_ghep', s2), ('don_ghep_3', o), ('don_ghep_4', o2), ('hoa_don_no', b);

  -- Bàn 7 và bàn 8 cùng gọi suất trứng tái nhân thịt; mẻ làm quả trứng của bàn 7 thì bàn 7 huỷ đơn;
  -- quầy chuyển quả trứng đã làm sang bàn 8 đang chờ đúng thứ ấy (U-033, I-004 tầng 4).
  s7 := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('7')]);
  s8 := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('8')]);
  o7 := pg_temp.bc_don('staff_pos', s7, pg_temp.bc_ban('7'), pg_temp.bc_luc('09:00'));
  PERFORM pg_temp.bc_mon(o7, 'Suất trứng tái', 1, ARRAY['Thịt', 'Thường']);
  o8 := pg_temp.bc_don('staff_pos', s8, pg_temp.bc_ban('8'), pg_temp.bc_luc('09:01'));
  PERFORM pg_temp.bc_mon(o8, 'Suất trứng tái', 1, ARRAY['Thịt', 'Thường']);
  UPDATE sales_order SET status = 'confirmed' WHERE id IN (o7, o8);
  PERFORM pg_temp.bc_no(o7); PERFORM pg_temp.bc_no(o8);
  UPDATE table_session SET status = 'serving' WHERE id IN (s7, s8);
  SELECT j.id INTO v_cho FROM station_job j JOIN order_line_component c ON c.id = j.order_line_component_id
   WHERE j.sales_order_id = o7 AND j.station_code = 'trang_banh' AND c.component_name = 'Trứng tái';
  SELECT j.id INTO v_nhan FROM station_job j JOIN order_line_component c ON c.id = j.order_line_component_id
   WHERE j.sales_order_id = o8 AND j.station_code = 'trang_banh' AND c.component_name = 'Trứng tái';
  PERFORM pg_temp.bc_me(ARRAY[v_cho]);
  UPDATE sales_order SET status = 'cancelled' WHERE id = o7;
  SELECT id INTO it FROM production_batch_item WHERE station_job_id = v_cho;
  UPDATE production_batch_item SET station_job_id = v_nhan WHERE id = it;
  INSERT INTO station_job_transfer (production_batch_item_id, from_station_job_id, to_station_job_id)
  VALUES (it, v_cho, v_nhan);
  UPDATE station_job SET status = 'pending' WHERE id = v_cho;
  UPDATE station_job SET status = 'made' WHERE id = v_nhan;
  PERFORM pg_temp.bc_lam_het(o8);
  UPDATE sales_order SET status = 'completed' WHERE id = o8;
  PERFORM pg_temp.bc_dong(s7, pg_temp.bc_luc('09:30'), 0, 0);
  b := pg_temp.bc_dong(s8, pg_temp.bc_luc('09:35'), pg_temp.bc_tong_phien(s8), 0);
  UPDATE table_session_member SET cleaned_at = pg_temp.bc_luc('09:40') WHERE table_session_id IN (s7, s8);
  INSERT INTO bc VALUES ('phien_7', s7), ('phien_8', s8), ('don_7_huy', o7), ('don_8', o8),
                        ('viec_cho', v_cho), ('viec_nhan', v_nhan), ('hoa_don_8', b);

  -- Đơn giao tận nơi, khách chuyển khoản trả trước đủ; người đi giao bấm đã giao + đã thu (U-057).
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, delivery_address,
                           submission_code, created_at)
  VALUES ('delivery', 'new', 'door_delivery', '0900000009', '9 Hàng Bạc', gen_random_uuid()::text,
          pg_temp.bc_luc('08:30')) RETURNING id INTO o;
  PERFORM pg_temp.bc_mon(o, 'Đầy đủ trứng vàng', 2, ARRAY['Chay']);
  due := pg_temp.bc_tong(o);
  INSERT INTO prepayment (sales_order_id, transfer_vnd, booked_at, sale_date)
  VALUES (o, due, pg_temp.bc_luc('08:31'), pg_temp.bc_ngay()) RETURNING id INTO p;
  UPDATE sales_order SET status = 'pending_confirmation' WHERE id = o;
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.bc_no(o);
  PERFORM pg_temp.bc_lam_het(o);
  UPDATE sales_order SET status = 'delivering' WHERE id = o;
  UPDATE sales_order SET status = 'completed' WHERE id = o;
  INSERT INTO bill (sales_order_id, due_vnd, prepaid_transfer_vnd, person_id, booked_at, sale_date)
  VALUES (o, due, due, giao, pg_temp.bc_luc('09:10'), pg_temp.bc_ngay()) RETURNING id INTO b;
  INSERT INTO prepayment_use (prepayment_id, sales_order_id, use_no, cash_before_vnd,
                              transfer_before_vnd, take_transfer_vnd, bill_id)
  VALUES (p, o, 1, 0, due, due, b);
  INSERT INTO bc VALUES ('don_giao', o), ('tra_truoc_giao', p), ('hoa_don_giao', b);

  -- Đơn tới lấy trả tiền mặt; sau đó quầy hoàn một phần bằng chuyển khoản — hoàn CHÉO (I-021).
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code, created_at)
  VALUES ('pickup', 'new', 'shop_pickup', '0900000010', pg_temp.bc_luc('09:30'),
          gen_random_uuid()::text, pg_temp.bc_luc('09:00')) RETURNING id INTO o;
  PERFORM pg_temp.bc_mon(o, 'Suất giò', 1, ARRAY['Thịt']);
  UPDATE sales_order SET status = 'pending_confirmation' WHERE id = o;
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.bc_no(o);
  PERFORM pg_temp.bc_lam_het(o);
  UPDATE sales_order SET status = 'completed' WHERE id = o;
  INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, booked_at, sale_date)
  VALUES (o, pg_temp.bc_tong(o), pg_temp.bc_tong(o), pg_temp.bc_luc('09:30'), pg_temp.bc_ngay())
  RETURNING id INTO b;
  INSERT INTO refund (bill_id, amount_vnd, method_code, source_method_code, reason, booked_at, sale_date)
  VALUES (b, 5000, 'transfer', 'cash', 'thiếu một chiếc giò, hoàn phần ấy', pg_temp.bc_luc('09:45'),
          pg_temp.bc_ngay()) RETURNING id INTO r;
  INSERT INTO bc VALUES ('don_lay', o), ('hoa_don_lay', b), ('hoan_lay', r);

  -- Đơn hotline khách tới lấy, trả trước tiền mặt; khách đổi ý ⇒ quầy huỷ và trả lại tiền trả trước.
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code, created_at)
  VALUES ('phone_preorder', 'new', 'shop_pickup', '0900000011', pg_temp.bc_luc('10:00'),
          gen_random_uuid()::text, pg_temp.bc_luc('09:15')) RETURNING id INTO o;
  PERFORM pg_temp.bc_mon(o, 'Bánh cuốn', 3, ARRAY['Chay']);
  due := pg_temp.bc_tong(o);
  INSERT INTO prepayment (sales_order_id, cash_vnd, booked_at, sale_date)
  VALUES (o, due, pg_temp.bc_luc('09:16'), pg_temp.bc_ngay()) RETURNING id INTO p;
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  UPDATE sales_order SET status = 'cancelled' WHERE id = o;
  INSERT INTO refund (prepayment_id, amount_vnd, method_code, reason, booked_at, sale_date)
  VALUES (p, due, 'cash', 'khách đổi ý, tới quán ngồi ăn', pg_temp.bc_luc('09:20'), pg_temp.bc_ngay())
  RETURNING id INTO r;
  INSERT INTO prepayment_use (prepayment_id, sales_order_id, use_no, cash_before_vnd,
                              transfer_before_vnd, take_cash_vnd, refund_id)
  VALUES (p, o, 1, due, 0, due, r);
  INSERT INTO bc VALUES ('don_hotline', o), ('tra_truoc_hotline', p), ('tra_lai_hotline', r);

  -- Một khoản tạm ứng và một khoản thưởng lễ Tết (P2A-04): để phép từ chối qd21_so_am có dòng thật
  -- mà thử cột tiền của hai bảng ấy. Chúng KHÔNG nối vào két hay doanh thu của ngày mẫu (I-028,
  -- task T-125 ở work/backlog.md), nên không câu đối chiếu nào của ngày này đổi kết quả.
  -- Người ghi khai thẳng trên dòng: không đổi người thao tác của ngày mẫu, các file lỗi cài đọc nó.
  -- T-140: khoản trừ theo ngày khai; mốc ghi của mẫu giữ nguyên.
  INSERT INTO staff_advance (worker_person_id, amount_vnd, paid_date, approver_person_id, person_id, created_at)
  VALUES (giao, 200000, pg_temp.bc_ngay(), chu, chu, pg_temp.bc_luc('10:50'));
  INSERT INTO holiday_bonus (worker_person_id, amount_vnd, paid_date, person_id, created_at)
  VALUES (giao, 100000, pg_temp.bc_ngay(), chu, pg_temp.bc_luc('10:51'));
  -- P2A-07, 2026-10-01: nguyên liệu có mua/dùng; sửa có lý do sinh vết.
  INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure, person_id)
  SELECT id, pg_temp.bc_ngay(), k, n, chu
  FROM (SELECT id FROM supply_item ORDER BY id LIMIT 2) i
  CROSS JOIN (VALUES ('purchased', 10::numeric), ('used', 3::numeric)) v(k, n);
  UPDATE supply_day_entry SET entered_measure = 12
  WHERE id = (SELECT min(id) FROM supply_day_entry WHERE kind_code = 'purchased');

  -- Chủ quán tick hai người; huỷ ô tick nhầm có ghi chú rồi tick lại.
  INSERT INTO attendance_day (worker_person_id, work_date, person_id)
  VALUES (a, pg_temp.bc_ngay(), chu), (giao, pg_temp.bc_ngay(), chu);
  UPDATE attendance_day
  SET cancelled_at = now(), cancelled_by_person_id = chu, cancel_note = 'tick nhầm, ghi lại ô đúng'
  WHERE worker_person_id = giao AND work_date = pg_temp.bc_ngay();
  INSERT INTO attendance_day (worker_person_id, work_date, person_id)
  VALUES (giao, pg_temp.bc_ngay(), chu);

  -- Người thao tác hiện hành vẫn là a; lý do của ngày mẫu đã khai, không đổi actor của file lỗi.
  UPDATE staff_advance SET amount_vnd = 250000 WHERE worker_person_id = giao;
END $$;

-- T-127: bàn 9 gọi; một thứ đã làm xong thì đơn bị huỷ.
-- Không bàn nào chờ đúng thứ ấy: quầy ghi chú bánh làm sai, không chuyển cho bàn nào.
-- Ca này phải ra 0 dòng ở I-004/6 nhờ ghi chú còn hiệu lực.
DO $$
DECLARE s bigint; o bigint; j bigint;
BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Người đứng quầy')::text, true);
  PERFORM set_config('shop.revision_reason', 'ngày mẫu: huỷ đơn và ghi chú bánh làm sai', true);
  s := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('9')]);
  o := pg_temp.bc_don('staff_pos', s, pg_temp.bc_ban('9'), pg_temp.bc_luc('10:30'));
  PERFORM pg_temp.bc_mon(o, 'Bánh cuốn', 1, ARRAY['Chay']);
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.bc_no(o);
  UPDATE table_session SET status = 'serving' WHERE id = s;
  SELECT min(id) INTO j FROM station_job
    WHERE sales_order_id = o AND order_line_component_id IS NOT NULL;
  PERFORM pg_temp.bc_me(ARRAY[j]);
  UPDATE sales_order SET status = 'cancelled' WHERE id = o;
  INSERT INTO wrong_make_note (station_job_id, sales_order_id) VALUES (j, o);
  PERFORM pg_temp.bc_dong(s, pg_temp.bc_luc('10:40'), 0, 0);
  UPDATE table_session_member SET cleaned_at = pg_temp.bc_luc('10:45') WHERE table_session_id = s;
END $$;

-- T-132: chủ quán tạm dừng 06:10–06:25 (hết nguyên liệu), không đơn nào tạo trong khoảng ấy. Máy thấy
-- quán hết nhìn thấy đơn lúc 07:05, người đứng quầy bấm mở lại 07:15; lượt gọi staff_pos của bàn 5
-- lúc 07:10 nằm TRONG khoảng mù và phải ra 0 dòng ở I-008/3 — hai kênh người của quán không dừng.
-- Hai khoảng đứng trước 08:00: không file lỗi cài nào tạo đơn ở đó.
INSERT INTO order_intake_pause (started_at, started_by_person_id, ended_at, ended_by_person_id)
VALUES (pg_temp.bc_luc('06:10'), pg_temp.bc_nguoi('Chủ quán'),
        pg_temp.bc_luc('06:25'), pg_temp.bc_nguoi('Chủ quán'));
INSERT INTO shop_blind_spell (started_at, ended_at, ended_by_person_id)
VALUES (pg_temp.bc_luc('07:05'), pg_temp.bc_luc('07:15'), pg_temp.bc_nguoi('Người đứng quầy'));

-- T-133: tối ngày mẫu chủ quán đếm két rồi bấm đối soát xong (shop-facts §6.10 · §6.27). Số đếm là
-- tiền đầu két cộng mọi lần tiền MẶT thật sự đổi tay trong ngày, đọc theo dòng tiền chứ không theo
-- hạng tử của I-021: vào két — phần tiền mặt của hoá đơn, thu nợ, trả trước; ra khỏi két — lần hoàn
-- hay trả lại trả bằng tiền mặt, tạm ứng, thưởng. Hai cách cộng khác nhau phải ra cùng một số.
DO $$
DECLARE c bigint; d date := pg_temp.bc_ngay(); ket bigint;
BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  ket := (SELECT sum(x.amount_vnd) FROM opening_float f JOIN opening_float_line x ON x.opening_float_id = f.id
          WHERE f.sale_date = d)
       + (SELECT coalesce(sum(cash_vnd), 0) FROM bill WHERE sale_date = d)
       + (SELECT coalesce(sum(cash_vnd), 0) FROM debt_collection WHERE sale_date = d)
       + (SELECT coalesce(sum(cash_vnd), 0) FROM prepayment WHERE sale_date = d)
       - (SELECT coalesce(sum(amount_vnd), 0) FROM refund WHERE method_code = 'cash' AND sale_date = d)
       - (SELECT coalesce(sum(amount_vnd), 0) FROM staff_advance WHERE paid_date = d)
       - (SELECT coalesce(sum(amount_vnd), 0) FROM holiday_bonus WHERE paid_date = d);
  INSERT INTO cash_count (sale_date) VALUES (d) RETURNING id INTO c;
  INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd)
  VALUES (c, 50000, ket / 50000 * 50000), (c, 1000, ket % 50000);
  INSERT INTO reconciled_day (sale_date) VALUES (d);
  INSERT INTO bc VALUES ('dem_ket', c);
  -- Trả người thao tác về người đứng quầy: các file lỗi cài ghi thao tác ở quầy bằng người ấy.
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Người đứng quầy')::text, true);
END $$;

-- Ngày mẫu phải qua MỌI ràng buộc hoãn, như lúc COMMIT.
SET CONSTRAINTS ALL IMMEDIATE;
SET CONSTRAINTS ALL DEFERRED;
