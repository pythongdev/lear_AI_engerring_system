-- Ngày quản trị lượt hai P2A-15; chạy sau s1…s4, cùng ngày mai của prelude.sql.
-- Mỗi DO ngoài cùng là một giao dịch psql tự COMMIT; sc_buoc khai người và lý do.
-- Tên vai là người sẵn có của dữ liệu diễn, không phải nhân viên thật. Tên tài khoản,
-- Gmail, mật khẩu $argon2id$ viết sẵn (KHÔNG băm thật), mã phiên, việc, hướng dẫn,
-- nhận xét, danh mục, combo, số phần 2 và giá 27000 đ đều là DỮ LIỆU DIỄN.
-- 11:31…12:20 nối sau khoảng 05:30–11:30 của mo_ngay, không chồng s1…s4.
-- S5.7 lúc 12:00 ngoài giờ bán 06:00–11:00 (shop-facts §1 dòng 26).
-- S5.9 mở lại một phiên ngoài quầy lúc 12:12 làm tiền đề cho quên mật khẩu:
-- đặt lại phải thực sự kết thúc một phiên, không kiểm đúng trên tập rỗng.
-- Không gửi thư, không gọi cửa đăng nhập thật; đây chỉ là diễn qua lược đồ.

-- S5.1 — master_plan/shop-facts.md §8.8 dòng 2071–2074.
DO $$
DECLARE acc bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người canh & dọn', 'S5.1 — tự đăng ký và tự đặt mật khẩu');
  CREATE TEMP TABLE s5_tien_truoc AS
    SELECT 'bill' AS bang, to_jsonb(x) AS dong FROM bill x
    UNION ALL SELECT 'prepayment', to_jsonb(x) FROM prepayment x
    UNION ALL SELECT 'prepayment_use', to_jsonb(x) FROM prepayment_use x
    UNION ALL SELECT 'refund', to_jsonb(x) FROM refund x
    UNION ALL SELECT 'debt_collection', to_jsonb(x) FROM debt_collection x
    UNION ALL SELECT 'opening_float', to_jsonb(x) FROM opening_float x
    UNION ALL SELECT 'opening_float_line', to_jsonb(x) FROM opening_float_line x;
  INSERT INTO account (username, email, requested_display_name, created_at)
  VALUES ('s5.nguoi.lam', 's5.nguoi.lam@gmail.com', 'Người canh & dọn', pg_temp.sc_luc('11:31'))
  RETURNING id INTO acc;
  INSERT INTO sc VALUES ('s5_account', acc);
  INSERT INTO account_password (account_id, password_hash, created_at)
  VALUES (acc, '$argon2id$s5-ban-dau-du-lieu-dien', pg_temp.sc_luc('11:31'));
  IF NOT EXISTS (SELECT 1 FROM account WHERE id = acc AND status = 'cho_duyet'
                 AND person_id IS NULL AND role_code IS NULL AND decided_at IS NULL
                 AND decided_by_person_id IS NULL) THEN
    RAISE EXCEPTION 'S5.1 tài khoản tự đăng ký phải chờ duyệt, chưa gắn người';
  END IF;
  RAISE NOTICE 'S5.1 tự đăng ký chờ duyệt, chưa gắn người; tự đặt mật khẩu';
END $$;

-- S5.2 — master_plan/shop-facts.md §8.8 dòng 2071–2072.
DO $$
BEGIN
  PERFORM pg_temp.sc_buoc('Chủ quán', 'S5.2 — duyệt và gán vai quầy');
  UPDATE account SET status = 'hoat_dong', person_id = pg_temp.sc_nguoi('Người canh & dọn'),
    role_code = 'quay', decided_at = pg_temp.sc_luc('11:32'),
    decided_by_person_id = pg_temp.sc_nguoi('Chủ quán') WHERE id = pg_temp.sc_id('s5_account');
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('11:32'));
  RAISE NOTICE 'S5.2 Chủ quán duyệt, gắn người sẵn có, gán vai quầy';
END $$;

