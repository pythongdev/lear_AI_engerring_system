-- I-029 — khoản chi; ánh xạ và giới hạn: 09-doi-chieu-bat-bien.md.
-- @@ I-029/1 — khoản thiếu loại/người, tiền không dương, thiếu ngày hoặc lúc ghi
SELECT e.id AS khoan
FROM expense e
LEFT JOIN expense_category c ON c.id = e.expense_category_id
LEFT JOIN person p ON p.id = e.person_id
WHERE c.id IS NULL OR p.id IS NULL OR e.amount_vnd IS NULL OR e.amount_vnd <= 0
   OR e.paid_date IS NULL OR e.created_at IS NULL

-- @@ I-029/2 — loại thiếu tên hay nguồn, hoặc trùng tên
SELECT c.id AS loai
FROM expense_category c
WHERE c.name IS NULL OR btrim(c.name) = '' OR c.paid_from_till IS NULL
   OR EXISTS (SELECT 1 FROM expense_category x WHERE x.name = c.name AND x.id <> c.id)

-- @@ I-029/3 — chuỗi vết khoản hoặc loại bị đứt
SELECT 'expense' AS bang, e.id AS dong FROM expense e
WHERE pg_temp.chuoi_vet_dut('expense', e)
UNION ALL
SELECT 'expense_category', c.id FROM expense_category c
WHERE pg_temp.chuoi_vet_dut('expense_category', c)
