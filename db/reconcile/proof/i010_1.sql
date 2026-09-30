-- kêu: I-010/1
-- Một dòng bánh cuốn nhân CHAY mang thêm "Nhiều nhân" — tổ hợp chủ quán cấm (§4.6 luật 3), không ai
-- từ chối; giá của dòng tính đủ cả phụ thu ấy.
DO $$ DECLARE o bigint; l bigint; BEGIN
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code, created_at)
  VALUES ('pickup', 'new', 'shop_pickup', '0900000025', pg_temp.bc_luc('10:30'),
          gen_random_uuid()::text, pg_temp.bc_luc('10:10')) RETURNING id INTO o;
  l := pg_temp.bc_mon(o, 'Bánh cuốn', 1, ARRAY['Chay']);
  INSERT INTO order_line_option (order_line_id, menu_option_id, option_group_name, option_name, surcharge_vnd)
  SELECT l, mo.id, g.name, mo.name, mo.surcharge_vnd
  FROM menu_option mo JOIN option_group g ON g.id = mo.option_group_id WHERE mo.name = 'Nhiều nhân';
  PERFORM set_config('shop.revision_reason', '', true);
  UPDATE order_line SET unit_price_vnd = pg_temp.gia_dong_tai(l) WHERE id = l;
END $$;
