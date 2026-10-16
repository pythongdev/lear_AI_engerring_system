-- T-186 / I-025: viết trước migration; trước bước 30 đỏ vì thiếu reminder_ratio.
-- Chạy trong giao dịch của db-check; không giữ dữ liệu thử.
DO $$
DECLARE item bigint; actor bigint; value numeric; rejected_name text;
BEGIN
  -- Đọc cột ngay đầu: lỗi trước migration phải là undefined_column.
  PERFORM reminder_ratio FROM supply_item LIMIT 1;
  INSERT INTO person(display_name, is_owner) VALUES ('test-tỉ lệ-chủ', true) RETURNING id INTO actor;
  PERFORM set_config('shop.actor_person_id', actor::text, true);
  PERFORM set_config('shop.revision_reason', 'test-tỉ lệ nhắc', true);
  INSERT INTO supply_item(name) VALUES ('test-tỉ lệ nhắc') RETURNING id INTO item;
  IF (SELECT reminder_ratio FROM supply_item WHERE id = item) <> 0.2 THEN
    RAISE EXCEPTION 'I-025: mặc định phải là 20%%';
  END IF;
  FOREACH value IN ARRAY ARRAY[-0.001, 1.001, 'NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric] LOOP
    BEGIN
      UPDATE supply_item SET reminder_ratio = value WHERE id = item;
      RAISE EXCEPTION 'I-025: nhận tỉ lệ ngoài miền %', value;
    EXCEPTION WHEN check_violation THEN
      GET STACKED DIAGNOSTICS rejected_name = CONSTRAINT_NAME;
      IF rejected_name <> 'supply_item_reminder_ratio_range_check' THEN RAISE; END IF;
    END;
  END LOOP;
  BEGIN
    UPDATE supply_item SET reminder_ratio = NULL WHERE id = item;
    RAISE EXCEPTION 'I-025: nhận tỉ lệ NULL';
  EXCEPTION WHEN not_null_violation THEN NULL;
  END;
  FOREACH value IN ARRAY ARRAY[0, 0.125, 1] LOOP
    UPDATE supply_item SET reminder_ratio = value WHERE id = item;
    IF (SELECT reminder_ratio FROM supply_item WHERE id = item) <> value THEN
      RAISE EXCEPTION 'I-025: không giữ đúng tỉ lệ %', value;
    END IF;
  END LOOP;
  IF NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code = 'supply_item'
      AND target_row = item AND person_id = actor
      AND before_image->>'reminder_ratio' = '0.2' AND after_image->>'reminder_ratio' = '0') THEN
    RAISE EXCEPTION 'I-025: đặt tỉ lệ không có vết người đặt và bản trước/sau';
  END IF;
  RAISE NOTICE 'I-025 tỉ lệ: mặc định 20%%; nhận 0/0.125/1; từ chối âm/>1/NaN/vô cực/NULL; có vết';
END $$;
