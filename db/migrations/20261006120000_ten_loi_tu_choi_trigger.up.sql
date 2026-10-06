-- P3-04 — lời từ chối do trigger phát ra mang tên theo QC-10 (F-058; ADR-082 điểm 5.4).
-- Thay thân hai hàm của bước 16 (20261005120000_khoa_so_dem_ngay_da_ky): cùng điều kiện, cùng mã lỗi,
-- cùng câu; thêm USING CONSTRAINT để backend đọc luật nào vừa chặn bằng tên, không bằng chữ.
-- Mỗi tên viết thành chuỗi trần ngay ở lệnh RAISE: Gate 1g đọc nó từ file (scripts/check-api-contract.sh)
-- và đòi một dòng trong bảng ánh xạ của hợp đồng (docs/product/3-be/openapi.yaml, x-constraint-errors).
CREATE OR REPLACE FUNCTION cash_day_reconciled_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
DECLARE d date[] := ARRAY[]::date[];
BEGIN
  IF TG_OP = 'TRUNCATE' THEN
    IF EXISTS (SELECT 1 FROM reconciled_day) THEN
      CASE TG_TABLE_NAME
        WHEN 'cash_count' THEN
          RAISE EXCEPTION '%: không được TRUNCATE khi có ngày đã đối soát xong', TG_TABLE_NAME
            USING ERRCODE = 'restrict_violation', CONSTRAINT = 'cash_count_reconciled_day_truncate_check';
        WHEN 'cash_count_line' THEN
          RAISE EXCEPTION '%: không được TRUNCATE khi có ngày đã đối soát xong', TG_TABLE_NAME
            USING ERRCODE = 'restrict_violation', CONSTRAINT = 'cash_count_line_reconciled_day_truncate_check';
        WHEN 'opening_float' THEN
          RAISE EXCEPTION '%: không được TRUNCATE khi có ngày đã đối soát xong', TG_TABLE_NAME
            USING ERRCODE = 'restrict_violation', CONSTRAINT = 'opening_float_reconciled_day_truncate_check';
        WHEN 'opening_float_line' THEN
          RAISE EXCEPTION '%: không được TRUNCATE khi có ngày đã đối soát xong', TG_TABLE_NAME
            USING ERRCODE = 'restrict_violation', CONSTRAINT = 'opening_float_line_reconciled_day_truncate_check';
      END CASE;
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
    CASE TG_TABLE_NAME
      WHEN 'cash_count' THEN
        RAISE EXCEPTION '%: không được ghi số của ngày đã đối soát xong', TG_TABLE_NAME
          USING ERRCODE = 'restrict_violation', CONSTRAINT = 'cash_count_reconciled_day_locked_check';
      WHEN 'cash_count_line' THEN
        RAISE EXCEPTION '%: không được ghi số của ngày đã đối soát xong', TG_TABLE_NAME
          USING ERRCODE = 'restrict_violation', CONSTRAINT = 'cash_count_line_reconciled_day_locked_check';
      WHEN 'opening_float' THEN
        RAISE EXCEPTION '%: không được ghi số của ngày đã đối soát xong', TG_TABLE_NAME
          USING ERRCODE = 'restrict_violation', CONSTRAINT = 'opening_float_reconciled_day_locked_check';
      WHEN 'opening_float_line' THEN
        RAISE EXCEPTION '%: không được ghi số của ngày đã đối soát xong', TG_TABLE_NAME
          USING ERRCODE = 'restrict_violation', CONSTRAINT = 'opening_float_line_reconciled_day_locked_check';
    END CASE;
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
      USING ERRCODE = 'check_violation', CONSTRAINT = 'reconciled_day_cash_count_has_lines_check';
  END IF;
  IF EXISTS (
    SELECT 1 FROM opening_float f WHERE f.sale_date = NEW.sale_date
      AND NOT EXISTS (SELECT 1 FROM opening_float_line l WHERE l.opening_float_id = f.id)
  ) THEN
    RAISE EXCEPTION 'reconciled_day: tiền đầu két ngày % không có dòng mệnh giá', NEW.sale_date
      USING ERRCODE = 'check_violation', CONSTRAINT = 'reconciled_day_opening_float_has_lines_check';
  END IF;
  RETURN NEW;
END $$;
