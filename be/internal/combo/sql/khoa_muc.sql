-- name: KhoaMuc :one
SELECT id, surcharge_vnd FROM menu_combo_item_option_surcharge
WHERE menu_combo_item_id = $1 AND menu_option_id = $2 FOR UPDATE;
