-- YC-07 · I-004 — thứ đã làm của một đơn HUỶ mà không bàn nào chờ đúng thứ ấy: người đứng quầy ghi
-- chú trên POS rằng đó là BÁNH LÀM SAI (shop-facts.md §5.4, lời đóng U-064). Mỗi ghi chú một dòng
-- wrong_make_note gắn vào đúng một đơn vị việc trạm đã làm xong / đã ra bàn của một đơn đã Huỷ, mang
-- người ghi và lúc ghi; chữ ghi chú để trống được. Ghi nhầm thì HUỶ ghi chú tại chỗ (lúc huỷ, người
-- huỷ), dòng ở lại làm vết; huỷ rồi thì thứ ấy chuyển được cho bàn khác như thường (lời chủ repo
-- 2026-10-01). Thiết kế: docs/decisions.md ADR-077. Viết TRƯỚC migration (T-127, Claude Code).
-- Dựng chung của file (pg_temp — mất cùng ROLLBACK). Menu, tên và số đều GIẢ (test-…); hàm don ·
-- no_don · bam_me đứng THAY các cửa của pha 3, cùng hình db/tests/i004_station_jobs_follow_approval.sql.
-- Người thao tác của giao dịch (P2-08, 06-luoc-do-nguoi-va-vet.md §0).
DO $$
DECLARE p bigint;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
END $$;

DO $$
DECLARE tai bigint; m bigint;
BEGIN
  INSERT INTO menu_component (name, base_price_vnd, takes_filling) VALUES ('test-trứng tái', 0, false) RETURNING id INTO tai;
  INSERT INTO menu_component_station (menu_component_id, station_code) VALUES (tai, 'trang_banh');
  INSERT INTO menu_item (name) VALUES ('test-trứng tái thêm') RETURNING id INTO m;
  INSERT INTO menu_item_component (menu_item_id, menu_component_id, quantity) VALUES (m, tai, 1);
END $$;

-- Một lượt gọi staff_pos của bàn p_ban, một dòng p_so_suat suất "test-trứng tái thêm", đơn ở Đã xác nhận.
CREATE FUNCTION pg_temp.don(p_ban text, p_so_suat integer) RETURNS bigint LANGUAGE plpgsql AS $f$
DECLARE t bigint; s bigint; o bigint; l bigint; m bigint;
BEGIN
  INSERT INTO dining_table (label) VALUES (p_ban) RETURNING id INTO t;
  INSERT INTO table_session (status) VALUES ('serving') RETURNING id INTO s;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s, t);
  INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, submission_code)
  VALUES ('staff_pos', 'confirmed', s, t, gen_random_uuid()::text) RETURNING id INTO o;
  SELECT id INTO m FROM menu_item WHERE name = 'test-trứng tái thêm';
  INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd, component_count)
  VALUES (o, p_so_suat, m, 'test-trứng tái thêm', 0, 1) RETURNING id INTO l;
  INSERT INTO order_line_component (order_line_id, position, line_component_count,
    menu_component_id, component_name, quantity, takes_filling, base_price_vnd)
  SELECT l, 1, 1, ic.menu_component_id, mc.name, ic.quantity, mc.takes_filling, 0
  FROM menu_item_component ic JOIN menu_component mc ON mc.id = ic.menu_component_id
  WHERE ic.menu_item_id = m;
  RETURN o;
END $f$;

-- Nổ đơn: Đã xác nhận → Đang thực hiện và mọi việc trạm trong cùng giao dịch (I-004 tầng 2).
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

-- Một lần bấm "đã làm xong": một mẻ làm ra đúng các đơn vị trong p_viec.
CREATE FUNCTION pg_temp.bam_me(p_viec bigint[]) RETURNS bigint LANGUAGE plpgsql AS $f$
DECLARE b bigint;
BEGIN
  INSERT INTO production_batch DEFAULT VALUES RETURNING id INTO b;
  INSERT INTO production_batch_item (production_batch_id, made_for_station_job_id, station_job_id)
  SELECT b, v, v FROM unnest(p_viec) AS v;
  UPDATE station_job SET status = 'made' WHERE id = ANY (p_viec);
  RETURN b;
END $f$;

