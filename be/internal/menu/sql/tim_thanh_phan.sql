-- Thành phần có tồn tại không; không có dòng ⇒ menu_component_not_found.
-- name: TimThanhPhan :one
SELECT id FROM menu_component WHERE id = $1;
