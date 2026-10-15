-- name: KhoaSo :one
SELECT id FROM supply_day_entry WHERE id = $1 FOR UPDATE;
