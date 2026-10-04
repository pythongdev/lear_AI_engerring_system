-- Chấm ngược YC-01…YC-20 · YC-22…YC-25 · YC-34 (P2-13 · T-132, docs/product/2-db/11-cong-chat-luong-pha-2.md §5),
-- mỗi dòng HAI câu (docs/product/1-system-design/04-yeu-cau-du-lieu.md §0 · §7):
--   YC-XX  đọc · …   đọc ra được không — in thẳng từ dữ liệu của ngày diễn;
--   YC-XX  sai · …   dựng được trạng thái sai không — một trong năm kết cục có tên:
--          TỪ CHỐI    database từ chối, lời nguyên văn;
--          KHÔNG CHỖ  lược đồ không có chỗ nào để trạng thái sai ấy đứng — in bằng chứng vắng mặt;
--          ĐI QUA     trạng thái sai là CHẶN NHẦM một việc hợp lệ — việc ấy ghi được;
--          GỌI TÊN    database không chặn (tầng 3–5 theo 03-bao-ve-invariant.md) nhưng một câu đối
--                     chiếu gọi tên nó — "(proof/<file>)" là lỗi cài chứng minh câu ấy biết kêu, chạy ở
--                     bước đối chiếu của cùng lần db-check; db-check kiểm file ấy còn và khai đúng mã;
--          DỰNG ĐƯỢC  trạng thái sai đứng được và không câu nào bắt — kèm mã chỗ hở; hoặc
--          CHƯA TRẢ LỜI ĐƯỢC  thiếu hẳn chỗ cất để đặt câu hỏi — kèm mã chỗ hở.
-- Kết cục nào không còn đúng (một TỪ CHỐI không xảy ra, một chỗ hở đã được lấp) ⇒ lỗi ⇒ db-check
-- FAIL: cổng đổi thì file này đổi cùng lượt.
--
-- Chạy sau khi ba scenario đã COMMIT, trên chính ngày ấy, cùng prelude.sql trong phiên (chỉ hàm).
-- Mọi phép tìm lại dữ liệu của scenario neo vào NGÀY DIỄN (pg_temp.yc_cua_ngay): database kiểm còn
-- giữ những gì bước trước đã COMMIT (test i024 COMMIT một đơn qua dblink, có chủ ý).
-- Các ca mà ba scenario không chạm — hoàn tiền, nợ, sổ giấy, đổi người đứng quầy, đổi mã QR, mẻ lùi
-- — dựng thêm ở khối đầu. Cả file là MỘT giao dịch và kết thúc bằng ROLLBACK.

BEGIN;

-- Dựng trạng thái sai, bắt đúng lớp lỗi ràng buộc (lớp 23), in lời từ chối. Không bị từ chối ⇒ lỗi.
CREATE FUNCTION pg_temp.yc_tu_choi(p_yc text, p_viec text, p_sql text) RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
  BEGIN
    EXECUTE p_sql;
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION '%: database KHÔNG từ chối — %', p_yc, p_viec;
  EXCEPTION WHEN integrity_constraint_violation THEN
    RAISE NOTICE '% sai · % ⇒ TỪ CHỐI: %', p_yc, p_viec, SQLERRM;
  END;
  SET CONSTRAINTS ALL DEFERRED;
END $f$;

-- Dựng trạng thái sai; nó phải đứng được (p_dung đúng sau khi mọi ràng buộc đã chấm), rồi gỡ.
CREATE FUNCTION pg_temp.yc_dung_duoc(p_yc text, p_viec text, p_sql text, p_dung text, p_ma text)
RETURNS void LANGUAGE plpgsql AS $f$
DECLARE ok boolean;
BEGIN
  BEGIN
    EXECUTE p_sql;
    SET CONSTRAINTS ALL IMMEDIATE;
    EXECUTE 'SELECT ' || p_dung INTO ok;
    RAISE EXCEPTION USING ERRCODE = 'YC001', MESSAGE = coalesce(ok::text, 'null');
  EXCEPTION WHEN SQLSTATE 'YC001' THEN
    IF SQLERRM <> 'true' THEN
      RAISE EXCEPTION '%: trạng thái sai KHÔNG đứng như mô tả — %', p_yc, p_viec;
    END IF;
    RAISE NOTICE '% sai · % ⇒ DỰNG ĐƯỢC — %', p_yc, p_viec, p_ma;
  END;
  SET CONSTRAINTS ALL DEFERRED;
END $f$;

-- Trạng thái sai không có chỗ đứng: p_vang (biểu thức boolean) phải đúng.
CREATE FUNCTION pg_temp.yc_khong_cho(p_yc text, p_viec text, p_vang text, p_ly_do text)
RETURNS void LANGUAGE plpgsql AS $f$
DECLARE ok boolean;
BEGIN
  EXECUTE 'SELECT ' || p_vang INTO ok;
  IF ok IS NOT TRUE THEN RAISE EXCEPTION '%: chỗ cho trạng thái sai ĐÃ CÓ — %', p_yc, p_viec; END IF;
  RAISE NOTICE '% sai · % ⇒ KHÔNG CHỖ: %', p_yc, p_viec, p_ly_do;
END $f$;

-- Thiếu hẳn chỗ cất để hỏi câu ấy: p_vang phải đúng; lấp chỗ ấy thì file này đổi cùng lượt.
CREATE FUNCTION pg_temp.yc_chua(p_yc text, p_viec text, p_vang text, p_ma text)
RETURNS void LANGUAGE plpgsql AS $f$
DECLARE ok boolean;
BEGIN
  EXECUTE 'SELECT ' || p_vang INTO ok;
  IF ok IS NOT TRUE THEN RAISE EXCEPTION '%: chỗ cất đã có — cập nhật kết cục của dòng này (%)', p_yc, p_ma; END IF;
  RAISE NOTICE '% sai · % ⇒ CHƯA TRẢ LỜI ĐƯỢC — %', p_yc, p_viec, p_ma;
END $f$;

-- Trạng thái sai là chặn nhầm: việc hợp lệ phải ghi được (p_dung đúng sau khi mọi ràng buộc chấm).
CREATE FUNCTION pg_temp.yc_di_qua(p_yc text, p_viec text, p_sql text, p_dung text) RETURNS void
LANGUAGE plpgsql AS $f$
DECLARE ok boolean;
BEGIN
  BEGIN
    EXECUTE p_sql;
    SET CONSTRAINTS ALL IMMEDIATE;
    EXECUTE 'SELECT ' || p_dung INTO ok;
    RAISE EXCEPTION USING ERRCODE = 'YC001', MESSAGE = coalesce(ok::text, 'null');
  EXCEPTION WHEN SQLSTATE 'YC001' THEN
    IF SQLERRM <> 'true' THEN RAISE EXCEPTION '%: việc hợp lệ KHÔNG ghi được — %', p_yc, p_viec; END IF;
    RAISE NOTICE '% sai · % ⇒ ĐI QUA: việc hợp lệ ghi được, không bị chặn nhầm', p_yc, p_viec;
  END;
  SET CONSTRAINTS ALL DEFERRED;
END $f$;

CREATE FUNCTION pg_temp.yc_goi_ten(p_yc text, p_viec text, p_tang text, p_cau text, p_proof text)
RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
  RAISE NOTICE '% sai · % ⇒ GỌI TÊN: % (proof/%) — database không chặn, %', p_yc, p_viec, p_cau, p_proof, p_tang;
END $f$;

CREATE FUNCTION pg_temp.yc_doc(p_yc text, p_noi_dung text) RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
  IF p_noi_dung IS NULL THEN RAISE EXCEPTION '%: câu đọc ra RỖNG', p_yc; END IF;
  RAISE NOTICE '% đọc · %', p_yc, p_noi_dung;
END $f$;

CREATE FUNCTION pg_temp.yc_cua_ngay(p timestamptz) RETURNS boolean LANGUAGE sql STABLE AS $f$
  SELECT (p AT TIME ZONE current_setting('TimeZone'))::date = pg_temp.sc_ngay()
$f$;
-- Đơn của ngày diễn theo kênh (mỗi kênh mang đi đúng một đơn trong ba scenario).
CREATE FUNCTION pg_temp.yc_don(p_kenh text) RETURNS bigint LANGUAGE sql STABLE AS $f$
  SELECT id FROM sales_order WHERE channel_code = p_kenh AND status = 'completed' AND pg_temp.yc_cua_ngay(created_at)
$f$;
-- Phiên của một bàn trong ngày diễn: phiên có lượt gọi tạo trong ngày ấy, sớm nhất.
CREATE FUNCTION pg_temp.yc_phien(p_ban text) RETURNS bigint LANGUAGE sql STABLE AS $f$
  SELECT m.table_session_id FROM table_session_member m JOIN dining_table t ON t.id = m.dining_table_id
  JOIN sales_order o ON o.table_session_id = m.table_session_id
  WHERE t.label = p_ban AND pg_temp.yc_cua_ngay(o.created_at) ORDER BY o.created_at LIMIT 1
$f$;
CREATE FUNCTION pg_temp.yc_hhmm(p timestamptz) RETURNS text LANGUAGE sql STABLE AS $f$
  SELECT to_char(p, 'DD/MM HH24:MI')
$f$;
CREATE FUNCTION pg_temp.yc_ten(p bigint) RETURNS text LANGUAGE sql STABLE AS $f$
  SELECT display_name FROM person WHERE id = p
$f$;
-- Ai đứng quầy tại một mốc (YC-15): khoảng [vào, ra) chứa mốc ấy.
CREATE FUNCTION pg_temp.yc_quay(p timestamptz) RETURNS text LANGUAGE sql STABLE AS $f$
  SELECT coalesce((SELECT pg_temp.yc_ten(person_id) FROM counter_duty
                   WHERE tstzrange(started_at, ended_at, '[)') @> p), '(không ai khai)')
$f$;

