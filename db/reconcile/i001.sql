-- I-001 — docs/product/1-system-design/03-bao-ve-invariant.md §2, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.

-- @@ I-001/1 — bàn đứng trong hơn một phiên chưa đóng
-- Đọc trạng thái thật của phiên, không đọc bản soi session_closed: câu này sinh ra để bắt đúng lúc
-- khoá duy nhất trên bản soi đã bị gỡ hoặc bản soi lệch.
SELECT m.dining_table_id AS ban, array_agg(m.table_session_id ORDER BY m.table_session_id) AS phien
FROM table_session_member m JOIN table_session s ON s.id = m.table_session_id
WHERE s.status <> 'closed'
GROUP BY m.dining_table_id
HAVING count(*) > 1

-- @@ I-001/2 — bàn của một nhóm ghép còn gắn một phiên chưa đóng khác ngoài phiên của nhóm
SELECT m.dining_table_id AS ban, m.table_session_id AS phien_nhom, k.table_session_id AS phien_khac
FROM table_session_member m
JOIN table_session s  ON s.id = m.table_session_id
JOIN table_session_member k
  ON k.dining_table_id = m.dining_table_id AND k.table_session_id <> m.table_session_id
JOIN table_session sk ON sk.id = k.table_session_id
WHERE s.status <> 'closed' AND sk.status <> 'closed'
  AND (SELECT count(*) FROM table_session_member x WHERE x.table_session_id = m.table_session_id) > 1
