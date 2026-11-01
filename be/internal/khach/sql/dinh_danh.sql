-- name: DinhDanh :one
SELECT id, phone, email, pending_email, display_name, delivery_name, delivery_phone, delivery_address, delivery_updated_at, created_at FROM customer_account WHERE phone=$1 OR email=$1 FOR UPDATE;
