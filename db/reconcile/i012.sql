-- I-012 — docs/product/1-system-design/03-bao-ve-invariant.md §1, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Thao tác chạm tiền = năm bảng mang "ai bấm" của 06-luoc-do-nguoi-va-vet.md §1: hoá đơn, thu nợ,
-- trả trước, hoàn tiền, tiền đầu két. Tập thứ hai của pha 1 (chỗ lệch của bảng đối soát không chỉ
-- ra đúng một thao tác) KHÔNG có câu: số đếm két và tin nhắn báo có chưa có chỗ cất — file 09 §2.

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
