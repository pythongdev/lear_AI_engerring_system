-- I-026 — docs/product/1-system-design/03-bao-ve-invariant.md §5, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.

-- Tổng và hiệu số không có chỗ cất (tập 1 · 2): file 09 §2.

-- @@ I-026/3 — cặp thứ, ngày có hơn một giá trị mua vào hay đã dùng
SELECT supply_item_id AS thu, entry_date AS ngay, kind_code AS loai, count(*) AS so_con_so
FROM supply_day_entry
WHERE kind_code IN ('purchased', 'used')
GROUP BY supply_item_id, entry_date, kind_code
HAVING count(*) > 1

-- @@ I-026/4 — tên đứng hơn một lần trong danh mục, theo phép bằng của cột name
SELECT name AS ten, count(*) AS so_lan
FROM supply_item
GROUP BY name
HAVING count(*) > 1
