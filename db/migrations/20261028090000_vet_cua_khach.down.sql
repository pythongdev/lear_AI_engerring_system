-- T-264 — đường lùi chỉ khi chưa có vết nào người sửa rỗng (ADR-127): gỡ là mất vết của khách.
LOCK TABLE record_revision IN ACCESS EXCLUSIVE MODE;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM record_revision WHERE person_id IS NULL) THEN
    RAISE EXCEPTION 'đường lùi từ chối: record_revision đang giữ vết của khách (người sửa rỗng)'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'record_revision_person_rollback_check';
  END IF;
END $$;
ALTER TABLE record_revision
  DROP CONSTRAINT record_revision_person_check,
  ALTER COLUMN person_id SET NOT NULL;
