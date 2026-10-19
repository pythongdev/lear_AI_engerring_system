-- Dữ liệu giả trong giao dịch rollback, giữ mọi ràng buộc hoãn.
INSERT INTO person(display_name,is_owner) VALUES ('test-p3a10-owner',true);
SELECT set_config('shop.actor_person_id',(SELECT id::text FROM person WHERE display_name='test-p3a10-owner'),true);
SELECT set_config('shop.revision_reason','test-p3a10',true);
CREATE FUNCTION pg_temp.t_order(day date, channel text DEFAULT 'pickup', state text DEFAULT 'confirmed') RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE o bigint;
BEGIN
 INSERT INTO sales_order(channel_code,status,handover_code,customer_phone,delivery_address,customer_needed_at,submission_code,created_at)
 VALUES(channel,state,CASE WHEN channel='delivery' THEN 'door_delivery' ELSE 'shop_pickup' END,
 '0900000000','test-address',day+time '08:00',gen_random_uuid()::text,day+time '08:00') RETURNING id INTO o;
 RETURN o;
END $$;
CREATE FUNCTION pg_temp.t_bill(day date, amount bigint, channel text DEFAULT 'pickup') RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE b bigint; o bigint;
BEGIN
 o := pg_temp.t_order(day,channel,'completed');
 INSERT INTO bill(sales_order_id,due_vnd,cash_vnd,booked_at,sale_date)
 VALUES(o,amount,amount,day+time '09:00',day) RETURNING id INTO b;
 RETURN b;
END $$;
DO $$
DECLARE s bigint; b bigint; o bigint; p bigint; r bigint;
BEGIN
 -- (a) Hai nguồn, đủ ba kênh mang đi.
 INSERT INTO table_session(status) VALUES ('closed') RETURNING id INTO s;
 INSERT INTO bill(table_session_id,due_vnd,cash_vnd,booked_at,sale_date)
 VALUES(s,10000,10000,'2186-01-01T09:00:00+07','2186-01-01');
 PERFORM pg_temp.t_bill('2186-01-01',2000,'delivery');
 PERFORM pg_temp.t_bill('2186-01-01',3000,'pickup');
 PERFORM pg_temp.t_bill('2186-01-01',4000,'phone_preorder');
 -- (b) Nợ nằm trọn ngày ghi hoá đơn, thu nợ hôm sau không là bán.
 INSERT INTO table_session(status) VALUES ('closed') RETURNING id INTO s;
 INSERT INTO bill(table_session_id,due_vnd,debt_vnd,debtor_name,booked_at,sale_date)
 VALUES(s,7000,7000,'test-debtor','2186-02-01T09:00:00+07','2186-02-01') RETURNING id INTO b;
 INSERT INTO debt_collection(bill_id,debt_vnd,cash_vnd,booked_at,sale_date)
 VALUES(b,7000,7000,'2186-02-02T09:00:00+07','2186-02-02');
 -- (c) Thứ Hai 2186-03-06 bán, thứ Tư 14 hoàn; không sửa ngày gốc.
 b := pg_temp.t_bill('2186-03-06',11000);
 INSERT INTO refund(bill_id,amount_vnd,method_code,source_method_code,reason,booked_at,sale_date)
 VALUES(b,2500,'cash','cash','test-return','2186-03-08T09:00:00+07','2186-03-08');
 -- (d) Nhận trước 9000, trả lại 1000 ngày nhận và 2000 hôm sau, đóng 6000 hôm sau.
 o := pg_temp.t_order('2186-04-01','phone_preorder');
 INSERT INTO prepayment(sales_order_id,cash_vnd,booked_at,sale_date)
 VALUES(o,9000,'2186-04-01T09:00:00+07','2186-04-01') RETURNING id INTO p;
 INSERT INTO refund(prepayment_id,amount_vnd,method_code,reason,booked_at,sale_date)
 VALUES(p,1000,'cash','test-prepay-return','2186-04-01T10:00:00+07','2186-04-01') RETURNING id INTO r;
 INSERT INTO prepayment_use(prepayment_id,sales_order_id,use_no,cash_before_vnd,transfer_before_vnd,take_cash_vnd,refund_id)
 VALUES(p,o,1,9000,0,1000,r);
 INSERT INTO refund(prepayment_id,amount_vnd,method_code,reason,booked_at,sale_date)
 VALUES(p,2000,'cash','test-prepay-return','2186-04-02T08:00:00+07','2186-04-02') RETURNING id INTO r;
 INSERT INTO prepayment_use(prepayment_id,sales_order_id,use_no,cash_before_vnd,transfer_before_vnd,take_cash_vnd,refund_id)
 VALUES(p,o,2,8000,0,2000,r);
 INSERT INTO bill(sales_order_id,due_vnd,prepaid_cash_vnd,booked_at,sale_date)
 VALUES(o,6000,6000,'2186-04-02T09:00:00+07','2186-04-02') RETURNING id INTO b;
 INSERT INTO prepayment_use(prepayment_id,sales_order_id,use_no,cash_before_vnd,transfer_before_vnd,take_cash_vnd,bill_id)
 VALUES(p,o,3,6000,0,6000,b);
 UPDATE sales_order SET status='completed' WHERE id=o;
END $$;
SET CONSTRAINTS ALL IMMEDIATE;
