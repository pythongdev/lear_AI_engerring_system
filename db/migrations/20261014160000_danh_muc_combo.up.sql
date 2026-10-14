-- P2A-13 — I-032 · YC-37, ADR-108. Ý định: docs/product/2-db/18-luoc-do-danh-muc-combo.md.
CREATE TABLE menu_category (
  id bigint GENERATED ALWAYS AS IDENTITY,
  name text COLLATE "vi-x-icu" NOT NULL,
  person_id bigint NOT NULL DEFAULT actor_person_id(),
  created_at timestamptz NOT NULL DEFAULT now(),
  hidden_at timestamptz,
  hidden_by_person_id bigint,
  CONSTRAINT menu_category_pkey PRIMARY KEY (id),
  CONSTRAINT menu_category_name_not_blank_check CHECK (btrim(name) <> ''),
  CONSTRAINT menu_category_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT menu_category_hidden_by_person_fkey FOREIGN KEY (hidden_by_person_id) REFERENCES person (id),
  CONSTRAINT menu_category_hidden_by_iff_hidden_check CHECK ((hidden_at IS NULL) = (hidden_by_person_id IS NULL)),
  CONSTRAINT menu_category_hidden_after_created_check CHECK (hidden_at IS NULL OR hidden_at >= created_at)
);

CREATE TABLE menu_item_category (
  id bigint GENERATED ALWAYS AS IDENTITY,
  menu_item_id bigint NOT NULL,
  menu_category_id bigint NOT NULL,
  person_id bigint NOT NULL DEFAULT actor_person_id(),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT menu_item_category_pkey PRIMARY KEY (id),
  CONSTRAINT menu_item_category_menu_item_fkey FOREIGN KEY (menu_item_id) REFERENCES menu_item (id),
  CONSTRAINT menu_item_category_menu_category_fkey FOREIGN KEY (menu_category_id) REFERENCES menu_category (id),
  CONSTRAINT menu_item_category_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT menu_item_category_menu_item_key UNIQUE (menu_item_id)
);

CREATE TABLE menu_combo (
  id bigint GENERATED ALWAYS AS IDENTITY,
  name text COLLATE "vi-x-icu" NOT NULL,
  price_vnd bigint NOT NULL,
  person_id bigint NOT NULL DEFAULT actor_person_id(),
  created_at timestamptz NOT NULL DEFAULT now(),
  hidden_at timestamptz,
  hidden_by_person_id bigint,
  CONSTRAINT menu_combo_pkey PRIMARY KEY (id),
  CONSTRAINT menu_combo_name_not_blank_check CHECK (btrim(name) <> ''),
  CONSTRAINT menu_combo_price_positive_check CHECK (price_vnd > 0),
  CONSTRAINT menu_combo_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT menu_combo_hidden_by_person_fkey FOREIGN KEY (hidden_by_person_id) REFERENCES person (id),
  CONSTRAINT menu_combo_hidden_by_iff_hidden_check CHECK ((hidden_at IS NULL) = (hidden_by_person_id IS NULL)),
  CONSTRAINT menu_combo_hidden_after_created_check CHECK (hidden_at IS NULL OR hidden_at >= created_at)
);

CREATE TABLE menu_combo_item (
  id bigint GENERATED ALWAYS AS IDENTITY,
  menu_combo_id bigint NOT NULL,
  menu_item_id bigint NOT NULL,
  quantity integer NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT menu_combo_item_pkey PRIMARY KEY (id),
  CONSTRAINT menu_combo_item_menu_combo_fkey FOREIGN KEY (menu_combo_id) REFERENCES menu_combo (id),
  CONSTRAINT menu_combo_item_menu_item_fkey FOREIGN KEY (menu_item_id) REFERENCES menu_item (id),
  CONSTRAINT menu_combo_item_quantity_positive_check CHECK (quantity > 0),
  CONSTRAINT menu_combo_item_once_key UNIQUE (menu_combo_id, menu_item_id)
);

CREATE UNIQUE INDEX menu_category_active_name_key ON menu_category (name) WHERE hidden_at IS NULL;

-- ADR-108: kiểm cha còn tồn tại khi chạy sự kiện hoãn, sau khi đã chèn các món.
CREATE FUNCTION menu_combo_has_item_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM menu_combo WHERE id = NEW.id)
     AND NOT EXISTS (SELECT 1 FROM menu_combo_item WHERE menu_combo_id = NEW.id) THEN
    RAISE EXCEPTION 'combo % phải có ít nhất một món', NEW.id
      USING ERRCODE = 'check_violation', CONSTRAINT = 'menu_combo_has_item_check';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION menu_combo_has_item_guard() FROM PUBLIC;
CREATE CONSTRAINT TRIGGER menu_combo_has_item_check AFTER INSERT ON menu_combo
  DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION menu_combo_has_item_guard();

-- QD-50/51/52: quyền mặc định không xoá, khoá ngoại không dây chuyền, sửa có vết.
CREATE TRIGGER menu_category_record_revision_trg AFTER UPDATE ON menu_category
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE ON menu_category FROM shop_app;
GRANT UPDATE (name, hidden_at, hidden_by_person_id) ON menu_category TO shop_app;
CREATE TRIGGER menu_item_category_record_revision_trg AFTER UPDATE ON menu_item_category
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE ON menu_item_category FROM shop_app;
GRANT UPDATE (menu_category_id) ON menu_item_category TO shop_app;
CREATE TRIGGER menu_combo_record_revision_trg AFTER UPDATE ON menu_combo
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE ON menu_combo FROM shop_app;
GRANT UPDATE (name, price_vnd, hidden_at, hidden_by_person_id) ON menu_combo TO shop_app;
CREATE TRIGGER menu_combo_item_record_revision_trg AFTER UPDATE ON menu_combo_item
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE ON menu_combo_item FROM shop_app;
GRANT UPDATE (quantity) ON menu_combo_item TO shop_app;
