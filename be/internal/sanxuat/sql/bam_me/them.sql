INSERT INTO production_batch DEFAULT VALUES RETURNING id, to_jsonb(made_at);
