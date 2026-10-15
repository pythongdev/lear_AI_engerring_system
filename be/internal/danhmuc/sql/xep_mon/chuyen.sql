-- name: Chuyen :exec
UPDATE menu_item_category SET menu_category_id = $2 WHERE menu_item_id = $1;