-- ============================================================ các ca ba scenario không chạm
DO $$
DECLARE a bigint := pg_temp.sc_nguoi('Người đứng quầy'); chu bigint := pg_temp.sc_nguoi('Chủ quán');
        hd_c bigint; r bigint; s bigint; o bigint; o2 bigint; due bigint; b bigint; m bigint;
        pl bigint; t12 bigint := pg_temp.sc_ban('12');
BEGIN
  PERFORM pg_temp.sc_buoc('Người đứng quầy', 'P2-13 chấm YC — ca dựng thêm');

  -- Hoàn tiền cho đơn C của Scenario 2 (YC-01).
  SELECT id INTO STRICT hd_c FROM bill WHERE sales_order_id = pg_temp.yc_don('phone_preorder');
  INSERT INTO refund (bill_id, amount_vnd, method_code, source_method_code, reason, booked_at, sale_date)
  VALUES (hd_c, 5000, 'cash', 'cash', 'khách trả lại một cái bánh bị rách', pg_temp.sc_luc('09:30'),
          pg_temp.sc_ngay()) RETURNING id INTO r;
  INSERT INTO sc VALUES ('hoan', r);

  -- Bàn 9: khách không đủ tiền, quán cho nợ cả bữa; sáng hôm sau khách trả nợ (YC-02 · 09 · 10 · 11).
  INSERT INTO counter_duty (person_id, started_at, ended_at)
  VALUES (a, pg_temp.sc_luc('06:00') + interval '1 day', pg_temp.sc_luc('07:00') + interval '1 day');
  INSERT INTO table_session (status) VALUES ('open') RETURNING id INTO s;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s, pg_temp.sc_ban('9'));
  o := pg_temp.sc_don('staff_pos', s, pg_temp.sc_ban('9'), pg_temp.sc_luc('10:15'));
  PERFORM pg_temp.sc_mon(o, 'Bánh cuốn', 2, ARRAY['Chay']);
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.sc_no(o, pg_temp.sc_luc('10:15'));
  PERFORM pg_temp.sc_me(ARRAY[o], pg_temp.sc_luc('10:17'));
  PERFORM pg_temp.sc_ra(o);
  UPDATE table_session SET status = 'serving' WHERE id = s;
  UPDATE table_session SET status = 'awaiting_payment' WHERE id = s;
  due := pg_temp.sc_tong_phien(s);
  INSERT INTO bill (table_session_id, due_vnd, debt_vnd, debtor_name, booked_at, sale_date)
  VALUES (s, due, due, 'Chị Hoa đầu ngõ (tên diễn)', pg_temp.sc_luc('10:20'), pg_temp.sc_ngay())
  RETURNING id INTO b;
  UPDATE table_session SET status = 'closed' WHERE id = s;
  UPDATE table_session_member SET session_closed = true WHERE table_session_id = s;
  INSERT INTO debt_collection (bill_id, debt_vnd, transfer_vnd, booked_at, sale_date)
  VALUES (b, due, due, pg_temp.sc_luc('06:30') + interval '1 day', pg_temp.sc_ngay() + 1);
  INSERT INTO sc VALUES ('phien_no', s), ('hd_no', b);

  -- Bàn 10: một đơn, một suất ăn tại chỗ và một suất ĐEM VỀ (YC-05). Bàn 11: một đơn khác. Một mẻ
  -- phủ cả hai bàn, bấm nhầm rồi lùi, rồi bấm lại (YC-07).
  INSERT INTO table_session (status) VALUES ('open') RETURNING id INTO s;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s, pg_temp.sc_ban('10'));
  o := pg_temp.sc_don('staff_pos', s, pg_temp.sc_ban('10'), pg_temp.sc_luc('10:25'));
  PERFORM pg_temp.sc_mon(o, 'Suất trứng chín', 1, ARRAY['Chay']);
  r := pg_temp.sc_mon(o, 'Suất trứng chín', 1, ARRAY['Chay']);
  UPDATE order_line SET is_takeaway = true WHERE id = r;
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.sc_no(o, pg_temp.sc_luc('10:25'));
  INSERT INTO sc VALUES ('phien_10', s), ('don_10', o), ('dong_dem_ve', r);
  INSERT INTO table_session (status) VALUES ('open') RETURNING id INTO s;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s, pg_temp.sc_ban('11'));
  o2 := pg_temp.sc_don('staff_pos', s, pg_temp.sc_ban('11'), pg_temp.sc_luc('10:26'));
  PERFORM pg_temp.sc_mon(o2, 'Suất trứng chín', 1, ARRAY['Thịt', 'Thường']);
  UPDATE sales_order SET status = 'confirmed' WHERE id = o2;
  PERFORM pg_temp.sc_no(o2, pg_temp.sc_luc('10:26'));
  INSERT INTO sc VALUES ('don_11', o2);
  m := pg_temp.sc_me(ARRAY[o, o2], pg_temp.sc_luc('10:35'));
  UPDATE production_batch SET rolled_back_at = pg_temp.sc_luc('10:36'), rolled_back_by_person_id = a WHERE id = m;
  UPDATE production_batch_item SET batch_rolled_back = true WHERE production_batch_id = m;
  UPDATE station_job SET status = 'pending'
   WHERE id IN (SELECT station_job_id FROM production_batch_item WHERE production_batch_id = m);
  INSERT INTO sc VALUES ('me_lui', m);
  m := pg_temp.sc_me(ARRAY[o, o2], pg_temp.sc_luc('10:40'));
  INSERT INTO sc VALUES ('me_lai', m);
  -- Bàn 13 gọi đúng món ấy, việc còn đang chờ ở bếp — chỗ nhận của một lần chuyển (YC-07).
  INSERT INTO table_session (status) VALUES ('open') RETURNING id INTO s;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s, pg_temp.sc_ban('13'));
  o := pg_temp.sc_don('staff_pos', s, pg_temp.sc_ban('13'), pg_temp.sc_luc('10:41'));
  PERFORM pg_temp.sc_mon(o, 'Suất trứng chín', 1, ARRAY['Thịt', 'Thường']);
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.sc_no(o, pg_temp.sc_luc('10:41'));
  INSERT INTO sc VALUES ('don_13', o);

  -- Sổ giấy của ngày diễn: hai lượt ghi trên giấy, mới nhập bù một (YC-08). Lượt nhập bù là một phiên
  -- bàn 12 gõ vào máy hôm sau; mốc bán là giờ trên giấy.
  INSERT INTO paper_ledger (sale_date, entry_count) VALUES (pg_temp.sc_ngay(), 2) RETURNING id INTO pl;
  INSERT INTO table_session (status) VALUES ('open') RETURNING id INTO s;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s, t12);
  o := pg_temp.sc_don('staff_pos', s, t12, pg_temp.sc_luc('07:10') + interval '1 day');
  PERFORM pg_temp.sc_mon(o, 'Bánh cuốn', 1, ARRAY['Chay']);
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  UPDATE table_session SET status = 'awaiting_payment' WHERE id = s;
  INSERT INTO bill (table_session_id, due_vnd, cash_vnd, booked_at, sale_date, paper_ledger_id,
                    paper_entry_count, paper_position)
  VALUES (s, pg_temp.sc_tong_phien(s), pg_temp.sc_tong_phien(s), pg_temp.sc_luc('06:45'), pg_temp.sc_ngay(),
          pl, 2, 1) RETURNING id INTO b;
  UPDATE table_session SET status = 'closed' WHERE id = s;
  UPDATE table_session_member SET session_closed = true WHERE table_session_id = s;
  INSERT INTO sc VALUES ('so_giay', pl), ('hd_nhap_bu', b), ('phien_nhap_bu', s);

  -- 10:30 chủ quán vào đứng quầy thay người đứng quầy (YC-15 · YC-16).
  UPDATE counter_duty SET ended_at = pg_temp.sc_luc('10:30')
   WHERE person_id = a AND started_at = pg_temp.sc_luc('05:30');
  INSERT INTO counter_duty (person_id, started_at, ended_at)
  VALUES (chu, pg_temp.sc_luc('10:30'), pg_temp.sc_luc('11:30'));

  -- Một đơn tới lấy bị huỷ, có khai lý do (YC-04).
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code, created_at)
  VALUES ('pickup', 'new', 'shop_pickup', '0900000299', pg_temp.sc_luc('10:45'), gen_random_uuid()::text,
          pg_temp.sc_luc('10:20')) RETURNING id INTO o;
  PERFORM pg_temp.sc_mon(o, 'Bánh cuốn', 1, ARRAY['Chay']);
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  PERFORM set_config('shop.revision_reason', 'khách gọi báo không tới lấy', true);
  UPDATE sales_order SET status = 'cancelled' WHERE id = o;
  UPDATE record_revision SET revised_at = pg_temp.sc_luc('10:42')
   WHERE target_table_code = 'sales_order' AND target_row = o;
  INSERT INTO sc VALUES ('don_huy', o);

  -- Chủ quán đổi mã QR của bàn 5 sau buổi bán (YC-24, U-062).
  PERFORM qr_code_issue(pg_temp.sc_ban('5'));
  PERFORM set_config('shop.actor_person_id', a::text, true);
  PERFORM set_config('shop.revision_reason', 'P2-13 chấm YC — ca dựng thêm', true);
END $$;
SET CONSTRAINTS ALL IMMEDIATE;
SET CONSTRAINTS ALL DEFERRED;

