-- Hoàn tất trạm gấp của vị trí 1; vị trí 2 vẫn chưa ra ở cả hai trạm.
SET CONSTRAINTS ALL DEFERRED;
DO $$
DECLARE j bigint; batch bigint;
BEGIN
 SELECT sj.id INTO STRICT j FROM station_job sj
 JOIN order_line l ON l.id=sj.order_line_id
 JOIN order_line g ON g.id=l.parent_order_line_id
 WHERE g.item_name='test-t199-combo' AND g.unit_price_vnd=9000
   AND sj.station_code='gap_banh' AND sj.position=1;
 INSERT INTO production_batch DEFAULT VALUES RETURNING id INTO batch;
 UPDATE station_job SET status='served' WHERE id=j;
 INSERT INTO production_batch_item(production_batch_id,made_for_station_job_id,station_job_id)
 VALUES(batch,j,j);
END $$;
SET CONSTRAINTS ALL IMMEDIATE;
