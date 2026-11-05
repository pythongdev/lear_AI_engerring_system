-- kêu: I-040/4
ALTER TABLE model_call DROP CONSTRAINT model_call_settled_after_check;
INSERT INTO model_call (provider_code, model_code, reserved_microusd, settled_at, cost_microusd)
VALUES ('gia', 'proof-i040-4', 1, now() - interval '1 second', 1);
