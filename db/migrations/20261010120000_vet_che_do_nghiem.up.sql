-- T-138 — vết cập nhật bật CHẾ ĐỘ NGHIÊM (F-046; ADR-092).
-- Ý định và ánh xạ I-018 · I-012 · I-016: docs/product/2-db/06-luoc-do-nguoi-va-vet.md §3 · §5.
-- File này thắng về tên · kiểu · ràng buộc (docs/decisions.md ADR-053 luật 2).
--
-- Bước 8 và bước 17 chụp vết khi giao dịch khai `shop.revision_reason`, và để lần sửa (lần thêm dòng
-- con) KHÔNG khai lý do đi qua mà không vết — chế độ mềm, chủ repo chọn 2026-09-28. Bước này thay thân
-- hai hàm ấy: không khai lý do thì database từ chối, cùng một tên `record_revision_reason_declared_check`
-- — lời từ chối giữ bảng vết, vì cái nó giữ là "không lần đổi nào thiếu vết" (QC-10). Từ bước này, mọi
-- migration sau sửa dữ liệu cũng phải khai lý do và người.
--
-- Một ngoại lệ, hẹp và kiểm được (F-060 vế b, ADR-087 điểm 5): khách quét QR gọi thêm lúc phiên đang
-- Chờ thanh toán thì phiên quay về Đang phục vụ — không có người của quán để ghi vết. Lần sửa ấy đi qua
-- không vết CHỈ KHI giao dịch không có người, không có lý do, chỉ cột trạng thái đổi đúng cặp ấy, và
-- chính giao dịch ấy vừa thêm một đơn `qr_table` vào phiên — lượt gọi ấy là bằng chứng của lần chuyển.

CREATE OR REPLACE FUNCTION record_revision_capture() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
DECLARE v_reason text := NULLIF(btrim(current_setting('shop.revision_reason', true)), '');
BEGIN
  IF to_jsonb(OLD) = to_jsonb(NEW) THEN
    RETURN NULL;
  END IF;
  IF v_reason IS NULL THEN
    IF TG_TABLE_NAME = 'table_session'
       AND actor_person_id() IS NULL
       AND to_jsonb(OLD) ->> 'status' = 'awaiting_payment'
       AND to_jsonb(NEW) ->> 'status' = 'serving'
       AND to_jsonb(OLD) - 'status' = to_jsonb(NEW) - 'status'
       AND EXISTS (SELECT 1 FROM sales_order s
                   WHERE s.table_session_id = NEW.id AND s.channel_code = 'qr_table'
                     AND s.created_at = now()) THEN
      RETURN NULL;
    END IF;
    RAISE EXCEPTION '%: sửa dòng % mà giao dịch không khai lý do — mọi lần sửa phải để lại vết',
        TG_TABLE_NAME, NEW.id
      USING ERRCODE = 'check_violation', CONSTRAINT = 'record_revision_reason_declared_check',
            HINT = 'khai shop.revision_reason và shop.actor_person_id trong giao dịch trước câu sửa';
  END IF;
  INSERT INTO record_revision (target_table_code, target_row, before_image, after_image, reason,
                               person_id)
  VALUES (TG_TABLE_NAME, NEW.id, to_jsonb(OLD), to_jsonb(NEW), v_reason, actor_person_id());
  RETURN NULL;
END $$;

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

-- Cửa duy nhất cấp và thay mã QR (bước 5) sửa mã cũ trong thân nó: lý do của lần sửa ấy là chính cửa,
-- nên hàm tự khai khi người gọi chưa khai, rồi trả cài đặt về như cũ. Người của vết vẫn là người của
-- giao dịch — thay mã mà không có người thì bị từ chối cùng vết (I-018 tầng 1).
CREATE OR REPLACE FUNCTION qr_code_issue(p_dining_table_id bigint) RETURNS bigint
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
DECLARE
  new_id   bigint;
  v_before text := current_setting('shop.revision_reason', true);
BEGIN
  IF NULLIF(btrim(v_before), '') IS NULL THEN
    PERFORM set_config('shop.revision_reason', 'qr_code_issue: thay mã của bàn ' || p_dining_table_id, true);
  END IF;
  UPDATE qr_code SET replaced_at = now()
   WHERE dining_table_id = p_dining_table_id AND replaced_at IS NULL;
  PERFORM set_config('shop.revision_reason', coalesce(v_before, ''), true);
  INSERT INTO qr_code (dining_table_id, code, issued_at)
  VALUES (p_dining_table_id,
          left(encode(sha256(convert_to(gen_random_uuid()::text, 'UTF8')), 'hex'), 32),
          now())
  RETURNING id INTO new_id;
  RETURN new_id;
END $$;

-- Ai gắn một bàn vào phiên (I-012: ghép bàn là thao tác chạm tiền; F-046 Decision (3)). Mặc định là
-- người của giao dịch. Dòng MỞ phiên được trống người: khách quét QR ở bàn trống mở phiên bằng chính
-- lượt gọi (ADR-087 điểm 1), và khách không phải người của quán. Dòng gắn vào phiên ĐÃ CÓ bàn — ghép bàn
-- — thiếu người thì bị từ chối.
ALTER TABLE table_session_member
  ADD COLUMN person_id bigint DEFAULT actor_person_id(),
  ADD CONSTRAINT table_session_member_person_fkey FOREIGN KEY (person_id) REFERENCES person (id);

CREATE FUNCTION table_session_member_merge_person_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
BEGIN
  IF NEW.person_id IS NULL
     AND EXISTS (SELECT 1 FROM table_session_member m
                 WHERE m.table_session_id = NEW.table_session_id AND m.id <> NEW.id) THEN
    RAISE EXCEPTION 'table_session_member: ghép bàn % vào phiên % mà không có người bấm',
        NEW.dining_table_id, NEW.table_session_id
      USING ERRCODE = 'not_null_violation',
            CONSTRAINT = 'table_session_member_merge_person_required_check';
  END IF;
  RETURN NULL;
END $$;
REVOKE ALL ON FUNCTION table_session_member_merge_person_guard() FROM PUBLIC;

CREATE TRIGGER table_session_member_merge_person_trg
  AFTER INSERT ON table_session_member
  FOR EACH ROW EXECUTE FUNCTION table_session_member_merge_person_guard();
