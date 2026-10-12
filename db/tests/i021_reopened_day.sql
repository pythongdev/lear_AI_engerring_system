-- T-146, ADR-096: viết trước bước 22; bước 21 phải từ chối vì chưa có đường mở lại.
DO $$
DECLARE p bigint; f bigint; c bigint; a bigint; b bigint; other_id bigint; n bigint;
BEGIN
  INSERT INTO person (display_name, is_owner) VALUES ('test mở lại két', true) RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
  INSERT INTO opening_float (sale_date) VALUES ('2026-09-18') RETURNING id INTO f;
  INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd) VALUES (f, 1000, 1000);
  INSERT INTO cash_count (sale_date) VALUES ('2026-09-18') RETURNING id INTO c;
  INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd) VALUES (c, 1000, 1000);
  INSERT INTO reconciled_day (sale_date) VALUES ('2026-09-18') RETURNING id INTO a;
  BEGIN
    INSERT INTO reconciled_day (sale_date) VALUES ('2026-09-18');
    RAISE EXCEPTION 'I-021: nhận dấu gốc thứ hai';
  EXCEPTION WHEN unique_violation THEN RAISE NOTICE 'I-021 từ chối dấu gốc thứ hai'; END;
  BEGIN
    INSERT INTO reconciled_day (sale_date, previous_reconciled_day_id) VALUES ('2026-09-18', a);
    RAISE EXCEPTION 'I-021: nối dấu chưa mở lại';
  EXCEPTION WHEN foreign_key_violation THEN RAISE NOTICE 'I-021 từ chối nối dấu chưa mở lại'; END;
  BEGIN
    INSERT INTO reconciled_day_reopening (reconciled_day_id, sale_date, reason) VALUES (a, '2026-09-18', '   ');
    RAISE EXCEPTION 'I-021: nhận lý do trắng';
  EXCEPTION WHEN check_violation THEN RAISE NOTICE 'I-021 từ chối lý do trắng'; END;
  BEGIN
    INSERT INTO reconciled_day_reopening (reconciled_day_id, sale_date) VALUES (a, '2026-09-18');
    RAISE EXCEPTION 'I-021: nhận thiếu lý do';
  EXCEPTION WHEN not_null_violation THEN RAISE NOTICE 'I-021 từ chối thiếu lý do'; END;
  BEGIN
    PERFORM set_config('shop.actor_person_id', '', true);
    INSERT INTO reconciled_day_reopening (reconciled_day_id, sale_date, reason) VALUES (a, '2026-09-18', 'đếm lại');
    RAISE EXCEPTION 'I-012: mở lại không người';
  EXCEPTION WHEN not_null_violation THEN RAISE NOTICE 'I-012 từ chối mở lại không người'; END;
  BEGIN
    UPDATE cash_count_line SET amount_vnd = 2000 WHERE cash_count_id = c;
    RAISE EXCEPTION 'I-021: sửa qua dấu đang đứng';
  EXCEPTION WHEN restrict_violation THEN RAISE NOTICE 'I-021 từ chối sửa số đang ký'; END;
  SET LOCAL ROLE shop_app;
  INSERT INTO reconciled_day_reopening (reconciled_day_id, sale_date, reason) VALUES (a, '2026-09-18', 'đếm lại');
  RESET ROLE;
  IF NOT EXISTS (SELECT 1 FROM reconciled_day_reopening WHERE reconciled_day_id = a AND person_id = p AND created_at IS NOT NULL) THEN
    RAISE EXCEPTION 'I-012: thiếu người hoặc mốc mở lại';
  END IF;
  BEGIN
    INSERT INTO reconciled_day_reopening (reconciled_day_id, sale_date, reason) VALUES (a, '2026-09-18', 'lần hai');
    RAISE EXCEPTION 'I-021: mở lại một dấu hai lần';
  EXCEPTION WHEN unique_violation THEN RAISE NOTICE 'I-021 từ chối mở lại trùng dấu'; END;
  BEGIN
    UPDATE cash_count_line SET amount_vnd = 2000 WHERE cash_count_id = c;
    RAISE EXCEPTION 'I-018: sửa không lý do';
  EXCEPTION WHEN check_violation THEN RAISE NOTICE 'I-018 từ chối sửa không lý do'; END;
  PERFORM set_config('shop.revision_reason', 'đếm lại', true);
  SET LOCAL ROLE shop_app;
  UPDATE cash_count_line SET amount_vnd = 2000 WHERE cash_count_id = c;
  RESET ROLE;
  SELECT count(*) INTO n FROM record_revision
   WHERE target_table_code = 'cash_count_line' AND person_id = p AND reason = 'đếm lại'
     AND before_image->>'amount_vnd' = '1000' AND after_image->>'amount_vnd' = '2000';
  IF n <> 1 THEN RAISE EXCEPTION 'I-018: chờ một vết đủ bản trước, sau, người, lý do; có %', n; END IF;
  SET LOCAL ROLE shop_app;
  INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd) VALUES (c, 5000, 5000);
  RESET ROLE;
  IF NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code = 'cash_count'
       AND target_row = c AND person_id = p AND reason = 'đếm lại'
       AND jsonb_array_length(before_image->'cash_count_line') = 1
       AND jsonb_array_length(after_image->'cash_count_line') = 2) THEN
    RAISE EXCEPTION 'I-018: thêm xấp ngày mở lại không có vết đủ hai ảnh';
  END IF;
  BEGIN
    UPDATE opening_float_line SET amount_vnd = 2000 WHERE opening_float_id = f;
    RAISE EXCEPTION 'I-021: tiền đầu két mở lại sửa được';
  EXCEPTION WHEN restrict_violation THEN RAISE NOTICE 'I-021 tiền đầu két vẫn khoá'; END;
  BEGIN
    TRUNCATE cash_count_line;
    RAISE EXCEPTION 'I-021: TRUNCATE ngày mở lại đi qua';
  EXCEPTION WHEN restrict_violation THEN RAISE NOTICE 'I-021 TRUNCATE vẫn bị chặn'; END;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE reconciled_day_reopening SET reason = 'đổi' WHERE reconciled_day_id = a;
    RAISE EXCEPTION 'QD-50: sửa được dòng mở lại';
  EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'QD-50 không sửa dòng mở lại'; END;
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM reconciled_day_reopening WHERE reconciled_day_id = a;
    RAISE EXCEPTION 'QD-50: xoá được dòng mở lại';
  EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'QD-50 không xoá dòng mở lại'; END;
  INSERT INTO opening_float (sale_date) VALUES ('2026-09-19') RETURNING id INTO f;
  INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd) VALUES (f, 1000, 1000);
  INSERT INTO cash_count (sale_date) VALUES ('2026-09-19') RETURNING id INTO other_id;
  INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd) VALUES (other_id, 1000, 1000);
  BEGIN
    INSERT INTO reconciled_day (sale_date, previous_reconciled_day_id) VALUES ('2026-09-19', a);
    RAISE EXCEPTION 'I-021: nối dấu của ngày khác';
  EXCEPTION WHEN foreign_key_violation THEN RAISE NOTICE 'I-021 từ chối nối khác ngày'; END;
  INSERT INTO reconciled_day (sale_date, previous_reconciled_day_id, gap_vnd, gap_explanation)
    VALUES ('2026-09-18', a, 1000, 'đếm lại thấy dư') RETURNING id INTO b;
  BEGIN
    INSERT INTO reconciled_day (sale_date, previous_reconciled_day_id) VALUES ('2026-09-18', a);
    RAISE EXCEPTION 'I-021: chuỗi rẽ nhánh';
  EXCEPTION WHEN unique_violation THEN RAISE NOTICE 'I-021 từ chối chuỗi rẽ nhánh'; END;
  BEGIN
    UPDATE cash_count_line SET amount_vnd = 3000 WHERE cash_count_id = c;
    RAISE EXCEPTION 'I-021: ký lại không khoá số';
  EXCEPTION WHEN restrict_violation THEN RAISE NOTICE 'I-021 ký lại khoá số'; END;
  SET CONSTRAINTS ALL IMMEDIATE;
END $$;
