-- name: ThemMon :exec
INSERT INTO menu_combo_item (menu_combo_id, menu_item_id, quantity) VALUES ($1, $2, $3);