-- Đơn vị trứng tái ở trạm tráng của đơn p_don, đang ở p_status.
CREATE FUNCTION pg_temp.trung(p_don bigint, p_status text) RETURNS bigint[] LANGUAGE sql AS $f$
  SELECT array_agg(id ORDER BY id) FROM station_job
  WHERE sales_order_id = p_don AND station_code = 'trang_banh' AND status = p_status
$f$;

-- Tập I-004/6 của bộ đối chiếu (db/reconcile/i004.sql) sau T-127: đơn vị đã làm xong / đã ra bàn của
-- một đơn Huỷ, chưa chuyển, và KHÔNG mang một ghi chú bánh làm sai còn hiệu lực.
CREATE FUNCTION pg_temp.chua_doi_soat() RETURNS bigint LANGUAGE sql AS $f$
  SELECT COUNT(*) FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
  WHERE o.status = 'cancelled' AND j.status IN ('made', 'served')
    AND NOT EXISTS (SELECT 1 FROM wrong_make_note w WHERE w.live_station_job_id = j.id)
$f$;

DO $$
DECLARE p bigint; chu bigint; o5 bigint; o7 bigint; o8 bigint; o9 bigint; u bigint[];
        f bigint; f2 bigint; t bigint; it bigint; w bigint; r record; cols text;
