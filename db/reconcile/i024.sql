-- I-024 — docs/product/1-system-design/03-bao-ve-invariant.md §1, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Hai vế không có tập (lần gửi lại được trả lời hay bị từ chối · lần gửi bị gộp nhầm) — pha 1 nói
-- thẳng. Một lượt gọi vào phiên bàn là một dòng sales_order, nên "đơn" dưới đây phủ cả lượt gọi.

-- @@ I-024/1 — dấu lần gửi mang bởi hơn một đơn hay lượt gọi
SELECT o.submission_code AS dau, count(*) AS so_don
FROM sales_order o
GROUP BY o.submission_code
HAVING count(*) > 1

-- @@ I-024/2 — đơn hay lượt gọi không mang dấu lần gửi nào
SELECT o.id AS don, o.channel_code AS kenh
FROM sales_order o
WHERE btrim(coalesce(o.submission_code, '')) = ''

-- @@ I-024/3 — đơn mà nội dung hiện tại khác nội dung lúc tạo mà không có một lần sửa mang vết
-- Nội dung lúc tạo = các dòng ghi cùng lúc với đơn. Một dòng tạo SAU đơn mà không vết sửa nào (của
-- đơn hay của một dòng của nó) ghi từ lúc ấy trở đi là lần gửi lại đã trở thành đường sửa đơn. Lần
-- sửa không khai lý do không có vết (F-046) — câu này vẫn thấy nó, vì nó đọc từ phía dòng.
SELECT o.id AS don, o.created_at AS luc_tao, min(l.created_at) AS luc_dong_them
FROM sales_order o JOIN order_line l ON l.sales_order_id = o.id
WHERE l.created_at > o.created_at
  AND NOT EXISTS (SELECT 1 FROM record_revision r
                  WHERE r.revised_at >= l.created_at
                    AND (   (r.target_table_code = 'sales_order' AND r.target_row = o.id)
                         OR (r.target_table_code = 'order_line'
                             AND r.target_row IN (SELECT id FROM order_line WHERE sales_order_id = o.id))))
GROUP BY o.id, o.created_at
