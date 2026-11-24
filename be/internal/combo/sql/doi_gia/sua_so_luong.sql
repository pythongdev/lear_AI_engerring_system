-- name: SuaSoLuongCombo :exec
UPDATE menu_combo_item SET quantity = $3
WHERE menu_combo_id = $1 AND menu_item_id = $2 AND retired_at IS NULL;
