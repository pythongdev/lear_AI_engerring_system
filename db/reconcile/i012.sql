-- I-012 — docs/product/1-system-design/03-bao-ve-invariant.md §1, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Thao tác chạm tiền = năm bảng mang "ai bấm" của 06-luoc-do-nguoi-va-vet.md §1: hoá đơn, thu nợ,
-- trả trước, hoàn tiền, tiền đầu két.

-- @@ I-012/2 — chỗ lệch của phép trừ két không chỉ ra đúng một thao tác có tên
-- Cách đọc của T-133 (file 09 §3): một chỗ lệch "chỉ ra được" một thao tác khi trong ngày ấy có
-- ĐÚNG MỘT thao tác chạm tiền mang một phần tiền bằng đúng độ lớn chỗ lệch — ví dụ một lần thu ghi
-- nhầm phương thức. Không thao tác nào, hay hơn một, là chỗ lệch vô danh. Chỉ vế tiền mặt: tin nhắn
-- báo có chưa có chỗ cất, nên vế chuyển khoản không có câu (I-015 tập 5). Ngày chờ U-072 không kết luận.
WITH lech AS (
  SELECT k.ngay, k.dem_duoc - k.dau_ket - k.ve_phai AS lech
  FROM pg_temp.ket_ngay(:mui_gio) k
  WHERE NOT k.cho_u072 AND k.dem_duoc - k.dau_ket <> k.ve_phai),
op(bang, id, ngay, tien) AS (
  SELECT 'bill', id, sale_date, unnest(ARRAY[cash_vnd, transfer_vnd, prepaid_cash_vnd]) FROM bill
  UNION ALL SELECT 'debt_collection', id, sale_date, unnest(ARRAY[cash_vnd, transfer_vnd]) FROM debt_collection
  UNION ALL SELECT 'prepayment', id, sale_date, unnest(ARRAY[cash_vnd, transfer_vnd]) FROM prepayment
  UNION ALL SELECT 'refund', id, sale_date, amount_vnd FROM refund
  UNION ALL SELECT 'staff_advance', id, paid_date, amount_vnd FROM staff_advance
  UNION ALL SELECT 'holiday_bonus', id, paid_date, amount_vnd FROM holiday_bonus)
SELECT l.ngay, l.lech,
       (SELECT count(DISTINCT (o.bang, o.id)) FROM op o
        WHERE o.ngay = l.ngay AND o.tien = abs(l.lech)) AS so_thao_tac_khop
FROM lech l
WHERE (SELECT count(DISTINCT (o.bang, o.id)) FROM op o
       WHERE o.ngay = l.ngay AND o.tien = abs(l.lech)) <> 1

-- @@ I-012/1 — thao tác chạm tiền thiếu một trong bốn câu: cái gì đổi, bao nhiêu, ai bấm, lúc mấy giờ
WITH op AS (
  SELECT 'bill' AS bang, id, person_id, booked_at AS luc, due_vnd AS bao_nhieu FROM bill
  UNION ALL SELECT 'debt_collection', id, person_id, booked_at,
                   coalesce(remaining_before_vnd, debt_vnd) - remaining_vnd FROM debt_collection
  UNION ALL SELECT 'prepayment', id, person_id, booked_at, cash_vnd + transfer_vnd FROM prepayment
  UNION ALL SELECT 'refund', id, person_id, booked_at, amount_vnd FROM refund
  UNION ALL SELECT 'opening_float', f.id, f.person_id, f.created_at,
                   (SELECT sum(amount_vnd) FROM opening_float_line x WHERE x.opening_float_id = f.id)
            FROM opening_float f)
SELECT bang, id, person_id AS ai_bam, luc, bao_nhieu
FROM op
WHERE person_id IS NULL OR luc IS NULL OR bao_nhieu IS NULL

-- @@ I-012/3 — thao tác chạm tiền không đi qua một trong ba chỗ bấm có tên
-- Ba chỗ: người đứng quầy lúc ấy (counter_duty); người đi giao bấm đã giao + đã thu tại chỗ khách
-- (hoá đơn của đơn giao tận nơi, POS khai tên — U-057); người nhập bù từ sổ giấy. Chủ quán đổi giá
-- trên mặt quản trị không chạm tiền của ngày. Tiền đầu két khai TRƯỚC khi mở ca nên đứng ngoài.
WITH op AS (
  SELECT 'bill' AS bang, b.id, b.person_id, b.booked_at AS luc
  FROM bill b LEFT JOIN sales_order o ON o.id = b.sales_order_id
  WHERE b.paper_ledger_id IS NULL AND o.handover_code IS DISTINCT FROM 'door_delivery'
  UNION ALL SELECT 'debt_collection', id, person_id, booked_at FROM debt_collection
  UNION ALL SELECT 'prepayment', id, person_id, booked_at FROM prepayment
  UNION ALL SELECT 'refund', id, person_id, booked_at FROM refund)
SELECT op.bang, op.id, p.display_name AS nguoi_bam, q.display_name AS dang_dung_quay
FROM op
JOIN person p ON p.id = op.person_id
LEFT JOIN counter_duty d ON tstzrange(d.started_at, d.ended_at, '[)') @> op.luc
LEFT JOIN person q ON q.id = d.person_id
WHERE d.person_id IS DISTINCT FROM op.person_id

-- @@ I-012/4 — lần hoàn tiền không đọc ra đủ bao nhiêu · cho lượt bán nào · ai bấm · lý do gì
SELECT r.id AS lan_hoan, r.amount_vnd AS bao_nhieu, r.bill_id AS hoa_don,
       r.prepayment_id AS khoan_tra_truoc, r.person_id AS ai_bam, r.reason AS ly_do
FROM refund r
WHERE r.amount_vnd IS NULL OR num_nonnulls(r.bill_id, r.prepayment_id) <> 1
   OR r.person_id IS NULL OR btrim(coalesce(r.reason, '')) = ''
