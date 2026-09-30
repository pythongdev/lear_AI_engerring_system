-- I-011 — docs/product/1-system-design/03-bao-ve-invariant.md §3, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Hai tập còn lại (lời nhắc đã hiện · lời nhắc nhầm cho lần đổi giá) KHÔNG có câu: lược đồ không cất
-- lời nhắc nào — file 09 §2.

-- @@ I-011/1 — lần đổi thành phần của một suất trong giờ bán mà không có vết đổi gì · lúc nào · ai
-- Hai hình: thành phần THÊM vào một suất đã có, trong giờ bán — một dòng mới không mang vết cập nhật
-- và không mang người; và một lần SỬA thành phần có khai lý do mà vết thiếu người — không tồn tại
-- được khi ràng buộc còn. Lần sửa không khai lý do không có vết (F-046) và không câu nào thấy.
SELECT c.menu_item_id AS mon, c.id AS dong_thanh_phan, 'thêm' AS kieu,
       (c.created_at AT TIME ZONE :mui_gio) AS luc
FROM menu_item_component c JOIN menu_item m ON m.id = c.menu_item_id
WHERE c.created_at > m.created_at
  AND (c.created_at AT TIME ZONE :mui_gio)::time BETWEEN :gio_mo AND :gio_dong
UNION ALL
SELECT (r.after_image ->> 'menu_item_id')::bigint, r.target_row, 'sửa',
       (r.revised_at AT TIME ZONE :mui_gio)
FROM record_revision r
WHERE r.target_table_code = 'menu_item_component' AND r.person_id IS NULL
  AND (r.revised_at AT TIME ZONE :mui_gio)::time BETWEEN :gio_mo AND :gio_dong
