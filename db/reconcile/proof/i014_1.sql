-- kêu: I-014/1 I-002/2
-- Ràng buộc "một khoản một nguồn" bị gỡ; hoá đơn của đơn tới lấy còn đứng tên thêm một phiên bàn
-- đã đóng — khoản ấy nằm ở cả hai nguồn (phiên kia thành ra có số phải trả không từ lượt gọi nào).
ALTER TABLE bill DROP CONSTRAINT bill_one_unit_check;
DO $$ DECLARE s bigint := pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('10')]); BEGIN
  UPDATE table_session SET status = 'serving' WHERE id = s;
  UPDATE table_session SET status = 'awaiting_payment' WHERE id = s;
  UPDATE table_session SET status = 'closed' WHERE id = s;
  UPDATE table_session_member SET session_closed = true WHERE table_session_id = s;
  UPDATE bill SET table_session_id = s WHERE id = (SELECT id FROM bc WHERE ten = 'hoa_don_lay');
END $$;
