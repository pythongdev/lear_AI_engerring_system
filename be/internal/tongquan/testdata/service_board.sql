-- T-225 (ADR-124): fixture riêng trong giao dịch rollback; giá giả. Mọi mốc là now() của giao dịch,
-- nên test lấy ngày bán bằng now() theo múi giờ quán, không dựng ngày tương lai.
-- S1 đang phục vụ (bàn A) · S2 sắp phục vụ, ghép hai bàn B1 B2 · S3 mở chưa gửi đơn (bàn C) ·
-- S4 đã đóng trong ngày (bàn E) · bàn D không phiên nào.
SET CONSTRAINTS ALL DEFERRED;
CREATE FUNCTION pg_temp.t225_job(o bigint, l bigint, c bigint, st text, lq integer, cq integer, pos integer, stt text)
RETURNS bigint LANGUAGE plpgsql AS $$
DECLARE j bigint; b bigint;
BEGIN
 INSERT INTO station_job(sales_order_id,order_line_id,order_line_component_id,station_code,line_quantity,component_quantity,position,status)
 VALUES(o,l,c,st,lq,cq,pos,stt) RETURNING id INTO j;
 IF stt IN ('made','served') THEN
  INSERT INTO production_batch DEFAULT VALUES RETURNING id INTO b;
  INSERT INTO production_batch_item(production_batch_id,made_for_station_job_id,station_job_id) VALUES(b,j,j);
 END IF;
 RETURN j;
END $$;
CREATE FUNCTION pg_temp.t225_line(o bigint, m bigint, c bigint, cname text, cq integer, fill boolean, price bigint, opts bigint[])
RETURNS bigint LANGUAGE plpgsql AS $$
DECLARE l bigint; lc bigint; x bigint;
BEGIN
 INSERT INTO order_line(sales_order_id,quantity,menu_item_id,item_name,unit_price_vnd,component_count)
 VALUES(o,1,m,'test-t225-item',price,1) RETURNING id INTO l;
 INSERT INTO order_line_component(order_line_id,position,line_component_count,menu_component_id,component_name,quantity,takes_filling,base_price_vnd)
 VALUES(l,1,1,c,cname,cq,fill,100) RETURNING id INTO lc;
 FOREACH x IN ARRAY opts LOOP
  INSERT INTO order_line_option(order_line_id,menu_option_id,option_group_name,option_name,surcharge_vnd)
  SELECT l,o2.id,g.name,o2.name,0 FROM menu_option o2 JOIN option_group g ON g.id=o2.option_group_id WHERE o2.id=x;
 END LOOP;
 RETURN lc;
END $$;
DO $$
DECLARE p bigint; mb bigint; mcanh bigint; ib bigint; ic bigint; gl bigint; gn bigint; nhieu bigint; thit bigint;
 ta bigint; tb1 bigint; tb2 bigint; tc bigint; td bigint; te bigint;
 s1 bigint; s2 bigint; s3 bigint; s4 bigint; o bigint; lc bigint; j bigint; served_later bigint[] := '{}';
