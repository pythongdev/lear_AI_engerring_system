-- P2A-05 — khoản chi; thiết kế ADR-106 · ADR-074.
-- Ý định và ánh xạ: docs/product/2-db/15-luoc-do-khoan-chi.md.
CREATE TABLE expense_category (
  id bigint GENERATED ALWAYS AS IDENTITY,
  name text COLLATE "vi-x-icu" NOT NULL,
  paid_from_till boolean NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT expense_category_pkey PRIMARY KEY (id),
  CONSTRAINT expense_category_name_key UNIQUE (name),
  CONSTRAINT expense_category_name_not_blank_check CHECK (btrim(name) <> '')
);

CREATE TABLE expense (
  id bigint GENERATED ALWAYS AS IDENTITY,
  expense_category_id bigint NOT NULL,
  amount_vnd bigint NOT NULL,
  paid_date date NOT NULL,
  person_id bigint NOT NULL DEFAULT actor_person_id(),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT expense_pkey PRIMARY KEY (id),
  CONSTRAINT expense_category_fkey FOREIGN KEY (expense_category_id) REFERENCES expense_category (id),
  CONSTRAINT expense_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT expense_positive_amount_check CHECK (amount_vnd > 0)
);

-- QD-52: dùng cơ chế vết nghiêm hiện hành (ADR-092).
CREATE TRIGGER expense_category_record_revision_trg AFTER UPDATE ON expense_category
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
CREATE TRIGGER expense_record_revision_trg AFTER UPDATE ON expense
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();

-- Quyền chèn và đọc có từ mặc định; không cấp xoá (QD-50).
REVOKE UPDATE ON expense_category, expense FROM shop_app;
GRANT UPDATE (name) ON expense_category TO shop_app;
GRANT UPDATE (expense_category_id, amount_vnd, paid_date) ON expense TO shop_app;
