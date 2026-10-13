-- name: ThemBan :exec
INSERT INTO table_session_member (table_session_id, dining_table_id, session_closed, cleaned_at)
VALUES ($1,$2,$3,$4);