BEGIN
 INSERT INTO person(display_name) VALUES ('test-t225-quay') RETURNING id INTO p;
 PERFORM set_config('shop.actor_person_id',p::text,true);
 PERFORM set_config('shop.revision_reason','test-t225-fixture',true);
 INSERT INTO menu_component(name,base_price_vnd,takes_filling) VALUES ('test-t225-banh',100,true) RETURNING id INTO mb;
 INSERT INTO menu_component(name,base_price_vnd,takes_filling) VALUES ('test-t225-canh',0,false) RETURNING id INTO mcanh;
 INSERT INTO menu_item(name) VALUES ('test-t225-mon-banh') RETURNING id INTO ib;
 INSERT INTO menu_item(name) VALUES ('test-t225-mon-canh') RETURNING id INTO ic;
 INSERT INTO menu_item_component(menu_item_id,menu_component_id,quantity) VALUES (ib,mb,2),(ic,mcanh,1);
 -- Nhóm "Lượng nhân" có thể đã có (seed); lựa chọn của fixture không là mặc định ⇒ extra_filling.
 INSERT INTO option_group(name) VALUES ('Lượng nhân') ON CONFLICT (name) DO NOTHING;
 SELECT id INTO STRICT gl FROM option_group WHERE name='Lượng nhân';
 INSERT INTO option_group(name) VALUES ('test-t225-nhan') RETURNING id INTO gn;
 INSERT INTO menu_option(option_group_id,name,surcharge_vnd) VALUES (gl,'test-t225-nhieu',1000) RETURNING id INTO nhieu;
 INSERT INTO menu_option(option_group_id,name,surcharge_vnd) VALUES (gn,'test-t225-thit',1000) RETURNING id INTO thit;
 INSERT INTO dining_table(label) VALUES ('test-t225-A') RETURNING id INTO ta;
 INSERT INTO dining_table(label) VALUES ('test-t225-B1') RETURNING id INTO tb1;
 INSERT INTO dining_table(label) VALUES ('test-t225-B2') RETURNING id INTO tb2;
 INSERT INTO dining_table(label) VALUES ('test-t225-C') RETURNING id INTO tc;
 INSERT INTO dining_table(label) VALUES ('test-t225-D') RETURNING id INTO td;
 INSERT INTO dining_table(label) VALUES ('test-t225-E') RETURNING id INTO te;

 -- S1 đang phục vụ, bàn A.
 INSERT INTO table_session(status) VALUES ('serving') RETURNING id INTO s1;
 INSERT INTO table_session_member(table_session_id,dining_table_id) VALUES (s1,ta);
 INSERT INTO sales_order(channel_code,status,table_session_id,dining_table_id,submission_code)
 VALUES ('staff_pos','in_progress',s1,ta,gen_random_uuid()::text) RETURNING id INTO o;
 -- L1 8000: bánh ×2, thịt + nhiều. Vị trí 1 ra hết (tráng served, gấp made→served sau);
 -- vị trí 2 tráng served, gấp còn made ⇒ chưa ra. Đơn vị bán chưa ra hết ⇒ không vào tiền đã ra.
 lc := pg_temp.t225_line(o,ib,mb,'test-t225-banh',2,true,8000,ARRAY[thit,nhieu]);
 PERFORM pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'trang_banh',1,2,1,'served');
 j := pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'gap_banh',1,2,1,'made');
 served_later := served_later || j;
 PERFORM pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'trang_banh',1,2,2,'served');
 PERFORM pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'gap_banh',1,2,2,'made');
 -- L2 1000: canh ×1, made→served sau ⇒ đơn vị bán ra hết.
 lc := pg_temp.t225_line(o,ic,mcanh,'test-t225-canh',1,false,1000,ARRAY[]::bigint[]);
 j := pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'canh',1,1,1,'made');
 served_later := served_later || j;
 -- L3 5000: bánh ×1, thịt (không nhiều). Tráng served, gấp made→served sau ⇒ ra hết.
 lc := pg_temp.t225_line(o,ib,mb,'test-t225-banh',1,true,5000,ARRAY[thit]);
 PERFORM pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'trang_banh',1,1,1,'served');
 j := pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'gap_banh',1,1,1,'made');
 served_later := served_later || j;
 -- Nước chấm cấp đơn, đã làm chưa ra.
 PERFORM pg_temp.t225_job(o,NULL,NULL,'don_ban',NULL,NULL,1,'made');
 -- Đơn huỷ của S1: không vào items, không vào tiền.
 INSERT INTO sales_order(channel_code,status,table_session_id,dining_table_id,submission_code)
 VALUES ('staff_pos','cancelled',s1,ta,gen_random_uuid()::text) RETURNING id INTO o;
 lc := pg_temp.t225_line(o,ib,mb,'test-t225-banh',1,true,99999,ARRAY[thit]);
 PERFORM pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'trang_banh',1,1,1,'pending');

 -- S2 sắp phục vụ: ghép B1 + B2, đơn gửi từ B2, chưa phần nào ra.
 INSERT INTO table_session(status) VALUES ('serving') RETURNING id INTO s2;
 INSERT INTO table_session_member(table_session_id,dining_table_id) VALUES (s2,tb1);
 INSERT INTO table_session_member(table_session_id,dining_table_id) VALUES (s2,tb2);
 INSERT INTO sales_order(channel_code,status,table_session_id,dining_table_id,submission_code)
 VALUES ('staff_pos','in_progress',s2,tb2,gen_random_uuid()::text) RETURNING id INTO o;
 lc := pg_temp.t225_line(o,ib,mb,'test-t225-banh',1,true,5000,ARRAY[thit]);
 PERFORM pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'trang_banh',1,1,1,'made');
 PERFORM pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'gap_banh',1,1,1,'pending');

 -- S3 mở, chưa gửi đơn nào.
 INSERT INTO table_session(status) VALUES ('open') RETURNING id INTO s3;
 INSERT INTO table_session_member(table_session_id,dining_table_id) VALUES (s3,tc);

 -- S4 đã đóng trong ngày, bàn E: canh ×2 cùng một lần bấm ⇒ một mục lịch sử, quantity 2.
 INSERT INTO table_session(status) VALUES ('closed') RETURNING id INTO s4;
 INSERT INTO table_session_member(table_session_id,dining_table_id,session_closed) VALUES (s4,te,true);
 INSERT INTO bill(table_session_id,due_vnd,cash_vnd) VALUES (s4,3000,3000);
 INSERT INTO sales_order(channel_code,status,table_session_id,dining_table_id,submission_code)
 VALUES ('staff_pos','completed',s4,te,gen_random_uuid()::text) RETURNING id INTO o;
 lc := pg_temp.t225_line(o,ic,mcanh,'test-t225-canh',2,false,3000,ARRAY[]::bigint[]);
 served_later := served_later || pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'canh',1,2,1,'made');
 served_later := served_later || pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'canh',1,2,2,'made');

 -- Lần bấm "đã ra bàn": made → served có vết (lý do và người của giao dịch), như cửa sanxuat/ra_ban.
 UPDATE station_job SET status='served' WHERE id = ANY(served_later);
END $$;
SET CONSTRAINTS ALL IMMEDIATE;
