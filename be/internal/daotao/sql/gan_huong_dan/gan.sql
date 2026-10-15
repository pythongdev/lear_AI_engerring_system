-- name: GanHuongDan :one
INSERT INTO assigned_task_guide (assigned_task_id, guide_kind_code, body, file_code) VALUES ($1,$2,$3,$4) RETURNING id;
