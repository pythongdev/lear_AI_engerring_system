-- name: CapNhatAnhMon :one
UPDATE menu_item SET image_code = $2 WHERE id = $1 RETURNING id, image_code;
