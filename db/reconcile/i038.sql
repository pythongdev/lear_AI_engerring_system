-- CHAT-12 — I-038; tin báo tách khỏi tiến độ (ADR-137).

-- @@ I-038/1 — khoá ngoại vượt ranh giới người, bàn và tin
SELECT c.conname, dn.nspname AS target_schema, dst.relname AS target_table
FROM pg_constraint c
JOIN pg_class src ON src.oid = c.conrelid
JOIN pg_namespace sn ON sn.oid = src.relnamespace
JOIN pg_class dst ON dst.oid = c.confrelid
JOIN pg_namespace dn ON dn.oid = dst.relnamespace
WHERE c.contype = 'f' AND sn.nspname = 'shop' AND src.relname = 'station_message'
  AND (dn.nspname <> 'shop' OR dst.relname NOT IN ('person', 'dining_table', 'station_message'))

-- @@ I-038/2 — người gửi trùng người nhận
SELECT id FROM station_message WHERE sender_person_id = recipient_person_id

-- @@ I-038/3 — vai ghi có quyền sửa hoặc xoá tin (kể cả sửa từng cột)
SELECT 'station_message' AS table_name
WHERE has_table_privilege('shop_app', 'shop.station_message', 'UPDATE')
   OR has_any_column_privilege('shop_app', 'shop.station_message', 'UPDATE')
   OR has_table_privilege('shop_app', 'shop.station_message', 'DELETE')

-- @@ I-038/4 — nội dung hoặc nhãn việc sai miền
SELECT id FROM station_message
WHERE body !~ '[^[:space:]]' OR char_length(body) > 500
   OR work_code NOT IN ('canh', 'don_ban', 'trang_banh', 'gap_banh', 'khac')
