-- T-343 · I-021 — lần ghi số đếm/tiền đầu két và lần ký cùng một ngày chạy NỐI TIẾP ở tầng database,
-- kể cả khi đi vòng backend (lệnh SQL thẳng). Trigger ghi lấy khoá tư vấn CHUNG, trigger ký lấy khoá
-- RIÊNG, cùng khoá với backend: pg_advisory_xact_lock(_shared)(309, ngày - DATE '2000-01-01')
-- (be/internal/ngayban/sql/khoa_*.sql). Thiết kế: docs/decisions.md ADR-080, Sửa đổi 2026-11-23.
-- Viết TRƯỚC migration (Claude Code); trên lược đồ cũ phần A đỏ ngay vì không có khoá nào.
--
-- Phần B mở HAI kết nối thật qua dblink và COMMIT dữ liệu dựng của ngày 2001-01-02 (một ngày
-- đếm cân: tiền đầu két = số đếm = 100.000đ, không bán gì) và dấu ký của nó — trong database
-- riêng mà db-check dựng rồi gỡ sau mỗi lần chạy, cùng cách db/tests/i024_one_submission_one_order.sql.
DO $$
DECLARE p bigint;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-người đứng quầy T-343') RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
END $$;
CREATE EXTENSION IF NOT EXISTS dblink;

-- Khoá tư vấn hai số (309, k) do giao dịch này giữ, theo chế độ.
CREATE FUNCTION pg_temp.giu_khoa(ngay date, che_do text) RETURNS boolean LANGUAGE sql AS $$
  SELECT EXISTS (SELECT 1 FROM pg_locks
                  WHERE locktype = 'advisory' AND pid = pg_backend_pid() AND granted
                    AND classid = 309 AND objid = (ngay - DATE '2000-01-01') AND objsubid = 2
                    AND mode = che_do)
$$;

-- ================================================================ phần A: đúng khoá, trong giao dịch của file
DO $$
DECLARE f bigint; c bigint; g bigint;
BEGIN
  INSERT INTO opening_float (sale_date) VALUES ('2001-01-05') RETURNING id INTO f;
  INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd) VALUES (f, 10000, 100000);
  IF NOT pg_temp.giu_khoa('2001-01-05', 'ShareLock') THEN
    RAISE EXCEPTION 'T-343: ghi tiền đầu két ngày 2001-01-05 không lấy khoá chung (309, ngày) của backend';
  END IF;
  INSERT INTO cash_count (sale_date) VALUES ('2001-01-05') RETURNING id INTO c;
  INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd) VALUES (c, 10000, 100000);
  RAISE NOTICE 'T-343 phần A: ghi số đếm và tiền đầu két giữ khoá chung (309, 2001-01-05)';

  -- Cùng giao dịch đã giữ khoá chung vẫn ký được: khoá tư vấn không chặn chính giao dịch giữ nó.
  INSERT INTO reconciled_day (sale_date) VALUES ('2001-01-05');
  IF NOT pg_temp.giu_khoa('2001-01-05', 'ExclusiveLock') THEN
    RAISE EXCEPTION 'T-343: ký ngày 2001-01-05 không lấy khoá riêng (309, ngày) của backend';
  END IF;
  RAISE NOTICE 'T-343 phần A: ký ngày giữ khoá riêng (309, 2001-01-05), không tự chặn mình';

  -- Dời một số đếm sang ngày khác: cả ngày cũ lẫn ngày mới đều được khoá.
  INSERT INTO cash_count (sale_date) VALUES ('2001-01-07') RETURNING id INTO g;
  PERFORM set_config('shop.revision_reason', 'T-343 dời ngày số đếm', true);
  UPDATE cash_count SET sale_date = '2001-01-08' WHERE id = g;
  PERFORM set_config('shop.revision_reason', '', true);
  IF NOT (pg_temp.giu_khoa('2001-01-07', 'ShareLock') AND pg_temp.giu_khoa('2001-01-08', 'ShareLock')) THEN
    RAISE EXCEPTION 'T-343: dời số đếm 2001-01-07 → 2001-01-08 không khoá chung cả hai ngày';
  END IF;
  RAISE NOTICE 'T-343 phần A: dời ngày số đếm khoá chung cả ngày cũ lẫn ngày mới';
END $$;

-- ================================================================ phần B: hai kết nối thật
DO $t343$
DECLARE conn text := 'dbname=banhcuon user=shop_owner password=shop_owner_dev';
        msg text; nguoi text; tong bigint; n bigint;
        ghi text := $q$INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd)
                       SELECT id, %s, %s FROM cash_count WHERE sale_date = '2001-01-02'$q$;
