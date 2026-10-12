-- name: DocMonDangBan :many
SELECT id, name FROM menu_item
 WHERE discontinued_at IS NULL OR discontinued_at > now() ORDER BY id;
