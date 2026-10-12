-- name: HienTai :one
SELECT duty.person_id, person.display_name, duty.id, duty.started_at
FROM counter_duty duty JOIN person ON person.id = duty.person_id WHERE duty.ended_at IS NULL;
