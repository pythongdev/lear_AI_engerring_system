-- CHAT-30 — I-039, ADR-138; mỗi tập phải rỗng.

-- @@ I-039/1 — một người một ngày vừa có ô vừa có báo nghỉ còn hiệu lực
SELECT l.id AS leave_notice_id, d.id AS attendance_day_id
FROM leave_notice l JOIN attendance_day d
  ON d.worker_person_id = l.person_id AND d.work_date = l.leave_date
WHERE l.cancelled_at IS NULL AND d.cancelled_at IS NULL

-- @@ I-039/2 — khoá ngoại báo nghỉ trỏ ra ngoài người
SELECT c.conname, n.nspname AS target_schema, t.relname AS target_table
FROM pg_constraint c
JOIN pg_class t ON t.oid = c.confrelid
JOIN pg_namespace n ON n.oid = t.relnamespace
WHERE c.contype = 'f' AND c.conrelid = 'shop.leave_notice'::regclass
  AND (n.nspname <> 'shop' OR t.relname <> 'person')

-- @@ I-039/3 — vai ứng dụng xoá được hoặc sửa được ngoài bốn dấu
SELECT 'leave_notice' AS table_name
WHERE has_table_privilege('shop_app', 'shop.leave_notice', 'DELETE')
   OR EXISTS (SELECT 1 FROM information_schema.columns c
              WHERE c.table_schema = 'shop' AND c.table_name = 'leave_notice'
                AND c.column_name NOT IN ('acknowledged_at', 'acknowledged_by_person_id', 'cancelled_at', 'cancelled_by_person_id')
                AND has_column_privilege('shop_app', 'shop.leave_notice', c.column_name, 'UPDATE'))

-- @@ I-039/4 — người ghi đã biết hoặc huỷ sai quyền
SELECT l.id FROM leave_notice l
LEFT JOIN person a ON a.id = l.acknowledged_by_person_id
LEFT JOIN person c ON c.id = l.cancelled_by_person_id
WHERE (l.acknowledged_at IS NOT NULL AND NOT a.is_owner)
   OR (l.cancelled_at IS NOT NULL AND NOT c.is_owner AND c.id <> l.person_id)
