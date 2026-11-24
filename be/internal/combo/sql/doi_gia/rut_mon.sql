-- name: RutMonCombo :exec
UPDATE menu_combo_item SET retired_at = now()
WHERE menu_combo_id = $1 AND menu_item_id = $2 AND retired_at IS NULL;
