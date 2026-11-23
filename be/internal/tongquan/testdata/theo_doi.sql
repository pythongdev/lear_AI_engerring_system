-- T-372 (ADR-148): Claude viết trước khi giao. Chạy SAU testdata/service_board.sql trong cùng giao dịch rollback
-- (dùng lại pg_temp.t225_line, pg_temp.t225_job và các bàn test-t225-*). Mốc đơn đặt tay quanh now() của giao dịch.
-- Codex được sửa chi tiết câu INSERT cho khớp ràng buộc của bảng, KHÔNG được đổi trạng thái, kênh, mốc hay việc trạm
-- của từng đơn — các kỳ vọng ở theo_doi_test.go dựa trên đúng các con số ấy.
-- 2026-11-23 (Claude, chạy be-check): thêm person_id cho qr_code và handover_code='shop_pickup' cho đơn đến lấy, dòng thành phần cho dòng chờ duyệt, hoá đơn cho đơn P3 đã xong, theo ràng buộc bảng.
SET CONSTRAINTS ALL DEFERRED;
DO $$
DECLARE nguoi bigint; ta bigint; tb1 bigint; tc bigint; td bigint; tf bigint; s1 bigint; s2 bigint; s5 bigint;
 mb bigint; ib bigint; thit bigint; ma_a bigint; ma_f bigint; o bigint; lc bigint; l bigint;
