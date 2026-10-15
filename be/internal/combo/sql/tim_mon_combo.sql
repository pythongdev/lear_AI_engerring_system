-- name: TimMonCombo :one
SELECT id FROM menu_combo_item WHERE menu_combo_id = $1 AND menu_item_id = $2;
