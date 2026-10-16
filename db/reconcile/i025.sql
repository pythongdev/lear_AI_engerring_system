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

-- @@ I-025/3 — tỉ lệ nhắc không thuộc miền tỉ phần hữu hạn
SELECT id AS thu
FROM supply_item
WHERE reminder_ratio IS NULL OR NOT (reminder_ratio >= 0 AND reminder_ratio <= 1)

-- @@ I-025/4 — danh mục (gồm tỉ lệ nhắc) có chuỗi vết đứt
SELECT i.id AS thu
FROM supply_item i
WHERE EXISTS (
  -- Vết trước bước 30 chưa có cột; thiếu khoá ấy nghĩa là mặc định 0.2 khi migrate,
  -- không phải giá trị hiện tại (có thể đã được chủ quán đổi). Không sửa lịch sử vết.
  SELECT 1 FROM (
    SELECT jsonb_populate_record(i, jsonb_build_object('reminder_ratio', 0.2) || before_image) AS before_row,
           jsonb_populate_record(i, jsonb_build_object('reminder_ratio', 0.2) || after_image) AS after_row,
           jsonb_populate_record(i, jsonb_build_object('reminder_ratio', 0.2) ||
             lag(after_image) OVER (ORDER BY revised_at, id)) AS previous_after_row,
           row_number() OVER (ORDER BY revised_at, id) AS first_order,
           row_number() OVER (ORDER BY revised_at DESC, id DESC) AS last_order
    FROM record_revision WHERE target_table_code = 'supply_item' AND target_row = i.id
  ) v
  WHERE (v.last_order = 1 AND v.after_row IS DISTINCT FROM i)
     OR (v.first_order > 1 AND v.before_row IS DISTINCT FROM v.previous_after_row)
)
