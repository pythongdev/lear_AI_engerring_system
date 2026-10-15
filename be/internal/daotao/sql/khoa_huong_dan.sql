-- name: KhoaHuongDan :one
SELECT hidden_at, guide_kind_code FROM assigned_task_guide WHERE id = $1 FOR UPDATE;
