-- name: DocXep :one
SELECT menu_category_id FROM menu_item_category WHERE menu_item_id = $1;
