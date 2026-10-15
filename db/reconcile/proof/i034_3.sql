-- kêu: I-034/3 I-006/2
DO $$ BEGIN
  PERFORM set_config('shop.actor_person_id', pg_temp.bc_nguoi('Chủ quán')::text, true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài I-034/3', true);
END $$;
-- Vượt khoá ngoại về cha (tắt mọi trigger của bảng) để mô phỏng một suất con khác dấu đem về với dòng combo —
-- dấu đem về trên đơn tới lấy cũng là suất rời phiên (I-006/2).
ALTER TABLE order_line DISABLE TRIGGER ALL;
UPDATE order_line SET is_takeaway = true
WHERE id = (SELECT min(id) FROM order_line WHERE parent_order_line_id = (SELECT id FROM bc WHERE ten = 'dong_combo'));
ALTER TABLE order_line ENABLE TRIGGER ALL;
