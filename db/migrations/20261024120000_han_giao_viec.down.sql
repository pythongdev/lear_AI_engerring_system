-- Không cho đường lùi làm mất hạn đã nhập (ADR-065).
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM assigned_task WHERE due_at IS NOT NULL) THEN
    RAISE EXCEPTION 'đường lùi từ chối: assigned_task đang giữ hạn hoàn thành'
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;
REVOKE UPDATE (due_at) ON assigned_task FROM shop_app;
ALTER TABLE assigned_task DROP COLUMN due_at;
