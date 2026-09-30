-- I-003 — docs/product/1-system-design/03-bao-ve-invariant.md §2, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Bàn KHÔNG có cột trạng thái (02-luoc-do-ban-hang.md §3): "Trống" đọc ra từ chi tiết, nên hai tập
-- dưới đây đọc hai nửa của điều kiện trên chi tiết ấy. Lúc đóng phiên = mốc của hoá đơn phiên.

-- @@ I-003/1 — bàn ghi đã dọn khi phiên của nó chưa đóng
SELECT m.dining_table_id AS ban, m.table_session_id AS phien, s.status
FROM table_session_member m JOIN table_session s ON s.id = m.table_session_id
WHERE m.cleaned_at IS NOT NULL AND s.status <> 'closed'

-- @@ I-003/2 — bàn nhận phiên sau khi phiên trước đã đóng mà chưa có "đã dọn" ghi sau lúc đóng
SELECT m.dining_table_id AS ban, m.table_session_id AS phien_truoc, b.booked_at AS luc_dong,
       m.cleaned_at AS luc_don, n.table_session_id AS phien_sau, n.created_at AS luc_ngoi
FROM table_session_member m
JOIN table_session s ON s.id = m.table_session_id AND s.status = 'closed'
LEFT JOIN bill b ON b.table_session_id = s.id
JOIN LATERAL (SELECT x.table_session_id, x.created_at FROM table_session_member x
              WHERE x.dining_table_id = m.dining_table_id AND x.id > m.id
              ORDER BY x.id LIMIT 1) n ON true
WHERE m.cleaned_at IS NULL OR m.cleaned_at < b.booked_at OR m.cleaned_at > n.created_at
