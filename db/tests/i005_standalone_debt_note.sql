-- I-005 · T-140: nợ đơn lẻ có ghi chú, không nợ không có ghi chú.
DO $$
DECLARE p bigint; o bigint; c text; note text;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-T140 người ghi nợ') RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at, submission_code)
  VALUES ('phone_preorder', 'confirmed', 'shop_pickup', '0900000000', now(), gen_random_uuid()::text)
  RETURNING id INTO o;

  FOREACH note IN ARRAY ARRAY[NULL::text, '', '   '] LOOP
    BEGIN
      INSERT INTO bill (sales_order_id, due_vnd, debt_vnd, debtor_name, debt_note)
      VALUES (o, 1000, 1000, 'Anh Sáu', note);
      RAISE EXCEPTION 'I-005: database KHÔNG từ chối nợ đơn lẻ thiếu ghi chú';
    EXCEPTION WHEN check_violation THEN
      GET STACKED DIAGNOSTICS c = CONSTRAINT_NAME;
      IF c <> 'bill_standalone_debt_note_check' THEN RAISE; END IF;
      RAISE NOTICE 'I-005 từ chối đúng %', c;
    END;
  END LOOP;

  BEGIN
    INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, debt_note)
    VALUES (o, 1000, 1000, 'không có nợ');
    RAISE EXCEPTION 'I-005: database KHÔNG từ chối ghi chú khi không nợ';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS c = CONSTRAINT_NAME;
    IF c <> 'bill_debt_note_only_with_debt_check' THEN RAISE; END IF;
    RAISE NOTICE 'I-005 từ chối đúng %', c;
  END;

  INSERT INTO bill (sales_order_id, due_vnd, debt_vnd, debtor_name, debt_note)
  VALUES (o, 1000, 1000, 'Anh Sáu', 'hẹn thứ bảy trả');
  SET CONSTRAINTS ALL IMMEDIATE;
END $$;
