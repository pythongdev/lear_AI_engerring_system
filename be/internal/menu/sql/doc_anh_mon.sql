-- name: DocAnhMon :one
SELECT image_code FROM menu_item WHERE id = $1;
