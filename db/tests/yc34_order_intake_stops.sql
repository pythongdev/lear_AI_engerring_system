-- YC-34 · I-008 — hai khoảng ngừng nhận đơn đọc lại được sau nhiều ngày (F-050, T-132): mỗi lần
-- TẠM DỪNG NHẬN ĐƠN (shop-facts.md §6.8 — nút của người, chặn cả năm kênh) mang lúc bắt đầu · ai bật ·
-- lúc kết thúc · ai tắt; mỗi khoảng QUÁN ĐANG MÙ (§6.11 — ba kênh khách tự bấm ngừng) mang lúc bắt
-- đầu tính từ lúc quán hết nhìn thấy (U-061) · máy phát hiện hay người bấm · lúc kết thúc · ai bấm
-- mở lại — mở lại là NÚT, không tự mở khi tín hiệu về (U-043). Một thời điểm có một câu trả lời cho
-- mỗi khoảng. Thiết kế: docs/decisions.md ADR-078. Viết TRƯỚC migration (T-132, Claude Code).
DO $$
DECLARE a bigint; b bigint; p1 bigint; m1 bigint; t0 timestamptz; r record; cols text;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO a;
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán', true) RETURNING id INTO b;
  t0 := date_trunc('day', now()) + interval '6 hours';

  -- 08:00 người đứng quầy bật tạm dừng (hết nguyên liệu), 08:15 tắt. Người lấy từ giao dịch.
  PERFORM set_config('shop.actor_person_id', a::text, true);
  INSERT INTO order_intake_pause (started_at) VALUES (t0 + interval '2 hours') RETURNING id INTO p1;
  UPDATE order_intake_pause SET ended_at = t0 + interval '135 minutes', ended_by_person_id = a WHERE id = p1;

  -- 09:00 máy thấy quán hết nhìn thấy đơn — không ai bấm; 09:20 chủ quán bấm mở lại.
  INSERT INTO shop_blind_spell (started_at) VALUES (t0 + interval '3 hours') RETURNING id INTO m1;
  UPDATE shop_blind_spell SET ended_at = t0 + interval '200 minutes', ended_by_person_id = b WHERE id = m1;
  -- 10:00 chủ quán bấm tắt qua 5G trước khi máy thấy; khoảng còn mở.
  INSERT INTO shop_blind_spell (started_at, declared_by_person_id) VALUES (t0 + interval '4 hours', b);

  -- Đọc lại tại những mốc đã qua: một mốc, một câu trả lời cho mỗi khoảng.
  FOR r IN
    SELECT m.moc,
           EXISTS (SELECT 1 FROM order_intake_pause p
                   WHERE tstzrange(p.started_at, p.ended_at, '[)') @> m.moc) AS tam_dung,
           EXISTS (SELECT 1 FROM shop_blind_spell s
                   WHERE tstzrange(s.started_at, s.ended_at, '[)') @> m.moc) AS mu
    FROM (VALUES (t0 + interval '119 minutes'), (t0 + interval '2 hours'), (t0 + interval '135 minutes'),
                 (t0 + interval '190 minutes'), (t0 + interval '200 minutes'), (t0 + interval '5 hours')) AS m(moc)
    ORDER BY m.moc
  LOOP
    RAISE NOTICE 'YC-34 lúc % — tạm dừng: % · quán đang mù: %', to_char(r.moc, 'HH24:MI'), r.tam_dung, r.mu;
  END LOOP;
  SELECT (SELECT display_name FROM person WHERE id = p.started_by_person_id) AS bat,
         (SELECT display_name FROM person WHERE id = p.ended_by_person_id) AS tat,
         to_char(p.started_at, 'HH24:MI') || '–' || to_char(p.ended_at, 'HH24:MI') AS khoang
  INTO r FROM order_intake_pause p WHERE p.id = p1;
  RAISE NOTICE 'YC-34 tạm dừng %: bật %, tắt %', r.khoang, r.bat, r.tat;
  IF r.bat IS DISTINCT FROM 'test-người đứng quầy' THEN
    RAISE EXCEPTION 'YC-34: người bật tạm dừng phải lấy từ người thao tác của giao dịch';
  END IF;
  SELECT coalesce((SELECT display_name FROM person WHERE id = s.declared_by_person_id), 'máy phát hiện') AS ai,
         (SELECT display_name FROM person WHERE id = s.ended_by_person_id) AS mo_lai,
         to_char(s.started_at, 'HH24:MI') || '–' || to_char(s.ended_at, 'HH24:MI') AS khoang
  INTO r FROM shop_blind_spell s WHERE s.id = m1;
  RAISE NOTICE 'YC-34 quán mù %: bắt đầu do %, mở lại bởi %', r.khoang, r.ai, r.mo_lai;
  IF r.ai <> 'máy phát hiện' OR r.mo_lai IS DISTINCT FROM 'test-chủ quán' THEN
    RAISE EXCEPTION 'YC-34: khoảng mù phải đọc ra được máy phát hiện và người bấm mở lại';
  END IF;

  -- Tạm dừng và quán mù là hai điều kiện khác nhau: chồng lên nhau thì được.
  INSERT INTO order_intake_pause (started_at, ended_at, ended_by_person_id)
  VALUES (t0 + interval '190 minutes', t0 + interval '195 minutes', a);
  RAISE NOTICE 'YC-34 tạm dừng trong lúc quán mù — ghi được (hai điều kiện độc lập)';

  -- Trạng thái sai.
  BEGIN
    INSERT INTO order_intake_pause (started_at, ended_at, ended_by_person_id)
    VALUES (t0 + interval '130 minutes', t0 + interval '140 minutes', a);
    RAISE EXCEPTION 'YC-34: database KHÔNG từ chối hai lần tạm dừng chồng nhau';
  EXCEPTION WHEN exclusion_violation THEN
    RAISE NOTICE 'YC-34 bị từ chối (hai lần tạm dừng chồng nhau): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO order_intake_pause (started_at) VALUES (t0 + interval '6 hours');
    INSERT INTO order_intake_pause (started_at) VALUES (t0 + interval '7 hours');
    RAISE EXCEPTION 'YC-34: database KHÔNG từ chối bật tạm dừng khi lần trước chưa tắt';
  EXCEPTION WHEN exclusion_violation THEN
    RAISE NOTICE 'YC-34 bị từ chối (bật tạm dừng khi lần trước còn mở): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO shop_blind_spell (started_at, ended_at, ended_by_person_id)
    VALUES (t0 + interval '190 minutes', t0 + interval '210 minutes', b);
    RAISE EXCEPTION 'YC-34: database KHÔNG từ chối hai khoảng mù chồng nhau';
  EXCEPTION WHEN exclusion_violation THEN
    RAISE NOTICE 'YC-34 bị từ chối (hai khoảng mù chồng nhau): %', SQLERRM;
  END;
  BEGIN
    PERFORM set_config('shop.actor_person_id', '', true);
    INSERT INTO order_intake_pause (started_at) VALUES (t0 - interval '1 hour');
    RAISE EXCEPTION 'YC-34: database KHÔNG từ chối một lần tạm dừng không có người bật';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'YC-34 bị từ chối (tạm dừng không có người bật): %', SQLERRM;
  END;
  BEGIN
    UPDATE order_intake_pause SET ended_at = started_at - interval '1 minute' WHERE id = p1;
    RAISE EXCEPTION 'YC-34: database KHÔNG từ chối tạm dừng kết thúc trước lúc bắt đầu';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-34 bị từ chối (tạm dừng kết thúc trước lúc bắt đầu): %', SQLERRM;
  END;
  BEGIN
    UPDATE order_intake_pause SET ended_by_person_id = NULL WHERE id = p1;
    RAISE EXCEPTION 'YC-34: database KHÔNG từ chối tạm dừng kết thúc mà không có người tắt';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-34 bị từ chối (tạm dừng kết thúc không có người tắt): %', SQLERRM;
  END;
  BEGIN
    UPDATE shop_blind_spell SET ended_by_person_id = NULL WHERE id = m1;
    RAISE EXCEPTION 'YC-34: database KHÔNG từ chối khoảng mù tự mở lại (không người bấm)';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-34 bị từ chối (khoảng mù kết thúc không có người bấm mở lại): %', SQLERRM;
  END;
  BEGIN
    UPDATE shop_blind_spell SET ended_at = started_at WHERE id = m1;
    RAISE EXCEPTION 'YC-34: database KHÔNG từ chối khoảng mù dài bằng không';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-34 bị từ chối (khoảng mù kết thúc không sau lúc bắt đầu): %', SQLERRM;
  END;
  BEGIN   -- vai ghi dời lúc bắt đầu
    SET LOCAL ROLE shop_app;
    UPDATE order_intake_pause SET started_at = started_at + interval '5 minutes' WHERE id = p1;
    RAISE EXCEPTION 'YC-34: vai shop_app dời được lúc bắt đầu của một lần tạm dừng';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'YC-34 lúc bắt đầu không dời được (shop_app): %', SQLERRM;
  END;
  BEGIN   -- vai ghi xoá một khoảng mù
    SET LOCAL ROLE shop_app;
    DELETE FROM shop_blind_spell WHERE id = m1;
    RAISE EXCEPTION 'YC-34: vai shop_app xoá được một khoảng mù';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'YC-34 khoảng mù không xoá được (shop_app): %', SQLERRM;
  END;
  -- Vai ghi khép được khoảng mù đang mở bằng nút mở lại.
  PERFORM set_config('shop.actor_person_id', b::text, true);
  SET LOCAL ROLE shop_app;
  UPDATE shop_blind_spell SET ended_at = t0 + interval '270 minutes', ended_by_person_id = b
  WHERE ended_at IS NULL;
  RESET ROLE;
  IF EXISTS (SELECT 1 FROM shop_blind_spell WHERE ended_at IS NULL) THEN
    RAISE EXCEPTION 'YC-34: vai shop_app phải khép được khoảng mù bằng nút mở lại';
  END IF;
  RAISE NOTICE 'YC-34 nút mở lại (shop_app) khép khoảng mù 10:00–10:30';

  -- Không cột nào khác: thêm một cột là phải đổi ADR-078 trước.
  SELECT string_agg(table_name || '.' || column_name, ',' ORDER BY table_name::text COLLATE "C", column_name::text COLLATE "C")
  INTO cols FROM information_schema.columns
  WHERE table_schema = 'shop' AND table_name IN ('order_intake_pause', 'shop_blind_spell');
  IF cols IS DISTINCT FROM 'order_intake_pause.created_at,order_intake_pause.ended_at,order_intake_pause.ended_by_person_id,order_intake_pause.id,order_intake_pause.started_at,order_intake_pause.started_by_person_id,'
                           'shop_blind_spell.created_at,shop_blind_spell.declared_by_person_id,shop_blind_spell.ended_at,shop_blind_spell.ended_by_person_id,shop_blind_spell.id,shop_blind_spell.started_at' THEN
    RAISE EXCEPTION 'YC-34: cột của hai bảng khác ADR-078: %', cols;
  END IF;
  RAISE NOTICE 'YC-34 cột: %', cols;
END $$;
