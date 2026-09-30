-- I-002 — docs/product/1-system-design/03-bao-ve-invariant.md §1, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.

-- @@ I-002/1 — phiên đã đóng mà số hoá đơn khác một
SELECT s.id AS phien, count(b.id) AS so_hoa_don
FROM table_session s LEFT JOIN bill b ON b.table_session_id = s.id
WHERE s.status = 'closed'
GROUP BY s.id
HAVING count(b.id) <> 1

-- @@ I-002/2 — phiên đã đóng mà số phải trả khác tổng mọi lượt gọi của phiên
-- Lượt gọi của mọi bàn trong nhóm ghép cùng mang phiên ấy, nên phép cộng theo phiên đã tính cả
-- chúng. Đơn Huỷ không vào tổng — trừ đơn đã Hoàn thành rồi mới huỷ SAU khi đóng (shop-facts
-- §6.19): hoá đơn giữ nguyên, tiền đi đường hoàn, nên hoá đơn có lần hoàn được đọc với cả phần ấy.
WITH tong AS (
  SELECT o.table_session_id AS phien,
         coalesce(sum(l.line_total_vnd) FILTER (WHERE o.status <> 'cancelled'), 0) AS con,
         coalesce(sum(l.line_total_vnd) FILTER (WHERE o.status = 'cancelled'), 0)  AS huy
  FROM sales_order o JOIN order_line l ON l.sales_order_id = o.id
  WHERE o.table_session_id IS NOT NULL
  GROUP BY 1)
SELECT b.table_session_id AS phien, b.id AS hoa_don, b.due_vnd AS phai_tra,
       coalesce(t.con, 0) AS tong_luot_goi
FROM bill b
JOIN table_session s ON s.id = b.table_session_id AND s.status = 'closed'
LEFT JOIN tong t ON t.phien = s.id
WHERE b.due_vnd <> coalesce(t.con, 0)
  AND NOT (b.due_vnd = coalesce(t.con, 0) + coalesce(t.huy, 0)
           AND EXISTS (SELECT 1 FROM refund r WHERE r.bill_id = b.id))

-- @@ I-002/3 — lượt gọi tại một bàn không thuộc phiên đang mở của bàn ấy
-- Hai hình: lượt gọi của kênh gắn bàn không mang phiên nào; và lượt gọi tạo SAU lúc phiên của nó
-- đã đóng — nó không vào hoá đơn nào. Hoá đơn nhập bù từ sổ giấy mang mốc bán thật còn đơn mang
-- lúc gõ (ADR-037), nên phiên của nó đứng ngoài hình thứ hai.
SELECT o.id AS don, o.channel_code AS kenh, o.dining_table_id AS ban, o.table_session_id AS phien
FROM sales_order o
WHERE (o.channel_code IN ('qr_table', 'staff_pos') AND o.table_session_id IS NULL)
   OR EXISTS (SELECT 1 FROM bill b
              WHERE b.table_session_id = o.table_session_id AND b.paper_ledger_id IS NULL
                AND o.created_at > b.booked_at)
