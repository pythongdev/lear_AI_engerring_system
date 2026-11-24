-- name: DocAnhCombo :one
SELECT image_code FROM menu_combo WHERE id = $1;
