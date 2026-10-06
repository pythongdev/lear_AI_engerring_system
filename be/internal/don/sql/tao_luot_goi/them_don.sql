-- Cửa don/tao_luot_goi (P3-06, lớp quay). Vế kênh mở rộng ở P3-07/P3-08.
INSERT INTO sales_order (channel_code, status, table_session_id, dining_table_id, submission_code)
VALUES ('staff_pos', 'new', $1, $2, $3)
RETURNING id
