-- Khoá đúng cặp món · thành phần trước khi sửa số lượng; không có dòng ⇒ menu_item_component_not_found.
-- name: KhoaMonThanhPhan :one
SELECT id FROM menu_item_component WHERE menu_item_id = $1 AND menu_component_id = $2 FOR UPDATE;
