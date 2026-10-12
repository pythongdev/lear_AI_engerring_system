-- name: ChuQuanGiamGia :one
SELECT is_owner FROM person WHERE id = $1;
