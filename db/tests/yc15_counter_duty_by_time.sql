-- YC-15 · YC-16 · YC-17 · YC-04: ai đứng quầy đọc được tại một thời điểm đã qua, không phải một ô
-- hiện tại bị ghi đè; hai người không đứng quầy trùng giờ; chủ quán đứng quầy thì CỘNG quyền của
-- quầy vào quyền quản trị; lát không đòi năm người và không ghi mốc đổi ở bốn trạm ngoài quầy
-- (shop-facts §8.8, U-055); mỗi lần huỷ · hoàn · ghi nợ đọc ra người đang trực lúc ấy.
-- Lát: 06-luoc-do-nguoi-va-vet.md.

-- Chế độ nghiêm của vết (T-138, ADR-092): mọi lần sửa trong file này khai lý do; người
-- sửa là một người thử của file, khai ngay đây.
DO $$ DECLARE p bigint; BEGIN
  INSERT INTO person (display_name) VALUES ('test-người sửa') RETURNING id INTO p;
  PERFORM set_config('shop.actor_person_id', p::text, true);
  PERFORM set_config('shop.revision_reason', 'test-yc15_counter_duty_by_time', true);
END $$;
DO $$
DECLARE a bigint; b bigint; chu bigint; d_a bigint; d_b bigint; r record; t0 timestamptz;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-A') RETURNING id INTO a;
  INSERT INTO person (display_name) VALUES ('test-B') RETURNING id INTO b;
  INSERT INTO person (display_name, is_owner) VALUES ('test-chủ quán', true) RETURNING id INTO chu;
  t0 := date_trunc('day', now()) + interval '6 hours';
  BEGIN
    INSERT INTO person (display_name) VALUES ('   ');
    RAISE EXCEPTION 'YC-15: database KHÔNG từ chối một người không có tên';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-15 bị từ chối (người chỉ có tên trắng — vết "ai bấm" không đọc được): %', SQLERRM;
  END;

  -- 06:00 A vào quầy. 08:30 A đi ăn, B vào: một lần đổi = A khép khoảng, B mở khoảng, cùng một giờ.
  INSERT INTO counter_duty (person_id, started_at) VALUES (a, t0) RETURNING id INTO d_a;
  UPDATE counter_duty SET ended_at = t0 + interval '150 minutes' WHERE id = d_a;
  INSERT INTO counter_duty (person_id, started_at) VALUES (b, t0 + interval '150 minutes')
  RETURNING id INTO d_b;
  -- 09:40 B ra, chủ quán vào đứng quầy tới hết buổi.
  UPDATE counter_duty SET ended_at = t0 + interval '220 minutes' WHERE id = d_b;
  INSERT INTO counter_duty (person_id, started_at) VALUES (chu, t0 + interval '220 minutes');

  -- YC-15: đọc lại ai đứng quầy tại những mốc đã qua.
  FOR r IN
    SELECT m.moc, p.display_name, p.is_owner
    FROM (VALUES (t0 + interval '10 minutes'), (t0 + interval '149 minutes'),
                 (t0 + interval '150 minutes'), (t0 + interval '4 hours')) AS m(moc)
    LEFT JOIN counter_duty d ON tstzrange(d.started_at, d.ended_at, '[)') @> m.moc
    LEFT JOIN person p ON p.id = d.person_id
    ORDER BY m.moc
  LOOP
    RAISE NOTICE 'YC-15 lúc % — đứng quầy: % %', to_char(r.moc, 'HH24:MI'), r.display_name,
      CASE WHEN r.is_owner THEN ' (vẫn giữ quyền quản trị — YC-16)' ELSE '' END;
  END LOOP;
  IF (SELECT d.person_id FROM counter_duty d
      WHERE tstzrange(d.started_at, d.ended_at, '[)') @> t0 + interval '150 minutes') <> b THEN
    RAISE EXCEPTION 'YC-15: đúng mốc đổi 08:30 phải là người VÀO (B), không phải người ra';
  END IF;

  -- Hai người đứng quầy trùng giờ: bị từ chối, ở cả ca chồng một phần lẫn ca quên khép khoảng.
  BEGIN
    INSERT INTO counter_duty (person_id, started_at, ended_at)
    VALUES (a, t0 + interval '2 hours', t0 + interval '3 hours');
    RAISE EXCEPTION 'YC-15: database KHÔNG từ chối hai người đứng quầy cùng lúc';
  EXCEPTION WHEN exclusion_violation THEN
    RAISE NOTICE 'YC-15 bị từ chối (A vào quầy lúc B đang đứng): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO counter_duty (person_id, started_at) VALUES (a, t0 + interval '5 hours');
    RAISE EXCEPTION 'YC-15: database KHÔNG từ chối người vào khi người trước chưa khép khoảng';
  EXCEPTION WHEN exclusion_violation THEN
    RAISE NOTICE 'YC-15 bị từ chối (người vào khi chủ quán chưa ra): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO counter_duty (person_id, started_at, ended_at) VALUES (a, t0, t0);
    RAISE EXCEPTION 'YC-15: database KHÔNG từ chối một khoảng trực dài bằng không';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-15 bị từ chối (khoảng trực khép trước lúc mở): %', SQLERRM;
  END;

  -- YC-16: chủ quán đang đứng quầy — cùng lúc có quyền của quầy (đang trực) và quyền quản trị (cờ).
  SELECT p.display_name,
         EXISTS (SELECT 1 FROM counter_duty d WHERE d.person_id = p.id
                   AND tstzrange(d.started_at, d.ended_at, '[)') @> t0 + interval '4 hours') AS o_quay,
         p.is_owner
  INTO r FROM person p WHERE p.id = chu;
  RAISE NOTICE 'YC-16 lúc 10:00 — %: đang trực quầy %, quyền quản trị %', r.display_name, r.o_quay, r.is_owner;
  IF NOT (r.o_quay AND r.is_owner) THEN
    RAISE EXCEPTION 'YC-16: chủ quán đứng quầy mà một trong hai vai biến mất';
  END IF;

  -- YC-17: lát không có bảng trạm-người cho bốn trạm ngoài quầy, nên không gì đòi năm người; buổi
  -- bán trên chạy với ba người, và chỉ trạm quầy có mốc đổi (U-055).
  RAISE NOTICE 'YC-17 bảng ghi mốc đổi người: % — chỉ trạm quầy; % người đã đứng quầy trong buổi',
    (SELECT string_agg(table_name, ', ') FROM information_schema.tables
     WHERE table_schema = 'shop' AND table_name LIKE '%duty%'),
    (SELECT COUNT(DISTINCT person_id) FROM counter_duty);
END $$;
