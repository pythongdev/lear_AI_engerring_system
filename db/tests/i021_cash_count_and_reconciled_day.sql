-- I-021 · I-014 · I-012 — số tiền mặt ĐẾM ĐƯỢC cuối ngày và dấu NGÀY ĐÃ ĐỐI SOÁT XONG (F-048).
-- Số đếm cùng hình tiền đầu két: mỗi ngày bán đúng MỘT lần đếm, mỗi dòng một mệnh giá, con số của
-- ngày là tổng các dòng (shop-facts.md §8.5, lời đóng U-038: bảng mệnh giá là cách đếm và kiểm
-- cuối ngày, phép trừ dùng tổng). Dấu đối soát xong: mỗi ngày nhiều nhất một dấu, và không đứng
-- được khi ngày ấy thiếu số đếm hay thiếu tiền đầu két (I-021 điều kiện biên thứ nhất, ADR-037).
-- Thiết kế: docs/decisions.md ADR-079. Viết TRƯỚC migration (T-133, Claude Code).
-- Lát: 04-luoc-do-duong-tien.md §7.
DO $$
DECLARE p bigint;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
END $$;

DO $$
DECLARE f bigint; c bigint; c2 bigint; m bigint; n bigint; tong bigint;
BEGIN
  -- Ngày 2026-09-21 có tiền đầu két 1.200.000; ngày 2026-09-22 KHÔNG có (đếm được mà chưa trừ được).
  INSERT INTO opening_float (sale_date) VALUES ('2026-09-21') RETURNING id INTO f;
  INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd)
  VALUES (f, 50000, 1000000), (f, 5000, 100000), (f, 1000, 100000);

  -- ------------------------------------------------------------------ số đếm: hình dạng
  INSERT INTO cash_count (sale_date) VALUES ('2026-09-21') RETURNING id INTO c;
  INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd)
  VALUES (c, 500000, 1000000), (c, 50000, 800000), (c, 5000, 100000), (c, 1000, 100000);
  SELECT sum(amount_vnd) INTO tong FROM cash_count_line WHERE cash_count_id = c;
  RAISE NOTICE 'I-021 số đếm ngày 2026-09-21: % dòng mệnh giá, tổng % — két − đầu két = %',
    (SELECT count(*) FROM cash_count_line WHERE cash_count_id = c), tong,
    tong - (SELECT sum(amount_vnd) FROM opening_float_line WHERE opening_float_id = f);
  IF tong - 1200000 <> 800000 THEN
    RAISE EXCEPTION 'I-021: két − đầu két đọc ra %, chờ 800000', tong - 1200000;
  END IF;
  IF (SELECT person_id FROM cash_count WHERE id = c) IS NULL THEN
    RAISE EXCEPTION 'I-012: số đếm không mang người đếm';
  END IF;

  BEGIN
    INSERT INTO cash_count (sale_date) VALUES ('2026-09-21');
    RAISE EXCEPTION 'I-021: database KHÔNG từ chối lần đếm thứ hai của một ngày';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-021 bị từ chối (hai lần đếm một ngày): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd) VALUES (c, 50000, 50000);
    RAISE EXCEPTION 'I-021: database KHÔNG từ chối dòng mệnh giá thứ hai cho cùng mệnh giá';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-021 bị từ chối (một mệnh giá hai dòng): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd) VALUES (c, 20000, 30000);
    RAISE EXCEPTION 'I-021: database KHÔNG từ chối một xấp 20.000 cộng ra 30.000';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-021 bị từ chối (dòng mệnh giá không phải bội của mệnh giá): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd) VALUES (c, 2000, -2000);
    RAISE EXCEPTION 'I-021: database KHÔNG từ chối số tiền âm';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-021 bị từ chối (số tiền âm): %', SQLERRM;
  END;
  BEGIN
    PERFORM set_config('shop.actor_person_id', '', true);
    INSERT INTO cash_count (sale_date) VALUES ('2026-09-23');
    RAISE EXCEPTION 'I-012: database KHÔNG từ chối lần đếm không người đếm';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'I-012 bị từ chối (lần đếm không người đếm): %', SQLERRM;
  END;
  -- Khối con hỏng thì cài đặt trong nó lùi theo: người thao tác còn nguyên.
  IF actor_person_id() IS NULL THEN RAISE EXCEPTION 'test: mất người thao tác'; END IF;

  -- Ngày không có tiền đầu két vẫn ĐẾM được — chỉ là chưa đối soát xong được.
  INSERT INTO cash_count (sale_date) VALUES ('2026-09-22') RETURNING id INTO c2;
  INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd) VALUES (c2, 10000, 500000);

  -- ------------------------------------------------------------------ dấu đối soát xong
  BEGIN
    INSERT INTO reconciled_day (sale_date) VALUES ('2026-09-22');
    RAISE EXCEPTION 'I-021: database KHÔNG từ chối dấu đối soát xong cho ngày chưa có tiền đầu két';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-021 bị từ chối (đối soát xong mà thiếu tiền đầu két): %', SQLERRM;
  END;
  INSERT INTO opening_float (sale_date) VALUES ('2026-09-24') RETURNING id INTO f;
  INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd) VALUES (f, 10000, 100000);
  BEGIN
    INSERT INTO reconciled_day (sale_date) VALUES ('2026-09-24');
    RAISE EXCEPTION 'I-021: database KHÔNG từ chối dấu đối soát xong cho ngày chưa đếm két';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'I-021 bị từ chối (đối soát xong mà thiếu số đếm): %', SQLERRM;
  END;

  -- Sửa một dòng số đếm (đếm lại) khai lý do thì để lại vết bản trước · bản sau · người (I-018).
  -- Đếm lại TRƯỚC khi ký: ngày đã ký thì số đếm đứng yên (T-134, ADR-080).
  PERFORM set_config('shop.revision_reason', 'đếm lại xấp 50.000', true);
  SET LOCAL ROLE shop_app;
  UPDATE cash_count_line SET amount_vnd = 750000 WHERE cash_count_id = c AND denomination_vnd = 50000;
  RESET ROLE;
  SELECT count(*) INTO n FROM record_revision
   WHERE target_table_code = 'cash_count_line' AND person_id IS NOT NULL
     AND (before_image ->> 'amount_vnd') = '800000' AND (after_image ->> 'amount_vnd') = '750000';
  RAISE NOTICE 'I-012 · I-018 đếm lại: % vết — từ 800000 sang 750000', n;
  IF n <> 1 THEN RAISE EXCEPTION 'I-018: lần đếm lại không để đúng một vết (có %)', n; END IF;
  PERFORM set_config('shop.revision_reason', '', true);

  INSERT INTO reconciled_day (sale_date) VALUES ('2026-09-21') RETURNING id INTO m;
  RAISE NOTICE 'I-014 ngày 2026-09-21 đối soát xong — người bấm %, lúc ghi có: %',
    (SELECT p.display_name FROM reconciled_day r JOIN person p ON p.id = r.person_id WHERE r.id = m),
    (SELECT created_at IS NOT NULL FROM reconciled_day WHERE id = m);
  BEGIN
    INSERT INTO reconciled_day (sale_date) VALUES ('2026-09-21');
    RAISE EXCEPTION 'I-014: database KHÔNG từ chối dấu đối soát xong thứ hai của một ngày';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-014 bị từ chối (hai dấu đối soát xong một ngày): %', SQLERRM;
  END;

  -- ------------------------------------------------------------------ vai ghi (QD-50)
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM cash_count_line WHERE cash_count_id = c;
    RAISE EXCEPTION 'QD-50: vai shop_app xoá được một dòng số đếm';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'QD-50 số đếm không xoá được (shop_app): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM reconciled_day WHERE id = m;
    RAISE EXCEPTION 'QD-50: vai shop_app xoá được dấu đối soát xong';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'QD-50 dấu đối soát xong không xoá được (shop_app): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE reconciled_day SET sale_date = '2026-09-22' WHERE id = m;
    RAISE EXCEPTION 'ADR-079: vai shop_app dời được dấu đối soát xong sang ngày khác';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'ADR-079 dấu đối soát xong không sửa được (shop_app): %', SQLERRM;
  END;

  SET CONSTRAINTS ALL IMMEDIATE;
END $$;