-- ============================================================ YC-01 vết hoàn tiền
DO $$
DECLARE r record;
BEGIN
  SELECT * INTO STRICT r FROM refund WHERE id = pg_temp.sc_id('hoan');
  PERFORM pg_temp.yc_doc('YC-01', format('hoàn %s đ · cho hoá đơn %s · %s bấm · lúc %s · lý do "%s" · trả bằng %s',
    r.amount_vnd, r.bill_id, pg_temp.yc_ten(r.person_id), pg_temp.yc_hhmm(r.booked_at), r.reason, r.method_code));
  PERFORM pg_temp.yc_tu_choi('YC-01', 'hoàn tiền không lý do',
    format($q$INSERT INTO refund (bill_id, amount_vnd, method_code, source_method_code, reason)
              VALUES (%s, 1000, 'cash', 'cash', '   ')$q$, r.bill_id));
  PERFORM pg_temp.yc_tu_choi('YC-01', 'hoàn tiền không người bấm',
    format($q$DO $d$ BEGIN PERFORM set_config('shop.actor_person_id', '', true);
              INSERT INTO refund (bill_id, amount_vnd, method_code, source_method_code, reason)
              VALUES (%s, 1000, 'cash', 'cash', 'x'); END $d$ $q$, r.bill_id));
  PERFORM pg_temp.yc_tu_choi('YC-01', 'hoàn tiền không lượt bán nào',
    $q$INSERT INTO refund (amount_vnd, method_code, reason) VALUES (1000, 'cash', 'x')$q$);
END $$;

-- ============================================================ YC-02 khoản nợ
DO $$
DECLARE b record; d record;
BEGIN
  SELECT * INTO STRICT b FROM bill WHERE id = pg_temp.sc_id('hd_no');
  SELECT * INTO STRICT d FROM debt_collection WHERE bill_id = b.id;
  PERFORM pg_temp.yc_doc('YC-02', format('ai nợ "%s" · %s đ · phiên %s (đã đóng: %s) · ghi lúc %s · thu lúc %s · đã thu: %s',
    b.debtor_name, b.debt_vnd, b.table_session_id, (SELECT is_closed FROM table_session WHERE id = b.table_session_id),
    pg_temp.yc_hhmm(b.booked_at), pg_temp.yc_hhmm(d.booked_at), d.id IS NOT NULL));
  PERFORM pg_temp.yc_tu_choi('YC-02', 'đóng phiên thu thiếu mà không ghi nợ (thiếu chủ nợ và số tiền)',
    format($q$UPDATE bill SET cash_vnd = 1000, debt_vnd = 0, debtor_name = NULL WHERE id = %s$q$, b.id));
  PERFORM pg_temp.yc_tu_choi('YC-02', 'nợ không có chủ',
    format($q$UPDATE bill SET debtor_name = NULL WHERE id = %s$q$, b.id));
  PERFORM pg_temp.yc_tu_choi('YC-02', 'một phiên mang hai khoản nợ',
    format($q$INSERT INTO bill (table_session_id, due_vnd, debt_vnd, debtor_name) VALUES (%s, 1000, 1000, 'x')$q$,
           b.table_session_id));
  PERFORM pg_temp.yc_tu_choi('YC-02', 'số tiền nợ âm',
    format($q$UPDATE bill SET debt_vnd = -1, cash_vnd = due_vnd + 1 WHERE id = %s$q$, b.id));
  PERFORM pg_temp.yc_goi_ten('YC-02', 'khoản nợ cộng vào tiền đã thu của ngày ghi nợ',
    'tầng 3 (đường đóng duy nhất); lược đồ để nợ ở cột riêng, không bao giờ trong tiền mặt · chuyển khoản', 'I-014/4', 'i014_4');
END $$;

-- ============================================================ YC-03 vết thao tác chạm tiền · vết sửa
DO $$
DECLARE v record; n_thieu int; n int;
BEGIN
  WITH t AS (
    SELECT 'bill' k, due_vnd so, person_id ai, booked_at luc FROM bill
    UNION ALL SELECT 'debt_collection', debt_vnd, person_id, booked_at FROM debt_collection
    UNION ALL SELECT 'prepayment', cash_vnd + transfer_vnd, person_id, booked_at FROM prepayment
    UNION ALL SELECT 'refund', amount_vnd, person_id, booked_at FROM refund)
  SELECT count(*), count(*) FILTER (WHERE so IS NULL OR ai IS NULL OR luc IS NULL) INTO n, n_thieu FROM t;
  SELECT r.* INTO STRICT v FROM record_revision r
   WHERE r.target_table_code = 'menu_component' AND r.after_image ->> 'name' = 'Bánh cuốn';
  PERFORM pg_temp.yc_doc('YC-03', format('%s thao tác chạm tiền, %s thiếu một trong bốn câu · lần sửa giá: trước %s → sau %s · lý do "%s" · người sửa %s',
    n, n_thieu, v.before_image ->> 'base_price_vnd', v.after_image ->> 'base_price_vnd', v.reason, pg_temp.yc_ten(v.person_id)));
  -- T-133 (F-048): số đếm cuối ngày có chỗ cất (cash_count); chỗ lệch đọc ra được và câu I-012/2 gọi
  -- tên chỗ lệch không khớp đúng một thao tác. Vế chuyển khoản (tin nhắn báo có) vẫn không có chỗ cất.
  PERFORM pg_temp.yc_goi_ten('YC-03', 'chỗ lệch két cuối ngày không quy về một thao tác',
    'tầng 4 (số đếm do người nhập, I-021); chỉ vế tiền mặt — lần sửa không khai lý do vẫn không có vết (F-046)',
    'I-012/2', 'i012_2');
END $$;

-- ============================================================ YC-04 người đang trực lúc thao tác
DO $$
DECLARE h record; b record; d record; huy record;
BEGIN
  SELECT * INTO STRICT h FROM refund WHERE id = pg_temp.sc_id('hoan');
  SELECT * INTO STRICT b FROM bill WHERE id = pg_temp.sc_id('hd_no');
  SELECT * INTO STRICT d FROM debt_collection WHERE bill_id = b.id;
  SELECT * INTO STRICT huy FROM record_revision
   WHERE target_table_code = 'sales_order' AND target_row = pg_temp.sc_id('don_huy')
     AND after_image ->> 'status' = 'cancelled';
  PERFORM pg_temp.yc_doc('YC-04', format('hoàn %s: bấm %s, đứng quầy %s · ghi nợ %s: bấm %s, đứng quầy %s · thu nợ %s: bấm %s, đứng quầy %s · huỷ %s: bấm %s, đứng quầy %s',
    pg_temp.yc_hhmm(h.booked_at), pg_temp.yc_ten(h.person_id), pg_temp.yc_quay(h.booked_at),
    pg_temp.yc_hhmm(b.booked_at), pg_temp.yc_ten(b.person_id), pg_temp.yc_quay(b.booked_at),
    pg_temp.yc_hhmm(d.booked_at), pg_temp.yc_ten(d.person_id), pg_temp.yc_quay(d.booked_at),
    pg_temp.yc_hhmm(huy.revised_at), pg_temp.yc_ten(huy.person_id), pg_temp.yc_quay(huy.revised_at)));
  PERFORM pg_temp.yc_khong_cho('YC-04', 'quyền quyết bởi chức vụ ghi cố định — cột của bảng người: '
      || (SELECT string_agg(column_name, ', ' ORDER BY ordinal_position) FROM information_schema.columns
          WHERE table_schema = 'shop' AND table_name = 'person'),
    $d$NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'shop'
                               AND table_name = 'person' AND column_name ~ 'role|position|title|chuc')$d$,
    'không có cột chức vụ nào để quyết; câu này in ra để chứng minh vắng mặt');
  PERFORM pg_temp.yc_dung_duoc('YC-04', 'một lần huỷ không khai lý do — không đọc ra ai huỷ',
    format($q$DO $d$ BEGIN PERFORM set_config('shop.revision_reason', '', true);
              UPDATE sales_order SET status = 'cancelled' WHERE id = %s; END $d$ $q$, pg_temp.sc_id('don_11')),
    format($d$(SELECT status FROM sales_order WHERE id = %1$s) = 'cancelled' AND NOT EXISTS
             (SELECT 1 FROM record_revision WHERE target_table_code = 'sales_order' AND target_row = %1$s
                AND after_image ->> 'status' = 'cancelled')$d$, pg_temp.sc_id('don_11')),
    'F-046 (chế độ mềm của vết)');
END $$;

-- ============================================================ YC-05 dấu đem về trên một suất
DO $$
DECLARE o bigint := pg_temp.sc_id('don_10');
BEGIN
  PERFORM pg_temp.yc_doc('YC-05', (SELECT format('đơn %s, phiên %s: %s', o, max(x.table_session_id),
      string_agg(format('dòng %s "%s" ×%s %s', l.id, l.item_name, l.quantity,
                        CASE WHEN l.is_takeaway THEN 'ĐEM VỀ' ELSE 'ăn tại chỗ' END), ' · ' ORDER BY l.id))
    FROM order_line l JOIN sales_order x ON x.id = l.sales_order_id WHERE l.sales_order_id = o));
  PERFORM pg_temp.yc_tu_choi('YC-05', 'suất đem về rời phiên bàn thành đơn lẻ',
    format($q$UPDATE sales_order SET table_session_id = NULL, dining_table_id = NULL WHERE id = %s$q$, o));
  PERFORM pg_temp.yc_khong_cho('YC-05', 'dấu chỉ có ở mức cả đơn — cột dấu đem về nằm ở bảng: '
      || (SELECT string_agg(table_name, ', ') FROM information_schema.columns
          WHERE table_schema = 'shop' AND column_name = 'is_takeaway'),
    $d$NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'shop'
                               AND table_name = 'sales_order' AND column_name = 'is_takeaway')$d$,
    'dấu chỉ ở dòng đơn; câu này in ra để chứng minh vắng mặt ở mức đơn');
END $$;

