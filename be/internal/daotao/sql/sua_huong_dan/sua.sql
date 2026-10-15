-- name: SuaHuongDan :exec
UPDATE assigned_task_guide SET body = $2 WHERE id = $1;
