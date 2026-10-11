-- I-021 · T-140: dấu ngày lệch phải giữ giải thích; ngày khớp không đòi.
DO $$
DECLARE p bigint; f bigint; k bigint; c text; note text; gap bigint;
BEGIN
  INSERT INTO person (display_name, is_owner) VALUES ('test-T140 chủ quán', true) RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
  INSERT INTO opening_float (sale_date) VALUES ('2032-10-09') RETURNING id INTO f;
  INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd) VALUES (f, 1000, 1000);
  INSERT INTO cash_count (sale_date) VALUES ('2032-10-09') RETURNING id INTO k;
  INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd) VALUES (k, 1000, 2000);

  FOREACH gap IN ARRAY ARRAY[-1000::bigint, 1000::bigint] LOOP
    FOREACH note IN ARRAY ARRAY[NULL::text, '', '   '] LOOP
      BEGIN
        INSERT INTO reconciled_day (sale_date, gap_vnd, gap_explanation) VALUES ('2032-10-09', gap, note);
        RAISE EXCEPTION 'I-021: database KHÔNG từ chối ngày lệch thiếu giải thích';
      EXCEPTION WHEN check_violation THEN
        GET STACKED DIAGNOSTICS c = CONSTRAINT_NAME;
        IF c <> 'reconciled_day_gap_explained_check' THEN RAISE; END IF;
        RAISE NOTICE 'I-021 từ chối đúng %', c;
      END;
    END LOOP;
  END LOOP;
  INSERT INTO reconciled_day (sale_date, gap_vnd, gap_explanation)
  VALUES ('2032-10-09', 1000, 'ghi nhầm phương thức');
  SET CONSTRAINTS ALL IMMEDIATE;
END $$;
