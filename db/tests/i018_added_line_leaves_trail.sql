-- I-018 (tầng 1 · tầng 2) cho lần THÊM một dòng con vào một bản ghi đã có (F-047, ADR-081): thêm món
-- vào một đơn đã tạo (sửa đơn, shop-facts §6.19) · thêm thành phần vào một suất đã có (I-011) · thêm một
-- xấp mệnh giá vào tiền đầu két đã khai (I-021). Giao dịch khai lý do ⇒ một vết trên BẢN GHI CHA, bản
-- trước không có dòng ấy, bản sau có, người là người của giao dịch. Dòng tạo cùng lúc với cha là nội dung
-- lúc tạo, không phải lần sửa ⇒ không vết. Chế độ NGHIÊM từ bước 20 (T-138, ADR-092; F-046 đã gỡ): không
-- khai lý do ⇒ database từ chối lần thêm. Lát: 06-luoc-do-nguoi-va-vet.md.

DO $$
DECLARE b bigint; c_banh bigint; c_gio bigint; m bigint; so bigint; f bigint;
        l_dau bigint; l_them bigint; x_dau bigint; x_them bigint; x_len bigint; mc_dau bigint; mc_them bigint;
        v record; r record; n bigint;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-B đứng quầy') RETURNING id INTO b;
  PERFORM set_config('shop.actor_person_id', b::text, true);
  -- Lý do khai ngay từ đầu: dòng ghi cùng lúc với cha vẫn KHÔNG được chụp thành lần sửa.
  PERFORM set_config('shop.revision_reason', 'test-tạo mới', true);

  INSERT INTO menu_component (name, base_price_vnd, takes_filling) VALUES ('test-bánh', 100, true) RETURNING id INTO c_banh;
  INSERT INTO menu_component (name, base_price_vnd, takes_filling) VALUES ('test-giò', 900, false) RETURNING id INTO c_gio;
  INSERT INTO menu_item (name) VALUES ('test-suất giò') RETURNING id INTO m;
  INSERT INTO menu_item_component (menu_item_id, menu_component_id, quantity) VALUES (m, c_gio, 1)
  RETURNING id INTO mc_dau;
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code)
  VALUES ('pickup', 'confirmed', 'shop_pickup', '0900000001', now(), gen_random_uuid()::text)
  RETURNING id INTO so;
  INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd, component_count)
  VALUES (so, 1, m, 'test-suất giò', 900, 1) RETURNING id INTO l_dau;
  INSERT INTO order_line_component (order_line_id, position, line_component_count,
    menu_component_id, component_name, quantity, takes_filling, base_price_vnd)
  VALUES (l_dau, 1, 1, c_gio, 'test-giò', 1, false, 900);
  INSERT INTO opening_float (sale_date) VALUES (DATE '2026-10-04') RETURNING id INTO f;
  INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd)
  VALUES (f, 10000, 200000) RETURNING id INTO x_dau;

  n := (SELECT count(*) FROM record_revision
        WHERE (target_table_code, target_row) IN (('sales_order', so), ('menu_item', m), ('opening_float', f)));
  RAISE NOTICE 'F-047 dòng ghi cùng lúc với cha (có khai lý do): % vết', n;
  IF n <> 0 THEN
    RAISE EXCEPTION 'F-047: dòng ghi cùng lúc với bản ghi cha bị chụp thành một lần sửa';
  END IF;

  -- Ba bản ghi cha và dòng đầu của chúng "đã có từ trước": lùi mốc tạo ba giờ. Lần lùi ấy cũng là một
  -- lần sửa, nên có vết của nó; các phép đếm dưới chỉ đọc vết thêm dòng con (bản sau mang khoá bảng con).
  PERFORM set_config('shop.revision_reason', 'test-dựng bản ghi đã có', true);
  UPDATE sales_order SET created_at = now() - interval '3 hours' WHERE id = so;
  UPDATE menu_item SET created_at = now() - interval '3 hours' WHERE id = m;
  UPDATE opening_float SET created_at = now() - interval '3 hours' WHERE id = f;
  UPDATE order_line SET created_at = now() - interval '3 hours' WHERE id = l_dau;
  UPDATE menu_item_component SET created_at = now() - interval '3 hours' WHERE id = mc_dau;
  UPDATE opening_float_line SET created_at = now() - interval '3 hours' WHERE id = x_dau;

  -- Chế độ nghiêm: thêm KHÔNG khai lý do vào cha đã có ⇒ từ chối, không dòng nào, không vết nào.
  PERFORM set_config('shop.revision_reason', '', true);
  BEGIN
    INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd)
    VALUES (f, 1000, 5000) RETURNING id INTO x_len;
    RAISE EXCEPTION 'F-046: database KHÔNG từ chối lần thêm xấp không khai lý do';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'F-046 chế độ nghiêm — thêm xấp không khai lý do bị từ chối: %', SQLERRM;
  END;

  -- Khai lý do mà không khai người: lần thêm bị từ chối cùng vết của nó.
  BEGIN
    PERFORM set_config('shop.revision_reason', 'test-thêm không người', true);
    PERFORM set_config('shop.actor_person_id', '', true);
    INSERT INTO menu_item_component (menu_item_id, menu_component_id, quantity) VALUES (m, c_banh, 2);
    RAISE EXCEPTION 'F-047: database KHÔNG từ chối lần thêm có lý do mà không có người';
  EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'F-047 bị từ chối (thêm có lý do, không người): %', SQLERRM;
  END;
  PERFORM set_config('shop.actor_person_id', b::text, true);

  -- Có lý do: mỗi bảng con một lần thêm.
  PERFORM set_config('shop.revision_reason', 'test-khách gọi thêm hai suất', true);
  INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd, component_count)
  VALUES (so, 2, m, 'test-suất giò', 900, 1) RETURNING id INTO l_them;
  INSERT INTO order_line_component (order_line_id, position, line_component_count,
    menu_component_id, component_name, quantity, takes_filling, base_price_vnd)
  VALUES (l_them, 1, 1, c_gio, 'test-giò', 1, false, 900);
  PERFORM set_config('shop.revision_reason', 'test-suất giò thêm một cái bánh', true);
  INSERT INTO menu_item_component (menu_item_id, menu_component_id, quantity)
  VALUES (m, c_banh, 1) RETURNING id INTO mc_them;
  PERFORM set_config('shop.revision_reason', 'test-khai thiếu xấp 2.000đ', true);
  INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd)
  VALUES (f, 2000, 20000) RETURNING id INTO x_them;

  -- Mỗi lần thêm: đúng một vết trên cha, mang người và lý do; bản trước có dòng cũ mà không có dòng
  -- thêm, bản sau có cả hai.
  FOR v IN
    SELECT * FROM (VALUES ('sales_order', so, 'order_line', l_them, l_dau),
                          ('menu_item', m, 'menu_item_component', mc_them, mc_dau),
                          ('opening_float', f, 'opening_float_line', x_them, x_dau)) t(cha, id, con, dong, cu)
  LOOP
    n := (SELECT count(*) FROM record_revision
          WHERE target_table_code = v.cha AND target_row = v.id AND after_image ? v.con);
    IF n <> 1 THEN
      RAISE EXCEPTION 'F-047: thêm một dòng % vào % đã có để lại % vết trên cha, cần đúng 1', v.con, v.cha, n;
    END IF;
    SELECT * INTO STRICT r FROM record_revision
    WHERE target_table_code = v.cha AND target_row = v.id AND after_image ? v.con;
    IF r.person_id IS DISTINCT FROM b
       OR NOT r.after_image -> v.con @> jsonb_build_array(jsonb_build_object('id', v.dong))
       OR r.before_image -> v.con @> jsonb_build_array(jsonb_build_object('id', v.dong))
       OR NOT r.before_image -> v.con @> jsonb_build_array(jsonb_build_object('id', v.cu))
       OR NOT r.after_image -> v.con @> jsonb_build_array(jsonb_build_object('id', v.cu)) THEN
      RAISE EXCEPTION 'F-047: vết thêm % vào % không mang đủ người · bản trước · bản sau: %', v.con, v.cha, row_to_json(r);
    END IF;
    RAISE NOTICE 'F-047 thêm % vào % — % dòng → % dòng, lý do "%", người %', v.con, v.cha,
      jsonb_array_length(r.before_image -> v.con), jsonb_array_length(r.after_image -> v.con), r.reason,
      (SELECT display_name FROM person WHERE id = r.person_id);
  END LOOP;
END $$;
