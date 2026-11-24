-- name: CapNhatAnhCombo :exec
UPDATE menu_combo SET image_code = $2 WHERE id = $1;
