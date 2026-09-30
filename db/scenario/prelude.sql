-- Phần dùng chung của ba scenario nghiệm thu diễn qua lược đồ (P2-13,
-- docs/product/2-db/11-cong-chat-luong-pha-2.md). scripts/db-check.sh nạp file này, rồi mo_ngay ·
-- s1 · s2 · s3, trong MỘT phiên kết nối: hàm và bảng tạm dưới đây sống tới hết phiên ấy. Phép chấm
-- yc.sql nạp lại file này ở phiên của nó (chỉ hàm, không ghi gì).
--
-- Mỗi bước ở quán là MỘT giao dịch được COMMIT — một khối DO ở mức ngoài cùng, chạy khi psql tự
-- COMMIT — đúng như cửa ghi của pha 3 sẽ ghi. Ràng buộc hoãn được chấm ở mỗi lần COMMIT ấy.
--
-- Các hàm pg_temp.sc_* ĐỨNG THAY những cửa mà pha 3 sẽ viết (tạo lượt gọi, nổ đơn, bấm mẻ, đóng
-- phiên); chúng không phải các cửa ấy và không quyết luật nào mới. Cùng vai với pg_temp.bc_* của
-- db/reconcile/proof/baseline.sql; tách riêng vì scenario cần mốc giờ cho TỪNG bước. Thứ tự trạng
-- thái theo docs/product/0-ba/ban-hang/05-vong-doi.md §5; phép tính giá theo db/seed/seed.pl
-- --price-cases. Không một con giá nào ở đây — giá đọc từ dữ liệu mồi, dữ liệu mồi đọc từ
-- master_plan/shop-facts.md (ADR-001).
--
-- Ngày diễn là NGÀY MAI của múi giờ kết nối, trong giờ bán — cùng cách ngày mẫu của P2-11. Mốc của
-- vết cập nhật lấy từ đồng hồ thật (không lùi được), nên cuối mỗi bước sc_xong đặt mốc của các vết
-- chính bước ấy vừa sinh về giờ của bước — tiền lệ db/reconcile/proof/i009_2.sql.

\set ON_ERROR_STOP 1
\set QUIET 1

-- Mốc hh:mm của ngày diễn, theo múi giờ của kết nối (QD-32).
CREATE FUNCTION pg_temp.sc_luc(p_gio text) RETURNS timestamptz LANGUAGE sql STABLE AS $f$
  SELECT ((now() AT TIME ZONE current_setting('TimeZone'))::date + 1 + p_gio::time)
         AT TIME ZONE current_setting('TimeZone')
$f$;
CREATE FUNCTION pg_temp.sc_ngay() RETURNS date LANGUAGE sql STABLE AS $f$
  SELECT (now() AT TIME ZONE current_setting('TimeZone'))::date + 1
$f$;
CREATE FUNCTION pg_temp.sc_nguoi(p_ten text) RETURNS bigint LANGUAGE sql STABLE AS $f$
  SELECT id FROM person WHERE display_name = p_ten
$f$;
CREATE FUNCTION pg_temp.sc_ban(p_so text) RETURNS bigint LANGUAGE sql STABLE AS $f$
  SELECT id FROM dining_table WHERE label = p_so
$f$;

-- Mở một bước: ai thao tác, và lý do khai cho mọi lần sửa của bước (vết I-018 — pha 3 nợ khai).
CREATE FUNCTION pg_temp.sc_buoc(p_nguoi text, p_ly_do text) RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.sc_nguoi(p_nguoi)::text, true);
  PERFORM set_config('shop.revision_reason', p_ly_do, true);
END $f$;

-- Đóng một bước: vết mà chính giao dịch này sinh ra mang giờ của bước.
CREATE FUNCTION pg_temp.sc_xong(p_luc timestamptz) RETURNS void LANGUAGE sql AS $f$
  UPDATE record_revision SET revised_at = p_luc WHERE created_at = now()
$f$;

-- Giá một suất (shop-facts §4.6 luật 1 · 5), NULL khi tổ hợp không hợp lệ (luật 3).
CREATE FUNCTION pg_temp.sc_gia(it bigint, sel bigint[]) RETURNS bigint LANGUAGE plpgsql AS $f$
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

-- Một đơn / một lượt gọi, dấu lần gửi mới (I-024). Kênh QR mang mã hiện hành của bàn (I-023).
CREATE FUNCTION pg_temp.sc_don(p_kenh text, p_phien bigint, p_ban bigint, p_luc timestamptz)
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

-- Gọi một món: dòng đơn + ảnh chụp thành phần và tuỳ chọn; giá và mốc khoá tại lúc gọi (I-009).
CREATE FUNCTION pg_temp.sc_mon(p_don bigint, p_mon text, p_so integer, p_tc text[])
RETURNS bigint LANGUAGE plpgsql AS $f$
DECLARE it bigint; sel bigint[]; price bigint; n integer; l bigint;
        luc timestamptz := (SELECT created_at FROM sales_order WHERE id = p_don);
