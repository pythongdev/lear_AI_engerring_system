SET CONSTRAINTS ALL DEFERRED;
-- Dòng con giữ quantity suất; tên ảnh chụp cố ý khác tên menu.
CREATE FUNCTION pg_temp.t_line(o bigint, m bigint, q integer, component bigint, parent bigint DEFAULT NULL) RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE l bigint;
BEGIN
 INSERT INTO order_line(sales_order_id,menu_item_id,quantity,item_name,unit_price_vnd,component_count,parent_order_line_id)
 VALUES(o,m,q,'old-item-name',100,1,parent) RETURNING id INTO l;
 INSERT INTO order_line_component(order_line_id,position,line_component_count,menu_component_id,component_name,quantity,takes_filling,base_price_vnd)
 VALUES(l,1,1,component,'test-component',1,false,100);
 RETURN l;
END $$;
DO $$
DECLARE mc bigint; m1 bigint; m2 bigint; m3 bigint; c1 bigint; c2 bigint; c3 bigint;
 s bigint; tab bigint; o bigint; root bigint; cb bigint; qty integer; a bigint; b bigint; z bigint;
 billid bigint; pp bigint; rr bigint;
BEGIN
 INSERT INTO menu_component(name,base_price_vnd,takes_filling) VALUES('test-summary-component',100,false) RETURNING id INTO mc;
 INSERT INTO menu_item(name) VALUES('test-item-low-a') RETURNING id INTO m1;
 INSERT INTO menu_item(name) VALUES('test-item-low-b') RETURNING id INTO m2;
 INSERT INTO menu_item(name) VALUES('test-current-item') RETURNING id INTO m3;
 INSERT INTO menu_item_component(menu_item_id,menu_component_id,quantity) VALUES(m1,mc,1),(m2,mc,1),(m3,mc,1);
 INSERT INTO menu_combo(name,price_vnd) VALUES('test-combo-low-a',100) RETURNING id INTO c1;
 INSERT INTO menu_combo(name,price_vnd) VALUES('test-combo-low-b',100) RETURNING id INTO c2;
 INSERT INTO menu_combo(name,price_vnd) VALUES('test-current-combo',100) RETURNING id INTO c3;
 INSERT INTO menu_combo_item(menu_combo_id,menu_item_id,quantity) VALUES(c1,m1,1),(c2,m1,1),(c3,m3,2);
 -- Phiên đã đóng có một đơn sống, một đơn huỷ.
 INSERT INTO table_session(status) VALUES('closed') RETURNING id INTO s;
 INSERT INTO dining_table(label) VALUES('test-summary-table') RETURNING id INTO tab;
 INSERT INTO table_session_member(table_session_id,dining_table_id,session_closed) VALUES(s,tab,true);
 INSERT INTO bill(table_session_id,due_vnd,cash_vnd,sale_date,booked_at) VALUES(s,100,100,'2186-05-01','2186-05-01T09:00:00+07');
 INSERT INTO sales_order(channel_code,status,table_session_id,dining_table_id,submission_code,created_at)
 VALUES('staff_pos','completed',s,tab,gen_random_uuid()::text,'2186-04-30T23:00:00+07') RETURNING id INTO o;
 PERFORM pg_temp.t_line(o,m1,1,mc);
 PERFORM pg_temp.t_line(o,m2,3,mc);
 INSERT INTO sales_order(channel_code,status,table_session_id,dining_table_id,submission_code,created_at)
 VALUES('staff_pos','cancelled',s,tab,gen_random_uuid()::text,'2186-05-01T08:00:00+07') RETURNING id INTO o;
 PERFORM pg_temp.t_line(o,m3,99,mc);
 -- Combo của đơn lẻ có bill trong ngày.
 billid:=pg_temp.t_bill('2186-05-01',1000);
 SELECT sales_order_id INTO o FROM bill WHERE id=billid;
 FOREACH cb IN ARRAY ARRAY[c1,c2,c3] LOOP
  qty:=CASE WHEN cb=c3 THEN 4 ELSE 2 END;
  INSERT INTO order_line(sales_order_id,menu_combo_id,quantity,item_name,unit_price_vnd)
  VALUES(o,cb,qty,'old-combo-name',100) RETURNING id INTO root;
  PERFORM pg_temp.t_line(o,CASE WHEN cb=c3 THEN m3 ELSE m1 END,CASE WHEN cb=c3 THEN 8 ELSE 1 END,mc,root);
 END LOOP;
 -- Đơn chưa bill và đơn có bill ngày khác không được đếm.
 o:=pg_temp.t_order('2186-05-01'); PERFORM pg_temp.t_line(o,m3,88,mc);
 billid:=pg_temp.t_bill('2186-05-03',100); SELECT sales_order_id INTO o FROM bill WHERE id=billid;
 PERFORM pg_temp.t_line(o,m3,77,mc);
 -- Staff: A đủ năm số; B chỉ có đơn trong khoảng trực; Z toàn 0 bị lọc.
 INSERT INTO person(display_name) VALUES('test-worker-a') RETURNING id INTO a;
 INSERT INTO person(display_name) VALUES('test-worker-b') RETURNING id INTO b;
 INSERT INTO person(display_name) VALUES('test-worker-zero') RETURNING id INTO z;
 INSERT INTO attendance_day(worker_person_id,work_date) VALUES(a,'2186-05-02');
 INSERT INTO attendance_day(worker_person_id,work_date,cancelled_at,cancelled_by_person_id,cancel_note)
 VALUES(b,'2186-05-02',now(),a,'test-cancel'),(z,'2186-05-02',now(),a,'test-cancel');
 UPDATE counter_duty SET ended_at=greatest(now(),started_at+interval '1 second') WHERE ended_at IS NULL;
 INSERT INTO counter_duty(person_id,started_at,ended_at) VALUES(a,'2186-05-02T08:00:00+07','2186-05-02T09:00:00+07');
 -- Khoảng mở của B được rollback, không ảnh hưởng test khác.
 INSERT INTO counter_duty(person_id,started_at) VALUES(b,'2186-05-02T09:00:00+07');
 billid:=pg_temp.t_bill('2186-05-02',1000,'delivery');
 UPDATE bill SET person_id=a WHERE id=billid;
 -- Đơn lấy tại quán trong khoảng A, không tăng deliveries.
 o:=pg_temp.t_bill('2186-05-02',1000,'pickup'); UPDATE bill SET person_id=a WHERE id=o;
 -- Đúng đầu khoảng B = ngoài khoảng A.
 o:=pg_temp.t_order('2186-05-02','phone_preorder'); UPDATE sales_order SET created_at='2186-05-02T09:00:00+07' WHERE id=o;
 o:=pg_temp.t_order('2186-05-02'); UPDATE sales_order SET created_at='2186-05-01T23:59:59+07' WHERE id=o;
 -- Trả trước chưa đóng: tạo ngoài khoảng A và B trong ngày, không tăng counter_orders.
 o:=pg_temp.t_order('2186-05-02'); UPDATE sales_order SET created_at='2186-05-02T07:59:59+07' WHERE id=o;
 INSERT INTO prepayment(sales_order_id,cash_vnd,sale_date,booked_at) VALUES(o,100,'2186-05-02','2186-05-02T09:00:00+07') RETURNING id INTO pp;
 INSERT INTO refund(prepayment_id,amount_vnd,method_code,reason,sale_date,booked_at,person_id)
 VALUES(pp,100,'cash','test-return','2186-05-02','2186-05-02T10:00:00+07',a) RETURNING id INTO rr;
 INSERT INTO prepayment_use(prepayment_id,sales_order_id,use_no,cash_before_vnd,transfer_before_vnd,take_cash_vnd,refund_id)
 VALUES(pp,o,1,100,0,100,rr);
 INSERT INTO refund(bill_id,amount_vnd,method_code,source_method_code,reason,sale_date,booked_at,person_id)
 VALUES(billid,100,'cash','cash','test-return','2186-05-02','2186-05-02T10:00:00+07',a);
 -- Mốc UTC 17:00 đã sang ngày kế theo phiên +07, nằm trong khoảng mở của B.
 o:=pg_temp.t_order('2186-05-02'); UPDATE sales_order SET created_at='2186-05-02T16:59:59Z' WHERE id=o;
 -- Vết kiểm đủ các vế lọc; dữ liệu test dùng owner để đặt mốc lịch sử tường minh.
 INSERT INTO record_revision(target_table_code,target_row,before_image,after_image,reason,person_id,revised_at) VALUES
 ('sales_order',o,jsonb_build_object('id',o,'status','confirmed'),jsonb_build_object('id',o,'status','cancelled'),'vongdoi/chuyen_don: confirmed → cancelled',a,'2186-05-01T17:00:00Z'),
 ('sales_order',o,jsonb_build_object('id',o,'status','cancelled','note','a'),jsonb_build_object('id',o,'status','cancelled','note','b'),'test-edit',a,'2186-05-02T09:00:00+07'),
 ('sales_order',o,jsonb_build_object('id',o,'status','confirmed'),jsonb_build_object('id',o,'status','completed'),'test-complete',a,'2186-05-02T09:00:00+07'),
 ('table_session',s,jsonb_build_object('id',s,'status','open'),jsonb_build_object('id',s,'status','cancelled'),'test-other-table',a,'2186-05-02T09:00:00+07'),
 ('sales_order',o,jsonb_build_object('id',o,'status','confirmed'),jsonb_build_object('id',o,'status','cancelled'),'test-other-day',a,'2186-05-02T17:00:00Z');
END $$;
SET CONSTRAINTS ALL IMMEDIATE;
