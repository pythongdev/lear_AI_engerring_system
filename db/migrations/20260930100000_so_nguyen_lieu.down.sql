-- Đường lùi của 20260930100000_so_nguyen_lieu.up.sql (P2A-02 — sổ nguyên liệu).
-- Thứ tự dựng và luật lùi: docs/product/2-db/07-thu-tu-migration.md · docs/decisions.md ADR-065.
--
-- KHOÁ CHẶN: đường lùi chỉ gỡ chỗ cất còn RỖNG. Bảng sắp gỡ có dòng ⇒ từ chối,
-- không gỡ gì (cả file là một giao dịch, QC-05). Lùi trên dữ liệu đã ghi bằng migration mới đi tới.
DO $$
DECLARE
  target text;
  n      bigint;
BEGIN
  FOREACH target IN ARRAY ARRAY['supply_day_entry', 'supply_item'] LOOP
    EXECUTE format('SELECT count(*) FROM %I', target) INTO n;
    IF n > 0 THEN
      RAISE EXCEPTION 'đường lùi từ chối: % đang giữ % giá trị đã ghi — gỡ nó là xoá dữ liệu', target, n
        USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
    END IF;
  END LOOP;
END $$;

DROP TRIGGER supply_day_entry_record_revision_trg ON supply_day_entry;
DROP TRIGGER supply_item_record_revision_trg ON supply_item;
DROP TABLE supply_day_entry;
DROP TABLE supply_item;
