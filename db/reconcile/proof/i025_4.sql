-- kêu: I-025/4
DO $$
DECLARE item bigint;
BEGIN
  INSERT INTO supply_item(name) VALUES ('lỗi cài vết tỉ lệ') RETURNING id INTO item;
  PERFORM set_config('shop.actor_person_id', (SELECT id::text FROM person ORDER BY id LIMIT 1), true);
  PERFORM set_config('shop.revision_reason', 'lỗi cài: vết hợp lệ trước khi sửa lén', true);
  UPDATE supply_item SET reminder_ratio = 0.3 WHERE id = item;
  PERFORM pg_temp.bc_vet('supply_item', false);
  UPDATE supply_item SET reminder_ratio = 0.4 WHERE id = item;
  PERFORM pg_temp.bc_vet('supply_item', true);
END $$;
