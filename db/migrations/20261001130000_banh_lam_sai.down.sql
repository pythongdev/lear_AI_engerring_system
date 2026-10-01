-- Đường lùi của 20261001130000_banh_lam_sai.up.sql (T-127; ADR-077).
-- KHOÁ CHẶN: có dòng, kể cả ghi chú đã huỷ, thì từ chối trước khi gỡ gì (QD-50).
DO $$
DECLARE n bigint;
BEGIN
  SELECT count(*) INTO n FROM wrong_make_note;
  IF n > 0 THEN
    RAISE EXCEPTION 'đường lùi từ chối: wrong_make_note đang giữ % giá trị đã ghi — gỡ nó là xoá dữ liệu', n
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;

DROP TRIGGER wrong_make_note_record_revision_trg ON wrong_make_note;
DROP TABLE wrong_make_note;
ALTER TABLE station_job DROP CONSTRAINT station_job_id_order_key;
ALTER TABLE sales_order DROP COLUMN id_if_cancelled;
