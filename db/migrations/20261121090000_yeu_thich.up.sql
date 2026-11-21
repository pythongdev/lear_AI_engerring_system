-- YT-03 — ADR-145; ý định: docs/product/2-db/29-luoc-do-yeu-thich.md.
-- Chỉ giữ tham chiếu menu và số lượng; không chụp giá, tên món hay ảnh.
CREATE TABLE customer_favourite_set (
  id bigint GENERATED ALWAYS AS IDENTITY,
  customer_account_id bigint NOT NULL,
  kind text COLLATE "vi-x-icu" NOT NULL,
  name text COLLATE "vi-x-icu" NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  removed_at timestamptz,
  CONSTRAINT customer_favourite_set_pkey PRIMARY KEY (id),
  CONSTRAINT customer_favourite_set_account_fkey
    FOREIGN KEY (customer_account_id) REFERENCES customer_account (id),
  CONSTRAINT customer_favourite_set_owner_key UNIQUE (id, customer_account_id),
  CONSTRAINT customer_favourite_set_kind_check CHECK (kind IN ('rieng', 'da_luu')),
  CONSTRAINT customer_favourite_set_name_check CHECK (btrim(name) <> '' AND char_length(name) <= 60)
);

CREATE TABLE customer_favourite_line (
  id bigint GENERATED ALWAYS AS IDENTITY,
  customer_account_id bigint NOT NULL,
  favourite_set_id bigint,
  parent_line_id bigint,
  menu_item_id bigint,
  menu_combo_id bigint,
  quantity integer NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  removed_at timestamptz,
  CONSTRAINT customer_favourite_line_pkey PRIMARY KEY (id),
  CONSTRAINT customer_favourite_line_account_fkey
    FOREIGN KEY (customer_account_id) REFERENCES customer_account (id),
  CONSTRAINT customer_favourite_line_owner_key UNIQUE (id, customer_account_id),
  CONSTRAINT customer_favourite_line_set_fkey
    FOREIGN KEY (favourite_set_id, customer_account_id)
    REFERENCES customer_favourite_set (id, customer_account_id),
  CONSTRAINT customer_favourite_line_parent_fkey
    FOREIGN KEY (parent_line_id, customer_account_id)
    REFERENCES customer_favourite_line (id, customer_account_id),
  CONSTRAINT customer_favourite_line_menu_item_fkey
    FOREIGN KEY (menu_item_id) REFERENCES menu_item (id),
  CONSTRAINT customer_favourite_line_menu_combo_fkey
    FOREIGN KEY (menu_combo_id) REFERENCES menu_combo (id),
  CONSTRAINT customer_favourite_line_item_xor_combo_check CHECK ((menu_item_id IS NULL) <> (menu_combo_id IS NULL)),
  CONSTRAINT customer_favourite_line_quantity_check CHECK (quantity BETWEEN 1 AND 99)
);

CREATE TABLE customer_favourite_line_option (
  id bigint GENERATED ALWAYS AS IDENTITY,
  favourite_line_id bigint NOT NULL,
  menu_option_id bigint NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT customer_favourite_line_option_pkey PRIMARY KEY (id),
  CONSTRAINT customer_favourite_line_option_line_fkey
    FOREIGN KEY (favourite_line_id) REFERENCES customer_favourite_line (id),
  CONSTRAINT customer_favourite_line_option_option_fkey
    FOREIGN KEY (menu_option_id) REFERENCES menu_option (id),
  CONSTRAINT customer_favourite_line_option_key UNIQUE (favourite_line_id, menu_option_id)
);

-- Khoá cùng dòng khách trước khi đếm, giữ đến hết giao dịch. NO KEY UPDATE
-- không xung đột với KEY SHARE của khoá ngoại về khách. Hai câu SQL riêng để
-- phép đếm thấy lần ghi vừa commit sau khi chờ khoá ở READ COMMITTED.
CREATE FUNCTION customer_favourite_set_limit_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
BEGIN
  PERFORM 1 FROM customer_account WHERE id = NEW.customer_account_id FOR NO KEY UPDATE;
  IF NEW.removed_at IS NULL AND
     (SELECT count(*) FROM customer_favourite_set
      WHERE customer_account_id = NEW.customer_account_id AND removed_at IS NULL) >= 20 THEN
    RAISE EXCEPTION 'mỗi khách chỉ giữ tối đa 20 bộ chưa gỡ'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'customer_favourite_set_limit_check';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION customer_favourite_set_limit_guard() FROM PUBLIC;
CREATE TRIGGER customer_favourite_set_limit_check BEFORE INSERT ON customer_favourite_set
  FOR EACH ROW EXECUTE FUNCTION customer_favourite_set_limit_guard();

CREATE FUNCTION customer_favourite_set_removed_once_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path = shop, pg_temp AS $$
BEGIN
  IF OLD.removed_at IS NOT NULL AND OLD.removed_at IS DISTINCT FROM NEW.removed_at THEN
    RAISE EXCEPTION 'mốc gỡ bộ chỉ được ghi một lần'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'customer_favourite_set_removed_once_check';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION customer_favourite_set_removed_once_guard() FROM PUBLIC;
CREATE TRIGGER customer_favourite_set_removed_once_check BEFORE UPDATE ON customer_favourite_set
  FOR EACH ROW EXECUTE FUNCTION customer_favourite_set_removed_once_guard();

