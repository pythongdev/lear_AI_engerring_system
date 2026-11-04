-- name: NguoiNhan :one
SELECT EXISTS (SELECT 1 FROM account WHERE person_id = $1 AND status = 'hoat_dong')::boolean;
