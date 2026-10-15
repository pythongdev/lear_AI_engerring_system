-- name: TimLoai :one
SELECT paid_from_till FROM expense_category WHERE id = $1;
