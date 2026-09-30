-- I-026 (tầng 1) và YC-29: tổng đã nhập, tổng đã dùng và hiệu số của một thứ là MỘT PHÉP CỘNG
-- trên các con số ngày của nó — không con số tổng nào được cất; cộng dồn từ ngày mua, không đặt
-- lại khi mua thêm; một thứ · một ngày · một loại con số có đúng một đáp số; một thứ đứng một lần
-- trong danh mục; hiệu số âm được nhận, máy không kết luận gì. Chạy đúng kịch bản của mục
-- Verification ở quality/invariants.md I-026. Lát: 12-luoc-do-nguyen-lieu.md.

-- Phép cộng ấy — cộng MỌI con số ngày của một thứ, không lọc theo lần mua hay theo lô.
CREATE FUNCTION pg_temp.tong(p_item bigint)
RETURNS TABLE (da_nhap numeric, da_dung numeric, hieu_so numeric) LANGUAGE sql AS $f$
  SELECT COALESCE(SUM(entered_measure) FILTER (WHERE kind_code = 'purchased'), 0),
         COALESCE(SUM(entered_measure) FILTER (WHERE kind_code = 'used'), 0),
         COALESCE(SUM(entered_measure) FILTER (WHERE kind_code = 'purchased'), 0)
           - COALESCE(SUM(entered_measure) FILTER (WHERE kind_code = 'used'), 0)
  FROM supply_day_entry WHERE supply_item_id = p_item
$f$;

DO $$
DECLARE chu bigint; gao bigint; quat bigint; e2 bigint; r record;
BEGIN
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán', true) RETURNING id INTO chu;
  PERFORM set_config('shop.actor_person_id', chu::text, true);
  INSERT INTO supply_item (name, purchase_unit) VALUES ('test-gạo', 'kg') RETURNING id INTO gao;
  INSERT INTO supply_item (name) VALUES ('test-quất') RETURNING id INTO quat;

  -- Một thứ chưa có con số nào: ba con số đọc ra là 0, không phải trống.
  SELECT * INTO r FROM pg_temp.tong(quat);
  IF (r.da_nhap, r.da_dung, r.hieu_so) IS DISTINCT FROM (0::numeric, 0::numeric, 0::numeric) THEN
    RAISE EXCEPTION 'I-026: thứ chưa có con số nào mà tổng không phải 0';
  END IF;

  -- Kịch bản dương: ba ngày liền, mua vào 10 · 0 · 5, đã dùng 4 · 3 · 6.
  INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure) VALUES
    (gao, '2026-09-21', 'purchased', 10), (gao, '2026-09-21', 'used', 4),
    (gao, '2026-09-22', 'purchased', 0),  (gao, '2026-09-23', 'purchased', 5),
    (gao, '2026-09-23', 'used', 6);
  INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
  VALUES (gao, '2026-09-22', 'used', 3) RETURNING id INTO e2;
  SELECT * INTO r FROM pg_temp.tong(gao);
  RAISE NOTICE 'I-026 ba ngày — tổng đã nhập %, tổng đã dùng %, hiệu số % (ngày thứ ba mua thêm, tổng không đặt lại)',
    r.da_nhap, r.da_dung, r.hieu_so;
  IF (r.da_nhap, r.da_dung, r.hieu_so) IS DISTINCT FROM (15::numeric, 13::numeric, 2::numeric) THEN
    RAISE EXCEPTION 'I-026: tổng không phải 15 · 13 · 2';
  END IF;

  -- Kịch bản sửa: đã dùng ngày thứ hai 3 → 5 ⇒ tổng đã dùng 15, hiệu số 0 — không ai sửa con số
  -- tổng nào, vì không có con số tổng nào để sửa.
  PERFORM set_config('shop.revision_reason', 'test-nhớ lại lượng đã dùng', true);
  UPDATE supply_day_entry SET entered_measure = 5 WHERE id = e2;
  SELECT * INTO r FROM pg_temp.tong(gao);
  RAISE NOTICE 'I-026 sau khi sửa một con số ngày — tổng đã nhập %, tổng đã dùng %, hiệu số %',
    r.da_nhap, r.da_dung, r.hieu_so;
  IF (r.da_nhap, r.da_dung, r.hieu_so) IS DISTINCT FROM (15::numeric, 15::numeric, 0::numeric) THEN
    RAISE EXCEPTION 'I-026: sau lần sửa, tổng không phải 15 · 15 · 0';
  END IF;

  -- Kịch bản biên: đã dùng lớn hơn tổng đã nhập ⇒ NHẬN; hiệu số âm là một con số, không phải một
  -- phán quyết (shop-facts §8.4, U-045).
  INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
  VALUES (gao, '2026-09-24', 'used', 4);
  SELECT * INTO r FROM pg_temp.tong(gao);
  RAISE NOTICE 'I-026 đã dùng vượt tổng đã nhập — nhận, hiệu số %', r.hieu_so;
  IF r.hieu_so IS DISTINCT FROM -4::numeric THEN
    RAISE EXCEPTION 'I-026: hiệu số âm không đọc ra đúng −4';
  END IF;

  -- Kịch bản âm: con số mua vào THỨ HAI cho cùng một thứ, cùng một ngày.
  BEGIN
    INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
    VALUES (gao, '2026-09-21', 'purchased', 2);
    RAISE EXCEPTION 'I-026: database KHÔNG từ chối con số mua vào thứ hai của một thứ trong một ngày';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-026 bị từ chối (hai con số mua vào cho một thứ, một ngày): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
    VALUES (gao, '2026-09-21', 'used', 1);
    RAISE EXCEPTION 'I-026: database KHÔNG từ chối con số đã dùng thứ hai của một thứ trong một ngày';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-026 bị từ chối (hai con số đã dùng cho một thứ, một ngày): %', SQLERRM;
  END;
  -- Một thứ đứng MỘT lần trong danh mục — trùng tên thì tổng của nó tách làm hai.
  BEGIN
    INSERT INTO supply_item (name) VALUES ('test-gạo');
    RAISE EXCEPTION 'I-026: database KHÔNG từ chối một thứ trùng tên một thứ đã có';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'I-026 bị từ chối (trùng tên trong danh mục): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL IMMEDIATE;
END $$;
