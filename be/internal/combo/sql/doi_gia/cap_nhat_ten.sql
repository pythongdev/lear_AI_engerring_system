-- name: CapNhatTenCombo :exec
UPDATE menu_combo SET name = $2 WHERE id = $1;
