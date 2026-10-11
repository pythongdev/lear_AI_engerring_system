-- QC-05: không gỡ cột đang giữ dữ liệu đã ghi.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM bill WHERE debt_note IS NOT NULL)
     OR EXISTS (SELECT 1 FROM reconciled_day WHERE gap_vnd <> 0 OR gap_explanation IS NOT NULL) THEN
    RAISE EXCEPTION 'đường lùi từ chối: ghi chú nợ hoặc số lệch/giải thích đang có dữ liệu'
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;
ALTER TABLE reconciled_day
  DROP CONSTRAINT reconciled_day_gap_explained_check,
  DROP COLUMN gap_explanation,
  DROP COLUMN gap_vnd;
ALTER TABLE bill
  DROP CONSTRAINT bill_debt_note_only_with_debt_check,
  DROP CONSTRAINT bill_standalone_debt_note_check,
  DROP COLUMN debt_note;
