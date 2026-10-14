-- Đường lùi P2A-05; chỉ gỡ hai bảng còn rỗng (QC-05, ADR-065).
-- KHOÁ CHẶN: có dữ liệu thì dùng migration mới đi tới, không xoá dữ liệu đã ghi.
DO $$
DECLARE target text; n bigint;
BEGIN
  FOREACH target IN ARRAY ARRAY['expense', 'expense_category'] LOOP
    EXECUTE format('SELECT count(*) FROM %I', target) INTO n;
    IF n > 0 THEN
      RAISE EXCEPTION 'đường lùi từ chối: % đang giữ % giá trị đã ghi — gỡ nó là xoá dữ liệu', target, n
        USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
    END IF;
  END LOOP;
END $$;
DROP TRIGGER expense_record_revision_trg ON expense;
DROP TRIGGER expense_category_record_revision_trg ON expense_category;
DROP TABLE expense;
DROP TABLE expense_category;
