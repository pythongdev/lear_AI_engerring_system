-- KC-02 — QC-05, ADR-065: không gỡ cột đang giữ giá trị đã ghi.
-- Khoá trước phép kiểm để không có lần ghi chen vào giữa kiểm và gỡ lược đồ.
LOCK TABLE expense_category, expense_item, supply_item, supply_day_entry, expense IN ACCESS EXCLUSIVE MODE;
DO $$
DECLARE stored_count bigint;
BEGIN
  -- Cờ mặc định false không phải dữ liệu đã ghi; chỉ cờ bật, nối, dấu ngừng và ngày nhập mới chặn đường lùi.
  SELECT (SELECT count(*) FROM expense_category WHERE tracks_supply)
       + (SELECT count(*) FROM expense_item WHERE tracks_supply OR supply_item_id IS NOT NULL)
       + (SELECT count(*) FROM supply_item WHERE deleted_at IS NOT NULL OR deleted_by_person_id IS NOT NULL)
       + (SELECT count(*) FROM expense WHERE received_date IS NOT NULL) INTO stored_count;
  IF stored_count > 0 THEN
    RAISE EXCEPTION 'đường lùi từ chối: cột nối kho và khoản chi đang giữ % dòng có giá trị đã ghi', stored_count;
  END IF;
END $$;

REVOKE UPDATE (received_date) ON expense FROM shop_app;
ALTER TABLE expense DROP COLUMN received_date;

DROP TRIGGER supply_day_entry_supply_item_stopped_check ON supply_day_entry;
DROP FUNCTION supply_day_entry_supply_item_stopped_guard();
DROP TRIGGER supply_item_expense_match_check ON supply_item;
DROP TRIGGER expense_item_supply_match_check ON expense_item;
DROP FUNCTION expense_item_supply_match_guard();

REVOKE UPDATE (deleted_at, deleted_by_person_id) ON supply_item FROM shop_app;
ALTER TABLE supply_item
  DROP CONSTRAINT supply_item_deleted_pair_check,
  DROP CONSTRAINT supply_item_deleted_by_person_fkey,
  DROP COLUMN deleted_by_person_id,
  DROP COLUMN deleted_at;

-- Trả đúng khoá ngoại của T-248: cùng tên, NO ACTION mặc định và không hoãn.
ALTER TABLE expense DROP CONSTRAINT expense_item_fkey,
  ADD CONSTRAINT expense_item_fkey
    FOREIGN KEY (expense_item_id, expense_category_id) REFERENCES expense_item (id, expense_category_id);

REVOKE UPDATE (expense_category_id) ON expense_item FROM shop_app;
ALTER TABLE expense_item
  DROP CONSTRAINT expense_item_supply_link_check,
  DROP CONSTRAINT expense_item_supply_item_key,
  DROP CONSTRAINT expense_item_supply_item_fkey,
  DROP CONSTRAINT expense_item_category_tracks_supply_fkey,
  DROP COLUMN supply_item_id,
  DROP COLUMN tracks_supply;
ALTER TABLE expense_category
  DROP CONSTRAINT expense_category_id_tracks_supply_key,
  DROP COLUMN tracks_supply;
