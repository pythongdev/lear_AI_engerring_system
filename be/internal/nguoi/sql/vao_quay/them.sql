INSERT INTO counter_duty (person_id, started_at) VALUES ($1, now())
RETURNING id, person_id, started_at
