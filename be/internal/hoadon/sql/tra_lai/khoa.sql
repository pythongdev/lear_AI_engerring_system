-- name: KhoaKhoanTraLai :one
SELECT id FROM prepayment WHERE id = $1 FOR UPDATE;