BEGIN
 SELECT id INTO STRICT nguoi FROM person WHERE display_name='test-t225-quay';
 SELECT id INTO STRICT ta FROM dining_table WHERE label='test-t225-A';
 SELECT id INTO STRICT tb1 FROM dining_table WHERE label='test-t225-B1';
 SELECT id INTO STRICT tc FROM dining_table WHERE label='test-t225-C';
 SELECT id INTO STRICT td FROM dining_table WHERE label='test-t225-D';
 SELECT table_session_id INTO STRICT s1 FROM table_session_member WHERE dining_table_id=ta AND NOT session_closed;
 SELECT table_session_id INTO STRICT s2 FROM table_session_member WHERE dining_table_id=tb1 AND NOT session_closed;
 SELECT id INTO STRICT mb FROM menu_component WHERE name='test-t225-banh';
 SELECT id INTO STRICT ib FROM menu_item WHERE name='test-t225-mon-banh';
 SELECT id INTO STRICT thit FROM menu_option WHERE name='test-t225-thit';

 -- Mã QR: bàn A có một mã đã thay (test-t372-A-cu) và một mã hiện hành; B1, C, D, F mỗi bàn một mã hiện hành.
 INSERT INTO qr_code(person_id,dining_table_id,code,issued_at,replaced_at) VALUES (nguoi,ta,'test-t372-A-cu',now()-interval '2 days',now()-interval '1 day');
 INSERT INTO qr_code(person_id,dining_table_id,code,issued_at) VALUES (nguoi,ta,'test-t372-A',now()-interval '1 day') RETURNING id INTO ma_a;
 INSERT INTO qr_code(person_id,dining_table_id,code,issued_at) VALUES (nguoi,tb1,'test-t372-B1',now()-interval '1 day');
 INSERT INTO qr_code(person_id,dining_table_id,code,issued_at) VALUES (nguoi,tc,'test-t372-C',now()-interval '1 day');
 INSERT INTO qr_code(person_id,dining_table_id,code,issued_at) VALUES (nguoi,td,'test-t372-D',now()-interval '1 day');

 -- Bàn F: phiên mở, chỉ có một đơn QR chờ duyệt.
 INSERT INTO dining_table(label) VALUES ('test-t372-F') RETURNING id INTO tf;
 INSERT INTO qr_code(person_id,dining_table_id,code,issued_at) VALUES (nguoi,tf,'test-t372-F',now()-interval '1 day') RETURNING id INTO ma_f;
 INSERT INTO table_session(status) VALUES ('open') RETURNING id INTO s5;
 INSERT INTO table_session_member(table_session_id,dining_table_id) VALUES (s5,tf);
 INSERT INTO sales_order(channel_code,status,table_session_id,dining_table_id,qr_code_id,submission_code)
 VALUES ('qr_table','pending_confirmation',s5,tf,ma_f,gen_random_uuid()::text) RETURNING id INTO o;
 INSERT INTO order_line(sales_order_id,quantity,menu_item_id,item_name,unit_price_vnd,component_count)
 VALUES (o,1,ib,'test-t372-cho-F',4000,1) RETURNING id INTO l;
 INSERT INTO order_line_component(order_line_id,position,line_component_count,menu_component_id,component_name,quantity,takes_filling,base_price_vnd)
 VALUES (l,1,1,mb,'test-t225-banh',1,true,100);

 -- Đơn QR chờ duyệt của bàn A (phiên S1): vào pending_lines, không vào items, lines, tiền, không làm mốc.
 INSERT INTO sales_order(channel_code,status,table_session_id,dining_table_id,qr_code_id,submission_code)
 VALUES ('qr_table','pending_confirmation',s1,ta,ma_a,gen_random_uuid()::text) RETURNING id INTO o;
 INSERT INTO order_line(sales_order_id,quantity,menu_item_id,item_name,unit_price_vnd,component_count)
 VALUES (o,2,ib,'test-t372-cho-A',4000,1) RETURNING id INTO l;
 INSERT INTO order_line_component(order_line_id,position,line_component_count,menu_component_id,component_name,quantity,takes_filling,base_price_vnd)
 VALUES (l,1,1,mb,'test-t225-banh',1,true,100);

 -- Đơn của bàn B (phiên S2), tạo 5 giây trước, còn việc pending ⇒ đứng trước bàn A (đơn S1 tạo lúc now()).
 INSERT INTO sales_order(channel_code,status,table_session_id,dining_table_id,submission_code,created_at)
 VALUES ('staff_pos','in_progress',s2,tb1,gen_random_uuid()::text,now()-interval '5 seconds') RETURNING id INTO o;
 lc := pg_temp.t225_line(o,ib,mb,'test-t225-banh',1,true,5000,ARRAY[thit]);
 PERFORM pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'trang_banh',1,1,1,'pending');

 -- P1: đơn đến lấy, đã duyệt, tạo 10 giây trước, còn việc pending ⇒ đứng trước cả A và B.
 INSERT INTO sales_order(channel_code,handover_code,status,customer_phone,customer_needed_at,submission_code,created_at)
 VALUES ('pickup','shop_pickup','in_progress','0900000001',now()+interval '1 hour',gen_random_uuid()::text,now()-interval '10 seconds') RETURNING id INTO o;
 lc := pg_temp.t225_line(o,ib,mb,'test-t225-banh',1,true,5000,ARRAY[thit]);
 PERFORM pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'trang_banh',1,1,1,'pending');

 -- P2: đã huỷ ⇒ không đếm, dù còn việc pending.
 INSERT INTO sales_order(channel_code,handover_code,status,customer_phone,customer_needed_at,submission_code,created_at)
 VALUES ('pickup','shop_pickup','cancelled','0900000002',now()+interval '1 hour',gen_random_uuid()::text,now()-interval '30 seconds') RETURNING id INTO o;
 lc := pg_temp.t225_line(o,ib,mb,'test-t225-banh',1,true,5000,ARRAY[thit]);
 PERFORM pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'trang_banh',1,1,1,'pending');

 -- P3: đã xong (completed) ⇒ không đếm, dù còn việc made.
 INSERT INTO sales_order(channel_code,handover_code,status,customer_phone,customer_needed_at,submission_code,created_at)
 VALUES ('pickup','shop_pickup','completed','0900000003',now()+interval '1 hour',gen_random_uuid()::text,now()-interval '40 seconds') RETURNING id INTO o;
 INSERT INTO bill(sales_order_id,due_vnd,cash_vnd) VALUES (o,5000,5000);
 lc := pg_temp.t225_line(o,ib,mb,'test-t225-banh',1,true,5000,ARRAY[thit]);
 PERFORM pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'trang_banh',1,1,1,'made');

 -- P4: đang làm nhưng mọi việc đã served ⇒ không còn chờ món, không đếm.
 INSERT INTO sales_order(channel_code,handover_code,status,customer_phone,customer_needed_at,submission_code,created_at)
 VALUES ('pickup','shop_pickup','in_progress','0900000004',now()+interval '1 hour',gen_random_uuid()::text,now()-interval '50 seconds') RETURNING id INTO o;
 lc := pg_temp.t225_line(o,ib,mb,'test-t225-banh',1,true,5000,ARRAY[thit]);
 PERFORM pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'trang_banh',1,1,1,'served');
 -- P5: đơn đến lấy của NGÀY BÁN TRƯỚC còn treo in_progress, việc pending ⇒ không đếm (ADR-148 điểm 3: chỉ ngày bán hiện tại).
 INSERT INTO sales_order(channel_code,handover_code,status,customer_phone,customer_needed_at,submission_code,created_at)
 VALUES ('pickup','shop_pickup','in_progress','0900000005',now()-interval '1 day'+interval '1 hour',gen_random_uuid()::text,now()-interval '1 day') RETURNING id INTO o;
 lc := pg_temp.t225_line(o,ib,mb,'test-t225-banh',1,true,5000,ARRAY[thit]);
 PERFORM pg_temp.t225_job(o,(SELECT order_line_id FROM order_line_component WHERE id=lc),lc,'trang_banh',1,1,1,'pending');
END $$;
SET CONSTRAINTS ALL IMMEDIATE;
