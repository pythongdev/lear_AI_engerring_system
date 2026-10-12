-- name: DocBan :one
SELECT t.id, t.label,
 CASE WHEN s.id IS NOT NULL THEN 'in_session'
 WHEN EXISTS (SELECT 1 FROM table_session_member m WHERE m.dining_table_id = t.id AND m.session_closed AND m.cleaned_at IS NULL)
 THEN 'needs_cleaning' ELSE 'empty' END::text AS state,
 s.id, s.status
 FROM dining_table t
 LEFT JOIN table_session_member m ON m.dining_table_id = t.id AND NOT m.session_closed
 LEFT JOIN table_session s ON s.id = m.table_session_id WHERE t.id = $1;
