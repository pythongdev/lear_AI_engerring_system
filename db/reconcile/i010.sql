-- I-010 — docs/product/1-system-design/03-bao-ve-invariant.md §3, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Ba tập còn lại (tổ hợp khác tổ hợp khách gửi · yêu cầu bị từ chối vẫn sinh dòng · dòng cũ bị đánh
-- dấu hỏng) KHÔNG có câu: lược đồ không cất yêu cầu gốc, lần từ chối hay dấu hỏng nào — file 09 §2.

-- @@ I-010/1 — dòng đơn mang một tổ hợp tuỳ chọn không hợp lệ theo luật đang hiệu lực tại mốc khoá của nó
-- Luật cất theo TẬP (03-luoc-do-menu-gia.md §2): nhóm của lựa chọn phải gắn với món, và nhóm có tập
-- điều kiện chỉ tồn tại khi ít nhất một lựa chọn trong tập được chọn. Không dòng luật nào bị xoá
-- (QD-50), nên "luật tại mốc" = các dòng luật tạo trước mốc ấy — dòng cũ không bị luật mới chấm.
SELECT l.id AS dong, l.item_name AS mon, x.option_group_name AS nhom, x.option_name AS lua_chon
FROM order_line l
JOIN order_line_option x ON x.order_line_id = l.id
JOIN menu_option o       ON o.id = x.menu_option_id
WHERE NOT EXISTS (SELECT 1 FROM menu_item_option_group g
                  WHERE g.menu_item_id = l.menu_item_id AND g.option_group_id = o.option_group_id
                    AND g.created_at <= l.priced_at)
   OR (    EXISTS (SELECT 1 FROM option_group_prerequisite p
                   WHERE p.option_group_id = o.option_group_id AND p.created_at <= l.priced_at)
       AND NOT EXISTS (SELECT 1 FROM option_group_prerequisite p
                       JOIN order_line_option y
                         ON y.menu_option_id = p.menu_option_id AND y.order_line_id = l.id
                       WHERE p.option_group_id = o.option_group_id AND p.created_at <= l.priced_at))
