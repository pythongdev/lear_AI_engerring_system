-- Ngày quản trị P2A-08, sau s1…s3 trong cùng phiên (ADR-067).
-- Mỗi DO ngoài cùng là một giao dịch được psql tự COMMIT; người thao tác khai ở sc_buoc.
-- Tên người dùng lại các vai của dữ liệu diễn, không phải tên nhân viên thật.
-- Tên hàng mới, lượng 10/7 · 2/6 · 4/1, tiền 100000/50000 và ghi chú là DỮ LIỆU DIỄN.
-- Không gán đơn vị lượng đã dùng, không quy đổi. D là ngày diễn; đọc cặp số D-1 và D
-- để chứng minh giữ được nhiều ngày, không suy thành quy tắc cho phép nhập bù.
-- Chủ quán huỷ trong ca diễn là lựa chọn dữ liệu, không quyết ai được huỷ (U-071).
-- Ghi khoản chi: vắng, chờ ADR-074 — P2A-05 chưa Done; không dựng bảng hay dòng thay.

-- S4.1 — master_plan/shop-facts.md §8.4 dòng 1552–1556, 1616–1617.
DO $$
BEGIN
  PERFORM pg_temp.sc_buoc('Chủ quán', 'S4.1 — thêm một thứ mới, đơn vị chưa có lời để trống');
  -- Chụp đường tiền trước admin; cuối S4 so từng dòng, không đổi đáp số s1…s3.
  CREATE TEMP TABLE s4_tien_truoc AS
    SELECT 'bill' AS bang, to_jsonb(x) AS dong FROM bill x
    UNION ALL SELECT 'prepayment', to_jsonb(x) FROM prepayment x
    UNION ALL SELECT 'prepayment_use', to_jsonb(x) FROM prepayment_use x
    UNION ALL SELECT 'refund', to_jsonb(x) FROM refund x
    UNION ALL SELECT 'debt_collection', to_jsonb(x) FROM debt_collection x
    UNION ALL SELECT 'opening_float', to_jsonb(x) FROM opening_float x
    UNION ALL SELECT 'opening_float_line', to_jsonb(x) FROM opening_float_line x;
  INSERT INTO supply_item (name) VALUES ('Hàng thêm S4 (dữ liệu diễn)');
  RAISE NOTICE 'S4.1 thêm một thứ mới, đơn vị chưa có lời để trống';
END $$;

-- S4.2 — master_plan/shop-facts.md §8.4 dòng 1525–1544, 1654–1657.
DO $$
BEGIN
  PERFORM pg_temp.sc_buoc('Chủ quán', 'S4.2 — Gạo: mua 10, dùng 7, ngày D-1');
  INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
  SELECT id, pg_temp.sc_ngay() + (-1), v.kind, v.amount
  FROM supply_item CROSS JOIN (VALUES ('purchased', 10), ('used', 7)) v(kind, amount)
  WHERE name = 'Gạo';
  RAISE NOTICE 'S4.2 Gạo: mua 10, dùng 7, ngày D-1';
END $$;

-- S4.3 — master_plan/shop-facts.md §8.4 dòng 1525–1544, 1654–1657.
DO $$
BEGIN
  PERFORM pg_temp.sc_buoc('Chủ quán', 'S4.3 — Gạo: mua 2, dùng 6, ngày D+0');
  INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
  SELECT id, pg_temp.sc_ngay() + (0), v.kind, v.amount
  FROM supply_item CROSS JOIN (VALUES ('purchased', 2), ('used', 6)) v(kind, amount)
  WHERE name = 'Gạo';
  RAISE NOTICE 'S4.3 Gạo: mua 2, dùng 6, ngày D+0';
END $$;

-- S4.4 — master_plan/shop-facts.md §8.4 dòng 1525–1544, 1654–1657.
DO $$
BEGIN
  PERFORM pg_temp.sc_buoc('Chủ quán', 'S4.4 — Hàng thêm S4 (dữ liệu diễn): mua 4, dùng 1, ngày D+0');
  INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
  SELECT id, pg_temp.sc_ngay() + (0), v.kind, v.amount
  FROM supply_item CROSS JOIN (VALUES ('purchased', 4), ('used', 1)) v(kind, amount)
  WHERE name = 'Hàng thêm S4 (dữ liệu diễn)';
  RAISE NOTICE 'S4.4 Hàng thêm S4 (dữ liệu diễn): mua 4, dùng 1, ngày D+0';
