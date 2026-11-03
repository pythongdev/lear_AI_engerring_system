-- T-248: khoản con và xoá mềm có vết; không sửa dữ liệu cũ.
ALTER TABLE expense_category ADD COLUMN deleted_at timestamptz;
ALTER TABLE expense_category ADD COLUMN deleted_by_person_id bigint;
ALTER TABLE expense_category ADD CONSTRAINT expense_category_deleted_by_person_fkey FOREIGN KEY (deleted_by_person_id) REFERENCES person(id);
ALTER TABLE expense_category ADD CONSTRAINT expense_category_deleted_pair_check CHECK ((deleted_at IS NULL) = (deleted_by_person_id IS NULL));
CREATE TABLE expense_item (
  id bigint GENERATED ALWAYS AS IDENTITY,
  CONSTRAINT expense_item_pkey PRIMARY KEY (id),
  expense_category_id bigint NOT NULL,
  CONSTRAINT expense_item_category_fkey FOREIGN KEY (expense_category_id) REFERENCES expense_category(id),
  name text COLLATE "vi-x-icu" NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  deleted_by_person_id bigint,
  CONSTRAINT expense_item_deleted_by_person_fkey FOREIGN KEY (deleted_by_person_id) REFERENCES person(id),
  CONSTRAINT expense_item_name_not_blank_check CHECK (btrim(name) <> ''),
  CONSTRAINT expense_item_name_key UNIQUE (expense_category_id, name),
  CONSTRAINT expense_item_category_key UNIQUE (id, expense_category_id),
  CONSTRAINT expense_item_deleted_pair_check CHECK ((deleted_at IS NULL) = (deleted_by_person_id IS NULL))
);
ALTER TABLE expense ADD COLUMN expense_item_id bigint;
ALTER TABLE expense ADD COLUMN deleted_at timestamptz;
ALTER TABLE expense ADD COLUMN deleted_by_person_id bigint;
ALTER TABLE expense ADD CONSTRAINT expense_deleted_by_person_fkey FOREIGN KEY (deleted_by_person_id) REFERENCES person(id);
ALTER TABLE expense ADD CONSTRAINT expense_item_fkey FOREIGN KEY (expense_item_id, expense_category_id) REFERENCES expense_item(id, expense_category_id);
ALTER TABLE expense ADD CONSTRAINT expense_deleted_pair_check CHECK ((deleted_at IS NULL) = (deleted_by_person_id IS NULL));
CREATE TRIGGER expense_item_record_revision_trg AFTER UPDATE ON expense_item
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE ON expense_item FROM shop_app;
GRANT UPDATE (name, deleted_at, deleted_by_person_id) ON expense_item TO shop_app;
GRANT UPDATE (deleted_at, deleted_by_person_id) ON expense_category TO shop_app;
GRANT UPDATE (expense_item_id, deleted_at, deleted_by_person_id) ON expense TO shop_app;
