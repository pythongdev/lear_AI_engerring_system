-- Mô phỏng MỘT vòng bán tại bàn, gõ tay thẳng vào database — để XEM, không phải backend.
-- Giải thích và cách chạy: docs/guideline/hieu-va-kiem-database.md §6.
--
-- Khách ngồi bàn 5 quét QR gọi 2 suất đầy đủ trứng chín (thịt, thường) → quầy duyệt → hệ thống
-- nổ đơn xuống trạm → khách nhờ quầy gọi thêm 1 giò bán rời → bếp làm hai mẻ, quầy bấm "đã làm
-- xong" → bưng ra bàn → quầy tính tiền → khách trả nửa tiền mặt, nửa chuyển khoản → đóng phiên
-- → dọn bàn → bàn 5 nhận khách mới. Dọc đường, vài lần cố tình làm sai để thấy database chặn.
--
-- Toàn bộ nằm trong BEGIN … ROLLBACK: chạy xong database trở lại y như trước.
-- Cần database đã có dữ liệu mồi (make setup), và kết nối đặt múi giờ của quán (make psql lo).
--
-- Các hàm pg_temp.* dưới đây ĐỨNG THAY những cửa mà pha 3 (backend) sẽ viết — tạo lượt gọi, nổ
-- đơn, bấm mẻ. Chúng không phải các cửa ấy và không quyết luật nào mới. Thứ tự trạng thái theo
-- docs/product/0-ba/ban-hang/05-vong-doi.md §5.2 · §5.3 · §5.4; phép tính giá chép từ
-- db/seed/seed.pl --price-cases (đã khớp 13 ca §4.8 trong ./scripts/db-check.sh).
-- Chỗ còn mở: bấm "đã ra bàn" theo mẻ hay theo bàn là S-5 (master_plan/shop-facts.md §7.2) —
-- ở đây bấm cho cả bàn một lần, chỉ để đi tiếp.

\set ON_ERROR_STOP 1
\set QUIET 1
\pset footer off
BEGIN;

-- Người thao tác của giao dịch: mọi cột "ai bấm" lấy từ đây (I-012). Người đứng quầy lấy từ dữ
-- liệu mồi.
DO $$
DECLARE p bigint;
BEGIN
  SELECT id INTO p FROM person WHERE NOT is_owner ORDER BY id LIMIT 1;
  IF p IS NULL THEN RAISE EXCEPTION 'chưa có dữ liệu mồi — chạy make setup (hoặc make seed) trước'; END IF;
  PERFORM set_config('shop.actor_person_id', p::text, true);
  INSERT INTO counter_duty (person_id, started_at) VALUES (p, now());
  RAISE NOTICE '0. % vào ca quầy', (SELECT display_name FROM person WHERE id = p);
END $$;

CREATE TEMP TABLE k (name text PRIMARY KEY, id bigint NOT NULL);

-- Giá một suất = Σ số lượng × giá gốc + (số phần nhận nhân) × Σ phụ thu đã chọn (§4.6 luật 1 · 5).
-- NULL khi tổ hợp tuỳ chọn không hợp lệ (§4.6 luật 3). Chép từ db/seed/seed.pl.
CREATE FUNCTION pg_temp.gia(it bigint, sel bigint[]) RETURNS bigint LANGUAGE plpgsql AS $f$
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

-- Gọi một món vào đơn: dòng đơn + ẢNH CHỤP thành phần và tuỳ chọn lúc đặt (I-009), giá khoá lúc này.
CREATE FUNCTION pg_temp.goi_mon(p_don bigint, p_mon text, p_so_suat integer, p_tuy_chon text[])
RETURNS bigint LANGUAGE plpgsql AS $f$
DECLARE it bigint; sel bigint[]; price bigint; n integer; l bigint;
BEGIN
  SELECT id INTO STRICT it FROM menu_item WHERE name = p_mon;
  SELECT coalesce(array_agg(id), '{}') INTO sel FROM menu_option WHERE name = ANY (p_tuy_chon);
  price := pg_temp.gia(it, sel);
  IF price IS NULL THEN RAISE EXCEPTION 'tổ hợp tuỳ chọn không hợp lệ: % %', p_mon, p_tuy_chon; END IF;
  SELECT count(*) INTO n FROM menu_item_component WHERE menu_item_id = it;
  INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd, component_count)
  VALUES (p_don, p_so_suat, it, p_mon, price, n) RETURNING id INTO l;
  INSERT INTO order_line_component (order_line_id, position, line_component_count, menu_component_id,
                                    component_name, quantity, takes_filling, base_price_vnd)
  SELECT l, row_number() OVER (ORDER BY ic.id), n, ic.menu_component_id, mc.name, ic.quantity,
         mc.takes_filling, mc.base_price_vnd
  FROM menu_item_component ic JOIN menu_component mc ON mc.id = ic.menu_component_id
  WHERE ic.menu_item_id = it;
  INSERT INTO order_line_option (order_line_id, menu_option_id, option_group_name, option_name, surcharge_vnd)
  SELECT l, o.id, g.name, o.name, o.surcharge_vnd
  FROM menu_option o JOIN option_group g ON g.id = o.option_group_id WHERE o.id = ANY (sel);
  RAISE NOTICE '   + % × % [%] — % đ/suất', p_so_suat, p_mon, array_to_string(p_tuy_chon, ' · '), price;
  RETURN l;
