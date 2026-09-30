-- kêu: I-014/7
-- Đơn giao đã thu (trả trước thành doanh thu) bị đẩy về Đang giao, không khai lý do — khoản trả
-- trước nằm trong doanh thu của một đơn chưa đóng.
DO $$ BEGIN
  PERFORM set_config('shop.revision_reason', '', true);
  UPDATE sales_order SET status = 'delivering' WHERE id = (SELECT id FROM bc WHERE ten = 'don_giao');
END $$;
