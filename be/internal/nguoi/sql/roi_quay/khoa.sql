SELECT id FROM counter_duty WHERE person_id = $1 AND ended_at IS NULL FOR UPDATE
