-- I-006 — docs/product/1-system-design/03-bao-ve-invariant.md §2, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Tập thứ nhất của pha 1 là "cùng một tập với I-007" và không đối chiếu hai lần: câu I-007/1.

-- @@ I-006/2 — suất mang dấu "đem về" đứng ở nguồn đơn lẻ thay vì nguồn phiên bàn
-- Dấu đem về là của khách ngồi bàn, ở mức dòng (YC-05); nguồn tiền đọc theo đơn vị tính tiền của
-- đơn. Một dòng mang dấu ấy trên một đơn không thuộc phiên nào là suất đã rời phiên của nó.
SELECT l.id AS dong, o.id AS don, o.channel_code AS kenh
FROM order_line l JOIN sales_order o ON o.id = l.sales_order_id
WHERE l.is_takeaway AND o.table_session_id IS NULL
