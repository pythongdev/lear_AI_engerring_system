-- I-010 · shop-facts §4.6 luật 8 (T-169, ADR-094): mặc định của nhóm tuỳ chọn là DỮ LIỆU —
-- cờ menu_option.is_default, mỗi nhóm nhiều nhất một. Cờ chỉ để màn gọi món chọn sẵn; cửa
-- tạo lượt gọi không tự điền (I-010 tầng 3, be/internal/gia). Tên dưới đây là tên giả; mặc
-- định thật do dữ liệu mồi đọc từ owner. Lát: 03-luoc-do-menu-gia.md.
DO $$
DECLARE
  g_nhan bigint; g_luong bigint; g_khac bigint; o_thit bigint; ten text; n int;
BEGIN
  INSERT INTO option_group (name) VALUES ('test-Nhân') RETURNING id INTO g_nhan;
  INSERT INTO option_group (name) VALUES ('test-Lượng nhân') RETURNING id INTO g_luong;
  INSERT INTO option_group (name) VALUES ('test-Nhóm không mặc định') RETURNING id INTO g_khac;

  -- Lựa chọn mới không nói gì ⇒ không phải mặc định.
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd) VALUES (g_nhan, 'test-Chay', 0);
  SELECT count(*) INTO n FROM menu_option WHERE option_group_id = g_nhan AND is_default;
  IF n <> 0 THEN RAISE EXCEPTION 'I-010: lựa chọn không khai cờ mà thành mặc định'; END IF;

  -- Một mặc định mỗi nhóm, ở hai nhóm; nhóm thứ ba không có mặc định nào.
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd, is_default)
  VALUES (g_nhan, 'test-Thịt', 10, true) RETURNING id INTO o_thit;
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd, is_default)
  VALUES (g_luong, 'test-Thường', 0, true), (g_luong, 'test-Nhiều nhân', 10, false);
  INSERT INTO menu_option (option_group_id, name, surcharge_vnd) VALUES (g_khac, 'test-Một', 0);
  RAISE NOTICE 'I-010 luật 8: một mặc định ở mỗi nhóm, nhóm không mặc định ⇒ nhận';

  -- Mặc định thứ hai trong cùng nhóm ⇒ database từ chối, mang tên QC-10.
  BEGIN
    INSERT INTO menu_option (option_group_id, name, surcharge_vnd, is_default)
    VALUES (g_nhan, 'test-Thịt + mộc nhĩ', 10, true);
    RAISE EXCEPTION 'I-010: nhóm nhận hai mặc định';
  EXCEPTION WHEN unique_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'menu_option_one_default_per_group_key' THEN
      RAISE EXCEPTION 'I-010: từ chối sai tên: %', ten;
    END IF;
    RAISE NOTICE 'I-010 luật 8: mặc định thứ hai trong nhóm ⇒ từ chối (%)', ten;
  END;

  SELECT count(*) INTO n FROM menu_option WHERE option_group_id = g_nhan AND is_default;
  IF n <> 1 THEN RAISE EXCEPTION 'I-010: nhóm có % mặc định sau lần từ chối', n; END IF;
END $$;