BEGIN
  SELECT id INTO STRICT it FROM menu_item WHERE name = p_mon;
  SELECT coalesce(array_agg(id), '{}') INTO sel FROM menu_option WHERE name = ANY (p_tc);
  price := pg_temp.sc_gia(it, sel);
  IF price IS NULL THEN RAISE EXCEPTION 'scenario: tổ hợp không hợp lệ % %', p_mon, p_tc; END IF;
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

-- Đã xác nhận → Đang thực hiện, và mọi việc trạm của đơn, cùng giao dịch (I-004 vế hai, tầng 2).
-- Mỗi đơn vị một dòng; mỗi đơn đúng một phần nước chấm ở trạm canh (shop-facts §5.3 · §6.6).
CREATE FUNCTION pg_temp.sc_no(p_don bigint, p_luc timestamptz) RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
  UPDATE sales_order SET status = 'in_progress' WHERE id = p_don;
  INSERT INTO station_job (sales_order_id, order_line_id, order_line_component_id, station_code,
                           line_quantity, component_quantity, position, created_at)
  SELECT p_don, l.id, c.id, s.station_code, l.quantity, c.quantity, g.p, p_luc
  FROM order_line l
  JOIN order_line_component c ON c.order_line_id = l.id
  JOIN menu_component_station s ON s.menu_component_id = c.menu_component_id
  CROSS JOIN LATERAL generate_series(1, l.quantity * c.quantity) AS g(p)
  WHERE l.sales_order_id = p_don;
  INSERT INTO station_job (sales_order_id, station_code, position, created_at)
  VALUES (p_don, 'canh', 1, p_luc);
END $f$;

-- Quầy bấm "đã làm xong": MỘT mẻ làm ra mọi việc đang chờ của các đơn đã nêu (một mẻ phủ được
-- nhiều đơn, nhiều bàn — YC-07). Trả về mã mẻ.
CREATE FUNCTION pg_temp.sc_me(p_don bigint[], p_luc timestamptz) RETURNS bigint
LANGUAGE plpgsql AS $f$
DECLARE b bigint;
BEGIN
  INSERT INTO production_batch (made_at) VALUES (p_luc) RETURNING id INTO b;
  INSERT INTO production_batch_item (production_batch_id, made_for_station_job_id, station_job_id)
  SELECT b, id, id FROM station_job WHERE sales_order_id = ANY (p_don) AND status = 'pending';
  UPDATE station_job SET status = 'made' WHERE sales_order_id = ANY (p_don) AND status = 'pending';
  RETURN b;
END $f$;

-- Quầy bấm "đã ra bàn" (với đơn mang đi: lúc TRAO) cho mọi thứ đã làm của một đơn, rồi đơn sang
-- Hoàn thành khi mọi việc đã ra (§5.5). Đơn vị BẤM của mốc này còn là S-5 (shop-facts §7.2):
-- bấm theo đơn ở đây chỉ để đi tiếp, không phải một câu trả lời.
CREATE FUNCTION pg_temp.sc_ra(p_don bigint) RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
  UPDATE station_job SET status = 'served' WHERE sales_order_id = p_don AND status = 'made';
  UPDATE sales_order SET status = 'completed'
   WHERE id = p_don
     AND NOT EXISTS (SELECT 1 FROM station_job WHERE sales_order_id = p_don AND status <> 'served');
END $f$;

-- Tổng các dòng của một đơn / của một phiên (đơn chưa huỷ).
CREATE FUNCTION pg_temp.sc_tong(p_don bigint) RETURNS bigint LANGUAGE sql STABLE AS $f$
  SELECT coalesce(sum(line_total_vnd), 0) FROM order_line WHERE sales_order_id = p_don
$f$;
CREATE FUNCTION pg_temp.sc_tong_phien(p_phien bigint) RETURNS bigint LANGUAGE sql STABLE AS $f$
  SELECT coalesce(sum(l.line_total_vnd), 0) FROM order_line l JOIN sales_order o ON o.id = l.sales_order_id
  WHERE o.table_session_id = p_phien AND o.status <> 'cancelled'
$f$;

-- Tên đã khai → mã, giữa các bước (bảng tạm sống tới hết phiên kết nối).
CREATE TEMP TABLE sc (ten text PRIMARY KEY, id bigint NOT NULL);
CREATE FUNCTION pg_temp.sc_id(p_ten text) RETURNS bigint LANGUAGE sql STABLE AS $f$
  SELECT id FROM sc WHERE ten = p_ten
$f$;
