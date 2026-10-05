-- I-021 · I-014 — số đếm và tiền đầu két của một ngày ĐÃ ĐỐI SOÁT XONG không đổi được nữa (F-056), và
-- dấu đối soát xong không đứng trên một số đếm hay tiền đầu két không có dòng mệnh giá nào (F-057).
-- shop-facts.md §6 mục 4: con số đã ký của một ngày đọc lại lúc nào cũng bằng chính nó. Đường sửa một
-- số đếm đã ký là câu của chủ quán (U-074) — test này không dựng, và chờ MỌI vai bị từ chối, kể cả
-- shop_owner: chỉ một migration mới (DDL) đi qua được khoá.
-- Thiết kế: docs/decisions.md ADR-080. Viết TRƯỚC migration (T-134, Claude Code).
-- Lát: 04-luoc-do-duong-tien.md §7.
DO $$
DECLARE p bigint;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
END $$;

DO $$
DECLARE f bigint; c bigint; f2 bigint; c2 bigint; f3 bigint; c3 bigint; c4 bigint;
        l_c bigint; l_f bigint; l_c4 bigint; n bigint; tong bigint;
BEGIN
  -- Ngày 2026-09-21: tiền đầu két 1.200.000, số đếm 2.000.000, rồi đóng dấu đối soát xong.
  INSERT INTO opening_float (sale_date) VALUES ('2026-09-21') RETURNING id INTO f;
  INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd)
  VALUES (f, 50000, 1000000), (f, 5000, 100000), (f, 1000, 100000);
  INSERT INTO cash_count (sale_date) VALUES ('2026-09-21') RETURNING id INTO c;
  INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd)
  VALUES (c, 500000, 1000000), (c, 100000, 500000), (c, 5000, 100000), (c, 1000, 400000);
  -- Ngày 2026-09-25: đếm mà CHƯA ký — đường đếm lại của nhóm ba, và nguồn của một dòng bị dời sang.
  INSERT INTO opening_float (sale_date) VALUES ('2026-09-25') RETURNING id INTO f2;
  INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd) VALUES (f2, 10000, 500000);
  INSERT INTO cash_count (sale_date) VALUES ('2026-09-25') RETURNING id INTO c2;
  INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd)
  VALUES (c2, 50000, 800000), (c2, 10000, 200000);

  -- ================================================================ nhóm ba: TRƯỚC khi ký, đếm lại được
  -- Đếm lại một xấp của ngày chưa ký, khai lý do ⇒ ghi được, để đúng một vết (I-018), dưới vai ghi.
  PERFORM set_config('shop.revision_reason', 'đếm lại xấp 50.000', true);
  SET LOCAL ROLE shop_app;
  UPDATE cash_count_line SET amount_vnd = 750000 WHERE cash_count_id = c2 AND denomination_vnd = 50000;
  INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd) VALUES (c2, 2000, 20000);
  RESET ROLE;
  PERFORM set_config('shop.revision_reason', '', true);
  SELECT count(*) INTO n FROM record_revision
   WHERE target_table_code = 'cash_count_line' AND person_id IS NOT NULL
     AND (before_image ->> 'amount_vnd') = '800000' AND (after_image ->> 'amount_vnd') = '750000';
  RAISE NOTICE 'T-134 nhóm ba — đếm lại trước khi ký: % vết, từ 800000 sang 750000', n;
  IF n <> 1 THEN RAISE EXCEPTION 'I-018: lần đếm lại trước khi ký không để đúng một vết (có %)', n; END IF;
  SELECT sum(amount_vnd) INTO tong FROM cash_count_line WHERE cash_count_id = c2;
  IF tong <> 970000 THEN RAISE EXCEPTION 'T-134: số đếm ngày chưa ký đọc ra %, chờ 970000', tong; END IF;

  INSERT INTO reconciled_day (sale_date) VALUES ('2026-09-21');
  SELECT id INTO l_c FROM cash_count_line WHERE cash_count_id = c AND denomination_vnd = 100000;
  SELECT id INTO l_f FROM opening_float_line WHERE opening_float_id = f AND denomination_vnd = 5000;

  -- ================================================================ nhóm một: ngày đã ký đứng yên
  -- Mọi vai, mọi lệnh ghi lên bốn bảng của ngày đã ký ⇒ restrict_violation. Vai chủ lược đồ trước.
  -- Phép thử của F-056: thêm một xấp 50.000 × 4 vào số đếm của ngày đã ký.
  BEGIN
    INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd) VALUES (c, 50000, 200000);
    RAISE EXCEPTION 'F-056: shop_owner THÊM được một xấp vào số đếm của ngày đã đối soát xong';
  EXCEPTION WHEN restrict_violation THEN
    RAISE NOTICE 'F-056 bị từ chối (shop_owner thêm xấp 50.000 × 4 vào số đếm ngày đã ký): %', SQLERRM;
  END;
  BEGIN
    UPDATE cash_count_line SET amount_vnd = 400000 WHERE id = l_c;
    RAISE EXCEPTION 'F-056: shop_owner SỬA được một xấp của số đếm ngày đã ký';
  EXCEPTION WHEN restrict_violation THEN
    RAISE NOTICE 'F-056 bị từ chối (shop_owner sửa xấp số đếm ngày đã ký): %', SQLERRM;
  END;
  BEGIN
    DELETE FROM cash_count_line WHERE id = l_c;
    RAISE EXCEPTION 'F-056: shop_owner XOÁ được một xấp của số đếm ngày đã ký';
  EXCEPTION WHEN restrict_violation THEN
    RAISE NOTICE 'F-056 bị từ chối (shop_owner xoá xấp số đếm ngày đã ký): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd) VALUES (f, 2000, 20000);
    RAISE EXCEPTION 'F-056: shop_owner THÊM được một xấp vào tiền đầu két của ngày đã ký';
  EXCEPTION WHEN restrict_violation THEN
    RAISE NOTICE 'F-056 bị từ chối (shop_owner thêm xấp vào tiền đầu két ngày đã ký): %', SQLERRM;
  END;
  BEGIN
    UPDATE opening_float_line SET amount_vnd = 50000 WHERE id = l_f;
    RAISE EXCEPTION 'F-056: shop_owner SỬA được một xấp của tiền đầu két ngày đã ký';
  EXCEPTION WHEN restrict_violation THEN
    RAISE NOTICE 'F-056 bị từ chối (shop_owner sửa xấp tiền đầu két ngày đã ký): %', SQLERRM;
  END;
  BEGIN
    DELETE FROM opening_float_line WHERE id = l_f;
    RAISE EXCEPTION 'F-056: shop_owner XOÁ được một xấp của tiền đầu két ngày đã ký';
  EXCEPTION WHEN restrict_violation THEN
    RAISE NOTICE 'F-056 bị từ chối (shop_owner xoá xấp tiền đầu két ngày đã ký): %', SQLERRM;
  END;
  -- Dòng đầu của hai bảng: đổi người đếm, dời ngày, xoá — cũng đứng yên.
  BEGIN
    UPDATE cash_count SET created_at = created_at - interval '1 hour' WHERE id = c;
    RAISE EXCEPTION 'F-056: shop_owner SỬA được dòng đầu số đếm của ngày đã ký';
  EXCEPTION WHEN restrict_violation THEN
    RAISE NOTICE 'F-056 bị từ chối (shop_owner sửa dòng đầu số đếm ngày đã ký): %', SQLERRM;
  END;
  BEGIN
    UPDATE opening_float SET created_at = created_at - interval '1 hour' WHERE id = f;
    RAISE EXCEPTION 'F-056: shop_owner SỬA được dòng đầu tiền đầu két của ngày đã ký';
  EXCEPTION WHEN restrict_violation THEN
    RAISE NOTICE 'F-056 bị từ chối (shop_owner sửa dòng đầu tiền đầu két ngày đã ký): %', SQLERRM;
  END;
  BEGIN
    DELETE FROM opening_float WHERE id = f;
    RAISE EXCEPTION 'F-056: shop_owner XOÁ được dòng đầu tiền đầu két của ngày đã ký';
  EXCEPTION WHEN restrict_violation THEN
    RAISE NOTICE 'F-056 bị từ chối (shop_owner xoá dòng đầu tiền đầu két ngày đã ký): %', SQLERRM;
  END;
  -- Dời một xấp của ngày CHƯA ký sang số đếm của ngày đã ký: bản sau chạm ngày đã ký ⇒ từ chối.
  BEGIN
    SELECT id INTO l_c4 FROM cash_count_line WHERE cash_count_id = c2 AND denomination_vnd = 10000;
    UPDATE cash_count_line SET cash_count_id = c WHERE id = l_c4;
    RAISE EXCEPTION 'F-056: shop_owner DỜI được một xấp từ ngày chưa ký sang số đếm ngày đã ký';
  EXCEPTION WHEN restrict_violation THEN
    RAISE NOTICE 'F-056 bị từ chối (dời xấp sang số đếm ngày đã ký): %', SQLERRM;
  END;
  -- TRUNCATE không đi qua trigger dòng: phải bị chặn riêng khi có ngày đã ký.
  BEGIN
    TRUNCATE cash_count_line;
    RAISE EXCEPTION 'F-056: shop_owner TRUNCATE được bảng xấp số đếm khi có ngày đã ký';
  EXCEPTION WHEN restrict_violation THEN
    RAISE NOTICE 'F-056 bị từ chối (shop_owner TRUNCATE cash_count_line): %', SQLERRM;
  END;
  BEGIN
    TRUNCATE opening_float_line;
    RAISE EXCEPTION 'F-056: shop_owner TRUNCATE được bảng xấp tiền đầu két khi có ngày đã ký';
  EXCEPTION WHEN restrict_violation THEN
    RAISE NOTICE 'F-056 bị từ chối (shop_owner TRUNCATE opening_float_line): %', SQLERRM;
  END;

  -- Vai ghi của hệ thống: thêm và sửa bị khoá từ chối (vai này vốn không có quyền xoá — QD-50).
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd) VALUES (c, 50000, 200000);
    RAISE EXCEPTION 'F-056: shop_app THÊM được một xấp vào số đếm của ngày đã ký';
  EXCEPTION WHEN restrict_violation THEN
    RAISE NOTICE 'F-056 bị từ chối (shop_app thêm xấp 50.000 × 4 vào số đếm ngày đã ký): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    PERFORM set_config('shop.revision_reason', 'đếm lại sau khi ký', true);
    UPDATE cash_count_line SET amount_vnd = 400000 WHERE id = l_c;
    RAISE EXCEPTION 'F-056: shop_app SỬA được một xấp của số đếm ngày đã ký (dù khai lý do)';
  EXCEPTION WHEN restrict_violation THEN
    RAISE NOTICE 'F-056 bị từ chối (shop_app sửa xấp số đếm ngày đã ký, có lý do): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd) VALUES (f, 2000, 20000);
    RAISE EXCEPTION 'F-056: shop_app THÊM được một xấp vào tiền đầu két của ngày đã ký';
  EXCEPTION WHEN restrict_violation THEN
    RAISE NOTICE 'F-056 bị từ chối (shop_app thêm xấp vào tiền đầu két ngày đã ký): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE opening_float_line SET amount_vnd = 50000 WHERE id = l_f;
    RAISE EXCEPTION 'F-056: shop_app SỬA được một xấp của tiền đầu két ngày đã ký';
  EXCEPTION WHEN restrict_violation THEN
    RAISE NOTICE 'F-056 bị từ chối (shop_app sửa xấp tiền đầu két ngày đã ký): %', SQLERRM;
  END;
  -- Khối con hỏng thì cài đặt trong nó lùi theo: vai và người thao tác còn nguyên.
  IF current_user <> session_user THEN RAISE EXCEPTION 'test: vai không lùi về'; END IF;
  IF actor_person_id() IS NULL THEN RAISE EXCEPTION 'test: mất người thao tác'; END IF;

  -- Con số của ngày đã ký đọc lại bằng chính nó, và không vết nào sinh ra từ các lần bị từ chối.
  SELECT sum(amount_vnd) INTO tong FROM cash_count_line WHERE cash_count_id = c;
  IF tong <> 2000000 THEN RAISE EXCEPTION 'F-056: số đếm ngày đã ký đổi thành %', tong; END IF;
  SELECT sum(amount_vnd) INTO tong FROM opening_float_line WHERE opening_float_id = f;
  IF tong <> 1200000 THEN RAISE EXCEPTION 'F-056: tiền đầu két ngày đã ký đổi thành %', tong; END IF;
  RAISE NOTICE 'T-134 nhóm một — ngày 2026-09-21 đã ký: số đếm 2000000, tiền đầu két 1200000, đứng yên';

  -- Ngày CHƯA ký bên cạnh vẫn ghi được sau khi ngày kia đã ký: khoá theo ngày, không theo bảng.
  INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd) VALUES (c2, 1000, 3000);

  -- ================================================================ nhóm hai: không ký ngày chưa đếm
  -- Phép thử của F-057: số đếm có dòng đầu mà không dòng mệnh giá nào ⇒ dấu bị từ chối.
  INSERT INTO opening_float (sale_date) VALUES ('2026-09-23') RETURNING id INTO f3;
  INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd) VALUES (f3, 10000, 300000);
  INSERT INTO cash_count (sale_date) VALUES ('2026-09-23') RETURNING id INTO c3;
  BEGIN
    INSERT INTO reconciled_day (sale_date) VALUES ('2026-09-23');
    RAISE EXCEPTION 'F-057: database KHÔNG từ chối dấu cho ngày có số đếm không dòng mệnh giá nào';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'F-057 bị từ chối (ký ngày có số đếm rỗng): %', SQLERRM;
  END;
  -- Tiền đầu két có dòng đầu mà không dòng nào ⇒ cũng từ chối.
  INSERT INTO opening_float (sale_date) VALUES ('2026-09-24');
  INSERT INTO cash_count (sale_date) VALUES ('2026-09-24') RETURNING id INTO c4;
  INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd) VALUES (c4, 10000, 100000);
  BEGIN
    INSERT INTO reconciled_day (sale_date) VALUES ('2026-09-24');
    RAISE EXCEPTION 'F-057: database KHÔNG từ chối dấu cho ngày có tiền đầu két không dòng mệnh giá nào';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'F-057 bị từ chối (ký ngày có tiền đầu két rỗng): %', SQLERRM;
  END;
  -- Dời một dấu đã đứng sang ngày có số đếm rỗng (chỉ chủ lược đồ có quyền sửa dấu) ⇒ từ chối.
  BEGIN
    UPDATE reconciled_day SET sale_date = '2026-09-23' WHERE sale_date = '2026-09-21';
    RAISE EXCEPTION 'F-057: shop_owner DỜI được dấu sang ngày có số đếm rỗng';
  EXCEPTION WHEN check_violation OR restrict_violation THEN
    RAISE NOTICE 'F-057 bị từ chối (dời dấu sang ngày có số đếm rỗng): %', SQLERRM;
  END;
  -- Đủ dòng ở cả hai vế thì ký được; dấu không đòi phép trừ ra 0 (U-073 — không chọn hộ).
  INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd) VALUES (c3, 10000, 10000);
  INSERT INTO reconciled_day (sale_date) VALUES ('2026-09-23');
  RAISE NOTICE 'T-134 nhóm hai — ngày 2026-09-23 có dòng ở cả hai vế: ký được dù két lệch (U-073 không chọn hộ)';

  SET CONSTRAINTS ALL IMMEDIATE;
END $$;
