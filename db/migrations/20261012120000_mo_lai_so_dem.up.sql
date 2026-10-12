-- T-146, ADR-096 — mở lại số đếm, giữ chuỗi dấu và khoá các cửa tiền khác.
ALTER TABLE reconciled_day
  ADD CONSTRAINT reconciled_day_id_sale_date_key UNIQUE (id, sale_date);

CREATE TABLE reconciled_day_reopening (
  id bigint GENERATED ALWAYS AS IDENTITY,
  reconciled_day_id bigint NOT NULL,
  sale_date date NOT NULL,
  reason text COLLATE "vi-x-icu" NOT NULL,
  person_id bigint NOT NULL DEFAULT actor_person_id(),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT reconciled_day_reopening_pkey PRIMARY KEY (id),
  CONSTRAINT reconciled_day_reopening_once_key UNIQUE (reconciled_day_id),
  CONSTRAINT reconciled_day_reopening_id_sale_date_key UNIQUE (reconciled_day_id, sale_date),
  CONSTRAINT reconciled_day_reopening_day_fkey FOREIGN KEY (reconciled_day_id, sale_date)
    REFERENCES reconciled_day (id, sale_date),
  CONSTRAINT reconciled_day_reopening_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT reconciled_day_reopening_reason_check CHECK (btrim(reason) <> '')
);
CREATE TRIGGER reconciled_day_reopening_record_revision_trg AFTER UPDATE ON reconciled_day_reopening
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE, DELETE, TRUNCATE ON reconciled_day_reopening FROM shop_app;
GRANT SELECT, INSERT ON reconciled_day_reopening TO shop_app;

ALTER TABLE reconciled_day
  DROP CONSTRAINT reconciled_day_one_per_day_key,
  ADD COLUMN previous_reconciled_day_id bigint,
  ADD CONSTRAINT reconciled_day_previous_key UNIQUE (previous_reconciled_day_id),
  ADD CONSTRAINT reconciled_day_previous_fkey FOREIGN KEY (previous_reconciled_day_id, sale_date)
    REFERENCES reconciled_day_reopening (reconciled_day_id, sale_date);
CREATE UNIQUE INDEX reconciled_day_one_per_day_key ON reconciled_day (sale_date)
  WHERE previous_reconciled_day_id IS NULL;

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

  IF EXISTS (
    SELECT 1 FROM reconciled_day r WHERE r.sale_date = ANY (d)
      AND (TG_TABLE_NAME IN ('opening_float', 'opening_float_line')
           OR NOT EXISTS (SELECT 1 FROM reconciled_day_reopening o WHERE o.reconciled_day_id = r.id))
  ) THEN
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


-- Xấp mới thêm khi sửa số đếm phải giữ ảnh trước/sau trên phiếu cha như ADR-081.
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
    WHEN 'cash_count_line' THEN
      -- Giữ hành vi đếm lần đầu; chỉ đường sửa ngày từng ký cần vết thêm xấp.
      IF NOT EXISTS (SELECT 1 FROM cash_count c JOIN reconciled_day r ON r.sale_date = c.sale_date
                     WHERE c.id = NEW.cash_count_id) THEN RETURN NULL; END IF;
      v_parent_table := 'cash_count'; v_parent_key := 'cash_count_id';
    WHEN 'opening_float_line'  THEN v_parent_table := 'opening_float'; v_parent_key := 'opening_float_id';
  END CASE;
  v_parent_id := (to_jsonb(NEW) ->> v_parent_key)::bigint;
  EXECUTE format('SELECT to_jsonb(p) FROM %I p WHERE p.id = $1 AND (p.created_at < $2 OR $3)', v_parent_table)
    INTO v_parent USING v_parent_id, NEW.created_at, TG_TABLE_NAME = 'cash_count_line';
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

CREATE TRIGGER cash_count_line_added_revision_trg AFTER INSERT ON cash_count_line
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture_added_line();
