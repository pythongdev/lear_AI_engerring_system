-- Khoá dòng món và đọc đã có mốc ngừng bán chưa; ép ::boolean để sqlc sinh bool, không interface{}.
-- name: KhoaMonNgungBan :one
SELECT (discontinued_at IS NOT NULL)::boolean AS da_ngung FROM menu_item WHERE id = $1 FOR UPDATE;
