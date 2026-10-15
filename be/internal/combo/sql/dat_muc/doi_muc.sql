-- name: DoiMuc :exec
UPDATE menu_combo_item_option_surcharge SET surcharge_vnd = $2 WHERE id = $1;
