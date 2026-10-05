-- T-134 — khoá số đếm và tiền đầu két của ngày đã ký (ADR-080; F-056 · F-057).
-- Ý định và ánh xạ I-021 · I-014: docs/product/2-db/04-luoc-do-duong-tien.md §7.
CREATE FUNCTION cash_day_reconciled_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
DECLARE d date[] := ARRAY[]::date[];
BEGIN
  IF TG_OP = 'TRUNCATE' THEN
    IF EXISTS (SELECT 1 FROM reconciled_day) THEN
      RAISE EXCEPTION '%: không được TRUNCATE khi có ngày đã đối soát xong', TG_TABLE_NAME
        USING ERRCODE = 'restrict_violation';
    END IF;
    RETURN NULL;
  END IF;

  -- Xét cả bản trước lẫn bản sau: không dời dòng ra khỏi hay vào một ngày đã ký.
  IF TG_TABLE_NAME IN ('cash_count', 'opening_float') THEN
    IF TG_OP <> 'INSERT' THEN d := array_append(d, OLD.sale_date); END IF;
    IF TG_OP <> 'DELETE' THEN d := array_append(d, NEW.sale_date); END IF;
  ELSIF TG_TABLE_NAME = 'cash_count_line' THEN
    IF TG_OP <> 'INSERT' THEN
      d := array_append(d, (SELECT sale_date FROM cash_count WHERE id = OLD.cash_count_id));
    END IF;
    IF TG_OP <> 'DELETE' THEN
      d := array_append(d, (SELECT sale_date FROM cash_count WHERE id = NEW.cash_count_id));
    END IF;
  ELSIF TG_TABLE_NAME = 'opening_float_line' THEN
    IF TG_OP <> 'INSERT' THEN
      d := array_append(d, (SELECT sale_date FROM opening_float WHERE id = OLD.opening_float_id));
    END IF;
    IF TG_OP <> 'DELETE' THEN
      d := array_append(d, (SELECT sale_date FROM opening_float WHERE id = NEW.opening_float_id));
    END IF;
  END IF;

  IF EXISTS (SELECT 1 FROM reconciled_day WHERE sale_date = ANY (d)) THEN
    RAISE EXCEPTION '%: không được ghi số của ngày đã đối soát xong', TG_TABLE_NAME
      USING ERRCODE = 'restrict_violation';
  END IF;
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION cash_day_reconciled_guard() FROM PUBLIC;

-- Thiếu dòng đầu thì để khoá ngoại sẵn có từ chối; có dòng đầu mà rỗng thì chặn ở đây.
-- Có dòng mệnh giá mang số 0 vẫn là đã khai số; không đòi phép trừ két ra 0 (U-073).
CREATE FUNCTION reconciled_day_nonempty_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM cash_count c WHERE c.sale_date = NEW.sale_date
      AND NOT EXISTS (SELECT 1 FROM cash_count_line l WHERE l.cash_count_id = c.id)
  ) THEN
    RAISE EXCEPTION 'reconciled_day: số đếm ngày % không có dòng mệnh giá', NEW.sale_date
      USING ERRCODE = 'check_violation';
  END IF;
  IF EXISTS (
    SELECT 1 FROM opening_float f WHERE f.sale_date = NEW.sale_date
      AND NOT EXISTS (SELECT 1 FROM opening_float_line l WHERE l.opening_float_id = f.id)
  ) THEN
    RAISE EXCEPTION 'reconciled_day: tiền đầu két ngày % không có dòng mệnh giá', NEW.sale_date
      USING ERRCODE = 'check_violation';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION reconciled_day_nonempty_guard() FROM PUBLIC;

CREATE TRIGGER cash_count_reconciled_guard_trg
  BEFORE INSERT OR UPDATE OR DELETE ON cash_count
  FOR EACH ROW EXECUTE FUNCTION cash_day_reconciled_guard();
CREATE TRIGGER cash_count_reconciled_truncate_trg
  BEFORE TRUNCATE ON cash_count
  FOR EACH STATEMENT EXECUTE FUNCTION cash_day_reconciled_guard();

CREATE TRIGGER cash_count_line_reconciled_guard_trg
  BEFORE INSERT OR UPDATE OR DELETE ON cash_count_line
  FOR EACH ROW EXECUTE FUNCTION cash_day_reconciled_guard();
CREATE TRIGGER cash_count_line_reconciled_truncate_trg
  BEFORE TRUNCATE ON cash_count_line
  FOR EACH STATEMENT EXECUTE FUNCTION cash_day_reconciled_guard();

CREATE TRIGGER opening_float_reconciled_guard_trg
  BEFORE INSERT OR UPDATE OR DELETE ON opening_float
  FOR EACH ROW EXECUTE FUNCTION cash_day_reconciled_guard();
CREATE TRIGGER opening_float_reconciled_truncate_trg
  BEFORE TRUNCATE ON opening_float
  FOR EACH STATEMENT EXECUTE FUNCTION cash_day_reconciled_guard();

CREATE TRIGGER opening_float_line_reconciled_guard_trg
  BEFORE INSERT OR UPDATE OR DELETE ON opening_float_line
  FOR EACH ROW EXECUTE FUNCTION cash_day_reconciled_guard();
CREATE TRIGGER opening_float_line_reconciled_truncate_trg
  BEFORE TRUNCATE ON opening_float_line
  FOR EACH STATEMENT EXECUTE FUNCTION cash_day_reconciled_guard();

CREATE TRIGGER reconciled_day_nonempty_guard_trg
  BEFORE INSERT OR UPDATE OF sale_date ON reconciled_day
  FOR EACH ROW EXECUTE FUNCTION reconciled_day_nonempty_guard();
