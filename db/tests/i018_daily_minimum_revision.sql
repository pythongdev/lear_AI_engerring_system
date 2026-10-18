-- T-199: dữ liệu giả, I-018 vết; không có số mặc định nghiệp vụ.
DO $$
DECLARE p bigint; d bigint; cn text; q text;
BEGIN
 INSERT INTO person(display_name,is_owner) VALUES ('test-daily-minimum',true) RETURNING id INTO p;
 PERFORM set_config('shop.actor_person_id',p::text,true);
 PERFORM set_config('shop.revision_reason','test-daily-minimum',true);
 SET LOCAL ROLE shop_app;
 INSERT INTO daily_minimum(sale_date,minimum_banh,minimum_workers)
 VALUES ('2088-01-01',100,2) RETURNING id INTO d;
 BEGIN
  INSERT INTO daily_minimum(sale_date,minimum_banh,minimum_workers) VALUES ('2088-01-01',200,3);
  RAISE EXCEPTION 'nhận ngày trùng';
 EXCEPTION WHEN unique_violation THEN
  GET STACKED DIAGNOSTICS cn = CONSTRAINT_NAME;
  IF cn <> 'daily_minimum_sale_date_key' THEN RAISE; END IF;
 END;
 FOREACH q IN ARRAY ARRAY[
  'INSERT INTO daily_minimum(sale_date,minimum_banh,minimum_workers) VALUES (''2088-01-02'',0,1)',
  'INSERT INTO daily_minimum(sale_date,minimum_banh,minimum_workers) VALUES (''2088-01-02'',-1,1)',
  'INSERT INTO daily_minimum(sale_date,minimum_banh,minimum_workers) VALUES (''2088-01-02'',1,0)',
  'INSERT INTO daily_minimum(sale_date,minimum_banh,minimum_workers) VALUES (''2088-01-02'',1,-1)'
 ] LOOP
  BEGIN EXECUTE q; RAISE EXCEPTION 'nhận số không dương';
  EXCEPTION WHEN check_violation THEN
   GET STACKED DIAGNOSTICS cn = CONSTRAINT_NAME;
   IF cn NOT IN ('daily_minimum_banh_positive_check','daily_minimum_workers_positive_check') THEN RAISE; END IF;
  END;
 END LOOP;
 UPDATE daily_minimum SET minimum_banh=120,minimum_workers=3 WHERE id=d;
 IF NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code='daily_minimum' AND target_row=d
   AND person_id=p AND reason='test-daily-minimum'
   AND before_image->>'minimum_banh'='100' AND after_image->>'minimum_banh'='120'
   AND before_image->>'minimum_workers'='2' AND after_image->>'minimum_workers'='3') THEN
  RAISE EXCEPTION 'sửa không có đủ vết';
 END IF;
 PERFORM set_config('shop.revision_reason','',true);
 BEGIN
  UPDATE daily_minimum SET minimum_banh=121 WHERE id=d;
  RAISE EXCEPTION 'sửa không lý do được nhận';
 EXCEPTION WHEN check_violation THEN
  GET STACKED DIAGNOSTICS cn = CONSTRAINT_NAME;
  IF cn <> 'record_revision_reason_declared_check' THEN RAISE; END IF;
 END;
 BEGIN DELETE FROM daily_minimum WHERE id=d; RAISE EXCEPTION 'xoá được';
 EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 BEGIN UPDATE daily_minimum SET sale_date='2088-01-03' WHERE id=d; RAISE EXCEPTION 'đổi ngày được';
 EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 RESET ROLE;
 RAISE NOTICE 'daily_minimum: unique day, positive counts, revision, no delete, immutable date OK';
END $$;
