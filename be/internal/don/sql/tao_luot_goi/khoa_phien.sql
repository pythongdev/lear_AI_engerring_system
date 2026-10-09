-- Kiểm trạng thái trên chính dòng bị khoá: nếu đóng chen vào lúc chờ khoá,
-- PostgreSQL xét lại is_closed và cửa đọc lại bàn từ chi tiết sau đó.
SELECT s.id, s.status FROM table_session s
JOIN table_session_member m ON m.table_session_id = s.id
WHERE m.dining_table_id = $1 AND NOT s.is_closed
FOR UPDATE OF s
