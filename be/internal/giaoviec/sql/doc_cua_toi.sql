-- name: DocCuaToi :many
SELECT t.id, t.content, t.due_at, t.created_at, p.display_name AS assigned_by_name,
 coalesce((SELECT m.mark_code = 'done' FROM assigned_task_mark m
 WHERE m.assigned_task_id = t.id ORDER BY m.created_at DESC, m.id DESC LIMIT 1), false)::boolean AS done,
 coalesce((SELECT jsonb_agg(jsonb_build_object('body', g.body) ORDER BY g.created_at, g.id)
 FROM assigned_task_guide g
 WHERE g.assigned_task_id = t.id AND g.guide_kind_code = 'text' AND g.hidden_at IS NULL), '[]'::jsonb)::jsonb AS guides
FROM assigned_task t JOIN person p ON p.id = t.person_id
WHERE t.assignee_person_id = $1::bigint AND t.hidden_at IS NULL
ORDER BY t.created_at DESC, t.id DESC;
