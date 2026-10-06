-- T-137 — vết khi THÊM một dòng con vào một bản ghi đã có (ADR-081; F-047).
-- Ý định và ánh xạ I-018 · I-024 · I-011 · I-021: docs/product/2-db/06-luoc-do-nguoi-va-vet.md §2.
-- File này thắng về tên · kiểu · ràng buộc (docs/decisions.md ADR-053 luật 2).
--
-- record_revision_capture (bước 8) chụp lần SỬA một dòng. Ba thay đổi nội dung của một bản ghi đã có
-- lại đi bằng lần THÊM một dòng con: món vào đơn đã tạo · thành phần vào suất đã có · xấp mệnh giá vào
-- tiền đầu két đã khai. Hàm dưới chụp lần thêm ấy thành một vết trên BẢN GHI CHA: bản trước là cha cùng
-- các dòng con đã có trước dòng ấy, bản sau thêm đúng dòng ấy; người là người của giao dịch. Dòng tạo
-- cùng lúc với cha (mốc tạo không muộn hơn) là nội dung lúc tạo, không phải lần sửa — cùng cách đọc
-- của ba câu đối chiếu. CHẾ ĐỘ MỀM như bước 8: không khai lý do thì không vết (F-046).
CREATE FUNCTION record_revision_capture_added_line() RETURNS trigger
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
REVOKE ALL ON FUNCTION record_revision_capture_added_line() FROM PUBLIC;

CREATE TRIGGER order_line_added_line_trg
  AFTER INSERT ON order_line
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture_added_line();
CREATE TRIGGER menu_item_component_added_line_trg
  AFTER INSERT ON menu_item_component
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture_added_line();
CREATE TRIGGER opening_float_line_added_line_trg
  AFTER INSERT ON opening_float_line
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture_added_line();
