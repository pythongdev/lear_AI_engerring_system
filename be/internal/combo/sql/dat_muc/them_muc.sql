-- name: ThemMuc :exec
INSERT INTO menu_combo_item_option_surcharge (menu_combo_item_id, menu_option_id, surcharge_vnd) VALUES ($1, $2, $3);