-- S5.3 — master_plan/shop-facts.md §8.8 dòng 2075–2076, 2019–2021.
DO $$
DECLARE duty bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người canh & dọn', 'S5.3 — đăng nhập ở quầy, đổi người cùng giao dịch');
  UPDATE counter_duty SET ended_at = pg_temp.sc_luc('11:35')
  WHERE started_at <= pg_temp.sc_luc('11:35')
    AND (ended_at IS NULL OR ended_at > pg_temp.sc_luc('11:35'));
  INSERT INTO counter_duty (person_id, started_at)
  VALUES (pg_temp.sc_nguoi('Người canh & dọn'), pg_temp.sc_luc('11:35')) RETURNING id INTO duty;
  INSERT INTO login_session (account_id, token_hash, created_at, expires_at, counter_duty_id)
  VALUES (pg_temp.sc_id('s5_account'), sha256('s5-phien-quay'::bytea),
    pg_temp.sc_luc('11:35'), pg_temp.sc_luc('13:35'), duty);
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('11:35'));
  RAISE NOTICE 'S5.3 đăng nhập ở quầy: phiên gắn trực của chính Người canh & dọn';
END $$;

-- S5.4 — master_plan/shop-facts.md §8.7 dòng 1992–1998, 2000–2002.
DO $$
DECLARE task bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Chủ quán', 'S5.4 — giao việc kèm hướng dẫn chữ của đúng việc');
  INSERT INTO assigned_task (content, assignee_person_id, created_at)
  VALUES ('S5 lau bàn dụng cụ (dữ liệu diễn)', pg_temp.sc_nguoi('Người canh & dọn'), pg_temp.sc_luc('11:40'))
  RETURNING id INTO task;
  INSERT INTO sc VALUES ('s5_task', task);
  INSERT INTO assigned_task_guide (assigned_task_id, guide_kind_code, body, created_at)
  VALUES (task, 'text', 'S5 dùng khăn sạch lau bàn dụng cụ (dữ liệu diễn)', pg_temp.sc_luc('11:40'));
  RAISE NOTICE 'S5.4 Chủ quán giao việc, hướng dẫn chữ gắn đúng việc ấy';
END $$;

-- S5.5 — master_plan/shop-facts.md §8.7 dòng 1994–1995.
DO $$
BEGIN
  PERFORM pg_temp.sc_buoc('Người canh & dọn', 'S5.5 — POS đánh dấu xong việc');
  INSERT INTO assigned_task_mark (assigned_task_id, mark_code, created_at)
  VALUES (pg_temp.sc_id('s5_task'), 'done', pg_temp.sc_luc('11:45'));
  RAISE NOTICE 'S5.5 POS đang đứng quầy đánh dấu xong việc';
END $$;

-- S5.6 — master_plan/shop-facts.md §8.7 dòng 1995–1998.
DO $$
BEGIN
  PERFORM pg_temp.sc_buoc('Chủ quán', 'S5.6 — ghi nhận đào tạo đạt và nhận xét');
  INSERT INTO training_record (trainee_person_id, remark, rating_code, created_at)
  VALUES (pg_temp.sc_nguoi('Người canh & dọn'), 'S5 lau sạch bàn dụng cụ (dữ liệu diễn)',
    'pass', pg_temp.sc_luc('11:50'));
  RAISE NOTICE 'S5.6 Chủ quán ghi nhận đạt kèm nhận xét về Người canh & dọn';
END $$;

-- S5.7 — master_plan/shop-facts.md §8.9 dòng 2107–2112, 2114–2118.
DO $$
DECLARE category bigint; combo bigint; item bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Chủ quán', 'S5.7 — danh mục và combo giá riêng ngoài giờ bán');
  SELECT id INTO STRICT item FROM menu_item WHERE name = 'Bánh trứng tái';
  INSERT INTO menu_category (name, created_at)
  VALUES ('S5 món sau buổi (dữ liệu diễn)', pg_temp.sc_luc('12:00')) RETURNING id INTO category;
  INSERT INTO menu_item_category (menu_item_id, menu_category_id, created_at)
  VALUES (item, category, pg_temp.sc_luc('12:00'));
  INSERT INTO menu_combo (name, price_vnd, created_at)
  VALUES ('S5 combo hai suất (dữ liệu diễn)', 27000, pg_temp.sc_luc('12:00')) RETURNING id INTO combo;
  INSERT INTO menu_combo_item (menu_combo_id, menu_item_id, quantity, created_at)
  VALUES (combo, item, 2, pg_temp.sc_luc('12:00'));
  RAISE NOTICE 'S5.7 12:00 Chủ quán thêm danh mục, xếp Bánh trứng tái, combo hai suất giá riêng 27000 đ';