CREATE FUNCTION customer_favourite_line_limit_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
DECLARE line_count bigint;
BEGIN
  PERFORM 1 FROM customer_account WHERE id = NEW.customer_account_id FOR NO KEY UPDATE;
  IF NEW.removed_at IS NULL AND NEW.parent_line_id IS NULL THEN
    SELECT count(*) INTO line_count FROM customer_favourite_line
      WHERE customer_account_id = NEW.customer_account_id
        AND favourite_set_id IS NOT DISTINCT FROM NEW.favourite_set_id
        AND parent_line_id IS NULL AND removed_at IS NULL;
    IF (NEW.favourite_set_id IS NULL AND line_count >= 50)
       OR (NEW.favourite_set_id IS NOT NULL AND line_count >= 20) THEN
      RAISE EXCEPTION 'mỗi khách chỉ giữ tối đa 50 dòng tim gốc, mỗi bộ tối đa 20 dòng gốc chưa gỡ'
        USING ERRCODE = 'check_violation', CONSTRAINT = 'customer_favourite_line_limit_check';
    END IF;
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION customer_favourite_line_limit_guard() FROM PUBLIC;
CREATE TRIGGER customer_favourite_line_limit_check BEFORE INSERT ON customer_favourite_line
  FOR EACH ROW EXECUTE FUNCTION customer_favourite_line_limit_guard();

CREATE FUNCTION customer_favourite_line_shape_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
DECLARE parent_line customer_favourite_line%ROWTYPE;
BEGIN
  IF NEW.parent_line_id IS NOT NULL THEN
    IF NEW.menu_combo_id IS NOT NULL THEN
      RAISE EXCEPTION 'dòng combo không có cha; dòng suất con phải là dòng món'
        USING ERRCODE = 'check_violation', CONSTRAINT = 'customer_favourite_line_shape_check';
    END IF;
    SELECT * INTO parent_line FROM customer_favourite_line
      WHERE id = NEW.parent_line_id AND customer_account_id = NEW.customer_account_id;
    -- Cha không có hoặc khác khách: để khoá ngoại ghép trả đúng lớp lỗi/tên.
    IF FOUND AND (parent_line.menu_combo_id IS NULL OR parent_line.removed_at IS NOT NULL
                  OR parent_line.favourite_set_id IS DISTINCT FROM NEW.favourite_set_id) THEN
      RAISE EXCEPTION 'cha phải là dòng combo chưa gỡ trong cùng bộ'
        USING ERRCODE = 'check_violation', CONSTRAINT = 'customer_favourite_line_shape_check';
    END IF;
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION customer_favourite_line_shape_guard() FROM PUBLIC;
CREATE TRIGGER customer_favourite_line_shape_check BEFORE INSERT ON customer_favourite_line
  FOR EACH ROW EXECUTE FUNCTION customer_favourite_line_shape_guard();

CREATE FUNCTION customer_favourite_line_removed_once_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path = shop, pg_temp AS $$
BEGIN
  IF OLD.removed_at IS NOT NULL AND OLD.removed_at IS DISTINCT FROM NEW.removed_at THEN
    RAISE EXCEPTION 'mốc gỡ dòng chỉ được ghi một lần'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'customer_favourite_line_removed_once_check';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION customer_favourite_line_removed_once_guard() FROM PUBLIC;
CREATE TRIGGER customer_favourite_line_removed_once_check BEFORE UPDATE ON customer_favourite_line
  FOR EACH ROW EXECUTE FUNCTION customer_favourite_line_removed_once_guard();

CREATE FUNCTION customer_favourite_line_option_item_line_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM customer_favourite_line
             WHERE id = NEW.favourite_line_id AND menu_combo_id IS NOT NULL) THEN
    RAISE EXCEPTION 'lựa chọn chỉ thuộc dòng món hoặc suất con, không thuộc dòng combo'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'customer_favourite_line_option_item_line_check';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION customer_favourite_line_option_item_line_guard() FROM PUBLIC;
CREATE TRIGGER customer_favourite_line_option_item_line_check BEFORE INSERT ON customer_favourite_line_option
  FOR EACH ROW EXECUTE FUNCTION customer_favourite_line_option_item_line_guard();

-- QD-52: vết trên cả bảng chỉ thêm; khách không phải người của quán.
-- record_revision_target_table_code_check chỉ kiểm dạng tên, không liệt kê bảng.
ALTER TABLE record_revision DROP CONSTRAINT record_revision_person_check,
  ADD CONSTRAINT record_revision_person_check CHECK (person_id IS NOT NULL OR target_table_code IN
    ('customer_account', 'customer_password', 'customer_session', 'customer_password_reset', 'customer_email_verification',
     'model_call', 'customer_favourite_set', 'customer_favourite_line', 'customer_favourite_line_option'));
CREATE TRIGGER customer_favourite_set_record_revision_trg AFTER UPDATE ON customer_favourite_set
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
CREATE TRIGGER customer_favourite_line_record_revision_trg AFTER UPDATE ON customer_favourite_line
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
CREATE TRIGGER customer_favourite_line_option_record_revision_trg AFTER UPDATE ON customer_favourite_line_option
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();

-- QC-03 cấp SELECT/INSERT và quyền sequence mặc định. QD-50 không xoá cứng.
REVOKE UPDATE ON customer_favourite_set, customer_favourite_line, customer_favourite_line_option FROM shop_app;
GRANT UPDATE (name, removed_at) ON customer_favourite_set TO shop_app;
GRANT UPDATE (quantity, removed_at) ON customer_favourite_line TO shop_app;
