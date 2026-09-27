-- YC-05: dấu "đem về" ở mức một suất; một đơn của phiên bàn mang cùng lúc suất ăn
-- tại chỗ và suất đem về; dấu ấy không làm suất rời phiên. Lát: 02-luoc-do-ban-hang.md.
DO $$
DECLARE t5 bigint; s1 bigint; o1 bigint; r record;
BEGIN
  INSERT INTO dining_table (label) VALUES ('test-5') RETURNING id INTO t5;
  INSERT INTO table_session (status) VALUES ('serving') RETURNING id INTO s1;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s1, t5);
  INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id)
  VALUES ('qr_table', 'new', s1, t5) RETURNING id INTO o1;
  INSERT INTO order_line (sales_order_id, quantity, is_takeaway) VALUES (o1, 2, false), (o1, 1, true);

  -- Câu 1 — ghi được: đọc lại từng dòng, suất nào gói, suất nào ăn tại chỗ, thuộc phiên nào.
  FOR r IN
    SELECT l.quantity, l.is_takeaway, o.table_session_id = s1 AS trong_phien
    FROM order_line l JOIN sales_order o ON o.id = l.sales_order_id
    WHERE o.id = o1 ORDER BY l.is_takeaway
  LOOP
    RAISE NOTICE 'YC-05 đọc lại: % suất, đem về = %, thuộc phiên bàn 5 = %',
      r.quantity, r.is_takeaway, r.trong_phien;
  END LOOP;

  -- Câu 2 — không xảy ra được: suất đem về tách khỏi đơn của phiên thành dòng mồ côi.
  BEGIN
    UPDATE order_line SET sales_order_id = NULL WHERE sales_order_id = o1 AND is_takeaway;
    RAISE EXCEPTION 'YC-05: database KHÔNG từ chối suất đem về rời khỏi đơn của phiên';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'YC-05 bị từ chối (suất đem về rời đơn): %', SQLERRM;
  END;
END $$;
