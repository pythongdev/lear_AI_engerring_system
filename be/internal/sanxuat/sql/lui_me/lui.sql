UPDATE production_batch SET rolled_back_at = clock_timestamp(), rolled_back_by_person_id = actor_person_id() WHERE id = $1 RETURNING to_jsonb(rolled_back_at);
