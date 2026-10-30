-- name: LuuGiao :exec
UPDATE customer_account SET delivery_name=$2,delivery_phone=$3,delivery_address=$4,delivery_updated_at=now() WHERE id=$1;
