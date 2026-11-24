-- T-309: giữ dòng thành phần cũ cho báo giá tại mốc; chỉ một dòng đang dùng cho mỗi món.
ALTER TABLE menu_combo_item ADD COLUMN retired_at timestamptz;
ALTER TABLE menu_combo_item ADD CONSTRAINT menu_combo_item_retired_after_created_check
  CHECK (retired_at IS NULL OR retired_at >= created_at);
ALTER TABLE menu_combo_item DROP CONSTRAINT menu_combo_item_once_key;
CREATE UNIQUE INDEX menu_combo_item_active_once_key
  ON menu_combo_item (menu_combo_id, menu_item_id) WHERE retired_at IS NULL;
GRANT UPDATE (retired_at) ON menu_combo_item TO shop_app;

CREATE FUNCTION menu_combo_active_item_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM menu_combo_item
                 WHERE menu_combo_id = NEW.menu_combo_id AND retired_at IS NULL) THEN
    RAISE EXCEPTION 'combo % phải có ít nhất một món đang dùng', NEW.menu_combo_id
      USING ERRCODE = 'check_violation', CONSTRAINT = 'menu_combo_active_item_check';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION menu_combo_active_item_guard() FROM PUBLIC;
CREATE CONSTRAINT TRIGGER menu_combo_active_item_check
  AFTER INSERT OR UPDATE ON menu_combo_item
  DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION menu_combo_active_item_guard();

-- Thêm món vào combo đã có là sửa nội dung của combo: ghi người, lý do và hai ảnh cha.
CREATE FUNCTION menu_combo_item_added_revision_capture() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
DECLARE
  v_reason text := NULLIF(btrim(current_setting('shop.revision_reason', true)), '');
  v_parent jsonb;
  v_lines jsonb;
BEGIN
  IF v_reason IS NULL THEN RETURN NULL; END IF;
  SELECT to_jsonb(c) INTO v_parent FROM menu_combo c
  WHERE c.id = NEW.menu_combo_id AND c.created_at < NEW.created_at;
  IF v_parent IS NULL THEN RETURN NULL; END IF;
  SELECT coalesce(jsonb_agg(to_jsonb(x) ORDER BY x.id), '[]'::jsonb) INTO v_lines
  FROM menu_combo_item x WHERE x.menu_combo_id = NEW.menu_combo_id AND x.id < NEW.id;
  INSERT INTO record_revision (target_table_code, target_row, before_image, after_image, reason, person_id)
  VALUES ('menu_combo', NEW.menu_combo_id,
          v_parent || jsonb_build_object('menu_combo_item', v_lines),
          v_parent || jsonb_build_object('menu_combo_item', v_lines || jsonb_build_array(to_jsonb(NEW))),
          v_reason, actor_person_id());
  RETURN NULL;
END $$;
REVOKE ALL ON FUNCTION menu_combo_item_added_revision_capture() FROM PUBLIC;
CREATE TRIGGER menu_combo_item_added_revision_trg AFTER INSERT ON menu_combo_item
  FOR EACH ROW EXECUTE FUNCTION menu_combo_item_added_revision_capture();