-- ============================================================ YC-06 đã gọi · đã phục vụ theo bàn
-- Đã gọi đọc từ ảnh chụp dòng đơn (số suất × số thành phần), đã phục vụ đếm đơn vị "đã ra bàn" ở trạm
-- gấp bánh — trạm cuối của mọi thành phần có bánh (05-luoc-do-san-xuat.md §2 hàng YC-06).
DO $$
DECLARE vj record;
BEGIN
  PERFORM pg_temp.yc_doc('YC-06', (SELECT string_agg(format('bàn %s %s: gọi %s, phục vụ %s', ban, ten, goi, ra),
                                                     ' · ' ORDER BY ban, ten)
    FROM (SELECT t.label ban, c.component_name ten,
                 (SELECT sum(l.quantity * c2.quantity) FROM order_line l
                    JOIN order_line_component c2 ON c2.order_line_id = l.id JOIN sales_order o2 ON o2.id = l.sales_order_id
                   WHERE o2.dining_table_id = t.id AND o2.status <> 'cancelled' AND c2.component_name = c.component_name) goi,
                 count(*) FILTER (WHERE sj.status = 'served') ra
          FROM station_job sj JOIN sales_order o ON o.id = sj.sales_order_id
          JOIN dining_table t ON t.id = o.dining_table_id
          JOIN order_line_component c ON c.id = sj.order_line_component_id
          WHERE t.label IN ('5', '3') AND o.status <> 'cancelled' AND sj.station_code = 'gap_banh'
          GROUP BY t.id, t.label, c.component_name) x));
  PERFORM pg_temp.yc_doc('YC-06', (SELECT format('tổng của mẻ Scenario 2: %s đơn vị = %s', sum(n),
      string_agg(n::text || ' của đơn ' || don, ' + ' ORDER BY don))
    FROM (SELECT sj.sales_order_id don, count(*) n FROM production_batch_item i JOIN station_job sj ON sj.id = i.station_job_id
          WHERE i.production_batch_id = (SELECT min(i2.production_batch_id) FROM production_batch_item i2
                                         JOIN station_job j2 ON j2.id = i2.station_job_id
                                         JOIN sales_order o2 ON o2.id = j2.sales_order_id WHERE o2.id = pg_temp.yc_don('delivery'))
          GROUP BY 1) x));
  SELECT * INTO STRICT vj FROM station_job
   WHERE sales_order_id = pg_temp.sc_id('don_10') AND order_line_component_id IS NOT NULL ORDER BY id LIMIT 1;
  PERFORM pg_temp.yc_tu_choi('YC-06', 'đã phục vụ vượt đã gọi (thêm một đơn vị ngoài số đã gọi)',
    format($q$INSERT INTO station_job (sales_order_id, order_line_id, order_line_component_id, station_code,
              line_quantity, component_quantity, position, status)
              VALUES (%s, %s, %s, %L, %s, %s, %s, 'pending')$q$,
           vj.sales_order_id, vj.order_line_id, vj.order_line_component_id, vj.station_code, vj.line_quantity,
           vj.component_quantity, vj.unit_limit + 1));
  PERFORM pg_temp.yc_khong_cho('YC-06', 'một con số tổng không chia hết về bàn — bảng sản xuất có cột tổng nào không',
    $d$NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'shop'
                    AND table_name IN ('station_job', 'production_batch', 'production_batch_item')
                    AND column_name ~ '(total|sum|count)')$d$,
    'không ô tổng nào để lệch (I-019): mọi con số cộng lại từ đơn vị');
END $$;

-- ============================================================ YC-07 mẻ · phần của từng bàn · lùi mẻ
DO $$
DECLARE ml record; vi record;
BEGIN
  PERFORM pg_temp.yc_doc('YC-07', (SELECT format('mẻ %s (bấm %s bởi %s): %s', pg_temp.sc_id('me_lai'),
      pg_temp.yc_hhmm(max(b.made_at)), pg_temp.yc_ten(max(b.made_by_person_id)),
      string_agg(format('bàn %s ×%s', ban, n), ' · ' ORDER BY ban))
    FROM (SELECT t.label ban, count(*) n FROM production_batch_item i JOIN station_job j ON j.id = i.station_job_id
          JOIN sales_order o ON o.id = j.sales_order_id JOIN dining_table t ON t.id = o.dining_table_id
          WHERE i.production_batch_id = pg_temp.sc_id('me_lai') GROUP BY t.label) x
    JOIN production_batch b ON b.id = pg_temp.sc_id('me_lai')));
  SELECT * INTO STRICT ml FROM production_batch WHERE id = pg_temp.sc_id('me_lui');
  PERFORM pg_temp.yc_doc('YC-07', format('lùi mẻ %s: bấm %s, lùi %s bởi %s, đã phủ %s thứ · bàn 10 · 11 sau khi bấm lại: chưa làm %s · đã làm xong còn ở bếp %s · đã ra bàn %s',
    ml.id, pg_temp.yc_hhmm(ml.made_at), pg_temp.yc_hhmm(ml.rolled_back_at), pg_temp.yc_ten(ml.rolled_back_by_person_id),
    (SELECT count(*) FROM production_batch_item WHERE production_batch_id = ml.id),
    (SELECT count(*) FROM station_job WHERE sales_order_id IN (pg_temp.sc_id('don_10'), pg_temp.sc_id('don_11')) AND status = 'pending'),
    (SELECT count(*) FROM station_job WHERE sales_order_id IN (pg_temp.sc_id('don_10'), pg_temp.sc_id('don_11')) AND status = 'made'),
    (SELECT count(*) FROM station_job WHERE sales_order_id IN (pg_temp.sc_id('don_10'), pg_temp.sc_id('don_11')) AND status = 'served')));
  SELECT * INTO STRICT vi FROM production_batch_item WHERE production_batch_id = pg_temp.sc_id('me_lai') ORDER BY id LIMIT 1;
  PERFORM pg_temp.yc_tu_choi('YC-07', 'một thứ của mẻ không chia về đơn vị nào (không bàn nào)',
    format($q$INSERT INTO production_batch_item (production_batch_id, made_for_station_job_id, station_job_id)
              VALUES (%s, %s, NULL)$q$, vi.production_batch_id, vi.made_for_station_job_id));
  PERFORM pg_temp.yc_tu_choi('YC-07', 'lùi một phần của mẻ (một thứ còn, một thứ lùi)',
    format($q$UPDATE production_batch_item SET batch_rolled_back = true WHERE id = %s$q$, vi.id));
  -- Thứ đã làm của bàn 11 chuyển sang đơn vị đang chờ cùng thành phần, cùng trạm của bàn 13 — đủ mọi
  -- bước của một lần chuyển, TRỪ dòng vết chuyển.
  SELECT i.* INTO STRICT vi FROM production_batch_item i JOIN station_job sj ON sj.id = i.station_job_id
    JOIN order_line_component c ON c.id = sj.order_line_component_id
   WHERE i.production_batch_id = pg_temp.sc_id('me_lai') AND sj.sales_order_id = pg_temp.sc_id('don_11')
     AND sj.station_code = 'trang_banh' AND c.component_name = 'Trứng chín';
  PERFORM pg_temp.yc_tu_choi('YC-07', 'thứ đã làm của một đơn đổi chủ sang bàn khác mà không có lần chuyển',
    format($q$DO $d$ DECLARE toi bigint; BEGIN
              SELECT sj.id INTO STRICT toi FROM station_job sj JOIN order_line_component c ON c.id = sj.order_line_component_id
               WHERE sj.sales_order_id = %s AND sj.station_code = 'trang_banh' AND c.component_name = 'Trứng chín';
              UPDATE production_batch_item SET station_job_id = toi WHERE id = %s;
              UPDATE station_job SET status = 'made' WHERE id = toi;
              UPDATE station_job SET status = 'pending' WHERE id = %s; END $d$ $q$,
           pg_temp.sc_id('don_13'), vi.id, vi.station_job_id));
  PERFORM pg_temp.yc_goi_ten('YC-07', 'phần đã làm của đơn huỷ nằm lại bàn không chờ đúng thứ ấy',
    'tầng 4 (người chọn bàn nhận); ca KHÔNG bàn nào chờ còn là U-064', 'I-004/6', 'i004_6');
END $$;

-- ============================================================ YC-08 nhập bù từ sổ giấy
DO $$
DECLARE b record; pl record;
BEGIN
  SELECT * INTO STRICT b FROM bill WHERE id = pg_temp.sc_id('hd_nhap_bu');
  SELECT * INTO STRICT pl FROM paper_ledger WHERE id = pg_temp.sc_id('so_giay');
  PERFORM pg_temp.yc_doc('YC-08', format('lượt %s/%s của sổ ngày %s: ngày bán %s lúc %s · gõ vào máy %s · người nhập bù %s · người đứng quầy lúc bán %s · còn %s lượt trên giấy chưa nhập',
    b.paper_position, pl.entry_count, pl.sale_date, b.sale_date, to_char(b.booked_at, 'HH24:MI'),
    to_char(b.created_at, 'YYYY-MM-DD HH24:MI'), pg_temp.yc_ten(b.person_id), pg_temp.yc_quay(b.booked_at),
    pl.entry_count - (SELECT count(*) FROM bill WHERE paper_ledger_id = pl.id)));
  PERFORM pg_temp.yc_tu_choi('YC-08', 'lượt nhập bù rơi vào ngày gõ',
    format($q$UPDATE bill SET sale_date = sale_date + 1 WHERE id = %s$q$, b.id));
  PERFORM pg_temp.yc_tu_choi('YC-08', 'nhập bù quá số lượt sổ đã khai',
    format($q$UPDATE bill SET paper_position = 3 WHERE id = %s$q$, b.id));
  -- T-133 (F-048): dấu ngày đã đối soát xong có chỗ cất (reconciled_day); "còn N > 0" là phép trừ qua
  -- nhiều dòng nên database không chặn, câu I-014/5 gọi tên.
  PERFORM pg_temp.yc_goi_ten('YC-08', 'ngày còn lượt giấy chưa nhập được coi là đã đối soát xong',
    'tầng 5 (ADR-037); cửa đóng ngày của pha 3 đọc còn N trước khi bấm', 'I-014/5', 'i014_5');
END $$;

