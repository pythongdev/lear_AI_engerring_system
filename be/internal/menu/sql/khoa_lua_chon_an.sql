-- Khoá lựa chọn trước khi ẩn · bật lại; không có dòng ⇒ menu_option_not_found.
-- name: KhoaLuaChonAn :one
SELECT id, is_default, (hidden_at IS NOT NULL)::boolean AS da_an FROM menu_option WHERE id = $1 FOR UPDATE;
