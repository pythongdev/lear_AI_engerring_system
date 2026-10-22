-- T-227 / ADR-125: cancelled không giữ mục mẻ, discarded giữ đúng mục mẻ;
-- tên từ chối lùi mẻ đến từ DB, không chỉ từ kiểm ở service. Fixture rollback bởi db-check.
DO $$
DECLARE p bigint; s bigint; t bigint; o1 bigint; o2 bigint; j1 bigint; j2 bigint; b bigint; refusal text;
BEGIN
 INSERT INTO person(display_name) VALUES ('test-t227-người đóng') RETURNING id INTO p;
 PERFORM set_config('shop.actor_person_id',p::text,true);
 PERFORM set_config('shop.revision_reason','test-t227-dóng phiên',true);
 INSERT INTO dining_table(label) VALUES ('test-t227-bàn') RETURNING id INTO t;
 INSERT INTO table_session(status) VALUES ('serving') RETURNING id INTO s;
 INSERT INTO table_session_member(table_session_id,dining_table_id) VALUES(s,t);
 INSERT INTO sales_order(channel_code,status,table_session_id,dining_table_id,submission_code)
 VALUES ('staff_pos','in_progress',s,t,gen_random_uuid()::text) RETURNING id INTO o1;
 INSERT INTO sales_order(channel_code,status,table_session_id,dining_table_id,submission_code)
 VALUES ('staff_pos','in_progress',s,t,gen_random_uuid()::text) RETURNING id INTO o2;
 INSERT INTO station_job(sales_order_id,station_code,position) VALUES(o1,'canh',1) RETURNING id INTO j1;
 INSERT INTO station_job(sales_order_id,station_code,position) VALUES(o2,'canh',1) RETURNING id INTO j2;
 INSERT INTO production_batch DEFAULT VALUES RETURNING id INTO b;
 INSERT INTO production_batch_item(production_batch_id,made_for_station_job_id,station_job_id) VALUES(b,j2,j2);
 UPDATE station_job SET status='made' WHERE id=j2;
 SET CONSTRAINTS ALL IMMEDIATE;
 UPDATE station_job SET status='cancelled' WHERE id=j1;
 UPDATE station_job SET status='discarded' WHERE id=j2;
 IF (SELECT id_if_made_or_served IS NOT NULL FROM station_job WHERE id=j1) OR
    (SELECT id_if_made_or_served IS DISTINCT FROM j2 FROM station_job WHERE id=j2) OR
    (SELECT count(*) FROM production_batch_item WHERE live_station_job_id=j2) <> 1 THEN
  RAISE EXCEPTION 'hai trạng thái huỷ không giữ đúng khoá mẻ';
 END IF;
 IF (SELECT count(*) FROM record_revision WHERE target_table_code='station_job' AND target_row IN (j1,j2)
     AND after_image->>'status' IN ('cancelled','discarded') AND person_id=p AND btrim(reason)<>'') <> 2 THEN
  RAISE EXCEPTION 'thiếu vết huỷ việc';
 END IF;
 -- Hoãn khoá bản soi để lời từ chối nghiệp vụ được kiểm trước lỗi tham chiếu.
 SET CONSTRAINTS ALL DEFERRED;
 BEGIN
  UPDATE production_batch SET rolled_back_at=clock_timestamp(),rolled_back_by_person_id=p WHERE id=b;
  RAISE EXCEPTION 'đã lùi được mẻ discarded';
 EXCEPTION WHEN check_violation THEN
  GET STACKED DIAGNOSTICS refusal = CONSTRAINT_NAME;
  IF refusal <> 'production_batch_no_discarded_jobs_check' THEN RAISE EXCEPTION 'sai tên từ chối: %',refusal; END IF;
 END;
 IF (SELECT is_rolled_back FROM production_batch WHERE id=b) THEN RAISE EXCEPTION 'mẻ đã bị đổi sau từ chối'; END IF;
 SET CONSTRAINTS ALL IMMEDIATE;
END $$;
