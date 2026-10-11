-- Khoá dòng thành phần trước khi đổi giá; không có dòng ⇒ menu_component_not_found.
-- name: KhoaThanhPhan :one
SELECT id FROM menu_component WHERE id = $1 FOR UPDATE;
