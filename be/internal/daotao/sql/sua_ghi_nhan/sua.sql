-- name: SuaGhiNhan :exec
UPDATE training_record SET remark = $2, rating_code = $3 WHERE id = $1;
