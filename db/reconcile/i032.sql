-- I-032 — tám tập có dữ liệu ở 03-bao-ve-invariant.md §5; ADR-108.
-- Vết sửa dùng I-018, đơn cũ dùng I-009; các vế chưa có tập ghi ở file lát và file 09.

-- @@ I-032/1 — tên đứng hơn một lần trong danh mục còn dùng
SELECT name, count(*) AS so_lan FROM menu_category
WHERE hidden_at IS NULL GROUP BY name HAVING count(*) > 1

-- @@ I-032/2 — món thuộc hơn một danh mục hoặc danh mục không có thật
SELECT x.menu_item_id AS mon FROM menu_item_category x
LEFT JOIN menu_category c ON c.id = x.menu_category_id
GROUP BY x.menu_item_id HAVING count(*) > 1 OR bool_or(c.id IS NULL)

-- @@ I-032/3 — combo không có món sau khi giao dịch kết thúc
SELECT c.id AS combo FROM menu_combo c
WHERE NOT EXISTS (SELECT 1 FROM menu_combo_item i WHERE i.menu_combo_id = c.id)

-- @@ I-032/4 — món trong combo không có thật, thiếu số phần hoặc số phần không dương
SELECT x.id AS thanh_phan FROM menu_combo_item x
LEFT JOIN menu_item i ON i.id = x.menu_item_id
WHERE i.id IS NULL OR x.quantity IS NULL OR x.quantity <= 0

-- @@ I-032/5 — combo không có đúng một giá nguyên đồng lớn hơn 0
-- Một cột bigint giữ đúng một số nguyên; câu đọc giá thiếu hoặc không dương.
SELECT id AS combo FROM menu_combo WHERE price_vnd IS NULL OR price_vnd <= 0

-- @@ I-032/6 — lần đổi giá combo có lúc trong giờ bán
-- Cùng tham số giờ và múi giờ từ owner như I-011, không đặt giờ riêng.
SELECT r.id AS vet, r.target_row AS combo, r.revised_at
FROM record_revision r
WHERE r.target_table_code = 'menu_combo'
  AND r.before_image -> 'price_vnd' IS DISTINCT FROM r.after_image -> 'price_vnd'
  AND r.revised_at IS NOT NULL
  AND (r.revised_at AT TIME ZONE :mui_gio)::time BETWEEN :gio_mo AND :gio_dong

-- @@ I-032/7 — danh mục hoặc combo ẩn thiếu người ẩn hay lúc ẩn
WITH dau_an AS (
  SELECT 'menu_category' AS loai, id, hidden_at, hidden_by_person_id FROM menu_category
  UNION ALL SELECT 'menu_combo', id, hidden_at, hidden_by_person_id FROM menu_combo
)
SELECT x.loai, x.id FROM dau_an x LEFT JOIN person p ON p.id = x.hidden_by_person_id
WHERE (x.hidden_at IS NOT NULL AND p.id IS NULL)
   OR (x.hidden_at IS NULL AND x.hidden_by_person_id IS NOT NULL)

-- @@ I-032/8 — người lập, sửa hoặc ẩn danh mục / combo không phải chủ quán
-- Đọc cờ chủ quán hiện hành như I-030/2; không có ngoại lệ cho người trực quầy.
WITH thao_tac AS (
  SELECT 'menu_category' AS bang, 'tao' AS loai, id AS dong, person_id FROM menu_category
  UNION ALL SELECT 'menu_combo', 'tao', id, person_id FROM menu_combo
  -- Xếp món vào danh mục là sửa danh mục (thêm 2026-10-14, P2A-15, Claude Code).
  UNION ALL SELECT 'menu_item_category', 'xep', id, person_id FROM menu_item_category
  UNION ALL SELECT 'menu_category', 'an', id, hidden_by_person_id FROM menu_category WHERE hidden_at IS NOT NULL
  UNION ALL SELECT 'menu_combo', 'an', id, hidden_by_person_id FROM menu_combo WHERE hidden_at IS NOT NULL
  UNION ALL SELECT target_table_code, 'sua', target_row, person_id FROM record_revision
    WHERE target_table_code IN ('menu_category', 'menu_combo')
)
SELECT x.* FROM thao_tac x JOIN person p ON p.id = x.person_id WHERE NOT p.is_owner
