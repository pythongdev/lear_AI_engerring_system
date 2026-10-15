-- T-193 — I-034, ADR-117 điểm 1 · 2 · 3. Ý định: docs/product/2-db/20-luoc-do-ban-combo.md.
-- File này thắng về tên · kiểu · ràng buộc (docs/decisions.md ADR-053 luật 2).
-- Không một con giá nào ở đây: mức do chủ quán đặt qua cửa (T-194).

-- ---------------------------------------------------------------------------
-- Mức phụ thu theo món của combo (ADR-117 điểm 1). Không có dòng ⇒ hàm giá cộng 0đ (lời đóng U-096).
-- ---------------------------------------------------------------------------
CREATE TABLE menu_combo_item_option_surcharge (
  id                 bigint GENERATED ALWAYS AS IDENTITY,
  menu_combo_item_id bigint NOT NULL,
  menu_option_id     bigint NOT NULL,
  surcharge_vnd      bigint NOT NULL,
  person_id          bigint NOT NULL DEFAULT actor_person_id(),
  created_at         timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT menu_combo_item_option_surcharge_pkey PRIMARY KEY (id),
  CONSTRAINT menu_combo_item_option_surcharge_menu_combo_item_fkey
    FOREIGN KEY (menu_combo_item_id) REFERENCES menu_combo_item (id),
  CONSTRAINT menu_combo_item_option_surcharge_menu_option_fkey
    FOREIGN KEY (menu_option_id) REFERENCES menu_option (id),
  CONSTRAINT menu_combo_item_option_surcharge_person_fkey
    FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT menu_combo_item_option_surcharge_once_key UNIQUE (menu_combo_item_id, menu_option_id),
  CONSTRAINT menu_combo_item_option_surcharge_non_negative_check CHECK (surcharge_vnd >= 0)
);

-- Lựa chọn phải thuộc một nhóm mà món của dòng combo mang. Món hay lựa chọn không có thật thì để khoá ngoại nói.
CREATE FUNCTION menu_combo_item_option_surcharge_option_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM menu_combo_item WHERE id = NEW.menu_combo_item_id)
     AND EXISTS (SELECT 1 FROM menu_option WHERE id = NEW.menu_option_id)
     AND NOT EXISTS (
       SELECT 1 FROM menu_combo_item ci
       JOIN menu_item_option_group g ON g.menu_item_id = ci.menu_item_id
       JOIN menu_option o ON o.option_group_id = g.option_group_id
       WHERE ci.id = NEW.menu_combo_item_id AND o.id = NEW.menu_option_id) THEN
    RAISE EXCEPTION 'lựa chọn % không thuộc nhóm nào mà món của dòng combo % mang', NEW.menu_option_id, NEW.menu_combo_item_id
      USING ERRCODE = 'check_violation', CONSTRAINT = 'menu_combo_item_option_surcharge_option_of_item_check';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION menu_combo_item_option_surcharge_option_guard() FROM PUBLIC;
CREATE TRIGGER menu_combo_item_option_surcharge_option_of_item_check BEFORE INSERT ON menu_combo_item_option_surcharge
  FOR EACH ROW EXECUTE FUNCTION menu_combo_item_option_surcharge_option_guard();

-- QD-50/51/52: không xoá, khoá ngoại không dây chuyền, sửa có vết; vai ghi chỉ sửa mức.
CREATE TRIGGER menu_combo_item_option_surcharge_record_revision_trg AFTER UPDATE ON menu_combo_item_option_surcharge
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE ON menu_combo_item_option_surcharge FROM shop_app;
GRANT UPDATE (surcharge_vnd) ON menu_combo_item_option_surcharge TO shop_app;

-- ---------------------------------------------------------------------------
-- Combo trên đơn: dòng combo + dòng suất con trong chính order_line (ADR-117 điểm 2 · 3).
-- Tổng đơn vẫn là Σ line_total_vnd: dòng combo mang giá combo, dòng con mang mức của một suất.
-- ---------------------------------------------------------------------------
ALTER TABLE order_line
  ALTER COLUMN menu_item_id DROP NOT NULL,
  ALTER COLUMN component_count DROP NOT NULL,
  ADD COLUMN menu_combo_id bigint,
  ADD COLUMN parent_order_line_id bigint,
  -- Hai cột sinh ra chỉ để khoá ngoại về cha bắt "cha là dòng combo"; dòng không cha ⇒ NULL, khoá ngoại không xét.
  ADD COLUMN is_combo_line boolean GENERATED ALWAYS AS (menu_combo_id IS NOT NULL) STORED,
  ADD COLUMN parent_is_combo_line boolean
    GENERATED ALWAYS AS (CASE WHEN parent_order_line_id IS NOT NULL THEN true END) STORED,
  ADD CONSTRAINT order_line_menu_combo_fkey FOREIGN KEY (menu_combo_id) REFERENCES menu_combo (id),
  ADD CONSTRAINT order_line_item_xor_combo_check CHECK ((menu_item_id IS NULL) <> (menu_combo_id IS NULL)),
  ADD CONSTRAINT order_line_item_has_component_count_check
    CHECK (menu_item_id IS NULL OR component_count IS NOT NULL),
  ADD CONSTRAINT order_line_combo_line_shape_check
    CHECK (menu_combo_id IS NULL OR (component_count IS NULL AND parent_order_line_id IS NULL)),
  -- Đích của khoá ngoại về cha: cùng đơn, là dòng combo, cùng dấu đem về.
  ADD CONSTRAINT order_line_combo_parent_key UNIQUE (id, sales_order_id, is_combo_line, is_takeaway),
  ADD CONSTRAINT order_line_combo_parent_fkey
    FOREIGN KEY (parent_order_line_id, sales_order_id, parent_is_combo_line, is_takeaway)
    REFERENCES order_line (id, sales_order_id, is_combo_line, is_takeaway);

-- Mỗi dòng combo có ít nhất một dòng con — kiểm lúc giao dịch kết thúc, khi dòng con đã chèn.
CREATE FUNCTION order_line_combo_has_child_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM order_line WHERE id = NEW.id)
     AND NOT EXISTS (SELECT 1 FROM order_line WHERE parent_order_line_id = NEW.id) THEN
    RAISE EXCEPTION 'dòng combo % phải có ít nhất một dòng suất con', NEW.id
      USING ERRCODE = 'check_violation', CONSTRAINT = 'order_line_combo_has_child_check';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION order_line_combo_has_child_guard() FROM PUBLIC;
CREATE CONSTRAINT TRIGGER order_line_combo_has_child_check AFTER INSERT ON order_line
  DEFERRABLE INITIALLY DEFERRED FOR EACH ROW WHEN (NEW.menu_combo_id IS NOT NULL)
  EXECUTE FUNCTION order_line_combo_has_child_guard();

-- Dòng combo không mang lựa chọn: lựa chọn là của từng suất.
CREATE FUNCTION order_line_option_item_line_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM order_line WHERE id = NEW.order_line_id AND menu_combo_id IS NOT NULL) THEN
    RAISE EXCEPTION 'dòng combo % không mang lựa chọn — lựa chọn thuộc dòng suất con', NEW.order_line_id
      USING ERRCODE = 'check_violation', CONSTRAINT = 'order_line_option_item_line_check';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION order_line_option_item_line_guard() FROM PUBLIC;
CREATE TRIGGER order_line_option_item_line_check BEFORE INSERT ON order_line_option
  FOR EACH ROW EXECUTE FUNCTION order_line_option_item_line_guard();
