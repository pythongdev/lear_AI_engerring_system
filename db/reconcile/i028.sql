-- I-028 — docs/product/1-system-design/03-bao-ve-invariant.md §5, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.

-- @@ I-028/1 — khoản thiếu hay lạ người nhận/người ghi, thiếu tiền/ngày/lúc ghi, hoặc tiền không lớn hơn 0
WITH khoan AS (
  SELECT 'staff_advance' AS bang, id, worker_person_id, amount_vnd, paid_date, person_id, created_at
  FROM staff_advance
  UNION ALL
  SELECT 'holiday_bonus', id, worker_person_id, amount_vnd, paid_date, person_id, created_at
  FROM holiday_bonus
)
SELECT k.bang, k.id AS khoan
FROM khoan k
LEFT JOIN person w ON w.id = k.worker_person_id
LEFT JOIN person p ON p.id = k.person_id
WHERE w.id IS NULL OR p.id IS NULL OR k.amount_vnd IS NULL OR k.amount_vnd <= 0
   OR k.paid_date IS NULL OR k.created_at IS NULL

-- @@ I-028/2 — tạm ứng thiếu hay lạ người duyệt
SELECT a.id AS khoan
FROM staff_advance a LEFT JOIN person p ON p.id = a.approver_person_id
WHERE p.id IS NULL

-- @@ I-028/3 — người duyệt tạm ứng không phải chủ quán
SELECT a.id AS khoan, a.approver_person_id AS nguoi_duyet
FROM staff_advance a JOIN person p ON p.id = a.approver_person_id
WHERE NOT p.is_owner

-- @@ I-028/4 — khoản có chuỗi vết đứt
SELECT 'staff_advance' AS bang, a.id AS khoan
FROM staff_advance a
WHERE pg_temp.chuoi_vet_dut('staff_advance', a)
UNION ALL
SELECT 'holiday_bonus', b.id
FROM holiday_bonus b
WHERE pg_temp.chuoi_vet_dut('holiday_bonus', b)
