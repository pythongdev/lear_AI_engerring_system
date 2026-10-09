SELECT id FROM table_session_member
WHERE dining_table_id = $1 AND session_closed AND cleaned_at IS NULL ORDER BY id FOR UPDATE
