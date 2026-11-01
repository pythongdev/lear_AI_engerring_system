-- T-267 — không gỡ liên kết Google đã ghi (ADR-132).
LOCK TABLE customer_google_identity IN ACCESS EXCLUSIVE MODE;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM customer_google_identity) THEN
    RAISE EXCEPTION 'đường lùi từ chối: customer_google_identity đang giữ dữ liệu'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'customer_google_identity_rollback_check';
  END IF;
END $$;
DROP TABLE customer_google_identity;
