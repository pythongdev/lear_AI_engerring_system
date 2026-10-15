-- name: DoiGia :exec
UPDATE menu_combo SET price_vnd = $2 WHERE id = $1;
