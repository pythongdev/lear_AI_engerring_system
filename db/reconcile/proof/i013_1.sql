-- kêu: I-013/1
-- Giá của dòng đơn tới lấy bị ghi đè cao hơn 1.000đ, không khai lý do — không vết nào.
DO $$ BEGIN
  PERFORM pg_temp.bc_vet('order_line', false);
  UPDATE order_line SET unit_price_vnd = unit_price_vnd + 1000
  WHERE sales_order_id = (SELECT id FROM bc WHERE ten = 'don_lay');
  PERFORM pg_temp.bc_vet('order_line', true);
END $$;
