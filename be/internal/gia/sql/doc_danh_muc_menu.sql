-- name: DocDanhMucMenu :many
SELECT c.id AS menu_category_id, c.name, x.menu_item_id
FROM menu_category c
JOIN menu_item_category x ON x.menu_category_id = c.id
WHERE c.hidden_at IS NULL AND x.menu_item_id = ANY($1::bigint[])
ORDER BY c.name, c.id, x.menu_item_id;
