UPDATE counter_duty SET ended_at = now() WHERE id = $1 AND ended_at IS NULL
RETURNING id, person_id, started_at, ended_at