END $$;

-- S4.5 — master_plan/shop-facts.md §8.7 dòng 1866–1869, 1880–1882.
DO $$
BEGIN
  PERFORM pg_temp.sc_buoc('Chủ quán', 'S4.5 — tick có đi làm: Người đứng quầy');
  INSERT INTO attendance_day (worker_person_id, work_date)
  VALUES (pg_temp.sc_nguoi('Người đứng quầy'), pg_temp.sc_ngay());
  RAISE NOTICE 'S4.5 tick có đi làm: Người đứng quầy';
END $$;

-- S4.6 — master_plan/shop-facts.md §8.7 dòng 1866–1869, 1880–1882.
DO $$
BEGIN
  PERFORM pg_temp.sc_buoc('Chủ quán', 'S4.6 — tick có đi làm: Người canh & dọn (tick nhầm)');
  INSERT INTO attendance_day (worker_person_id, work_date)
  VALUES (pg_temp.sc_nguoi('Người canh & dọn'), pg_temp.sc_ngay());
  RAISE NOTICE 'S4.6 tick có đi làm: Người canh & dọn (tick nhầm)';
END $$;

-- S4.7 — master_plan/shop-facts.md §8.7 dòng 1870–1874.
DO $$
BEGIN
  PERFORM pg_temp.sc_buoc('Chủ quán', 'S4.7 — huỷ ô tick nhầm, giữ người huỷ và ghi chú');
  UPDATE attendance_day SET cancelled_at = now(),
    cancelled_by_person_id = pg_temp.sc_nguoi('Chủ quán'), cancel_note = 'Tick nhầm người (dữ liệu diễn)'
  WHERE worker_person_id = pg_temp.sc_nguoi('Người canh & dọn') AND work_date = pg_temp.sc_ngay()
    AND cancelled_at IS NULL;
  RAISE NOTICE 'S4.7 huỷ ô tick nhầm, giữ người huỷ và ghi chú';
END $$;

-- S4.8 — master_plan/shop-facts.md §8.7 dòng 1835, 1858–1861.
DO $$
BEGIN
  PERFORM pg_temp.sc_buoc('Chủ quán', 'S4.8 — tạm ứng 100000 đ, Chủ quán duyệt');
  INSERT INTO staff_advance (worker_person_id, amount_vnd, paid_date, approver_person_id)
  VALUES (pg_temp.sc_nguoi('Người đứng quầy'), 100000, pg_temp.sc_ngay(), pg_temp.sc_nguoi('Chủ quán'));
  RAISE NOTICE 'S4.8 tạm ứng 100000 đ, Chủ quán duyệt';
END $$;

-- S4.9 — master_plan/shop-facts.md §8.7 dòng 1834, 1858–1861.
DO $$
BEGIN
  PERFORM pg_temp.sc_buoc('Chủ quán', 'S4.9 — thưởng lễ Tết 50000 đ');
  INSERT INTO holiday_bonus (worker_person_id, amount_vnd, paid_date)
  VALUES (pg_temp.sc_nguoi('Người canh & dọn'), 50000, pg_temp.sc_ngay());
  IF EXISTS (
    WITH sau AS (
      SELECT 'bill' AS bang, to_jsonb(x) AS dong FROM bill x
      UNION ALL SELECT 'prepayment', to_jsonb(x) FROM prepayment x
      UNION ALL SELECT 'prepayment_use', to_jsonb(x) FROM prepayment_use x
      UNION ALL SELECT 'refund', to_jsonb(x) FROM refund x
      UNION ALL SELECT 'debt_collection', to_jsonb(x) FROM debt_collection x
      UNION ALL SELECT 'opening_float', to_jsonb(x) FROM opening_float x
      UNION ALL SELECT 'opening_float_line', to_jsonb(x) FROM opening_float_line x
    )
    (SELECT * FROM sau EXCEPT ALL SELECT * FROM s4_tien_truoc)
    UNION ALL (SELECT * FROM s4_tien_truoc EXCEPT ALL SELECT * FROM sau)
  ) THEN
    RAISE EXCEPTION 'S4 DỪNG: khoản admin làm đổi đường tiền bán hàng/két — báo Claude, không sửa đáp số S1…S3';
  END IF;
  RAISE NOTICE 'S4.9 thưởng lễ Tết 50000 đ';
END $$;
