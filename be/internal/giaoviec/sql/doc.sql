-- name: Doc :many
SELECT t.id, t.content, t.assignee_person_id, a.display_name AS assignee_name,
 t.person_id, p.display_name AS person_name, t.created_at, t.due_at,
 t.hidden_at, t.hidden_by_person_id, h.display_name AS hidden_by_name,
 coalesce((SELECT m.mark_code = 'done' FROM assigned_task_mark m
 WHERE m.assigned_task_id = t.id ORDER BY m.created_at DESC, m.id DESC LIMIT 1), false)::boolean AS done,
 coalesce((SELECT jsonb_agg(jsonb_build_object('assigned_task_mark_id', m.id,
 'mark', m.mark_code, 'person_id', m.person_id, 'person_name', mp.display_name,
 'created_at', m.created_at) ORDER BY m.created_at, m.id)
 FROM assigned_task_mark m JOIN person mp ON mp.id = m.person_id
 WHERE m.assigned_task_id = t.id), '[]'::jsonb)::jsonb AS marks
FROM assigned_task t JOIN person a ON a.id = t.assignee_person_id
JOIN person p ON p.id = t.person_id LEFT JOIN person h ON h.id = t.hidden_by_person_id
WHERE ($1::bigint = 0 OR t.id = $1) AND ($2::bigint = 0 OR t.assignee_person_id = $2)
 AND ($3::boolean OR t.hidden_at IS NULL)
ORDER BY t.created_at DESC, t.id DESC;
