-- name: An :exec
UPDATE menu_category SET hidden_at = now(), hidden_by_person_id = actor_person_id() WHERE id = $1;
