-- name: KhoaThu :one
SELECT purchase_unit FROM supply_item WHERE id = $1 FOR UPDATE;
