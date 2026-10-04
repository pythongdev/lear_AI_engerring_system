-- Đường lùi của 20261001150000_dem_ket_doi_soat.up.sql (T-133; ADR-079).
-- KHOÁ CHẶN: một trong ba bảng có dòng thì từ chối trước khi gỡ gì (QD-50).
DO $$
DECLARE n bigint;
BEGIN
  SELECT (SELECT count(*) FROM reconciled_day) + (SELECT count(*) FROM cash_count_line)
       + (SELECT count(*) FROM cash_count) INTO n;
  IF n > 0 THEN
    RAISE EXCEPTION 'đường lùi từ chối: reconciled_day · cash_count_line · cash_count đang giữ % giá trị đã ghi — gỡ nó là xoá dữ liệu', n
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;

DROP TRIGGER reconciled_day_record_revision_trg ON reconciled_day;
DROP TRIGGER cash_count_line_record_revision_trg ON cash_count_line;
DROP TRIGGER cash_count_record_revision_trg ON cash_count;
DROP TABLE reconciled_day;
DROP TABLE cash_count_line;
DROP TABLE cash_count;
