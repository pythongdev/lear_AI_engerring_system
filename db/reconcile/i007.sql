-- I-007 — docs/product/1-system-design/03-bao-ve-invariant.md §1, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- "Đơn lẻ đóng" đọc là Hoàn thành (04-luoc-do-duong-tien.md §3). Đơn Hoàn thành rồi huỷ giữ hoá
-- đơn của nó (shop-facts §6.19), nên nó không đứng trong tập "khác một lần thu".

-- @@ I-007/1 — đơn của ba kênh không gắn bàn đang gắn với một phiên bàn
-- Cũng là tập thứ nhất của I-006: một ranh giới, một tập.
SELECT o.id AS don, o.channel_code AS kenh, o.table_session_id AS phien, o.status
FROM sales_order o
WHERE o.channel_code IN ('delivery', 'pickup', 'phone_preorder')
  AND (o.table_session_id IS NOT NULL OR o.dining_table_id IS NOT NULL)

-- @@ I-007/2 — lần thu gộp hai đơn lẻ làm một
-- Hoá đơn đứng tên đúng một đơn, nên một lần thu gộp hiện ra là một hoá đơn thu nhiều hơn chính đơn
-- của nó — phần dư là tiền của đơn kia.
SELECT b.id AS hoa_don, b.sales_order_id AS don, b.due_vnd AS phai_tra,
       (SELECT coalesce(sum(l.line_total_vnd), 0) FROM order_line l
        WHERE l.sales_order_id = b.sales_order_id) AS tong_don
FROM bill b
WHERE b.sales_order_id IS NOT NULL
  AND b.due_vnd > (SELECT coalesce(sum(l.line_total_vnd), 0) FROM order_line l
                   WHERE l.sales_order_id = b.sales_order_id)

-- @@ I-007/3 — đơn lẻ đã Hoàn thành mà số lần thu khác một
SELECT o.id AS don, o.channel_code AS kenh, count(b.id) AS so_lan_thu
FROM sales_order o LEFT JOIN bill b ON b.sales_order_id = o.id
WHERE o.table_session_id IS NULL AND o.status = 'completed'
GROUP BY o.id, o.channel_code
HAVING count(b.id) <> 1