-- ============================================================ YC-09 nợ sống lâu hơn phiên
DO $$
DECLARE b record;
BEGIN
  SELECT * INTO STRICT b FROM bill WHERE id = pg_temp.sc_id('hd_no');
  PERFORM pg_temp.yc_doc('YC-09', format('phiên %s đóng (%s) · khoản nợ %s đ của "%s" sinh lúc đóng %s · thu ngày %s — đọc được khi phiên đã đóng',
    b.table_session_id, (SELECT status FROM table_session WHERE id = b.table_session_id), b.debt_vnd, b.debtor_name,
    pg_temp.yc_hhmm(b.booked_at), (SELECT sale_date FROM debt_collection WHERE bill_id = b.id)));
  PERFORM pg_temp.yc_tu_choi('YC-09', 'khoản nợ chỉ đứng được trong lúc phiên còn mở (hoá đơn nợ trên phiên chưa đóng)',
    format($q$INSERT INTO bill (table_session_id, due_vnd, debt_vnd, debtor_name) VALUES (%s, 1000, 1000, 'x')$q$,
           pg_temp.sc_id('phien_10')));
END $$;

-- ============================================================ YC-10 hai mốc của một khoản nợ
DO $$
DECLARE b record; d record;
BEGIN
  SELECT * INTO STRICT b FROM bill WHERE id = pg_temp.sc_id('hd_no');
  SELECT * INTO STRICT d FROM debt_collection WHERE bill_id = b.id;
  PERFORM pg_temp.yc_doc('YC-10', format('doanh thu đọc mốc ghi nợ: ngày %s · đối soát tiền đọc mốc thu nợ: ngày %s, %s đ chuyển khoản',
    b.sale_date, d.sale_date, d.transfer_vnd));
  PERFORM pg_temp.yc_tu_choi('YC-10', 'lần trả nợ ghi thành một hoá đơn bán mới của cùng phiên',
    format($q$INSERT INTO bill (table_session_id, due_vnd, cash_vnd) VALUES (%s, %s, %s)$q$,
           b.table_session_id, b.debt_vnd, b.debt_vnd));
  PERFORM pg_temp.yc_tu_choi('YC-10', 'thu nợ hai lần',
    format($q$INSERT INTO debt_collection (bill_id, debt_vnd, cash_vnd) VALUES (%s, %s, %s)$q$,
           b.id, b.debt_vnd, b.debt_vnd));
END $$;

-- ============================================================ YC-11 danh tính chỉ ở ca ghi nợ
DO $$
BEGIN
  PERFORM pg_temp.yc_doc('YC-11', format('hoá đơn mang tên người nợ: %s / %s hoá đơn, đều có nợ: %s · cột danh tính ở bảng phiên: %s',
    (SELECT count(*) FROM bill WHERE debtor_name IS NOT NULL), (SELECT count(*) FROM bill),
    NOT EXISTS (SELECT 1 FROM bill WHERE debtor_name IS NOT NULL AND debt_vnd = 0),
    coalesce((SELECT string_agg(column_name, ', ') FROM information_schema.columns WHERE table_schema = 'shop'
               AND table_name IN ('table_session', 'table_session_member') AND column_name ~ '(name|phone)'), 'không có')));
  PERFORM pg_temp.yc_tu_choi('YC-11', 'hỏi danh tính ở một phiên không nợ',
    format($q$UPDATE bill SET debtor_name = 'x' WHERE table_session_id = %s$q$, pg_temp.yc_phien('5')));
END $$;

-- ============================================================ YC-12 vết thao tác chạm tiền
DO $$
BEGIN
  PERFORM pg_temp.yc_doc('YC-12', (SELECT string_agg(format('%s %s đ %s %s', k, so, pg_temp.yc_ten(ai), pg_temp.yc_hhmm(luc)), ' · ' ORDER BY luc)
    FROM (SELECT 'thu' k, cash_vnd + transfer_vnd so, person_id ai, booked_at luc FROM bill WHERE cash_vnd + transfer_vnd > 0
          UNION ALL SELECT 'ghi nợ', debt_vnd, person_id, booked_at FROM bill WHERE debt_vnd > 0
          UNION ALL SELECT 'thu nợ', debt_vnd, person_id, booked_at FROM debt_collection
          UNION ALL SELECT 'nhận trả trước', cash_vnd + transfer_vnd, person_id, booked_at FROM prepayment
          UNION ALL SELECT 'hoàn', amount_vnd, person_id, booked_at FROM refund) x));
  PERFORM pg_temp.yc_doc('YC-12', 'vết sống độc lập với bản ghi: khoá ngoại của bảng vết chỉ tới — '
    || (SELECT string_agg(ccu.table_name, ', ') FROM information_schema.table_constraints tc
        JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
        WHERE tc.table_schema = 'shop' AND tc.table_name = 'record_revision' AND tc.constraint_type = 'FOREIGN KEY'));
  PERFORM pg_temp.yc_goi_ten('YC-12', 'một đường đổi tiền không đi qua chỗ bấm đã chốt',
    'tầng 3 (cửa ghi của POS, pha 3)', 'I-012/3', 'i012_3');
END $$;

-- ============================================================ YC-13 vết một lần cập nhật
DO $$
DECLARE v record; a bigint := pg_temp.yc_don('delivery');
BEGIN
  SELECT r.* INTO STRICT v FROM record_revision r
   WHERE r.target_table_code = 'menu_item_component';
  PERFORM pg_temp.yc_doc('YC-13', format('sửa thành phần combo: trước %s → sau %s cái bánh · lý do "%s" · người sửa %s · lúc %s',
    v.before_image ->> 'quantity', v.after_image ->> 'quantity', v.reason, pg_temp.yc_ten(v.person_id), pg_temp.yc_hhmm(v.revised_at)));
  PERFORM pg_temp.yc_tu_choi('YC-13', 'một lần sửa có khai lý do nhưng không có người sửa',
    format($q$DO $d$ BEGIN PERFORM set_config('shop.actor_person_id', '', true);
              UPDATE sales_order SET contact_note = 'sửa không người' WHERE id = %s; END $d$ $q$, a));
  PERFORM pg_temp.yc_dung_duoc('YC-13', 'một lần sửa không khai lý do — không bản trước, không bản sau',
    format($q$DO $d$ BEGIN PERFORM set_config('shop.revision_reason', '', true);
              UPDATE sales_order SET delivery_address = '99 phố khác' WHERE id = %s; END $d$ $q$, a),
    format($d$(SELECT delivery_address FROM sales_order WHERE id = %1$s) = '99 phố khác' AND NOT EXISTS
             (SELECT 1 FROM record_revision WHERE target_table_code = 'sales_order' AND target_row = %1$s
                AND after_image ->> 'delivery_address' = '99 phố khác')$d$, a),
    'F-046 (chế độ mềm của vết)');
END $$;

-- ============================================================ YC-14 không hoàn tác; sửa giữ hai phía
DO $$
DECLARE s bigint := pg_temp.yc_phien('5'); j bigint;
BEGIN
  PERFORM pg_temp.yc_doc('YC-14', (SELECT format('phiên bàn 5 quay ngược: %s → %s lúc %s bởi %s, lý do "%s"',
      before_image ->> 'status', after_image ->> 'status', pg_temp.yc_hhmm(revised_at), pg_temp.yc_ten(person_id), reason)
    FROM record_revision WHERE target_table_code = 'table_session' AND target_row = s
      AND before_image ->> 'status' = 'awaiting_payment' AND after_image ->> 'status' = 'serving'));
  SELECT id INTO j FROM station_job WHERE sales_order_id = pg_temp.yc_don('pickup')
   AND status = 'served' ORDER BY id LIMIT 1;
  PERFORM pg_temp.yc_dung_duoc('YC-14', 'quay trạng thái về chỗ cũ không để lại hai phía (đơn vị đã ra bàn lùi về đã làm xong, không khai lý do)',
    format($q$DO $d$ BEGIN PERFORM set_config('shop.revision_reason', '', true);
              UPDATE station_job SET status = 'made' WHERE id = %s; END $d$ $q$, j),
    format($d$(SELECT status FROM station_job WHERE id = %1$s) = 'made' AND NOT EXISTS
             (SELECT 1 FROM record_revision WHERE target_table_code = 'station_job' AND target_row = %1$s
                AND before_image ->> 'status' = 'served' AND after_image ->> 'status' = 'made')$d$, j),
    'F-046 (chế độ mềm của vết)');
END $$;

-- ============================================================ YC-15 ai đứng quầy tại một thời điểm
DO $$
BEGIN
  PERFORM pg_temp.yc_doc('YC-15', format('07:00 %s · 10:29 %s · 10:30 %s · hôm sau 06:30 %s · hôm sau 08:00 %s',
    pg_temp.yc_quay(pg_temp.sc_luc('07:00')), pg_temp.yc_quay(pg_temp.sc_luc('10:29')),
    pg_temp.yc_quay(pg_temp.sc_luc('10:30')), pg_temp.yc_quay(pg_temp.sc_luc('06:30') + interval '1 day'),
    pg_temp.yc_quay(pg_temp.sc_luc('08:00') + interval '1 day')));
  PERFORM pg_temp.yc_tu_choi('YC-15', 'hai người đứng quầy cùng một lúc (khoảng chồng nhau)',
    format($q$INSERT INTO counter_duty (person_id, started_at, ended_at) VALUES (%s, %L, %L)$q$,
           pg_temp.sc_nguoi('Người canh & dọn'), pg_temp.sc_luc('09:00'), pg_temp.sc_luc('09:30')));
END $$;

-- ============================================================ YC-16 chủ quán đứng quầy: hai vai cộng
DO $$
DECLARE chu bigint := pg_temp.sc_nguoi('Chủ quán');
BEGIN
  PERFORM pg_temp.yc_doc('YC-16', format('10:45: đứng quầy %s · %s là chủ quán: %s — cùng lúc',
    pg_temp.yc_quay(pg_temp.sc_luc('10:45')), pg_temp.yc_ten(chu), (SELECT is_owner FROM person WHERE id = chu)));
  PERFORM pg_temp.yc_khong_cho('YC-16', 'vai này thay vai kia — có ô "vai hiện tại" nào để ghi đè không',
    $d$NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'shop'
                               AND table_name IN ('person', 'counter_duty') AND column_name ~ '(role|current|vai)')$d$,
    'cờ chủ quán và khoảng trực là hai chỗ riêng; câu này in ra để chứng minh vắng mặt');
