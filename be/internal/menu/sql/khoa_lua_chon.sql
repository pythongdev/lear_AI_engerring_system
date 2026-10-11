-- Khoá dòng lựa chọn trước khi đổi phụ thu; không có dòng ⇒ menu_option_not_found.
-- name: KhoaLuaChon :one
SELECT id FROM menu_option WHERE id = $1 FOR UPDATE;
