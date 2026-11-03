-- CHAT-12 — chỉ gỡ chỗ cất rỗng, không mất tin đã gửi (ADR-065).
LOCK TABLE station_message IN ACCESS EXCLUSIVE MODE;
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM station_message) THEN
    RAISE EXCEPTION 'đường lùi từ chối: station_message đang giữ tin đã gửi'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'station_message_rollback_check';
  END IF;
END $$;
DROP TRIGGER station_message_record_revision_trg ON station_message;
DROP TABLE station_message;
