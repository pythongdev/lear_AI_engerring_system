-- P2A-02 — lát sổ nguyên liệu: danh mục hàng mua vào và từng con số ngày do người nhập.
-- Ý định, lý do và ánh xạ I-0xx/YC-xx: docs/product/2-db/12-luoc-do-nguyen-lieu.md.
-- File này thắng về tên · kiểu · ràng buộc (docs/decisions.md ADR-053 luật 2).
-- Thiết kế: ADR-071; quy ước: 01-quy-uoc-du-lieu.md (QD-XX) · 10-quy-uoc-code.md (QC-XX).

CREATE TABLE supply_item (
  id            bigint GENERATED ALWAYS AS IDENTITY,
  name          text COLLATE "vi-x-icu" NOT NULL,
  purchase_unit text COLLATE "vi-x-icu",
  created_at    timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT supply_item_pkey PRIMARY KEY (id),
  CONSTRAINT supply_item_name_key UNIQUE (name),
  CONSTRAINT supply_item_name_not_blank_check CHECK (btrim(name) <> ''),
  CONSTRAINT supply_item_purchase_unit_not_blank_check CHECK (btrim(purchase_unit) <> '')
);

-- Một dòng là một con số: người nhập và lúc gõ thuộc riêng từng con số của ngày người khai.
CREATE TABLE supply_day_entry (
  id              bigint GENERATED ALWAYS AS IDENTITY,
  supply_item_id   bigint NOT NULL,
  entry_date      date NOT NULL,
  kind_code       text NOT NULL,
  entered_measure numeric NOT NULL,
  person_id       bigint NOT NULL DEFAULT actor_person_id(),
  created_at      timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT supply_day_entry_pkey PRIMARY KEY (id),
  CONSTRAINT supply_day_entry_supply_item_fkey FOREIGN KEY (supply_item_id) REFERENCES supply_item (id),
  CONSTRAINT supply_day_entry_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT supply_day_entry_one_kind_per_item_day_key UNIQUE (supply_item_id, entry_date, kind_code),
  CONSTRAINT supply_day_entry_kind_code_check CHECK (kind_code IN ('purchased', 'used')),
  CONSTRAINT supply_day_entry_measure_nonnegative_finite_check
    CHECK (entered_measure >= 0 AND entered_measure < 'Infinity'::numeric)
);

-- Dùng lại chế độ mềm của P2-08 (F-046), không dựng đường ghi vết thứ hai.
CREATE TRIGGER supply_item_record_revision_trg AFTER UPDATE ON supply_item
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
CREATE TRIGGER supply_day_entry_record_revision_trg AFTER UPDATE ON supply_day_entry
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
