-- Mốc gửi xuống theo RFC 3339 có độ lệch, ở múi giờ của kết nối — múi giờ quán (QC-15).
-- name: DocMaVuaCap :one
SELECT code, dining_table_id,
       to_char(issued_at, 'YYYY-MM-DD"T"HH24:MI:SS.USTZH:TZM')
  FROM qr_code WHERE id = $1;
