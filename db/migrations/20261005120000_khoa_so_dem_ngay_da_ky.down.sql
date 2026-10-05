-- Đường lùi bước 16 (T-134; ADR-080). Khoá chặn chạy trước khi gỡ bất kỳ trigger nào.
DO $$
DECLARE n bigint;
BEGIN
  SELECT count(*) INTO n FROM reconciled_day;
  IF n > 0 THEN
    RAISE EXCEPTION 'đường lùi từ chối: reconciled_day đang giữ % ngày đã ký — gỡ khoá là mở lại sửa số đã ký', n
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;

DROP TRIGGER reconciled_day_nonempty_guard_trg ON reconciled_day;
DROP TRIGGER opening_float_line_reconciled_truncate_trg ON opening_float_line;
DROP TRIGGER opening_float_line_reconciled_guard_trg ON opening_float_line;
DROP TRIGGER opening_float_reconciled_truncate_trg ON opening_float;
DROP TRIGGER opening_float_reconciled_guard_trg ON opening_float;
DROP TRIGGER cash_count_line_reconciled_truncate_trg ON cash_count_line;
DROP TRIGGER cash_count_line_reconciled_guard_trg ON cash_count_line;
DROP TRIGGER cash_count_reconciled_truncate_trg ON cash_count;
DROP TRIGGER cash_count_reconciled_guard_trg ON cash_count;
DROP FUNCTION reconciled_day_nonempty_guard();
DROP FUNCTION cash_day_reconciled_guard();