END $f$;

-- Nổ đơn: Đã xác nhận → Đang thực hiện, và mọi việc trạm của đơn, trong cùng giao dịch (I-004).
-- Mỗi đơn vị một dòng; mỗi đơn đúng một phần nước chấm ở trạm canh (shop-facts §5.3 · §6.6).
CREATE FUNCTION pg_temp.no_don(p_don bigint) RETURNS void LANGUAGE plpgsql AS $f$
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

-- Quầy bấm "đã làm xong" cho một mẻ: mẻ làm ra đúng các việc đang chờ ở những trạm đã nêu.
CREATE FUNCTION pg_temp.bam_me(p_tram text[]) RETURNS void LANGUAGE plpgsql AS $f$
DECLARE b bigint; n int;
BEGIN
  INSERT INTO production_batch DEFAULT VALUES RETURNING id INTO b;
  INSERT INTO production_batch_item (production_batch_id, made_for_station_job_id, station_job_id)
  SELECT b, id, id FROM station_job WHERE status = 'pending' AND station_code = ANY (p_tram);
  UPDATE station_job SET status = 'made' WHERE status = 'pending' AND station_code = ANY (p_tram);
  GET DIAGNOSTICS n = ROW_COUNT;
  RAISE NOTICE '   mẻ % xong: % đơn vị ở trạm %', b, n, array_to_string(p_tram, ', ');
END $f$;

-- Bảng của quầy cho phiên: mỗi trạm, bao nhiêu việc ở từng trạng thái (đọc từ chi tiết, I-019).
CREATE FUNCTION pg_temp.bep(p_phien bigint) RETURNS text LANGUAGE sql AS $f$
  SELECT string_agg(format('%s: chờ %s · xong %s · ra bàn %s', station_code, cho, xong, ra), ' | '
                    ORDER BY station_code)
  FROM (SELECT j.station_code,
               count(*) FILTER (WHERE j.status = 'pending') cho,
               count(*) FILTER (WHERE j.status = 'made') xong,
               count(*) FILTER (WHERE j.status = 'served') ra
        FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
        WHERE o.table_session_id = p_phien GROUP BY 1) x
$f$;

-- Kiểm mọi ràng buộc hoãn NGAY bây giờ, như lúc COMMIT — vì cuối file là ROLLBACK, không COMMIT.
CREATE FUNCTION pg_temp.chot() RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
END $f$;

-- ============================================================ 1. khách ngồi bàn 5, quét QR
DO $$
DECLARE t bigint; s bigint; o bigint;
BEGIN
  RAISE NOTICE '1. Khách ngồi bàn 5, quét QR, gọi món';
  SELECT id INTO STRICT t FROM dining_table WHERE label = '5';
  INSERT INTO table_session (status) VALUES ('open') RETURNING id INTO s;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s, t);
  -- Đơn QR: khách tự gửi ⇒ Mới rồi sang Chờ xác nhận (kênh phải duyệt, §5.2). Đơn ghi mã QR
  -- hiện hành của chính bàn ấy mà khách đã quét (I-023).
  INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, qr_code_id, submission_code)
  VALUES ('qr_table', 'new', s, t,
          (SELECT id FROM qr_code WHERE dining_table_id = t AND replaced_at IS NULL),
          gen_random_uuid()::text) RETURNING id INTO o;
  PERFORM pg_temp.goi_mon(o, 'Đầy đủ trứng chín', 2, ARRAY['Thịt', 'Thường']);
  UPDATE sales_order SET status = 'pending_confirmation' WHERE id = o;
  RAISE NOTICE '   phiên % mở cho bàn 5 · đơn % (qr_table) đang chờ quầy duyệt', s, o;
  INSERT INTO k VALUES ('ban5', t), ('phien', s), ('don1', o);
  PERFORM pg_temp.chot();

  -- Làm sai: đẩy phần nước chấm của đơn xuống bếp khi quầy chưa duyệt.
  BEGIN
    INSERT INTO station_job (sales_order_id, station_code, position) VALUES (o, 'canh', 1);
    RAISE EXCEPTION 'database KHÔNG chặn việc bếp của đơn chưa duyệt';
  EXCEPTION WHEN foreign_key_violation OR check_violation THEN
    RAISE NOTICE '   ✗ bị chặn — đơn chưa duyệt không xuống bếp được (I-004): %', SQLERRM;
  END;
