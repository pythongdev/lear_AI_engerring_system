-- name: KhoaMe :one
SELECT is_rolled_back FROM production_batch WHERE id = $1 FOR UPDATE;
