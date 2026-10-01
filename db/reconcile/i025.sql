-- I-025 — docs/product/1-system-design/03-bao-ve-invariant.md §5, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.

-- @@ I-025/1 — con số thiếu người nhập, ngày hoặc lúc gõ, hay người nhập không thuộc quán
SELECT e.id AS dong
FROM supply_day_entry e LEFT JOIN person p ON p.id = e.person_id
WHERE p.id IS NULL OR e.entry_date IS NULL OR e.created_at IS NULL

-- @@ I-025/2 — con số có chuỗi vết đứt
SELECT e.id AS dong
FROM supply_day_entry e
WHERE pg_temp.chuoi_vet_dut('supply_day_entry', e)
