-- kêu: I-013/1
-- Giá của dòng đơn tới lấy bị ghi đè cao hơn 1.000đ, không khai lý do — không vết nào.
DO $$ BEGIN
  PERFORM set_config('shop.revision_reason', '', true);
  UPDATE order_line SET unit_price_vnd = unit_price_vnd + 1000
  WHERE sales_order_id = (SELECT id FROM bc WHERE ten = 'don_lay');
END $$;
