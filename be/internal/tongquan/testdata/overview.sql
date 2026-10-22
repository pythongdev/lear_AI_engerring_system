-- Fixture riêng trong giao dịch rollback; giá giả, kiểm cả ràng buộc hoãn.
DO $$
DECLARE p bigint; mc bigint; mi bigint; cb bigint; o bigint; root bigint; line bigint;
 c bigint; j bigint; batch bigint; closed_session bigint; r record; k integer;
BEGIN
 INSERT INTO person(display_name,is_owner) VALUES ('test-t199-sql',true) RETURNING id INTO p;
 PERFORM set_config('shop.actor_person_id',p::text,true);
 PERFORM set_config('shop.revision_reason','test-t199-sql',true);
 INSERT INTO menu_component(name,base_price_vnd,takes_filling) VALUES ('test-t199-component',100,true) RETURNING id INTO mc;
 -- no_jobs là chưa nổ việc của thành phần có trạm, không phải thành phần miễn trạm (ADR-125).
 INSERT INTO menu_component_station(menu_component_id,station_code) VALUES (mc,'trang_banh'),(mc,'gap_banh');
 INSERT INTO menu_item(name) VALUES ('test-t199-item') RETURNING id INTO mi;
 INSERT INTO menu_item_component(menu_item_id,menu_component_id,quantity) VALUES(mi,mc,1);
 INSERT INTO menu_combo(name,price_vnd) VALUES ('test-t199-combo',5000) RETURNING id INTO cb;
 INSERT INTO menu_combo_item(menu_combo_id,menu_item_id,quantity) VALUES(cb,mi,2);
 INSERT INTO production_batch DEFAULT VALUES RETURNING id INTO batch;
 INSERT INTO table_session(status) VALUES ('open'),('serving'),('awaiting_payment');
 INSERT INTO table_session(status) VALUES ('closed') RETURNING id INTO closed_session;
 INSERT INTO bill(table_session_id,due_vnd,cash_vnd) VALUES(closed_session,0,0);
 -- Full combo includes child surcharge 800; partial combo must contribute zero.
 FOR r IN SELECT * FROM (VALUES
  ('full','in_progress','2089-01-02T00:00:00+07',5000,true,2,2),
  ('partial','in_progress','2089-01-02T10:00:00+07',9000,true,2,1),
  ('cancelled','cancelled','2089-01-02T08:00:00+07',7777,true,2,2),
  ('yesterday','completed','2089-01-01T23:59:59+07',8888,true,2,2),
  ('plain','completed','2089-01-02T10:00:00+07',600,false,1,1),
  ('no_jobs','confirmed','2089-01-02T10:00:00+07',9999,false,0,0)
 ) AS f(label,status,created,price,combo,job_count,served_count) LOOP
  INSERT INTO sales_order(channel_code,status,handover_code,customer_phone,customer_needed_at,submission_code,created_at)
  VALUES('pickup',r.status,'shop_pickup','0900000000',r.created::timestamptz,gen_random_uuid()::text,r.created::timestamptz) RETURNING id INTO o;
  IF r.combo THEN
   INSERT INTO order_line(sales_order_id,quantity,menu_combo_id,item_name,unit_price_vnd)
   VALUES(o,1,cb,'test-t199-combo',r.price) RETURNING id INTO root;
   INSERT INTO order_line(sales_order_id,quantity,menu_item_id,item_name,unit_price_vnd,component_count,parent_order_line_id)
   VALUES(o,1,mi,'test-t199-child',800,1,root) RETURNING id INTO line;
  ELSE
   INSERT INTO order_line(sales_order_id,quantity,menu_item_id,item_name,unit_price_vnd,component_count)
   VALUES(o,1,mi,'test-t199-item',r.price,1) RETURNING id INTO line;
  END IF;
  INSERT INTO order_line_component(order_line_id,position,line_component_count,menu_component_id,component_name,quantity,takes_filling,base_price_vnd)
  VALUES(line,1,1,mc,'test-t199-component',greatest(r.job_count,1),r.combo,100) RETURNING id INTO c;
  FOR k IN 1..r.job_count LOOP
   INSERT INTO station_job(sales_order_id,order_line_id,order_line_component_id,station_code,line_quantity,component_quantity,position,status)
   VALUES(o,line,c,'trang_banh',1,greatest(r.job_count,1),k,CASE WHEN k<=r.served_count THEN 'served' ELSE 'pending' END) RETURNING id INTO j;
   IF k<=r.served_count THEN
    INSERT INTO production_batch_item(production_batch_id,made_for_station_job_id,station_job_id) VALUES(batch,j,j);
   END IF;
  END LOOP;
  -- Một thành phần có việc ở cả tráng và gấp. Partial: tráng đã ra vị trí 1,
  -- nhưng gấp chưa ra, nên chưa có đơn vị nào ra hết.
  IF r.combo THEN
   FOR k IN 1..r.job_count LOOP
    INSERT INTO station_job(sales_order_id,order_line_id,order_line_component_id,station_code,line_quantity,component_quantity,position,status)
    VALUES(o,line,c,'gap_banh',1,r.job_count,k,
      CASE WHEN r.label <> 'partial' AND k<=r.served_count THEN 'served' ELSE 'pending' END) RETURNING id INTO j;
    IF r.label <> 'partial' AND k<=r.served_count THEN
     INSERT INTO production_batch_item(production_batch_id,made_for_station_job_id,station_job_id) VALUES(batch,j,j);
    END IF;
   END LOOP;
  END IF;
  -- Đơn lẻ hoàn thành cũng phải có hoá đơn để qua khoá ngoại hoãn.
  IF r.status = 'completed' THEN
   INSERT INTO bill(sales_order_id,due_vnd,cash_vnd,booked_at,sale_date)
   SELECT o,sum(line_total_vnd),sum(line_total_vnd),r.created::timestamptz,r.created::timestamptz::date
   FROM order_line WHERE sales_order_id=o;
  END IF;
 END LOOP;
 -- Yesterday's minimum must never supply today's missing value.
 INSERT INTO daily_minimum(sale_date,minimum_banh,minimum_workers) VALUES('2089-01-01',999,9);
END $$;
SET CONSTRAINTS ALL IMMEDIATE;
