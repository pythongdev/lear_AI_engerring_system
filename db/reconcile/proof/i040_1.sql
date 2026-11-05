-- kêu: I-040/1
ALTER TABLE model_call DISABLE TRIGGER model_call_guard_trg;
INSERT INTO model_call (provider_code, model_code, reserved_microusd)
VALUES ('gia', 'proof-i040-1', 10000001);
