-- name: Doc :one
SELECT id, phone, email, display_name, delivery_name, delivery_phone, delivery_address, delivery_updated_at, created_at FROM customer_account WHERE id=$1 FOR UPDATE;
