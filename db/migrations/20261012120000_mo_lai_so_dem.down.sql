-- T-146: khoá chặn trước mọi thay đổi; không xoá lịch sử mở lại hay chuỗi dấu.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM reconciled_day_reopening)
     OR EXISTS (SELECT 1 FROM reconciled_day WHERE previous_reconciled_day_id IS NOT NULL) THEN
    RAISE EXCEPTION 'đường lùi từ chối: đang giữ dòng mở lại hoặc dấu nối đã ghi'
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;

DROP TRIGGER cash_count_line_added_revision_trg ON cash_count_line;
CREATE OR REPLACE FUNCTION record_revision_capture_added_line() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
DECLARE
  v_reason text := NULLIF(btrim(current_setting('shop.revision_reason', true)), '');
  v_parent_table text;
  v_parent_key   text;
  v_parent_id    bigint;
  v_parent       jsonb;
  v_lines        jsonb;
BEGIN
  CASE TG_TABLE_NAME
    WHEN 'order_line'          THEN v_parent_table := 'sales_order';   v_parent_key := 'sales_order_id';
    WHEN 'menu_item_component' THEN v_parent_table := 'menu_item';     v_parent_key := 'menu_item_id';
    WHEN 'opening_float_line'  THEN v_parent_table := 'opening_float'; v_parent_key := 'opening_float_id';
  END CASE;
  v_parent_id := (to_jsonb(NEW) ->> v_parent_key)::bigint;
  EXECUTE format('SELECT to_jsonb(p) FROM %I p WHERE p.id = $1 AND p.created_at < $2', v_parent_table)
    INTO v_parent USING v_parent_id, NEW.created_at;
  -- Dòng tạo cùng lúc với cha là nội dung lúc tạo, không phải lần sửa (bước 17).
  IF v_parent IS NULL THEN
    RETURN NULL;
  END IF;
  IF v_reason IS NULL THEN
    RAISE EXCEPTION '%: thêm dòng vào % % đã có mà giao dịch không khai lý do — mọi lần đổi phải để lại vết',
        TG_TABLE_NAME, v_parent_table, v_parent_id
      USING ERRCODE = 'check_violation', CONSTRAINT = 'record_revision_reason_declared_check',
            HINT = 'khai shop.revision_reason và shop.actor_person_id trong giao dịch trước câu thêm';
  END IF;
  EXECUTE format('SELECT coalesce(jsonb_agg(to_jsonb(c) ORDER BY c.id), ''[]''::jsonb) '
                 'FROM %I c WHERE c.%I = $1 AND c.id < $2', TG_TABLE_NAME, v_parent_key)
    INTO v_lines USING v_parent_id, NEW.id;
  INSERT INTO record_revision (target_table_code, target_row, before_image, after_image, reason,
                               person_id)
  VALUES (v_parent_table, v_parent_id,
          v_parent || jsonb_build_object(TG_TABLE_NAME, v_lines),
          v_parent || jsonb_build_object(TG_TABLE_NAME, v_lines || jsonb_build_array(to_jsonb(NEW))),
          v_reason, actor_person_id());
  RETURN NULL;
END $$;

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

ALTER TABLE reconciled_day
  DROP CONSTRAINT reconciled_day_previous_fkey,
  DROP CONSTRAINT reconciled_day_previous_key;
DROP INDEX reconciled_day_one_per_day_key;
ALTER TABLE reconciled_day
  DROP COLUMN previous_reconciled_day_id,
  ADD CONSTRAINT reconciled_day_one_per_day_key UNIQUE (sale_date);
DROP TABLE reconciled_day_reopening;
ALTER TABLE reconciled_day DROP CONSTRAINT reconciled_day_id_sale_date_key;