END $$;

-- ============================================================ YC-17 năm trạm, bốn vai người
DO $$
BEGIN
  PERFORM pg_temp.yc_doc('YC-17', format('người của quán: %s · bảng nối người với trạm: %s',
    (SELECT string_agg(display_name, ', ' ORDER BY id) FROM person),
    coalesce((SELECT string_agg(DISTINCT c.table_name, ', ') FROM information_schema.columns c
              WHERE c.table_schema = 'shop' AND c.column_name = 'station_code'
                AND EXISTS (SELECT 1 FROM information_schema.columns p WHERE p.table_schema = 'shop'
                              AND p.table_name = c.table_name AND p.column_name ~ 'person')), 'không có')));
  PERFORM pg_temp.yc_khong_cho('YC-17', 'hệ thống đòi năm người cho năm trạm — có ràng buộc nào đòi đủ người mỗi trạm không',
    $d$NOT EXISTS (SELECT 1 FROM information_schema.columns c WHERE c.table_schema = 'shop'
                    AND c.column_name = 'station_code'
                    AND EXISTS (SELECT 1 FROM information_schema.columns p WHERE p.table_schema = 'shop'
                                  AND p.table_name = c.table_name AND p.column_name ~ 'person'))$d$,
    'trạm canh và dọn bàn không nối với người nào (U-055: bốn trạm ngoài quầy không ghi mốc đổi)');
END $$;

-- ============================================================ YC-18 mỗi việc chạm tiền đúng một mốc
DO $$
BEGIN
  PERFORM pg_temp.yc_doc('YC-18', (SELECT string_agg(format('%s.sale_date %s', table_name,
                                        CASE is_nullable WHEN 'NO' THEN 'bắt buộc' ELSE 'TRỐNG ĐƯỢC' END), ' · ' ORDER BY table_name)
    FROM information_schema.columns WHERE table_schema = 'shop' AND column_name = 'sale_date'
      AND table_name IN ('bill', 'debt_collection', 'prepayment', 'refund')));
  PERFORM pg_temp.yc_tu_choi('YC-18', 'một lần hoàn không có ngày tính tiền',
    format($q$INSERT INTO refund (bill_id, amount_vnd, method_code, source_method_code, reason, sale_date)
              VALUES (%s, 1000, 'cash', 'cash', 'x', NULL)$q$, (SELECT bill_id FROM refund WHERE id = pg_temp.sc_id('hoan'))));
END $$;

-- ============================================================ YC-19 các phần của một lần thu chung một mốc
DO $$
DECLARE b record;
BEGIN
  SELECT * INTO STRICT b FROM bill WHERE table_session_id = pg_temp.yc_phien('5');
  PERFORM pg_temp.yc_doc('YC-19', format('hoá đơn %s: tiền mặt %s + chuyển khoản %s trên MỘT dòng, một mốc %s, ngày %s',
    b.id, b.cash_vnd, b.transfer_vnd, pg_temp.yc_hhmm(b.booked_at), b.sale_date));
  PERFORM pg_temp.yc_tu_choi('YC-19', 'phần chuyển khoản của cùng lần thu ghi sang ngày khác (dòng thứ hai)',
    format($q$INSERT INTO bill (table_session_id, due_vnd, transfer_vnd, sale_date) VALUES (%s, %s, %s, %L)$q$,
           b.table_session_id, b.transfer_vnd, b.transfer_vnd, b.sale_date + 1));
END $$;

-- ============================================================ YC-20 mốc đã ghi không dời âm thầm
DO $$
DECLARE b bigint := (SELECT id FROM bill WHERE table_session_id = pg_temp.yc_phien('3'));
BEGIN
  PERFORM pg_temp.yc_doc('YC-20', (SELECT format('hoá đơn bàn 3: mốc %s, ngày %s — số lần sửa mốc có vết: %s',
      pg_temp.yc_hhmm(booked_at), sale_date,
      (SELECT count(*) FROM record_revision WHERE target_table_code = 'bill' AND target_row = b
         AND before_image -> 'booked_at' IS DISTINCT FROM after_image -> 'booked_at'))
    FROM bill WHERE id = b));
  PERFORM pg_temp.yc_goi_ten('YC-20', 'dời mốc có khai lý do', 'tầng 5 — đọc từ vết', 'QD-33/b', 'qd33_b');
  PERFORM pg_temp.yc_dung_duoc('YC-20', 'dời mốc tính tiền không khai lý do — không vết, không câu nào thấy',
    format($q$DO $d$ BEGIN PERFORM set_config('shop.revision_reason', '', true);
              UPDATE bill SET booked_at = booked_at - interval '1 hour' WHERE id = %s; END $d$ $q$, b),
    format($d$NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code = 'bill' AND target_row = %s
                AND before_image -> 'booked_at' IS DISTINCT FROM after_image -> 'booked_at')$d$, b),
    'F-046 (chế độ mềm của vết)');
END $$;

-- ============================================================ YC-22 liên hệ tối thiểu của đơn mang đi
DO $$
BEGIN
  PERFORM pg_temp.yc_doc('YC-22', (SELECT string_agg(format('%s: %s · sđt %s · địa chỉ %s · cần lúc %s · tên %s', channel_code,
      handover_code, customer_phone, coalesce(delivery_address, '—'), coalesce(to_char(customer_needed_at, 'HH24:MI'), '—'),
      coalesce(customer_name, '— (nên có, không bắt buộc)')), ' | ' ORDER BY created_at)
    FROM sales_order WHERE table_session_id IS NULL AND status = 'completed' AND pg_temp.yc_cua_ngay(created_at)));
  PERFORM pg_temp.yc_tu_choi('YC-22', 'đơn Delivery thiếu địa chỉ',
    $q$INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, submission_code)
       VALUES ('delivery', 'new', 'door_delivery', '0900000001', 'yc22-a')$q$);
  PERFORM pg_temp.yc_tu_choi('YC-22', 'đơn hotline không có cách trao hàng',
    $q$INSERT INTO sales_order (channel_code, status, customer_phone, customer_needed_at, submission_code)
       VALUES ('phone_preorder', 'new', '0900000001', now(), 'yc22-b')$q$);
  PERFORM pg_temp.yc_tu_choi('YC-22', 'đơn Delivery mang nhánh tới lấy',
    $q$INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, delivery_address, submission_code)
       VALUES ('delivery', 'new', 'shop_pickup', '0900000001', 'x', 'yc22-c')$q$);
  PERFORM pg_temp.yc_tu_choi('YC-22', 'đơn Pickup thiếu giờ khách cần',
    $q$INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, submission_code)
       VALUES ('pickup', 'new', 'shop_pickup', '0900000001', 'yc22-d')$q$);
  PERFORM pg_temp.yc_di_qua('YC-22', 'trường "nên có" thành điều kiện tạo đơn (đơn không tên khách)',
    $q$INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
       VALUES ('pickup', 'new', 'shop_pickup', '0900000001', now(), 'yc22-e')$q$,
    $d$EXISTS (SELECT 1 FROM sales_order WHERE submission_code = 'yc22-e' AND customer_name IS NULL)$d$);
END $$;

-- ============================================================ YC-23 khoản trả trước
DO $$
DECLARE p record; b record; d date := pg_temp.sc_ngay();
BEGIN
  SELECT * INTO STRICT p FROM prepayment WHERE sales_order_id = pg_temp.yc_don('pickup');
  SELECT * INTO STRICT b FROM bill WHERE sales_order_id = p.sales_order_id;
  PERFORM pg_temp.yc_doc('YC-23', format('đơn %s · %s đ (tiền mặt %s · chuyển khoản %s) · nhận lúc %s · %s bấm đã nhận · thành doanh thu ở hoá đơn %s ngày %s',
    p.sales_order_id, p.cash_vnd + p.transfer_vnd, p.cash_vnd, p.transfer_vnd, pg_temp.yc_hhmm(p.booked_at),
    pg_temp.yc_ten(p.person_id), b.id, b.sale_date));
  PERFORM pg_temp.yc_doc('YC-23', format('ngày %s — nhận: %s · thành doanh thu: %s · trả lại: %s', d,
    coalesce((SELECT string_agg(format('#%s %s đ', id, cash_vnd + transfer_vnd), ', ') FROM prepayment WHERE sale_date = d), 'không'),
    coalesce((SELECT string_agg(format('#%s %s đ', u.prepayment_id, u.take_vnd), ', ') FROM prepayment_use u
               JOIN bill x ON x.id = u.bill_id WHERE x.sale_date = d), 'không'),
    coalesce((SELECT string_agg(format('#%s %s đ bằng %s', prepayment_id, amount_vnd, method_code), ', ') FROM refund
               WHERE prepayment_id IS NOT NULL AND sale_date = d), 'không')));
  PERFORM pg_temp.yc_tu_choi('YC-23', 'đã thành doanh thu + đã trả lại vượt số đã nhận (trả lại thêm sau khi đã dùng hết)',
    format($q$INSERT INTO prepayment_use (prepayment_id, sales_order_id, use_no, cash_before_vnd, transfer_before_vnd,
              take_transfer_vnd, refund_id) VALUES (%s, %s, 2, 0, 0, 1000, NULL)$q$, p.id, p.sales_order_id));
  PERFORM pg_temp.yc_goi_ten('YC-23', 'khoản trả trước vào doanh thu ngày nhận khi đơn đóng ngày khác',
    'tầng 3 (doanh thu đọc ngày của hoá đơn)', 'I-014/7', 'i014_7');
  PERFORM pg_temp.yc_tu_choi('YC-23', 'lần trả lại khoản CHƯA thành doanh thu trừ vào một hoá đơn (hai đích cùng lúc)',
    format($q$INSERT INTO refund (bill_id, prepayment_id, amount_vnd, method_code, source_method_code, reason)
              VALUES (%s, %s, 1000, 'cash', 'transfer', 'x')$q$, b.id, p.id));
END $$;

