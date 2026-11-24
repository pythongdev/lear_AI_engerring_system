-- T-309: không thể rút món cuối cùng, dù ràng buộc kiểm ở cuối giao dịch.
DO $$
DECLARE
  actor_id bigint;
  item_id bigint;
  combo_id bigint;
BEGIN
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ kiểm combo còn món', true) RETURNING id INTO actor_id;
  PERFORM set_config('shop.actor_person_id', actor_id::text, true);
  PERFORM set_config('shop.revision_reason', 'test combo còn món', true);
  INSERT INTO menu_item (name) VALUES ('test-món giữ combo') RETURNING id INTO item_id;
  INSERT INTO menu_combo (name, price_vnd) VALUES ('test-combo giữ món', 10000) RETURNING id INTO combo_id;
  INSERT INTO menu_combo_item (menu_combo_id, menu_item_id, quantity) VALUES (combo_id, item_id, 1);
  BEGIN
    UPDATE menu_combo_item SET retired_at = now() WHERE menu_combo_id = combo_id;
    SET CONSTRAINTS menu_combo_active_item_check IMMEDIATE;
    RAISE EXCEPTION 'I-032: cho rút món cuối cùng khỏi combo';
  EXCEPTION WHEN check_violation THEN
    IF SQLERRM LIKE 'I-032:%' THEN RAISE; END IF;
  END;
  IF (SELECT count(*) FROM menu_combo_item WHERE menu_combo_id = combo_id AND retired_at IS NULL) <> 1 THEN
    RAISE EXCEPTION 'I-032: lời từ chối không giữ món đang dùng';
  END IF;
END $$;
