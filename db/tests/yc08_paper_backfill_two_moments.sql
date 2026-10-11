-- YC-08 · ADR-037: lượt bán ghi trên sổ giấy hôm mất điện, nhập vào máy hôm sau, mang HAI mốc đọc
-- riêng — ngày quán bán thật (booked_at · sale_date) và lúc gõ (created_at) — cùng NGƯỜI NHẬP BÙ,
-- khác người bán; một ngày đọc ra "còn N lượt trên giấy chưa nhập"; lượt nhập bù không rơi vào ngày
-- gõ và không vượt số lượt đã khai trên sổ. Lát: 06-luoc-do-nguoi-va-vet.md.

-- Chế độ nghiêm của vết (T-138, ADR-092): mọi lần sửa trong file này khai lý do; người sửa là người
-- thao tác mà từng khối khai. Khối nào xoá lý do là để thử lời từ chối.
DO $$ BEGIN PERFORM set_config('shop.revision_reason', 'test-yc08_paper_backfill_two_moments', true); END $$;
DO $$
DECLARE a bigint; b bigint; so bigint; o bigint; bl bigint; hom_qua date := CURRENT_DATE - 1;
        i integer; r record;
BEGIN
  INSERT INTO person (display_name) VALUES ('test-A đứng quầy hôm qua') RETURNING id INTO a;
  INSERT INTO person (display_name) VALUES ('test-B nhập bù hôm nay') RETURNING id INTO b;
  -- Hôm qua A đứng quầy cả buổi; mất điện, quán ghi tay. Sáng nay B (POS) khai sổ: 3 lượt.
  INSERT INTO counter_duty (person_id, started_at, ended_at)
  VALUES (a, hom_qua + time '06:00', hom_qua + time '11:00');
  PERFORM set_config('shop.actor_person_id', b::text, true);
  INSERT INTO paper_ledger (sale_date, entry_count) VALUES (hom_qua, 3) RETURNING id INTO so;

  -- B nhập hai trong ba lượt: mốc tính tiền là giờ bán trên giấy, hôm qua.
  FOR i IN 1 .. 2 LOOP
    INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                             submission_code)
    VALUES ('pickup', 'confirmed', 'shop_pickup', '0900000000', hom_qua + time '07:30',
            gen_random_uuid()::text) RETURNING id INTO o;
    INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, booked_at, sale_date,
                      paper_ledger_id, paper_entry_count, paper_position)
    VALUES (o, 30000, 30000, hom_qua + time '07:30' + i * interval '10 minutes', hom_qua, so, 3, i)
    RETURNING id INTO bl;
    UPDATE sales_order SET status = 'completed' WHERE id = o;
  END LOOP;
  SET CONSTRAINTS ALL IMMEDIATE;
  SET CONSTRAINTS ALL DEFERRED;

  -- Hai mốc, hai người, đọc riêng.
  SELECT b2.sale_date, to_char(b2.booked_at, 'YYYY-MM-DD HH24:MI') AS ban_luc,
         to_char(b2.created_at, 'YYYY-MM-DD') AS go_ngay, pn.display_name AS nguoi_nhap,
         pb.display_name AS nguoi_ban
  INTO r
  FROM bill b2 JOIN person pn ON pn.id = b2.person_id
  LEFT JOIN counter_duty d ON tstzrange(d.started_at, d.ended_at, '[)') @> b2.booked_at
  LEFT JOIN person pb ON pb.id = d.person_id
  WHERE b2.id = bl;
  RAISE NOTICE 'YC-08 lượt nhập bù — ngày bán % (bán lúc %), gõ ngày %, người nhập bù %, người đứng quầy lúc bán %',
    r.sale_date, r.ban_luc, r.go_ngay, r.nguoi_nhap, r.nguoi_ban;
  IF r.sale_date <> hom_qua OR r.nguoi_nhap = r.nguoi_ban THEN
    RAISE EXCEPTION 'YC-08: lẫn ngày bán với ngày gõ, hoặc lẫn người nhập bù với người bán';
  END IF;

  -- "Còn N lượt trên giấy chưa nhập" của từng ngày — một phép trừ, không ô nào ghi tay.
  SELECT p.sale_date, p.entry_count, p.entry_count - COUNT(b3.id) AS con_lai INTO r
  FROM paper_ledger p LEFT JOIN bill b3 ON b3.paper_ledger_id = p.id
  WHERE p.id = so GROUP BY p.id;
  RAISE NOTICE 'YC-08 ngày % — sổ khai % lượt, còn % lượt trên giấy chưa nhập (ADR-037: ngày ấy chưa đối soát xong)',
    r.sale_date, r.entry_count, r.con_lai;
  IF r.con_lai <> 1 THEN RAISE EXCEPTION 'YC-08: đếm sai số lượt còn trên giấy'; END IF;

  -- Kịch bản âm.
  INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                           submission_code)
  VALUES ('pickup', 'confirmed', 'shop_pickup', '0900000000', now(), gen_random_uuid()::text)
  RETURNING id INTO o;
  BEGIN   -- nhập bù mà ghi vào NGÀY GÕ
    INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, paper_ledger_id, paper_entry_count, paper_position)
    VALUES (o, 30000, 30000, so, 3, 3);
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION 'YC-08: database KHÔNG từ chối lượt nhập bù rơi vào ngày gõ';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'YC-08 bị từ chối (lượt trên sổ hôm qua ghi vào ngày gõ): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL DEFERRED;
  BEGIN   -- lượt thứ tư của sổ chỉ khai ba
    INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, booked_at, sale_date,
                      paper_ledger_id, paper_entry_count, paper_position)
    VALUES (o, 30000, 30000, hom_qua + time '09:00', hom_qua, so, 3, 4);
    RAISE EXCEPTION 'YC-08: database KHÔNG từ chối lượt vượt số đã khai trên sổ';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-08 bị từ chối (lượt thứ 4 của sổ khai 3): %', SQLERRM;
  END;
  BEGIN   -- cùng một lượt trên giấy nhập hai lần
    INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, booked_at, sale_date,
                      paper_ledger_id, paper_entry_count, paper_position)
    VALUES (o, 30000, 30000, hom_qua + time '09:00', hom_qua, so, 3, 2);
    RAISE EXCEPTION 'YC-08: database KHÔNG từ chối nhập một lượt trên giấy hai lần';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'YC-08 bị từ chối (lượt thứ 2 nhập lần hai): %', SQLERRM;
  END;
  BEGIN   -- khai vị trí mà không khai sổ
    INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, booked_at, sale_date, paper_position)
    VALUES (o, 30000, 30000, hom_qua + time '09:00', hom_qua, 3);
    RAISE EXCEPTION 'YC-08: database KHÔNG từ chối lượt nhập bù không có sổ';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-08 bị từ chối (vị trí trên giấy mà không có sổ): %', SQLERRM;
  END;
  BEGIN   -- bản soi số lượt lệch sổ
    INSERT INTO bill (sales_order_id, due_vnd, cash_vnd, booked_at, sale_date,
                      paper_ledger_id, paper_entry_count, paper_position)
    VALUES (o, 30000, 30000, hom_qua + time '09:00', hom_qua, so, 9, 9);
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION 'YC-08: database KHÔNG từ chối bản soi số lượt khác sổ';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'YC-08 bị từ chối (khai sổ 9 lượt để nhập lượt thứ 9, sổ thật 3): %', SQLERRM;
  END;
  SET CONSTRAINTS ALL DEFERRED;
  BEGIN   -- hai sổ cho một ngày
    INSERT INTO paper_ledger (sale_date, entry_count) VALUES (hom_qua, 2);
    RAISE EXCEPTION 'YC-08: database KHÔNG từ chối sổ thứ hai cho cùng ngày';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'YC-08 bị từ chối (hai sổ một ngày): %', SQLERRM;
  END;
  BEGIN
    INSERT INTO paper_ledger (sale_date, entry_count) VALUES (hom_qua - 1, 0);
    RAISE EXCEPTION 'YC-08: database KHÔNG từ chối sổ khai 0 lượt';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'YC-08 bị từ chối (sổ khai 0 lượt): %', SQLERRM;
  END;
END $$;