-- ============================================================ YC-24 mã QR của bàn
DO $$
DECLARE t bigint := pg_temp.sc_ban('5'); cu record; moi record; l1 bigint; s bigint;
BEGIN
  SELECT * INTO STRICT cu FROM qr_code WHERE dining_table_id = t AND replaced_at IS NOT NULL;
  SELECT * INTO STRICT moi FROM qr_code WHERE dining_table_id = t AND replaced_at IS NULL;
  SELECT id INTO l1 FROM sales_order WHERE table_session_id = pg_temp.yc_phien('5') ORDER BY created_at LIMIT 1;
  PERFORM pg_temp.yc_doc('YC-24', format('bàn 5: mã hiện hành #%s từ %s · mã đã thay #%s hiện hành %s → %s · lần đổi bởi %s · lượt 1 của Scenario 1 mang mã #%s',
    moi.id, pg_temp.yc_hhmm(moi.issued_at), cu.id, pg_temp.yc_hhmm(cu.issued_at), pg_temp.yc_hhmm(cu.replaced_at),
    pg_temp.yc_ten(moi.person_id), (SELECT qr_code_id FROM sales_order WHERE id = l1)));
  PERFORM pg_temp.yc_tu_choi('YC-24', 'một bàn hai mã hiện hành',
    format($q$INSERT INTO qr_code (dining_table_id, code, issued_at) VALUES (%s, 'yc24-thu-hai', now())$q$, t));
  PERFORM pg_temp.yc_tu_choi('YC-24', 'một mã, kể cả mã đã thay, chỉ tới bàn thứ hai',
    format($q$INSERT INTO qr_code (dining_table_id, code, issued_at, replaced_at) VALUES (%s, %L, now(), now())$q$,
           pg_temp.sc_ban('14'), cu.code));
  PERFORM pg_temp.yc_tu_choi('YC-24', 'lượt gọi QR không mang mã',
    format($q$UPDATE sales_order SET qr_code_id = NULL WHERE id = %s$q$, l1));
  s := pg_temp.sc_id('phien_10');
  PERFORM qr_code_issue(pg_temp.sc_ban('10'));
  PERFORM pg_temp.yc_doc('YC-24', format('đổi mã bàn 10 khi phiên %s đang mở: phiên vẫn %s, số bàn vẫn "%s", số mã hiện hành của bàn 10: %s',
    s, (SELECT status FROM table_session WHERE id = s), (SELECT label FROM dining_table WHERE id = pg_temp.sc_ban('10')),
    (SELECT count(*) FROM qr_code WHERE dining_table_id = pg_temp.sc_ban('10') AND replaced_at IS NULL)));
  PERFORM pg_temp.yc_tu_choi('YC-24', 'lượt gọi QR mang mã của bàn khác',
    format($q$UPDATE sales_order SET qr_code_id = %s WHERE id = %s$q$,
           (SELECT id FROM qr_code WHERE dining_table_id = pg_temp.sc_ban('14') AND replaced_at IS NULL), l1));
END $$;

-- ============================================================ YC-25 dấu lần gửi
DO $$
DECLARE o record;
BEGIN
  SELECT * INTO STRICT o FROM sales_order WHERE id = pg_temp.yc_don('phone_preorder');
  PERFORM pg_temp.yc_doc('YC-25', format('%s / %s đơn mang dấu, %s dấu khác nhau · dấu %s… ⇒ đơn %s',
    (SELECT count(submission_code) FROM sales_order), (SELECT count(*) FROM sales_order),
    (SELECT count(DISTINCT submission_code) FROM sales_order), left(o.submission_code, 8),
    (SELECT id FROM sales_order WHERE submission_code = o.submission_code)));
  PERFORM pg_temp.yc_tu_choi('YC-25', 'hai đơn chung một dấu (gửi lại thành đơn thứ hai)',
    format($q$INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
              VALUES ('phone_preorder', 'new', 'shop_pickup', %L, now(), %L)$q$, o.customer_phone, o.submission_code));
  PERFORM pg_temp.yc_tu_choi('YC-25', 'một đơn không mang dấu',
    $q$INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at)
       VALUES ('pickup', 'new', 'shop_pickup', '0900000001', now())$q$);
  PERFORM pg_temp.yc_di_qua('YC-25', 'hai lần gửi khác dấu, nội dung giống hệt — phải là HAI đơn',
    format($q$INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
              VALUES ('phone_preorder', 'new', 'shop_pickup', %L, %L, 'yc25-khac-dau')$q$, o.customer_phone, o.customer_needed_at),
    format($d$(SELECT count(*) FROM sales_order WHERE customer_phone = %L AND channel_code = 'phone_preorder') = 2$d$, o.customer_phone));
END $$;

-- ============================================================ YC-34 khoảng ngừng nhận đơn (T-132)
-- Ba scenario không có lần tạm dừng hay lần quán mù nào: dựng ở đây, trong giao dịch ROLLBACK của file.
DO $$
DECLARE chu bigint := pg_temp.sc_nguoi('Chủ quán'); quay bigint := pg_temp.sc_nguoi('Người đứng quầy');
BEGIN
  INSERT INTO order_intake_pause (started_at, started_by_person_id, ended_at, ended_by_person_id)
  VALUES (pg_temp.sc_luc('09:40'), chu, pg_temp.sc_luc('09:50'), chu);
  INSERT INTO shop_blind_spell (started_at, ended_at, ended_by_person_id)
  VALUES (pg_temp.sc_luc('10:40'), pg_temp.sc_luc('10:50'), quay);
  PERFORM pg_temp.yc_doc('YC-34', (SELECT format('tạm dừng %s–%s bật %s tắt %s · quán mù %s–%s do %s, mở lại %s · lúc 09:45 tạm dừng %s, lúc 10:45 mù %s',
    to_char(p.started_at, 'HH24:MI'), to_char(p.ended_at, 'HH24:MI'), pg_temp.yc_ten(p.started_by_person_id),
    pg_temp.yc_ten(p.ended_by_person_id), to_char(m.started_at, 'HH24:MI'), to_char(m.ended_at, 'HH24:MI'),
    coalesce(pg_temp.yc_ten(m.declared_by_person_id), 'máy phát hiện'), pg_temp.yc_ten(m.ended_by_person_id),
    tstzrange(p.started_at, p.ended_at, '[)') @> pg_temp.sc_luc('09:45'),
    tstzrange(m.started_at, m.ended_at, '[)') @> pg_temp.sc_luc('10:45'))
    FROM order_intake_pause p, shop_blind_spell m WHERE pg_temp.yc_cua_ngay(p.started_at) AND pg_temp.yc_cua_ngay(m.started_at)));
  PERFORM pg_temp.yc_tu_choi('YC-34', 'hai lần tạm dừng chồng nhau (một mốc hai câu trả lời)',
    format($q$INSERT INTO order_intake_pause (started_at, started_by_person_id) VALUES (%L, %s)$q$,
           pg_temp.sc_luc('09:45'), chu));
  PERFORM pg_temp.yc_tu_choi('YC-34', 'tạm dừng không có người bật',
    format($q$INSERT INTO order_intake_pause (started_at, started_by_person_id) VALUES (%L, NULL)$q$,
           pg_temp.sc_luc('05:00')));
  PERFORM pg_temp.yc_tu_choi('YC-34', 'khoảng mù tự mở lại — kết thúc không có người bấm',
    format($q$INSERT INTO shop_blind_spell (started_at, ended_at) VALUES (%L, %L)$q$,
           pg_temp.sc_luc('05:00'), pg_temp.sc_luc('05:10')));
  PERFORM pg_temp.yc_goi_ten('YC-34', 'đơn tạo trong lúc tạm dừng', 'tầng 3 (cửa tạo lượt gọi)', 'I-008/2', 'i008_2');
  PERFORM pg_temp.yc_goi_ten('YC-34', 'đơn ba kênh khách tự bấm tạo trong lúc quán mù', 'tầng 3 (cửa tạo lượt gọi)', 'I-008/3', 'i008_3');
END $$;

