-- Đường lùi bước 20 (T-138; ADR-092). Trả thân ba hàm về đúng chữ của bước 8 · bước 17 · bước 5 và gỡ
-- cột người của table_session_member. KHOÁ CHẶN: đã có dòng bàn của phiên mang người thì từ chối trước
-- khi gỡ gì — gỡ cột lúc ấy là xoá "ai mở phiên, ai ghép bàn" đã ghi (luật 2 của 07-thu-tu-migration.md).
-- Lùi về chế độ mềm trên database rỗng là trả lại chỗ hở F-046, không mất dòng nào.
DO $$
DECLARE n bigint;
BEGIN
  SELECT count(*) INTO n FROM table_session_member WHERE person_id IS NOT NULL;
  IF n > 0 THEN
    RAISE EXCEPTION 'đường lùi từ chối: table_session_member đang giữ % dòng mang người mở phiên hay ghép bàn', n
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;

DROP TRIGGER table_session_member_merge_person_trg ON table_session_member;
DROP FUNCTION table_session_member_merge_person_guard();
ALTER TABLE table_session_member DROP COLUMN person_id;

-- Bước 5, đúng chữ.
CREATE OR REPLACE FUNCTION qr_code_issue(p_dining_table_id bigint) RETURNS bigint
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
DECLARE new_id bigint;
BEGIN
  UPDATE qr_code SET replaced_at = now()
   WHERE dining_table_id = p_dining_table_id AND replaced_at IS NULL;
  INSERT INTO qr_code (dining_table_id, code, issued_at)
  VALUES (p_dining_table_id,
          left(encode(sha256(convert_to(gen_random_uuid()::text, 'UTF8')), 'hex'), 32),
          now())
  RETURNING id INTO new_id;
  RETURN new_id;
END $$;

-- Bước 8, đúng chữ.
CREATE OR REPLACE FUNCTION record_revision_capture() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
DECLARE v_reason text := NULLIF(btrim(current_setting('shop.revision_reason', true)), '');
BEGIN
  IF v_reason IS NULL OR to_jsonb(OLD) = to_jsonb(NEW) THEN
    RETURN NULL;
  END IF;
  INSERT INTO record_revision (target_table_code, target_row, before_image, after_image, reason,
                               person_id)
  VALUES (TG_TABLE_NAME, NEW.id, to_jsonb(OLD), to_jsonb(NEW), v_reason, actor_person_id());
  RETURN NULL;
END $$;

-- Bước 17, đúng chữ.
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
  IF v_reason IS NULL THEN
    RETURN NULL;
  END IF;
  CASE TG_TABLE_NAME
    WHEN 'order_line'          THEN v_parent_table := 'sales_order';   v_parent_key := 'sales_order_id';
    WHEN 'menu_item_component' THEN v_parent_table := 'menu_item';     v_parent_key := 'menu_item_id';
    WHEN 'opening_float_line'  THEN v_parent_table := 'opening_float'; v_parent_key := 'opening_float_id';
  END CASE;
  v_parent_id := (to_jsonb(NEW) ->> v_parent_key)::bigint;
  EXECUTE format('SELECT to_jsonb(p) FROM %I p WHERE p.id = $1 AND p.created_at < $2', v_parent_table)
    INTO v_parent USING v_parent_id, NEW.created_at;
  IF v_parent IS NULL THEN
    RETURN NULL;
  END IF;
  -- Các dòng con đã có trước dòng này (theo khoá tự sinh, nên một câu lệnh thêm nhiều dòng cho mỗi
  -- dòng đúng bản trước của nó).
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