END $$;

-- ============================================================ 2. quầy duyệt, đơn xuống bếp
DO $$
DECLARE s bigint := (SELECT id FROM k WHERE name = 'phien'); o bigint := (SELECT id FROM k WHERE name = 'don1');
BEGIN
  RAISE NOTICE '2. Quầy duyệt đơn %; hệ thống nổ đơn xuống các trạm', o;
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.no_don(o);
  UPDATE table_session SET status = 'serving' WHERE id = s;
  PERFORM pg_temp.chot();
  RAISE NOTICE '   bếp: %', pg_temp.bep(s);
END $$;

-- ============================================================ 3. khách nhờ quầy gọi thêm
DO $$
DECLARE s bigint := (SELECT id FROM k WHERE name = 'phien'); t bigint := (SELECT id FROM k WHERE name = 'ban5');
        o bigint;
BEGIN
  RAISE NOTICE '3. Khách nhờ quầy gọi thêm (staff_pos — nhân viên nhập nên không cần duyệt)';
  INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, submission_code)
  VALUES ('staff_pos', 'new', s, t, gen_random_uuid()::text) RETURNING id INTO o;
  PERFORM pg_temp.goi_mon(o, 'Giò bán rời', 1, ARRAY[]::text[]);
  UPDATE sales_order SET status = 'confirmed' WHERE id = o;
  PERFORM pg_temp.no_don(o);
  INSERT INTO k VALUES ('don2', o);
  PERFORM pg_temp.chot();
  RAISE NOTICE '   đơn % vào CHÍNH phiên % · bếp: %', o, s, pg_temp.bep(s);

  -- Làm sai: bàn 5 đang có phiên chưa đóng mà mở thêm phiên thứ hai.
  BEGIN
    INSERT INTO table_session (status) VALUES ('open') RETURNING id INTO o;
    INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (o, t);
    RAISE EXCEPTION 'database KHÔNG chặn phiên thứ hai của bàn 5';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE '   ✗ bị chặn — một bàn chỉ một phiên chưa đóng (I-001): %', SQLERRM;
  END;
END $$;

-- ============================================================ 4. bếp làm theo mẻ
DO $$
DECLARE s bigint := (SELECT id FROM k WHERE name = 'phien');
BEGIN
  RAISE NOTICE '4. Bếp làm; quầy bấm "đã làm xong" theo mẻ (ba trạm bếp không bấm gì)';
  PERFORM pg_temp.bam_me(ARRAY['trang_banh']);
  PERFORM pg_temp.bam_me(ARRAY['gap_banh', 'canh']);
  PERFORM pg_temp.chot();
  RAISE NOTICE '   bếp: %', pg_temp.bep(s);
END $$;

-- ============================================================ 5. bưng ra bàn
DO $$
DECLARE s bigint := (SELECT id FROM k WHERE name = 'phien'); n int;
BEGIN
  RAISE NOTICE '5. Quầy bấm "đã ra bàn" (bấm theo mẻ hay theo bàn còn là S-5 — ở đây cả bàn một lần)';
  UPDATE station_job j SET status = 'served'
    FROM sales_order o WHERE o.id = j.sales_order_id AND o.table_session_id = s AND j.status = 'made';
  -- Mọi việc của đơn đã ra tới tay khách ⇒ đơn Hoàn thành (§5.2).
  UPDATE sales_order o SET status = 'completed'
   WHERE o.table_session_id = s AND o.status = 'in_progress'
     AND NOT EXISTS (SELECT 1 FROM station_job j WHERE j.sales_order_id = o.id AND j.status <> 'served');
  GET DIAGNOSTICS n = ROW_COUNT;
  PERFORM pg_temp.chot();
  RAISE NOTICE '   bếp: % · % đơn Hoàn thành', pg_temp.bep(s), n;
END $$;

-- ============================================================ 6. tính tiền
DO $$
DECLARE s bigint := (SELECT id FROM k WHERE name = 'phien'); due bigint;
BEGIN
  SELECT sum(l.line_total_vnd) INTO due
    FROM order_line l JOIN sales_order o ON o.id = l.sales_order_id
   WHERE o.table_session_id = s AND o.status <> 'cancelled';
  UPDATE table_session SET status = 'awaiting_payment' WHERE id = s;
  INSERT INTO k VALUES ('phai_tra', due);
  RAISE NOTICE '6. Quầy tính tiền cả phiên: % đ — phiên sang Chờ thanh toán (bàn vẫn bận)', due;
