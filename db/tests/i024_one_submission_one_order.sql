-- I-024 (tầng 1, hai vế): một dấu lần gửi sinh nhiều nhất một đơn — kể cả khi hai lần gửi
-- lại tới CÙNG LÚC — và không đơn nào thiếu dấu. Kịch bản: quality/invariants.md I-024
-- Verification. Lát: 02-luoc-do-ban-hang.md §2. Mỗi kịch bản âm phải bị từ chối bởi ĐÚNG
-- ràng buộc nó nhắm.
--
-- Kịch bản song song mở HAI kết nối thật qua dblink. Kết nối đầu COMMIT, nên một đơn
-- Pickup của kịch bản ấy còn lại sau ROLLBACK của file — trong database riêng mà
-- db-check dựng rồi gỡ sau mỗi lần chạy, không phải database làm việc.
-- Người thao tác của giao dịch (P2-08, 06-luoc-do-nguoi-va-vet.md §0): mọi cột "ai bấm" lấy mặc
-- định từ đây — không khai thì thao tác chạm tiền, mẻ, lần chuyển, mã QR đều không ghi được.
DO $$
DECLARE p bigint;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy') RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
END $$;
CREATE EXTENSION IF NOT EXISTS dblink;

CREATE FUNCTION pg_temp.expect_reject(label text, stmt text, want text) RETURNS void
LANGUAGE plpgsql AS $$
DECLARE got text; col text;
BEGIN
  BEGIN
    EXECUTE stmt;
  EXCEPTION WHEN unique_violation OR check_violation OR not_null_violation THEN
    GET STACKED DIAGNOSTICS got = CONSTRAINT_NAME, col = COLUMN_NAME;
    IF coalesce(nullif(got, ''), 'NOT NULL ' || col) IS DISTINCT FROM want THEN
      RAISE EXCEPTION 'I-024 (%): bị chặn bởi % thay vì %', label, coalesce(nullif(got, ''), col), want;
    END IF;
    RAISE NOTICE 'I-024 bị từ chối (%): %', label, SQLERRM;
    RETURN;
  END;
  RAISE EXCEPTION 'I-024: database KHÔNG từ chối — %', label;
END $$;

-- Một đơn Pickup hợp lệ theo I-022, mang dấu cho trước.
CREATE FUNCTION pg_temp.pickup(code text) RETURNS text LANGUAGE sql AS $$
  SELECT format($q$INSERT INTO sales_order (channel_code, status, handover_code, customer_phone,
                                             customer_needed_at, submission_code)
                   VALUES ('pickup', 'pending_confirmation', 'shop_pickup', '0900000000', now(), %L)$q$,
                code)
$$;

DO $$
DECLARE t5 bigint; s5 bigint; o1 bigint; n bigint; msg text; code text; q5 bigint;
        conn text := 'dbname=banhcuon user=shop_app password=shop_app_dev';
