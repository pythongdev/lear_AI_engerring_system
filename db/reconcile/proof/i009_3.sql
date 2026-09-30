-- kêu: I-009/3
-- Quầy sửa dòng đơn tới lấy (mốc khoá đặt lại 10:30) mà không khai lý do — không vết nào.
DO $$ BEGIN
  PERFORM set_config('shop.revision_reason', '', true);
  UPDATE order_line SET priced_at = pg_temp.bc_luc('10:30')
  WHERE sales_order_id = (SELECT id FROM bc WHERE ten = 'don_lay');
END $$;
