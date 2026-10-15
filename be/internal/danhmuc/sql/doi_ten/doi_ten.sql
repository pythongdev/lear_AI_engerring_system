-- name: DoiTen :exec
UPDATE menu_category SET name = $2 WHERE id = $1;
