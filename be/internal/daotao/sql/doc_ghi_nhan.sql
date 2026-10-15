-- name: DocGhiNhan :many
SELECT g.id, g.trainee_person_id, a.display_name AS trainee_name, g.remark, g.rating_code,
 g.person_id, p.display_name AS person_name, g.created_at,
 g.hidden_at, g.hidden_by_person_id, h.display_name AS hidden_by_name
FROM training_record g JOIN person a ON a.id = g.trainee_person_id
JOIN person p ON p.id = g.person_id LEFT JOIN person h ON h.id = g.hidden_by_person_id
WHERE ($1::bigint = 0 OR g.id = $1) AND ($2::bigint = 0 OR g.trainee_person_id = $2)
 AND ($3::boolean OR g.hidden_at IS NULL)
ORDER BY g.created_at, g.id;
