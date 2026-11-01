-- name: XacNhanEmail :exec
UPDATE customer_account SET email=pending_email,pending_email=NULL WHERE id=$1;
