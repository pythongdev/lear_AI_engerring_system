-- T-197, QD-50/51/52: mỗi lần khai là một dòng; vai ứng dụng chỉ thêm.
DO $$
DECLARE p bigint; d bigint; cn text; n integer;
BEGIN
 INSERT INTO person(display_name) VALUES ('test-workers-present') RETURNING id INTO p;
 PERFORM set_config('shop.actor_person_id',p::text,true);
 SET LOCAL ROLE shop_app;
 INSERT INTO workers_present_declaration(worker_count,sale_date) VALUES (3,'2086-01-01') RETURNING id INTO d;
 INSERT INTO workers_present_declaration(worker_count,sale_date) VALUES (5,'2086-01-01');
 IF (SELECT count(*) FROM workers_present_declaration WHERE sale_date='2086-01-01') <> 2 THEN
  RAISE EXCEPTION 'hai lần khai không giữ hai dòng';
 END IF;
 FOREACH n IN ARRAY ARRAY[0,-1] LOOP
  BEGIN
   INSERT INTO workers_present_declaration(worker_count,sale_date) VALUES (n,'2086-01-01');
   RAISE EXCEPTION 'nhận số không dương';
  EXCEPTION WHEN check_violation THEN
   GET STACKED DIAGNOSTICS cn = CONSTRAINT_NAME;
   IF cn <> 'workers_present_declaration_count_positive_check' THEN RAISE; END IF;
  END;
 END LOOP;
 PERFORM set_config('shop.actor_person_id','',true);
 BEGIN
  INSERT INTO workers_present_declaration(worker_count,sale_date) VALUES (1,'2086-01-01');
  RAISE EXCEPTION 'nhận thiếu người khai';
 EXCEPTION WHEN not_null_violation THEN NULL; END;
 PERFORM set_config('shop.actor_person_id',p::text,true);
 BEGIN UPDATE workers_present_declaration SET worker_count=4 WHERE id=d; RAISE EXCEPTION 'sửa được';
 EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 BEGIN DELETE FROM workers_present_declaration WHERE id=d; RAISE EXCEPTION 'xoá được';
 EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 RESET ROLE;
 -- QD-52: chủ lược đồ sửa để chứng minh trigger vẫn giữ vết.
 PERFORM set_config('shop.revision_reason','test-workers-present-revision',true);
 UPDATE workers_present_declaration SET worker_count=4 WHERE id=d;
 IF NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code='workers_present_declaration'
  AND target_row=d AND person_id=p AND before_image->>'worker_count'='3' AND after_image->>'worker_count'='4') THEN
  RAISE EXCEPTION 'thiếu trigger vết';
 END IF;
 RAISE NOTICE 'workers_present_declaration: positive count, actor required, append only, revision OK';
END $$;
