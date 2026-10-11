-- kêu: I-009/3
-- Quầy sửa dòng đơn tới lấy (mốc khoá đặt lại 10:30) mà không khai lý do — không vết nào.
DO $$ BEGIN
  PERFORM pg_temp.bc_vet('order_line', false);
  UPDATE order_line SET priced_at = pg_temp.bc_luc('10:30')
  WHERE sales_order_id = (SELECT id FROM bc WHERE ten = 'don_lay');
  PERFORM pg_temp.bc_vet('order_line', true);
END $$;
