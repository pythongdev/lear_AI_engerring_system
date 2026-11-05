-- CHAT-35 — chỉ gỡ sổ rỗng (ADR-065).
LOCK TABLE model_call IN ACCESS EXCLUSIVE MODE;
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM model_call) THEN
    RAISE EXCEPTION 'đường lùi từ chối: model_call đang giữ lần gọi đã ghi'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'model_call_rollback_check';
  END IF;
END $$;
ALTER TABLE record_revision DROP CONSTRAINT record_revision_person_check,
  ADD CONSTRAINT record_revision_person_check CHECK (person_id IS NOT NULL OR target_table_code IN
    ('customer_account', 'customer_password', 'customer_session', 'customer_password_reset', 'customer_email_verification'));
DROP TRIGGER model_call_guard_trg ON model_call;
DROP TRIGGER model_call_record_revision_trg ON model_call;
DROP FUNCTION model_call_guard();
DROP TABLE model_call;
