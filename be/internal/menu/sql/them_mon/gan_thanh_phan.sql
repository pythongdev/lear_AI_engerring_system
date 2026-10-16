-- name: GanThanhPhan :exec
INSERT INTO menu_item_component (menu_item_id, menu_component_id, quantity) VALUES ($1, $2, $3);
