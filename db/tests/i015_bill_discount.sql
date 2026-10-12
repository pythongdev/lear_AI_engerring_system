-- T-175, ADR-098: test trước migration bước 23; mỗi lỗi phải đúng tên ràng buộc.
DO $$
DECLARE p bigint; s bigint; c record; actual text;
BEGIN
  INSERT INTO person (display_name) VALUES ('test giảm giá') RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
  INSERT INTO table_session (status) VALUES ('closed') RETURNING id INTO s;
  FOR c IN SELECT * FROM (VALUES
    (-1::bigint, NULL::text, 10001::bigint, 'bill_discount_not_negative_check'),
    (1000, NULL, 9000, 'bill_discount_customer_name_check'),
    (1000, '   ', 9000, 'bill_discount_customer_name_check'),
    (0, 'Khách', 10000, 'bill_discount_customer_name_check'),
    (0, '   ', 10000, 'bill_discount_customer_name_check'),
    (1000, 'Khách', 10000, 'bill_parts_equal_due_check')
  ) AS cases(discount, customer, cash, refusal) LOOP
    BEGIN
      INSERT INTO bill (table_session_id, due_vnd, cash_vnd, discount_vnd, discount_customer_name)
      VALUES (s, 10000, c.cash, c.discount, c.customer);
      RAISE EXCEPTION 'I-015: không từ chối %', c.refusal;
    EXCEPTION WHEN check_violation THEN
      GET STACKED DIAGNOSTICS actual = CONSTRAINT_NAME;
      IF actual <> c.refusal THEN RAISE EXCEPTION 'muốn %, nhận %', c.refusal, actual; END IF;
    END;
  END LOOP;
  INSERT INTO bill (table_session_id, due_vnd, discount_vnd, discount_customer_name)
  VALUES (s, 10000, 10000, 'Khách quen');
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'I-015: giảm cả đơn 100%% được; giảm âm, tên sai và tổng sai bị từ chối';
END $$;
