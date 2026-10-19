-- Khoá nhóm trước khi thêm lựa chọn vào nó; không có dòng ⇒ option_group_not_found.
-- name: KhoaNhom :one
SELECT id FROM option_group WHERE id = $1 FOR UPDATE;
