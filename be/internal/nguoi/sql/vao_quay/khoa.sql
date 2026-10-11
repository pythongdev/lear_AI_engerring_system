SELECT id, person_id, started_at, started_at >= now()
FROM counter_duty WHERE ended_at IS NULL FOR UPDATE
