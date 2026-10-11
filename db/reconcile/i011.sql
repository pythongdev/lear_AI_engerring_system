-- I-011 — docs/product/1-system-design/03-bao-ve-invariant.md §3, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Hai tập còn lại (lời nhắc đã hiện · lời nhắc nhầm cho lần đổi giá) KHÔNG có câu: lược đồ không cất
-- lời nhắc nào — file 09 §2.

-- @@ I-011/1 — lần đổi thành phần của một suất trong giờ bán mà không có vết đổi gì · lúc nào · ai
-- Hai hình: thành phần THÊM vào một suất đã có, trong giờ bán, mà suất không có vết thêm của chính
-- dòng ấy (T-137, ADR-081: bản trước không có dòng, bản sau có — đọc ra đổi gì · lúc nào · ai); và
-- một lần SỬA thành phần có khai lý do mà vết thiếu người — không tồn tại được khi ràng buộc còn.
-- Từ bước 20 (T-138) database từ chối lần sửa hay lần thêm không khai lý do; lần đổi vượt database
-- (tắt trigger vết) thì không vết: lần thêm thì câu này thấy, lần sửa thì không.
SELECT c.menu_item_id AS mon, c.id AS dong_thanh_phan, 'thêm' AS kieu,
       (c.created_at AT TIME ZONE :mui_gio) AS luc
FROM menu_item_component c JOIN menu_item m ON m.id = c.menu_item_id
WHERE c.created_at > m.created_at
  AND (c.created_at AT TIME ZONE :mui_gio)::time BETWEEN :gio_mo AND :gio_dong
  AND NOT EXISTS (SELECT 1 FROM record_revision r
                  WHERE r.target_table_code = 'menu_item' AND r.target_row = m.id
                    AND r.after_image -> 'menu_item_component'
                        @> jsonb_build_array(jsonb_build_object('id', c.id))
                    AND NOT coalesce(r.before_image -> 'menu_item_component'
                                     @> jsonb_build_array(jsonb_build_object('id', c.id)), false))
UNION ALL
SELECT (r.after_image ->> 'menu_item_id')::bigint, r.target_row, 'sửa',
       (r.revised_at AT TIME ZONE :mui_gio)
FROM record_revision r
WHERE r.target_table_code = 'menu_item_component' AND r.person_id IS NULL
  AND (r.revised_at AT TIME ZONE :mui_gio)::time BETWEEN :gio_mo AND :gio_dong