END $$;

-- S5.8 — master_plan/shop-facts.md §8.8 dòng 2075–2076, 2019–2021.
DO $$
BEGIN
  PERFORM pg_temp.sc_buoc('Người canh & dọn', 'S5.8 — đăng xuất và khép trực của phiên');
  UPDATE login_session SET ended_at = pg_temp.sc_luc('12:10'), end_reason = 'dang_xuat'
  WHERE token_hash = sha256('s5-phien-quay'::bytea) AND ended_at IS NULL;
  UPDATE counter_duty SET ended_at = pg_temp.sc_luc('12:10')
  WHERE id = (SELECT counter_duty_id FROM login_session WHERE token_hash = sha256('s5-phien-quay'::bytea));
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('12:10'));
  RAISE NOTICE 'S5.8 đăng xuất dang_xuat, khép khoảng trực của chính phiên lúc 12:10';
END $$;

-- S5.9 — master_plan/shop-facts.md §8.8 dòng 2061–2064, 2072–2074.
-- Hạn mã, băm và kết thúc phiên theo lát 19 / ADR-109 và phiếu P2A-15, không phải lời quán mới.
DO $$
DECLARE reset_id bigint;
BEGIN
  PERFORM pg_temp.sc_buoc('Người canh & dọn', 'S5.9 — quên mật khẩu, tự đặt lại trong hạn');
  INSERT INTO login_session (account_id, token_hash, created_at, expires_at)
  VALUES (pg_temp.sc_id('s5_account'), sha256('s5-phien-ngoai-quay'::bytea),
    pg_temp.sc_luc('12:12'), pg_temp.sc_luc('14:12'));
  INSERT INTO password_reset (account_id, token_hash, created_at, expires_at)
  VALUES (pg_temp.sc_id('s5_account'), sha256('s5-ma-dat-lai'::bytea),
    pg_temp.sc_luc('12:15'), pg_temp.sc_luc('12:45')) RETURNING id INTO reset_id;
  UPDATE password_reset SET used_at = pg_temp.sc_luc('12:20')
  WHERE id = reset_id AND used_at IS NULL
    AND created_at <= pg_temp.sc_luc('12:20') AND pg_temp.sc_luc('12:20') < expires_at;
  IF NOT FOUND THEN RAISE EXCEPTION 'S5.9 mã đặt lại không dùng được'; END IF;
  INSERT INTO account_password (account_id, password_hash, created_at)
  VALUES (pg_temp.sc_id('s5_account'), '$argon2id$s5-dat-lai-du-lieu-dien', pg_temp.sc_luc('12:20'));
  UPDATE login_session SET ended_at = pg_temp.sc_luc('12:20'), end_reason = 'dat_lai_mat_khau'
  WHERE account_id = pg_temp.sc_id('s5_account') AND ended_at IS NULL;
  PERFORM pg_temp.sc_xong(pg_temp.sc_luc('12:20'));
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
    (SELECT * FROM sau EXCEPT ALL SELECT * FROM s5_tien_truoc)
    UNION ALL (SELECT * FROM s5_tien_truoc EXCEPT ALL SELECT * FROM sau)
  ) THEN RAISE EXCEPTION 'S5 làm đổi đường tiền: DỪNG, không sửa đáp số TIỀN'; END IF;
  RAISE NOTICE 'S5.9 mã dùng một lần trong hạn, thêm mật khẩu, kết thúc mọi phiên mở vì dat_lai_mat_khau';
END $$;
