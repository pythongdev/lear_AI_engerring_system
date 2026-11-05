-- I-040 (tầng 1): chi phí gọi model của một tháng — và của một ngày — KHÔNG vượt trần; không lần gọi nào tới nhà cung cấp
-- mà không có dòng giữ chỗ ghi trước. Một dòng `model_call` là một lần gọi: ghi giữ chỗ TRƯỚC khi gọi, chốt MỘT lần sau
-- khi gọi. Trong tổng, dòng đã chốt tính bằng chi phí thật, dòng chưa chốt tính bằng tiền giữ chỗ (server chết giữa chừng
-- không mở lại ngân sách). Tháng và ngày tính theo giờ Việt Nam của `created_at`. Trần tháng 10 USD là lời
-- master_plan/shop-facts.md §8.11 điểm 5; trần ngày một phần mười trần tháng là phiên chọn ở ADR-139 điểm 6.
-- Không cột nội dung câu hỏi, không người, không phiên (ADR-139 điểm 2 · 5).
-- Thiết kế: docs/decisions.md ADR-139. Kịch bản: quality/invariants.md I-040.
-- Viết trước lược đồ (CHAT-35, Claude Code, 2026-11-04): đỏ cho tới khi migration sổ gọi model dựng.
--
-- Đơn vị: phần triệu USD (hậu tố `_microusd`). Trần tháng 10_000_000, trần ngày 1_000_000; so bằng ≤ (chạm trần vẫn nhận).
-- Quyền vai ghi: INSERT chỉ ba cột provider_code · model_code · reserved_microusd (created_at do database cấp);
-- UPDATE chỉ bốn cột chốt; không DELETE.
--
-- Tên Claude chốt (ràng buộc / trigger phát lời từ chối với CONSTRAINT = tên dưới, ERRCODE như ghi):
--   model_call_pkey
--   model_call_provider_code_check (check: ^[a-z][a-z0-9_]*$) · model_call_model_code_check (check: không trắng)
--   model_call_reserved_check (check: > 0) · model_call_cost_check (check: ≥ 0)
--   model_call_token_count_check (check: hai số token ≥ 0 khi có)
--   model_call_settlement_pair_check (check: settled_at và cost_microusd cả hai hoặc không)
--   model_call_tokens_settled_check (check: số token chỉ có khi đã chốt)
--   model_call_settled_after_check (check: settled_at ≥ created_at)
--   model_call_month_budget_check · model_call_day_budget_check (trigger BEFORE INSERT, check_violation)
--   model_call_settle_once_check (trigger BEFORE UPDATE, check_violation)

DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-i040_model_call_budget', true); END $$;
DO $$
DECLARE r1 bigint; r2 bigint; r3 bigint; j bigint; n int; d int; ten text; cols text; snap text; snap2 text; tong bigint;
BEGIN
  -- Chụp nội dung mọi bảng ngoài sổ gọi model và vết: sổ gọi model không đổi gì khác.
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(
              format('SELECT coalesce(md5(string_agg(x::text, %L ORDER BY x::text COLLATE "C")), %L) AS c FROM shop.%I x',
                     '|', 'rong', t.table_name), false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('model_call', 'record_revision');

  -- Lược đồ: đúng chín cột, không nội dung, không người, không phiên.
  SELECT string_agg(column_name::text, ',' ORDER BY column_name::text COLLATE "C") INTO cols
  FROM information_schema.columns WHERE table_schema = 'shop' AND table_name = 'model_call';
  IF cols IS DISTINCT FROM 'cost_microusd,created_at,id,input_token_count,model_code,output_token_count,provider_code,reserved_microusd,settled_at' THEN
    RAISE EXCEPTION 'I-040: cột của model_call lệch thiết kế ADR-139 điểm 5: %', cols;
  END IF;
  RAISE NOTICE 'I-040 đọc lược đồ — model_call: %', cols;

  -- Kịch bản dương bằng vai ghi, hôm nay: giữ chỗ rồi chốt.
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO model_call (provider_code, model_code, reserved_microusd) VALUES ('gia', 'gia-1', 300000) RETURNING id INTO r1;
    UPDATE model_call SET settled_at = now(), input_token_count = 1000, output_token_count = 200, cost_microusd = 120000
      WHERE id = r1;
    INSERT INTO model_call (provider_code, model_code, reserved_microusd) VALUES ('gia', 'gia-1', 500000) RETURNING id INTO r2;
    RESET ROLE;
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE EXCEPTION 'I-040: vai shop_app KHÔNG giữ chỗ hay chốt được: %', SQLERRM;
  END;
  RAISE NOTICE 'I-040 dương: vai ghi giữ chỗ, chốt; giữ chỗ thứ hai còn treo';

  -- Trần ngày: hôm nay đã có 120_000 (chốt) + 500_000 (chưa chốt, tính bằng giữ chỗ) = 620_000; thêm 400_000 vượt 1_000_000.
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO model_call (provider_code, model_code, reserved_microusd) VALUES ('gia', 'gia-1', 400000);
    RESET ROLE;
    RAISE EXCEPTION 'I-040: database KHÔNG từ chối giữ chỗ vượt trần ngày (dòng chưa chốt phải tính bằng tiền giữ chỗ)';
  EXCEPTION WHEN check_violation THEN
    RESET ROLE;
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'model_call_day_budget_check' THEN RAISE EXCEPTION 'I-040: vượt trần ngày bị từ chối bằng % thay vì model_call_day_budget_check', ten; END IF;
    RAISE NOTICE 'I-040 bị từ chối (vượt trần ngày, dòng treo tính bằng giữ chỗ): %', SQLERRM;
  END;
  -- Chốt dòng treo ở 100_000: tổng ngày còn 220_000, giữ chỗ 400_000 qua được; chốt cao hơn giữ chỗ vẫn ghi đúng sự thật.
  SET LOCAL ROLE shop_app;
  UPDATE model_call SET settled_at = now(), cost_microusd = 100000 WHERE id = r2;
  INSERT INTO model_call (provider_code, model_code, reserved_microusd) VALUES ('gia', 'gia-1', 400000) RETURNING id INTO r3;
  UPDATE model_call SET settled_at = now(), input_token_count = 9000, output_token_count = 800, cost_microusd = 450000 WHERE id = r3;
  RESET ROLE;
  RAISE NOTICE 'I-040 dương: chốt thấp mở lại phần dư; chốt không có số token; chốt cao hơn giữ chỗ được ghi';

  -- Trần tháng, dựng bằng vai chủ lược đồ ở một tháng đã qua (tháng 1/2026, giờ Việt Nam): mười ngày × 950_000.
  FOR d IN 1..10 LOOP
    INSERT INTO model_call (provider_code, model_code, reserved_microusd, created_at)
    VALUES ('gia', 'gia-1', 950000, make_timestamptz(2026, 1, d, 10, 0, 0, 'Asia/Ho_Chi_Minh'));
  END LOOP;
  BEGIN
    INSERT INTO model_call (provider_code, model_code, reserved_microusd, created_at)
    VALUES ('gia', 'gia-1', 600000, make_timestamptz(2026, 1, 11, 10, 0, 0, 'Asia/Ho_Chi_Minh'));
    RAISE EXCEPTION 'I-040: database KHÔNG từ chối giữ chỗ vượt trần tháng';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'model_call_month_budget_check' THEN RAISE EXCEPTION 'I-040: vượt trần tháng bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-040 bị từ chối (vượt trần tháng): %', SQLERRM;
  END;
  -- Chạm đúng trần thì nhận.
  INSERT INTO model_call (provider_code, model_code, reserved_microusd, created_at)
  VALUES ('gia', 'gia-1', 500000, make_timestamptz(2026, 1, 11, 10, 0, 0, 'Asia/Ho_Chi_Minh'));
  -- Biên tháng theo giờ Việt Nam: 23:30 ngày 31/1 (giờ VN) còn là tháng 1 → bị từ chối; 00:30 ngày 1/2 (giờ VN, vẫn là
  -- ngày 31/1 theo UTC) là tháng mới → nhận.
  BEGIN
    INSERT INTO model_call (provider_code, model_code, reserved_microusd, created_at)
    VALUES ('gia', 'gia-1', 100000, make_timestamptz(2026, 1, 31, 23, 30, 0, 'Asia/Ho_Chi_Minh'));
    RAISE EXCEPTION 'I-040: database KHÔNG tính 23:30 ngày 31/1 giờ Việt Nam vào tháng 1';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'model_call_month_budget_check' THEN RAISE EXCEPTION 'I-040: biên tháng bị từ chối bằng %', ten; END IF;
  END;
  INSERT INTO model_call (provider_code, model_code, reserved_microusd, created_at)
  VALUES ('gia', 'gia-1', 100000, make_timestamptz(2026, 2, 1, 0, 30, 0, 'Asia/Ho_Chi_Minh'));
  RAISE NOTICE 'I-040 dương: chạm đúng trần tháng được nhận; tháng mới theo giờ Việt Nam mở ngân sách mới';

  -- Chốt một lần.
  BEGIN
    UPDATE model_call SET cost_microusd = 130000 WHERE id = r1;
    RAISE EXCEPTION 'I-040: database KHÔNG từ chối chốt lại một lần gọi đã chốt';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'model_call_settle_once_check' THEN RAISE EXCEPTION 'I-040: chốt lại bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-040 bị từ chối (chốt lại): %', SQLERRM;
  END;
  BEGIN
    UPDATE model_call SET settled_at = NULL, cost_microusd = NULL, input_token_count = NULL, output_token_count = NULL WHERE id = r1;
    RAISE EXCEPTION 'I-040: database KHÔNG từ chối xoá trắng phần chốt';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'model_call_settle_once_check' THEN RAISE EXCEPTION 'I-040: xoá trắng phần chốt bị từ chối bằng %', ten; END IF;
  END;
  INSERT INTO model_call (provider_code, model_code, reserved_microusd, created_at)
  VALUES ('gia', 'gia-1', 1000, make_timestamptz(2026, 3, 1, 10, 0, 0, 'Asia/Ho_Chi_Minh')) RETURNING id INTO j;
  BEGIN
    UPDATE model_call SET reserved_microusd = 1 WHERE id = j;
    RAISE EXCEPTION 'I-040: database KHÔNG từ chối sửa tiền giữ chỗ';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'model_call_settle_once_check' THEN RAISE EXCEPTION 'I-040: sửa giữ chỗ bị từ chối bằng %', ten; END IF;
  END;
  BEGIN
    UPDATE model_call SET created_at = make_timestamptz(2026, 4, 1, 10, 0, 0, 'Asia/Ho_Chi_Minh') WHERE id = j;
    RAISE EXCEPTION 'I-040: database KHÔNG từ chối dời mốc ghi của giữ chỗ';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'model_call_settle_once_check' THEN RAISE EXCEPTION 'I-040: dời mốc bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-040 bị từ chối (sửa giữ chỗ, dời mốc, chốt lại, xoá trắng): một lần, không sửa';
  END;

  -- Khuôn từng cột.
  BEGIN
    INSERT INTO model_call (provider_code, model_code, reserved_microusd) VALUES ('gia', 'gia-1', 0);
    RAISE EXCEPTION 'I-040: database KHÔNG từ chối giữ chỗ bằng 0';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'model_call_reserved_check' THEN RAISE EXCEPTION 'I-040: giữ chỗ 0 bị từ chối bằng %', ten; END IF;
  END;
  BEGIN
    INSERT INTO model_call (provider_code, model_code, reserved_microusd) VALUES ('OpenAI', 'gia-1', 1);
    RAISE EXCEPTION 'I-040: database KHÔNG từ chối mã nhà cung cấp sai khuôn';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'model_call_provider_code_check' THEN RAISE EXCEPTION 'I-040: mã nhà cung cấp sai bị từ chối bằng %', ten; END IF;
  END;
  BEGIN
    INSERT INTO model_call (provider_code, model_code, reserved_microusd) VALUES ('gia', '  ', 1);
    RAISE EXCEPTION 'I-040: database KHÔNG từ chối mã model trắng';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'model_call_model_code_check' THEN RAISE EXCEPTION 'I-040: mã model trắng bị từ chối bằng %', ten; END IF;
  END;
  BEGIN
    INSERT INTO model_call (provider_code, model_code, reserved_microusd, input_token_count) VALUES ('gia', 'gia-1', 1, 5);
    RAISE EXCEPTION 'I-040: database KHÔNG từ chối số token trên dòng chưa chốt';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'model_call_tokens_settled_check' THEN RAISE EXCEPTION 'I-040: token khi chưa chốt bị từ chối bằng %', ten; END IF;
  END;
  BEGIN
    UPDATE model_call SET settled_at = now() WHERE id = j;
    RAISE EXCEPTION 'I-040: database KHÔNG từ chối mốc chốt thiếu chi phí';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'model_call_settlement_pair_check' THEN RAISE EXCEPTION 'I-040: chốt lẻ đôi bị từ chối bằng %', ten; END IF;
  END;
  BEGIN
    UPDATE model_call SET settled_at = make_timestamptz(2026, 2, 1, 10, 0, 0, 'Asia/Ho_Chi_Minh'), cost_microusd = 1 WHERE id = j;
    RAISE EXCEPTION 'I-040: database KHÔNG từ chối mốc chốt trước mốc giữ chỗ';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'model_call_settled_after_check' THEN RAISE EXCEPTION 'I-040: chốt trước giữ chỗ bị từ chối bằng %', ten; END IF;
  END;
  BEGIN
    UPDATE model_call SET settled_at = now(), cost_microusd = -1 WHERE id = j;
    RAISE EXCEPTION 'I-040: database KHÔNG từ chối chi phí âm';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'model_call_cost_check' THEN RAISE EXCEPTION 'I-040: chi phí âm bị từ chối bằng %', ten; END IF;
  END;
  BEGIN
    UPDATE model_call SET settled_at = now(), cost_microusd = 1, output_token_count = -1 WHERE id = j;
    RAISE EXCEPTION 'I-040: database KHÔNG từ chối số token âm';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS ten = CONSTRAINT_NAME;
    IF ten IS DISTINCT FROM 'model_call_token_count_check' THEN RAISE EXCEPTION 'I-040: token âm bị từ chối bằng %', ten; END IF;
    RAISE NOTICE 'I-040 bị từ chối (khuôn cột: giữ chỗ 0, mã sai, token khi chưa chốt, chốt lẻ đôi, chốt trước giữ chỗ, số âm)';
  END;

  -- Quyền vai ghi: không tự đặt mốc ghi, không sửa giữ chỗ, không xoá.
  BEGIN
    SET LOCAL ROLE shop_app;
    INSERT INTO model_call (provider_code, model_code, reserved_microusd, created_at)
    VALUES ('gia', 'gia-1', 1, make_timestamptz(2026, 3, 2, 10, 0, 0, 'Asia/Ho_Chi_Minh'));
    RESET ROLE;
    RAISE EXCEPTION 'I-040: vai shop_app TỰ ĐẶT ĐƯỢC mốc ghi của giữ chỗ (lách được trần ngày, trần tháng)';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE model_call SET reserved_microusd = 1 WHERE id = j;
    RESET ROLE;
    RAISE EXCEPTION 'I-040: vai shop_app SỬA ĐƯỢC tiền giữ chỗ';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    DELETE FROM model_call WHERE id = j;
    RESET ROLE;
    RAISE EXCEPTION 'I-040: vai shop_app XOÁ ĐƯỢC một lần gọi khỏi sổ';
  EXCEPTION WHEN insufficient_privilege THEN
    RESET ROLE;
    RAISE NOTICE 'I-040 bị từ chối (vai ghi tự đặt mốc, sửa giữ chỗ, xoá)';
  END;

  -- Kiểm ngược (1): không tháng nào (giờ Việt Nam) có tổng vượt trần.
  SELECT max(s) INTO tong FROM (
    SELECT sum(coalesce(cost_microusd, reserved_microusd)) AS s FROM model_call
    GROUP BY date_trunc('month', created_at AT TIME ZONE 'Asia/Ho_Chi_Minh')) m;
  IF tong > 10000000 THEN RAISE EXCEPTION 'I-040: một tháng có tổng % vượt trần', tong; END IF;
  -- Kiểm ngược (2): sổ gọi model không có khoá ngoại nào (không người, không phiên, không đơn).
  SELECT count(*) INTO n FROM information_schema.table_constraints
  WHERE table_schema = 'shop' AND table_name = 'model_call' AND constraint_type = 'FOREIGN KEY';
  IF n <> 0 THEN RAISE EXCEPTION 'I-040: model_call có % khoá ngoại; ADR-139 điểm 5 không cho cột người hay phiên', n; END IF;
  -- Kiểm ngược (3): trigger giữ trần lấy khoá giao dịch, để hai giữ chỗ song song không cùng đọc tổng cũ.
  SELECT count(*) INTO n FROM pg_proc p JOIN pg_namespace s ON s.oid = p.pronamespace
  WHERE s.nspname = 'shop' AND p.prosrc ILIKE '%pg_advisory_xact_lock%'
    AND p.oid IN (SELECT tgfoid FROM pg_trigger WHERE tgrelid = 'shop.model_call'::regclass AND NOT tgisinternal);
  IF n < 1 THEN RAISE EXCEPTION 'I-040: không hàm trigger nào của model_call lấy khoá giao dịch trước khi cộng tổng'; END IF;
  -- Kiểm ngược (4): không bảng nào khác đổi nội dung.
  SELECT string_agg(t.table_name || '=' ||
           (xpath('//c/text()', query_to_xml(
              format('SELECT coalesce(md5(string_agg(x::text, %L ORDER BY x::text COLLATE "C")), %L) AS c FROM shop.%I x',
                     '|', 'rong', t.table_name), false, true, '')))[1]::text,
           ',' ORDER BY t.table_name::text COLLATE "C") INTO snap2
  FROM information_schema.tables t
  WHERE t.table_schema = 'shop' AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT IN ('model_call', 'record_revision');
  IF snap IS DISTINCT FROM snap2 THEN RAISE EXCEPTION 'I-040: sổ gọi model đã làm đổi một bảng khác'; END IF;
  RAISE NOTICE 'I-040 kiểm ngược: không tháng vượt trần, không khoá ngoại, trigger lấy khoá, không bảng khác đổi';
END $$;
