-- name: TimLoai :one
SELECT paid_from_till, tracks_supply FROM expense_category WHERE id = $1 AND deleted_at IS NULL FOR SHARE;
