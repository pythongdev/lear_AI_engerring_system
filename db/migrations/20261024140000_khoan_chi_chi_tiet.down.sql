-- Khoá chặn: đường lùi từ chối khi có dữ liệu; không làm mất khoản con, liên kết hay dấu xoá khi lùi.
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM expense_item) OR EXISTS (SELECT 1 FROM expense WHERE expense_item_id IS NOT NULL OR deleted_at IS NOT NULL)
     OR EXISTS (SELECT 1 FROM expense_category WHERE deleted_at IS NOT NULL) THEN
    RAISE EXCEPTION 'T-248: cannot remove expense item or deletion history';
  END IF;
END $$;
ALTER TABLE expense DROP CONSTRAINT expense_item_fkey, DROP CONSTRAINT expense_deleted_pair_check,
  DROP COLUMN expense_item_id, DROP COLUMN deleted_at, DROP COLUMN deleted_by_person_id;
DROP TABLE expense_item;
ALTER TABLE expense_category DROP CONSTRAINT expense_category_deleted_pair_check,
  DROP COLUMN deleted_at, DROP COLUMN deleted_by_person_id;
