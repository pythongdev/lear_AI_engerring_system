-- Món có tồn tại không; không có dòng ⇒ menu_item_not_found.
-- name: TimMon :one
SELECT id FROM menu_item WHERE id = $1;
