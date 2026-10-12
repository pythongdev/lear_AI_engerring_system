-- name: DanhSach :many
SELECT id, display_name, is_owner FROM person ORDER BY display_name, id;
