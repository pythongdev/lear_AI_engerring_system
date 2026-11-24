-- đường lùi từ chối khi đã rút thành phần; không làm mất lịch sử combo.
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM menu_combo_item WHERE retired_at IS NOT NULL) THEN
    RAISE EXCEPTION 'menu_combo_item_retired_in_use';
  END IF;
END $$;
DROP TRIGGER menu_combo_item_added_revision_trg ON menu_combo_item;
DROP FUNCTION menu_combo_item_added_revision_capture();
DROP TRIGGER menu_combo_active_item_check ON menu_combo_item;
DROP FUNCTION menu_combo_active_item_guard();
REVOKE UPDATE (retired_at) ON menu_combo_item FROM shop_app;
DROP INDEX menu_combo_item_active_once_key;
ALTER TABLE menu_combo_item ADD CONSTRAINT menu_combo_item_once_key UNIQUE (menu_combo_id, menu_item_id);
ALTER TABLE menu_combo_item DROP CONSTRAINT menu_combo_item_retired_after_created_check;
ALTER TABLE menu_combo_item DROP COLUMN retired_at;
