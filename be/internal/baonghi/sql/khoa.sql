-- name: Khoa :one
SELECT m.id FROM leave_notice m
WHERE m.id = $1 AND (m.person_id = actor_person_id() OR
 (SELECT is_owner FROM person WHERE id = actor_person_id()))
FOR UPDATE OF m;
