-- name: ThemPhien :one
INSERT INTO table_session (status) VALUES ($1) RETURNING id;
