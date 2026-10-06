-- Đường lùi bước 18 (P3-04; F-058). Trả thân hai hàm về đúng chữ của bước 16: cùng điều kiện, cùng mã
-- lỗi, chỉ mất tên của lời từ chối. Không có khoá chặn "đường lùi từ chối": luật 2 của
-- 07-thu-tu-migration.md chỉ chặn khi đường lùi gỡ chỗ đang cất dữ liệu, mà bước này không dựng bảng,
-- cột hay dòng nào. Hệ quả của việc lùi: backend nhận lại lời từ chối không tên và dịch nó thành lỗi
-- hệ thống chung (ADR-082 điểm 5.3).
CREATE OR REPLACE FUNCTION cash_day_reconciled_guard() RETURNS trigger
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

CREATE OR REPLACE FUNCTION reconciled_day_nonempty_guard() RETURNS trigger
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
