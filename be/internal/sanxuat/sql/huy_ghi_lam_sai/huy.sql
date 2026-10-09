UPDATE wrong_make_note SET cancelled_at = clock_timestamp(), cancelled_by_person_id = actor_person_id() WHERE id = $1 RETURNING to_jsonb(cancelled_at);
