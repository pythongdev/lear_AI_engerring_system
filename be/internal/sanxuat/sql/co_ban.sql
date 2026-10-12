-- name: CoBan :one
SELECT EXISTS (SELECT 1 FROM dining_table WHERE id = $1)::boolean;