BEGIN
  p := current_setting('shop.actor_person_id')::bigint;
  INSERT INTO person (display_name) VALUES ('test-chủ quán') RETURNING id INTO chu;

  -- Bàn 5 gọi hai trứng tái thêm; một mẻ làm xong cả hai; rồi đơn bàn 5 bị huỷ.
  -- Bàn 7 gọi một trứng tái thêm, đã làm xong, đơn KHÔNG huỷ. Bàn 8 huỷ trước khi duyệt.
  o5 := pg_temp.don('test-b5', 2);
  PERFORM pg_temp.no_don(o5);
  u := pg_temp.trung(o5, 'pending');
  PERFORM pg_temp.bam_me(u);
  f := u[1]; f2 := u[2];
  o7 := pg_temp.don('test-b7', 1);
  PERFORM pg_temp.no_don(o7);
  PERFORM pg_temp.bam_me(pg_temp.trung(o7, 'pending'));
  o8 := pg_temp.don('test-b8', 1);
  UPDATE sales_order SET status = 'cancelled' WHERE id = o8;
  UPDATE sales_order SET status = 'cancelled' WHERE id = o5;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'YC-07 vừa huỷ đơn bàn 5 — đã làm của đơn huỷ, chưa chuyển, chưa ghi chú: %', pg_temp.chua_doi_soat();
  IF pg_temp.chua_doi_soat() <> 2 THEN
    RAISE EXCEPTION 'YC-07: trước ghi chú, tập I-004/6 phải có đúng hai quả trứng của bàn 5';
  END IF;

  -- -------------------------------------------------------------- ghi chú sai chỗ bị từ chối
  BEGIN   -- thứ đã làm của một đơn KHÔNG huỷ (bàn 7 đang ăn)
    INSERT INTO wrong_make_note (station_job_id, sales_order_id)
    SELECT id, sales_order_id FROM station_job WHERE id = (pg_temp.trung(o7, 'made'))[1];
    RAISE EXCEPTION 'YC-07: database KHÔNG từ chối ghi chú bánh làm sai cho thứ của một đơn chưa huỷ';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'YC-07 bị từ chối (ghi chú cho đơn chưa huỷ): %', SQLERRM;
  END;
  BEGIN   -- đơn vị CHƯA làm của đơn đã huỷ (phần nước chấm bàn 5 chưa ai làm)
    INSERT INTO wrong_make_note (station_job_id, sales_order_id)
    SELECT id, sales_order_id FROM station_job WHERE sales_order_id = o5 AND station_code = 'canh';
    RAISE EXCEPTION 'YC-07: database KHÔNG từ chối ghi chú bánh làm sai cho thứ chưa làm';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'YC-07 bị từ chối (ghi chú cho thứ chưa làm): %', SQLERRM;
  END;
  BEGIN   -- đơn vị của bàn 5 nhưng khai đơn bàn 8 (cũng đã huỷ)
    INSERT INTO wrong_make_note (station_job_id, sales_order_id) VALUES (f, o8);
    RAISE EXCEPTION 'YC-07: database KHÔNG từ chối ghi chú khai sai đơn của đơn vị';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'YC-07 bị từ chối (đơn vị và đơn không khớp): %', SQLERRM;
  END;
  BEGIN   -- không có người ghi
    PERFORM set_config('shop.actor_person_id', '', true);
    INSERT INTO wrong_make_note (station_job_id, sales_order_id) VALUES (f, o5);
    RAISE EXCEPTION 'YC-07: database KHÔNG từ chối ghi chú không có người ghi';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'YC-07 bị từ chối (không có người ghi): %', SQLERRM;
  END;
  BEGIN   -- chữ ghi chú toàn khoảng trắng
    INSERT INTO wrong_make_note (station_job_id, sales_order_id, note) VALUES (f, o5, '   ');
    RAISE EXCEPTION 'YC-07: database KHÔNG từ chối chữ ghi chú trắng';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-07 bị từ chối (chữ ghi chú trắng): %', SQLERRM;
  END;

  -- ------------------------------------------------------------------ ghi chú đúng được nhận
  -- Không chữ: chỉ dấu + người + lúc. Có chữ: POS gõ thêm.
  INSERT INTO wrong_make_note (station_job_id, sales_order_id) VALUES (f, o5) RETURNING id INTO w;
  INSERT INTO wrong_make_note (station_job_id, sales_order_id, note) VALUES (f2, o5, 'test-tráng rách');
  SELECT n.id, n.note, n.created_at, (SELECT display_name FROM person WHERE id = n.person_id) AS nguoi
  INTO r FROM wrong_make_note n WHERE n.id = w;
  RAISE NOTICE 'YC-07 ghi chú bánh làm sai — dòng %, chữ: %, lúc %, người ghi %', r.id, COALESCE(r.note, '(trống)'), r.created_at, r.nguoi;
  IF r.nguoi IS DISTINCT FROM 'test-người đứng quầy' THEN
    RAISE EXCEPTION 'YC-07: người ghi không lấy từ người thao tác của giao dịch';
  END IF;
  RAISE NOTICE 'YC-07 sau hai ghi chú — đã làm của đơn huỷ, chưa chuyển, chưa ghi chú: %', pg_temp.chua_doi_soat();
  IF pg_temp.chua_doi_soat() <> 0 THEN
    RAISE EXCEPTION 'YC-07: thứ đã ghi chú bánh làm sai vẫn nằm trong tập I-004/6';
  END IF;
  BEGIN   -- hai ghi chú còn hiệu lực cho cùng một đơn vị
    INSERT INTO wrong_make_note (station_job_id, sales_order_id) VALUES (f, o5);
    RAISE EXCEPTION 'YC-07: database KHÔNG từ chối ghi chú thứ hai còn hiệu lực cho cùng thứ';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'YC-07 bị từ chối (hai ghi chú còn hiệu lực cho một thứ): %', SQLERRM;
  END;

  -- -------------------------------- đang có ghi chú thì không chuyển, không lùi về chưa làm
  -- Bàn 9 vào sau, gọi đúng một trứng tái thêm.
  o9 := pg_temp.don('test-b9', 1);
  PERFORM pg_temp.no_don(o9);
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  t := (pg_temp.trung(o9, 'pending'))[1];
  SELECT id INTO it FROM production_batch_item WHERE live_station_job_id = f;
  BEGIN
    INSERT INTO station_job_transfer (production_batch_item_id, from_station_job_id, to_station_job_id)
    VALUES (it, f, t);
    UPDATE production_batch_item SET station_job_id = t WHERE id = it;
    UPDATE station_job SET status = 'pending' WHERE id = f;
    UPDATE station_job SET status = 'made' WHERE id = t;
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION 'YC-07: database KHÔNG từ chối chuyển thứ đang mang ghi chú bánh làm sai';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'YC-07 bị từ chối (chuyển thứ đang có ghi chú — huỷ ghi chú trước): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL DEFERRED;

  -- ------------------------------------------------------- huỷ ghi chú nhầm: có vết, rồi chuyển
  BEGIN   -- huỷ mà không có người huỷ
    UPDATE wrong_make_note SET cancelled_at = now() WHERE id = w;
    RAISE EXCEPTION 'YC-07: database KHÔNG từ chối huỷ ghi chú không có người huỷ';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-07 bị từ chối (huỷ ghi chú không có người huỷ): %', SQLERRM;
  END;
  BEGIN   -- huỷ trước lúc ghi
    UPDATE wrong_make_note SET cancelled_at = created_at - interval '1 minute', cancelled_by_person_id = chu
    WHERE id = w;
    RAISE EXCEPTION 'YC-07: database KHÔNG từ chối lúc huỷ đứng trước lúc ghi';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-07 bị từ chối (lúc huỷ trước lúc ghi): %', SQLERRM;
  END;
  BEGIN   -- vai ghi sửa thứ đã ghi
    SET LOCAL ROLE shop_app;
    UPDATE wrong_make_note SET note = 'test-sửa lại' WHERE id = w;
    RAISE EXCEPTION 'YC-07: vai shop_app sửa được chữ của ghi chú đã ghi';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'YC-07 ghi chú đã ghi không sửa được (shop_app): %', SQLERRM;
  END;
  BEGIN   -- vai ghi xoá ghi chú
    SET LOCAL ROLE shop_app;
    DELETE FROM wrong_make_note WHERE id = w;
    RAISE EXCEPTION 'YC-07: vai shop_app xoá được ghi chú';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'YC-07 ghi chú không xoá được (shop_app): %', SQLERRM;
  END;
  SET LOCAL ROLE shop_app;
  UPDATE wrong_make_note SET cancelled_at = now(), cancelled_by_person_id = p WHERE id = w;
  RESET ROLE;
  SELECT n.cancelled_at IS NOT NULL AS da_huy, (SELECT display_name FROM person WHERE id = n.cancelled_by_person_id) AS nguoi_huy
  INTO r FROM wrong_make_note n WHERE n.id = w;
  RAISE NOTICE 'YC-07 huỷ ghi chú nhầm — dòng % còn ở lại: đã huỷ %, người huỷ %', w, r.da_huy, r.nguoi_huy;
  IF pg_temp.chua_doi_soat() <> 1 THEN
    RAISE EXCEPTION 'YC-07: huỷ ghi chú xong, quả trứng ấy phải về lại tập I-004/6';
  END IF;

  -- Huỷ rồi thì chuyển như thường: bốn lệnh, một giao dịch.
  INSERT INTO station_job_transfer (production_batch_item_id, from_station_job_id, to_station_job_id)
  VALUES (it, f, t);
  UPDATE production_batch_item SET station_job_id = t WHERE id = it;
  UPDATE station_job SET status = 'pending' WHERE id = f;
  UPDATE station_job SET status = 'made' WHERE id = t;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'YC-07 sau khi huỷ ghi chú, bàn 9 nhận quả trứng: đã làm xong còn ở bếp của bàn 9 %; tập I-004/6 %',
    COALESCE(array_length(pg_temp.trung(o9, 'made'), 1), 0), pg_temp.chua_doi_soat();
  IF pg_temp.chua_doi_soat() <> 0 THEN
    RAISE EXCEPTION 'YC-07: sau lần chuyển, tập I-004/6 phải rỗng (quả kia đang có ghi chú)';
  END IF;
  -- Dòng đã huỷ ở lại làm vết, và không chặn một ghi chú mới cho thứ khác của cùng đơn.
  IF (SELECT COUNT(*) FROM wrong_make_note WHERE sales_order_id = o5) <> 2 THEN
    RAISE EXCEPTION 'YC-07: ghi chú đã huỷ phải ở lại làm vết';
  END IF;

  -- Không cột nào khác: thêm một cột là phải đổi ADR-077 trước.
  SELECT string_agg(column_name::text, ',' ORDER BY column_name::text COLLATE "C") INTO cols
  FROM information_schema.columns WHERE table_schema = 'shop' AND table_name = 'wrong_make_note';
  IF cols IS DISTINCT FROM 'cancelled_at,cancelled_by_person_id,created_at,id,live_station_job_id,note,person_id,sales_order_id,station_job_id' THEN
    RAISE EXCEPTION 'YC-07: cột của wrong_make_note khác ADR-077: %', cols;
  END IF;
  RAISE NOTICE 'YC-07 cột của wrong_make_note: %', cols;
END $$;