-- ============================================================ YC-26…YC-32 (P2A-08)
DO $$
DECLARE i bigint; e bigint; a bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Chủ quán', 'P2A-08 chấm YC trên ngày quản trị');
  SELECT id INTO STRICT i FROM supply_item WHERE name = 'Hàng thêm S4 (dữ liệu diễn)';
  PERFORM pg_temp.yc_doc('YC-26', (SELECT format('%s · đơn vị %s', name, coalesce(purchase_unit, '(trống)'))
    FROM supply_item WHERE id = i));
  PERFORM pg_temp.yc_tu_choi('YC-26', 'một thứ đứng hai lần',
    $q$INSERT INTO supply_item (name) VALUES ('Hàng thêm S4 (dữ liệu diễn)')$q$);
  PERFORM pg_temp.yc_di_qua('YC-26', 'buộc có đơn vị mới cho thêm thứ',
    $q$INSERT INTO supply_item (name) VALUES ('YC-26 thử đơn vị trống')$q$,
    $d$EXISTS (SELECT 1 FROM supply_item WHERE name = 'YC-26 thử đơn vị trống' AND purchase_unit IS NULL)$d$);
  PERFORM pg_temp.yc_khong_cho('YC-26', 'danh mục có ngưỡng hoặc định lượng suất',
    $d$(SELECT array_agg(column_name::text ORDER BY ordinal_position) FROM information_schema.columns
        WHERE table_schema = 'shop' AND table_name = 'supply_item') =
        ARRAY['id','name','purchase_unit','created_at']$d$, 'đọc toàn bộ cột danh mục, không cột ngưỡng/định lượng');

  PERFORM pg_temp.yc_doc('YC-27', (SELECT string_agg(format('%s %s %s = %s', s.name, e.entry_date,
    e.kind_code, e.entered_measure), ' · ' ORDER BY s.name, e.entry_date, e.kind_code)
    FROM supply_day_entry e JOIN supply_item s ON s.id = e.supply_item_id
    WHERE e.entry_date BETWEEN pg_temp.sc_ngay()-1 AND pg_temp.sc_ngay()));
  PERFORM pg_temp.yc_tu_choi('YC-27', 'hai đáp số cùng thứ, ngày và loại',
    format($q$INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
      VALUES (%s, %L, 'purchased', 9)$q$, i, pg_temp.sc_ngay()));
  SELECT id INTO STRICT e FROM supply_day_entry WHERE supply_item_id = i AND kind_code = 'purchased';
  PERFORM pg_temp.yc_dung_duoc('YC-27', 'sửa con số không lý do, mất bản trước',
    format($q$DO $d$ BEGIN PERFORM set_config('shop.revision_reason', '', true);
      UPDATE supply_day_entry SET entered_measure = 99 WHERE id = %s; END $d$ $q$, e),
    format($d$(SELECT entered_measure = 99 FROM supply_day_entry WHERE id = %1$s)
      AND NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code = 'supply_day_entry'
        AND target_row = %1$s)$d$, e), 'F-046 — vết ở chế độ mềm');
  PERFORM pg_temp.yc_goi_ten('YC-27', 'con số có vết nhưng chuỗi bản trước/sau đứt',
    'tầng 5, chỉ bắt được khi đã có vết', 'I-025/2', 'i025_2');
  PERFORM pg_temp.yc_dung_duoc('YC-27', 'nhóm công tơ nhận cặp mua/dùng',
    $q$WITH x AS (INSERT INTO supply_item (name) VALUES ('Chỉ số công tơ điện (YC-27 diễn sai)') RETURNING id)
      INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
      SELECT id, CURRENT_DATE, v.kind, 1 FROM x CROSS JOIN (VALUES ('purchased'), ('used')) v(kind)$q$,
    $d$(SELECT count(*) = 2 FROM supply_day_entry e JOIN supply_item s ON s.id = e.supply_item_id
      WHERE s.name = 'Chỉ số công tơ điện (YC-27 diễn sai)')$d$,
    '12-luoc-do-nguyen-lieu.md §5 — máy không ngăn được tên công tơ, Claude nhận chỗ hở');

  PERFORM pg_temp.yc_doc('YC-28', (SELECT format('người nhập %s · ngày hàng %s · lúc gõ %s',
    p.display_name, x.entry_date, x.created_at) FROM supply_day_entry x JOIN person p ON p.id = x.person_id
    WHERE x.id = e));
  PERFORM pg_temp.yc_tu_choi('YC-28', 'con số không có người nhập',
    format('UPDATE supply_day_entry SET person_id = NULL WHERE id = %s', e));
  PERFORM pg_temp.yc_khong_cho('YC-28', 'gộp hai mốc thành một',
    $d$(SELECT count(*) = 2 FROM information_schema.columns WHERE table_schema = 'shop'
      AND table_name = 'supply_day_entry' AND column_name IN ('entry_date','created_at') AND is_nullable = 'NO')$d$,
    'ngày người khai và lúc ghi là hai cột bắt buộc riêng');

  PERFORM pg_temp.yc_doc('YC-29', (SELECT format('Gạo: tổng mua %s · tổng dùng %s · hiệu %s', mua, dung, mua-dung)
    FROM (SELECT sum(e.entered_measure) FILTER (WHERE kind_code = 'purchased') mua,
      sum(e.entered_measure) FILTER (WHERE kind_code = 'used') dung FROM supply_day_entry e
      JOIN supply_item s ON s.id = e.supply_item_id WHERE s.name = 'Gạo') t));
  PERFORM pg_temp.yc_khong_cho('YC-29', 'cất tổng, lô, kết luận thiếu hoặc lời nhắc',
    $d$(SELECT array_agg(column_name::text ORDER BY ordinal_position) FROM information_schema.columns
      WHERE table_schema = 'shop' AND table_name = 'supply_day_entry') =
      ARRAY['id','supply_item_id','entry_date','kind_code','entered_measure','person_id','created_at']$d$,
    'đọc toàn bộ cột con số ngày; tổng chỉ là phép cộng, không đặt lại ở lần mua thêm');
  PERFORM pg_temp.yc_di_qua('YC-29', 'từ chối hiệu số âm',
    format('UPDATE supply_day_entry SET entered_measure = 0 WHERE id = %s', e),
    format($d$(SELECT sum(CASE kind_code WHEN 'purchased' THEN entered_measure ELSE -entered_measure END) < 0
      FROM supply_day_entry WHERE supply_item_id = %s)$d$, i));

  PERFORM pg_temp.yc_doc('YC-30', (SELECT string_agg(format('%s ngày %s · tick bởi %s lúc %s · huỷ bởi %s lúc %s · %s',
    w.display_name, x.work_date, p.display_name, x.created_at, coalesce(c.display_name,'—'),
    coalesce(x.cancelled_at::text,'—'), coalesce(x.cancel_note,'—')), ' | ' ORDER BY w.display_name)
    FROM attendance_day x JOIN person w ON w.id = x.worker_person_id JOIN person p ON p.id = x.person_id
    LEFT JOIN person c ON c.id = x.cancelled_by_person_id WHERE x.work_date = pg_temp.sc_ngay()));
  PERFORM pg_temp.yc_tu_choi('YC-30', 'hai ô còn hiệu lực cùng người cùng ngày',
    format($q$INSERT INTO attendance_day (worker_person_id, work_date) VALUES (%s, %L)$q$,
      pg_temp.sc_nguoi('Người đứng quầy'), pg_temp.sc_ngay()));
  PERFORM pg_temp.yc_tu_choi('YC-30', 'huỷ không có người huỷ',
    format($q$UPDATE attendance_day SET cancelled_by_person_id = NULL
      WHERE work_date = %L AND cancelled_at IS NOT NULL$q$, pg_temp.sc_ngay()));
  PERFORM pg_temp.yc_goi_ten('YC-30', 'người tick không là chủ quán', 'tầng 3', 'I-027/4', 'i027_4');

  SELECT id INTO STRICT a FROM staff_advance WHERE paid_date = pg_temp.sc_ngay();
  PERFORM pg_temp.yc_doc('YC-31', (SELECT format('nhận %s · %s đ · ngày %s · lúc ghi %s · duyệt %s · ghi %s; chưa chọn ngày trừ két (U-072)',
    pg_temp.yc_ten(worker_person_id), amount_vnd, paid_date, created_at,
    pg_temp.yc_ten(approver_person_id), pg_temp.yc_ten(person_id)) FROM staff_advance WHERE id = a));
  PERFORM pg_temp.yc_tu_choi('YC-31', 'tạm ứng thiếu người duyệt',
    format('UPDATE staff_advance SET approver_person_id = NULL WHERE id = %s', a));
  PERFORM pg_temp.yc_goi_ten('YC-31', 'người duyệt không là chủ quán', 'tầng 3', 'I-028/3', 'i028_3');
  PERFORM pg_temp.yc_dung_duoc('YC-31', 'sửa đè tạm ứng không lý do',
    format($q$DO $d$ BEGIN PERFORM set_config('shop.revision_reason', '', true);
      UPDATE staff_advance SET amount_vnd = 100001 WHERE id = %s; END $d$ $q$, a),
    format($d$(SELECT amount_vnd = 100001 FROM staff_advance WHERE id = %1$s) AND NOT EXISTS
      (SELECT 1 FROM record_revision WHERE target_table_code = 'staff_advance' AND target_row = %1$s)$d$, a), 'F-046');
  PERFORM pg_temp.yc_chua('YC-31', 'gắn khoản rời két vào ngày bán',
    $d$NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'shop'
      AND table_name = 'staff_advance' AND column_name = 'sale_date')$d$,
    'U-072 — chưa có luật chọn ngày; không tự dựng cột ngày bán của két');

  SELECT id INTO STRICT a FROM holiday_bonus WHERE paid_date = pg_temp.sc_ngay();
  PERFORM pg_temp.yc_doc('YC-32', (SELECT format('nhận %s · %s đ · ngày %s · lúc ghi %s · ghi %s; chưa chọn ngày trừ két (U-072)',
    pg_temp.yc_ten(worker_person_id), amount_vnd, paid_date, created_at, pg_temp.yc_ten(person_id))
    FROM holiday_bonus WHERE id = a));
  PERFORM pg_temp.yc_tu_choi('YC-32', 'thưởng thiếu người nhận',
    format('UPDATE holiday_bonus SET worker_person_id = NULL WHERE id = %s', a));
  PERFORM pg_temp.yc_tu_choi('YC-32', 'thưởng thiếu số tiền',
    format('UPDATE holiday_bonus SET amount_vnd = NULL WHERE id = %s', a));
  PERFORM pg_temp.yc_dung_duoc('YC-32', 'sửa đè thưởng không lý do',
    format($q$DO $d$ BEGIN PERFORM set_config('shop.revision_reason', '', true);
      UPDATE holiday_bonus SET amount_vnd = 50001 WHERE id = %s; END $d$ $q$, a),
    format($d$(SELECT amount_vnd = 50001 FROM holiday_bonus WHERE id = %1$s) AND NOT EXISTS
      (SELECT 1 FROM record_revision WHERE target_table_code = 'holiday_bonus' AND target_row = %1$s)$d$, a), 'F-046');
  PERFORM pg_temp.yc_khong_cho('YC-32', 'cất sẵn loại thưởng ngày đông khách',
    $d$(SELECT array_agg(column_name::text ORDER BY ordinal_position) FROM information_schema.columns
      WHERE table_schema = 'shop' AND table_name = 'holiday_bonus') =
      ARRAY['id','worker_person_id','amount_vnd','paid_date','person_id','created_at']$d$, 'không cột loại thưởng');
  PERFORM pg_temp.yc_chua('YC-32', 'gắn khoản thưởng rời két vào ngày bán',
    $d$NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'shop'
      AND table_name = 'holiday_bonus' AND column_name = 'sale_date')$d$,
    'U-072 — chưa có luật chọn ngày; không tự dựng cột ngày bán của két');
END $$;

ROLLBACK;