BEGIN
  -- Kịch bản âm 1: một đơn Pickup, gửi lại cùng dấu năm lần (tuần tự) ⇒ đúng một đơn.
  EXECUTE pg_temp.pickup('lan-gui-pickup');
  FOR i IN 1..5 LOOP
    PERFORM pg_temp.expect_reject(format('gửi lại Pickup lần %s', i),
      pg_temp.pickup('lan-gui-pickup'), 'sales_order_submission_code_key');
  END LOOP;
  SELECT count(*) INTO n FROM sales_order WHERE submission_code = 'lan-gui-pickup';
  IF n <> 1 THEN RAISE EXCEPTION 'I-024: dấu lan-gui-pickup mang % đơn', n; END IF;
  RAISE NOTICE 'I-024 sau năm lần gửi lại: dấu lan-gui-pickup mang % đơn', n;

  -- Kịch bản âm 2: lượt gọi qr_table và staff_pos vào bàn 5, mỗi lượt gửi lại một lần.
  INSERT INTO dining_table (label) VALUES ('test-5') RETURNING id INTO t5;
  q5 := qr_code_issue(t5);  -- lượt gọi qr_table mang mã của bàn (I-023, T-114)
  INSERT INTO table_session (status) VALUES ('serving') RETURNING id INTO s5;
  INSERT INTO table_session_member (table_session_id, dining_table_id) VALUES (s5, t5);
  INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, submission_code, qr_code_id)
  VALUES ('qr_table', 'new', s5, t5, 'lan-gui-qr', q5);
  PERFORM pg_temp.expect_reject('gửi lại lượt gọi qr_table',
    format($q$INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, submission_code, qr_code_id)
              VALUES ('qr_table', 'new', %s, %s, 'lan-gui-qr', %s)$q$, s5, t5, q5),
    'sales_order_submission_code_key');
  INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, submission_code)
  VALUES ('staff_pos', 'confirmed', s5, t5, 'lan-gui-pos');
  PERFORM pg_temp.expect_reject('gửi lại lượt gọi staff_pos (bấm đúp lúc đông)',
    format($q$INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, submission_code)
              VALUES ('staff_pos', 'confirmed', %s, %s, 'lan-gui-pos')$q$, s5, t5),
    'sales_order_submission_code_key');
  SELECT count(*) INTO n FROM sales_order WHERE table_session_id = s5;
  IF n <> 2 THEN RAISE EXCEPTION 'I-024: phiên bàn 5 có % lượt gọi thay vì 2', n; END IF;
  RAISE NOTICE 'I-024 phiên bàn 5 sau hai lần gửi lại: % lượt gọi (một qr_table, một staff_pos)', n;

  -- Kịch bản âm 3: gửi lại cùng dấu mà khác nội dung ⇒ từ chối, đơn đầu giữ nguyên. Nội
  -- dung đổi ở đây là số điện thoại: dòng suất cần ảnh chụp menu của P2-05, và ràng buộc
  -- chỉ đọc dấu nên trường nào khác cũng cho cùng một lời từ chối.
  SELECT id INTO o1 FROM sales_order WHERE submission_code = 'lan-gui-pickup';
  PERFORM pg_temp.expect_reject('gửi lại cùng dấu, đổi số điện thoại',
    $q$INSERT INTO sales_order (channel_code, status, handover_code, customer_phone,
                                customer_needed_at, submission_code)
       VALUES ('pickup', 'pending_confirmation', 'shop_pickup', '0911111111', now(), 'lan-gui-pickup')$q$,
    'sales_order_submission_code_key');
  SELECT customer_phone INTO msg FROM sales_order WHERE id = o1;
  IF msg <> '0900000000' THEN RAISE EXCEPTION 'I-024: đơn đầu đổi số thành %', msg; END IF;
  RAISE NOTICE 'I-024 đơn đầu sau lần gửi lại khác nội dung: số vẫn là %', msg;

  -- Kịch bản âm 4: đơn không mang dấu, và dấu chỉ có khoảng trắng.
  PERFORM pg_temp.expect_reject('đơn không mang dấu',
    $q$INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at)
       VALUES ('pickup', 'pending_confirmation', 'shop_pickup', '0900000000', now())$q$,
    'NOT NULL submission_code');
  PERFORM pg_temp.expect_reject('dấu chỉ có khoảng trắng', pg_temp.pickup('   '),
    'sales_order_submission_code_not_blank_check');
  PERFORM pg_temp.expect_reject('xoá dấu của một đơn đã tạo',
    format('UPDATE sales_order SET submission_code = NULL WHERE id = %s', o1),
    'NOT NULL submission_code');

  -- Kịch bản âm 1, nửa song song: hai lần gửi lại tới CÙNG LÚC trên hai kết nối thật.
  -- A ghi mà chưa COMMIT; B ghi cùng dấu trong lúc ấy. B phải bị database GIỮ LẠI (chưa
  -- trả lời), rồi bị từ chối khi A COMMIT — không phải cả hai cùng "kiểm thấy chưa có".
  code := 'lan-gui-song-song-' || gen_random_uuid();
  PERFORM dblink_connect('i024_a', conn);
  PERFORM dblink_connect('i024_b', conn);
  PERFORM dblink_exec('i024_a', 'BEGIN');
  PERFORM dblink_exec('i024_a', pg_temp.pickup(code));
  PERFORM dblink_send_query('i024_b', pg_temp.pickup(code));
  PERFORM pg_sleep(0.5);
  IF dblink_is_busy('i024_b') <> 1 THEN
    RAISE EXCEPTION 'I-024: kết nối B không bị giữ lại — hai lần ghi không chồng lên nhau';
  END IF;
  RAISE NOTICE 'I-024 song song: A đã ghi chưa COMMIT, B ghi cùng dấu và đang bị giữ lại';
  PERFORM dblink_exec('i024_a', 'COMMIT');
  PERFORM * FROM dblink_get_result('i024_b', false) AS t(res text);
  msg := dblink_error_message('i024_b');
  PERFORM * FROM dblink_get_result('i024_b', false) AS t(res text);
  PERFORM dblink_disconnect('i024_a');
  PERFORM dblink_disconnect('i024_b');
  IF msg NOT LIKE '%sales_order_submission_code_key%' THEN
    RAISE EXCEPTION 'I-024: database KHÔNG từ chối lần gửi song song thứ hai (B: %)', msg;
  END IF;
  RAISE NOTICE 'I-024 bị từ chối (lần gửi song song thứ hai, sau khi A COMMIT): %', msg;
  SELECT count(*) INTO n FROM sales_order WHERE submission_code = code;
  IF n <> 1 THEN RAISE EXCEPTION 'I-024: dấu song song mang % đơn', n; END IF;
  RAISE NOTICE 'I-024 song song: dấu mang % đơn', n;

  -- Kịch bản biên: lần đầu bị I-022 từ chối (thiếu địa chỉ) ⇒ không đơn nào mang dấu;
  -- gửi lại cùng dấu khi đã điền ⇒ tạo được.
  PERFORM pg_temp.expect_reject('lần gửi đầu thiếu địa chỉ',
    $q$INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, submission_code)
       VALUES ('delivery', 'pending_confirmation', 'door_delivery', '0900000000', 'lan-gui-bien')$q$,
    'sales_order_door_delivery_address_check');
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, delivery_address,
                           submission_code)
  VALUES ('delivery', 'pending_confirmation', 'door_delivery', '0900000000', '12 Hàng Bạc', 'lan-gui-bien');
  RAISE NOTICE 'I-024 tạo được: gửi lại cùng dấu sau khi lần đầu bị I-022 từ chối';

  -- Kịch bản dương, chống đọc rộng: nội dung giống hệt, dấu khác ⇒ hai đơn thật.
  INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, submission_code, qr_code_id)
  VALUES ('qr_table', 'new', s5, t5, 'lan-gui-qr-goi-them', q5);
  SELECT count(*) INTO n FROM sales_order WHERE table_session_id = s5;
  RAISE NOTICE 'I-024 tạo được: bàn 5 gọi thêm đúng món bằng một lần gửi mới — phiên có % lượt gọi', n;
  EXECUTE pg_temp.pickup('lan-gui-lay-1');
  EXECUTE pg_temp.pickup('lan-gui-lay-2');
  SELECT count(*) INTO n FROM sales_order WHERE submission_code IN ('lan-gui-lay-1', 'lan-gui-lay-2');
  IF n <> 2 THEN RAISE EXCEPTION 'I-024: hai đơn tới lấy giống hệt thành % đơn', n; END IF;
  RAISE NOTICE 'I-024 tạo được: hai đơn tới lấy giống hệt, hai dấu ⇒ % đơn', n;

  -- Tập đối chiếu của hàng I-024 (03-bao-ve-invariant.md §1) viết được hôm nay. Tập thứ ba
  -- (nội dung khác lúc tạo mà không có vết I-018) chờ vết của P2-08 — file lát §5.
  SELECT count(*) INTO n FROM (
    SELECT submission_code FROM sales_order GROUP BY submission_code HAVING count(*) > 1) d;
  IF n > 0 THEN RAISE EXCEPTION 'I-024 đối chiếu 1: % dấu mang hơn một đơn', n; END IF;
  SELECT count(*) INTO n FROM sales_order
   WHERE submission_code IS NULL OR btrim(submission_code) = '';
  IF n > 0 THEN RAISE EXCEPTION 'I-024 đối chiếu 2: % đơn không mang dấu', n; END IF;
  RAISE NOTICE 'I-024 đối chiếu: hai tập viết được đều rỗng';
END $$;