END $$;

-- Hoá đơn tạm của phiên, đọc từ ảnh chụp lúc đặt (không đọc menu hiện hành).
SELECT o.id AS don, o.channel_code AS kenh, l.item_name AS mon,
       coalesce(string_agg(op.option_name, ' · ' ORDER BY op.id), '') AS tuy_chon,
       l.quantity AS sl, l.unit_price_vnd AS don_gia, l.line_total_vnd AS thanh_tien
FROM sales_order o JOIN order_line l ON l.sales_order_id = o.id
LEFT JOIN order_line_option op ON op.order_line_id = l.id
WHERE o.table_session_id = (SELECT id FROM k WHERE name = 'phien')
GROUP BY o.id, o.channel_code, l.id ORDER BY o.id, l.id;

-- ============================================================ 7. khách trả, đóng phiên
DO $$
DECLARE s bigint := (SELECT id FROM k WHERE name = 'phien'); due bigint := (SELECT id FROM k WHERE name = 'phai_tra');
        cash bigint := 20000; b bigint;
BEGIN
  RAISE NOTICE '7. Khách trả % đ tiền mặt + % đ chuyển khoản; quầy đóng phiên', cash, due - cash;

  -- Làm sai: ghi thu nhiều hơn số phải trả.
  BEGIN
    INSERT INTO bill (table_session_id, due_vnd, cash_vnd, transfer_vnd) VALUES (s, due, cash, due);
    RAISE EXCEPTION 'database KHÔNG chặn thu vượt';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE '   ✗ bị chặn — tiền thu phải khớp số phải trả (I-015): %', SQLERRM;
  END;

  -- Làm sai: đóng phiên mà không có hoá đơn.
  BEGIN
    UPDATE table_session SET status = 'closed' WHERE id = s;
    UPDATE table_session_member SET session_closed = true WHERE table_session_id = s;
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION 'database KHÔNG chặn phiên đóng thiếu hoá đơn';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE '   ✗ bị chặn — phiên đã đóng phải có hoá đơn: %', SQLERRM;
  END;
  SET CONSTRAINTS ALL DEFERRED;

  -- Đường đúng: hoá đơn + đóng phiên + mọi bàn của phiên, cùng một giao dịch (I-017).
  INSERT INTO bill (table_session_id, due_vnd, cash_vnd, transfer_vnd)
  VALUES (s, due, cash, due - cash) RETURNING id INTO b;
  UPDATE table_session SET status = 'closed' WHERE id = s;
  UPDATE table_session_member SET session_closed = true WHERE table_session_id = s;
  PERFORM pg_temp.chot();
  RAISE NOTICE '   hoá đơn % ghi xong — ngày bán %, người thu %', b,
    (SELECT sale_date FROM bill WHERE id = b),
    (SELECT p.display_name FROM bill JOIN person p ON p.id = bill.person_id WHERE bill.id = b);
END $$;

-- ============================================================ 8. dọn bàn, khách mới
DO $$
DECLARE s bigint := (SELECT id FROM k WHERE name = 'phien'); t bigint := (SELECT id FROM k WHERE name = 'ban5');
        s2 bigint;
BEGIN
  UPDATE table_session_member SET cleaned_at = now() WHERE table_session_id = s;
  RAISE NOTICE '8. Người canh & dọn dọn bàn 5 xong — bàn trống';
  INSERT INTO table_session (status) VALUES ('open') RETURNING id INTO s2;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s2, t);
  PERFORM pg_temp.chot();
  RAISE NOTICE '   khách mới ngồi bàn 5 — phiên % mở được, vì phiên % đã đóng', s2, s;
END $$;

-- Hoá đơn cuối cùng, như đối soát sẽ đọc.
SELECT b.id AS hoa_don, b.due_vnd AS phai_tra, b.cash_vnd AS tien_mat, b.transfer_vnd AS chuyen_khoan,
       b.debt_vnd AS no, b.sale_date AS ngay_ban, to_char(b.booked_at, 'HH24:MI') AS luc, p.display_name AS nguoi_thu
FROM bill b JOIN person p ON p.id = b.person_id
WHERE b.table_session_id = (SELECT id FROM k WHERE name = 'phien');

ROLLBACK;
\echo 'Xong mô phỏng — ROLLBACK: database trở lại như trước khi chạy.'
