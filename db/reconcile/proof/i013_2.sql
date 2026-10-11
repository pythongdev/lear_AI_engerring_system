-- kêu: I-013/2 I-013/1 I-007/2
-- Dòng đơn tới lấy bị ghi giá 0đ, không khai lý do — hoá đơn của đơn ấy thành ra thu nhiều hơn chính
-- đơn (I-007/2 đọc đúng hình ấy).
DO $$ BEGIN
  PERFORM pg_temp.bc_vet('order_line', false);
  UPDATE order_line SET unit_price_vnd = 0
  WHERE sales_order_id = (SELECT id FROM bc WHERE ten = 'don_lay');
  PERFORM pg_temp.bc_vet('order_line', true);
END $$;