BEGIN
  PERFORM dblink_connect('t343_a', conn);
  PERFORM dblink_connect('t343_b', conn);
  -- Dựng ngày 2001-01-02 đã đếm, CHƯA ký, và COMMIT để kết nối kia thấy.
  PERFORM dblink_exec('t343_a', $s$DO $d$
    DECLARE p bigint; f bigint; c bigint;
    BEGIN
      INSERT INTO person (display_name) VALUES ('test-người ký T-343') RETURNING id INTO p;
      PERFORM set_config('shop.actor_person_id', p::text, false);
      INSERT INTO opening_float (sale_date) VALUES ('2001-01-02') RETURNING id INTO f;
      INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd) VALUES (f, 10000, 100000);
      INSERT INTO cash_count (sale_date) VALUES ('2001-01-02') RETURNING id INTO c;
      INSERT INTO cash_count_line (cash_count_id, denomination_vnd, amount_vnd) VALUES (c, 10000, 100000);
    END $d$$s$);
  SELECT v INTO nguoi FROM dblink('t343_a', $s$SELECT current_setting('shop.actor_person_id')$s$) AS t(v text);
  PERFORM dblink_exec('t343_b', format($s$SET shop.actor_person_id = %L$s$, nguoi));

  -- B1 — ký trước, chưa COMMIT; lần ghi đến sau phải bị GIỮ LẠI. Ký lùi ⇒ lần ghi đi tiếp.
  PERFORM dblink_exec('t343_a', 'BEGIN');
  PERFORM dblink_exec('t343_a', $s$INSERT INTO reconciled_day (sale_date) VALUES ('2001-01-02')$s$);
  PERFORM dblink_exec('t343_b', 'BEGIN');
  PERFORM dblink_send_query('t343_b', format(ghi, 20000, 20000));
  PERFORM pg_sleep(0.5);
  IF dblink_is_busy('t343_b') <> 1 THEN
    RAISE EXCEPTION 'T-343 B1: lần ghi số đếm KHÔNG chờ lần ký đang dở của cùng ngày — hai bên cùng qua';
  END IF;
  RAISE NOTICE 'T-343 B1: lần ký chưa COMMIT, lần ghi cùng ngày đang bị giữ lại';
  PERFORM dblink_exec('t343_a', 'ROLLBACK');
  PERFORM * FROM dblink_get_result('t343_b', false) AS t(res text);
  msg := dblink_error_message('t343_b');
  PERFORM * FROM dblink_get_result('t343_b', false) AS t(res text);
  PERFORM dblink_exec('t343_b', 'ROLLBACK');
  IF msg IS DISTINCT FROM 'OK' THEN
    RAISE EXCEPTION 'T-343 B1: lần ký lùi rồi mà lần ghi vẫn hỏng: %', msg;
  END IF;
  RAISE NOTICE 'T-343 B1: lần ký lùi, lần ghi được đi tiếp';

  -- B2 — ghi trước, chưa COMMIT; lần ký đến sau phải bị GIỮ LẠI.
  PERFORM dblink_exec('t343_b', 'BEGIN');
  PERFORM dblink_exec('t343_b', format(ghi, 20000, 20000));
  PERFORM dblink_exec('t343_a', 'BEGIN');
  PERFORM dblink_send_query('t343_a', $s$INSERT INTO reconciled_day (sale_date) VALUES ('2001-01-02')$s$);
  PERFORM pg_sleep(0.5);
  IF dblink_is_busy('t343_a') <> 1 THEN
    RAISE EXCEPTION 'T-343 B2: lần ký KHÔNG chờ lần ghi số đếm đang dở của cùng ngày — ký trên số chưa đủ';
  END IF;
  RAISE NOTICE 'T-343 B2: lần ghi chưa COMMIT, lần ký cùng ngày đang bị giữ lại';
  PERFORM dblink_exec('t343_b', 'ROLLBACK');
  PERFORM * FROM dblink_get_result('t343_a', false) AS t(res text);
  msg := dblink_error_message('t343_a');
  PERFORM * FROM dblink_get_result('t343_a', false) AS t(res text);
  PERFORM dblink_exec('t343_a', 'ROLLBACK');
  IF msg IS DISTINCT FROM 'OK' THEN
    RAISE EXCEPTION 'T-343 B2: lần ghi lùi rồi mà lần ký vẫn hỏng: %', msg;
  END IF;
  RAISE NOTICE 'T-343 B2: lần ghi lùi, lần ký được đi tiếp';

  -- B3 — chỗ hở của bản đánh giá: ký COMMIT trong lúc lần ghi đang chờ ⇒ lần ghi bị TỪ CHỐI, số đếm đứng yên.
  PERFORM dblink_exec('t343_a', 'BEGIN');
  PERFORM dblink_exec('t343_a', $s$INSERT INTO reconciled_day (sale_date) VALUES ('2001-01-02')$s$);
  PERFORM dblink_exec('t343_b', 'BEGIN');
  PERFORM dblink_send_query('t343_b', format(ghi, 50000, 50000));
  PERFORM pg_sleep(0.5);
  IF dblink_is_busy('t343_b') <> 1 THEN
    RAISE EXCEPTION 'T-343 B3: lần ghi số đếm KHÔNG chờ lần ký đang dở của cùng ngày';
  END IF;
  PERFORM dblink_exec('t343_a', 'COMMIT');
  PERFORM * FROM dblink_get_result('t343_b', false) AS t(res text);
  msg := dblink_error_message('t343_b');
  PERFORM * FROM dblink_get_result('t343_b', false) AS t(res text);
  PERFORM dblink_exec('t343_b', 'ROLLBACK');
  PERFORM dblink_disconnect('t343_a');
  PERFORM dblink_disconnect('t343_b');
  IF msg NOT LIKE '%không được ghi số của ngày đã đối soát xong%' THEN
    RAISE EXCEPTION 'T-343 B3: lần ghi chạy cùng lúc với lần ký KHÔNG bị từ chối sau khi dấu COMMIT (B: %)', msg;
  END IF;
  RAISE NOTICE 'T-343 B3 bị từ chối (ghi xấp 50.000 trong lúc ký, sau khi dấu COMMIT): %', msg;
  SELECT count(*), sum(l.amount_vnd) INTO n, tong
    FROM cash_count_line l JOIN cash_count c ON c.id = l.cash_count_id WHERE c.sale_date = '2001-01-02';
  IF n <> 1 OR tong <> 100000 THEN
    RAISE EXCEPTION 'T-343 B3: số đếm ngày đã ký đọc ra % dòng, %đ — chờ 1 dòng, 100000đ', n, tong;
  END IF;
  RAISE NOTICE 'T-343 B3: số đếm ngày đã ký đứng yên — % dòng, %đ', n, tong;
END $t343$;
