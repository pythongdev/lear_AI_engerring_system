-- kêu: I-018/1
-- 2026-11-16 (T-339): gỡ ràng buộc người sửa, rồi xoá người trên một vết tạm ứng của ngày mẫu.
-- staff_advance không được miễn; chỉ đổi người trên vết, không đổi khoản tiền hay hai bản chụp,
-- nên suy ra chỉ I-018/1 kêu. Mất ràng buộc cũng khiến các vết người rỗng hợp lệ của ngày mẫu kêu.
ALTER TABLE record_revision DROP CONSTRAINT record_revision_person_check;
DO $$
BEGIN
  UPDATE record_revision SET person_id = NULL
  WHERE id = (
    SELECT min(r.id) FROM record_revision r
    JOIN staff_advance a ON a.id = r.target_row
    WHERE r.target_table_code = 'staff_advance' AND r.person_id IS NOT NULL
      AND a.paid_date = pg_temp.bc_ngay()
  );
  IF NOT FOUND THEN
    RAISE EXCEPTION 'lỗi cài T-339: ngày mẫu thiếu vết tạm ứng có người sửa';
  END IF;
END $$;
