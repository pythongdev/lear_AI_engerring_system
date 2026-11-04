-- CHAT-30 — chỉ gỡ chỗ cất rỗng (ADR-065).
LOCK TABLE leave_notice IN ACCESS EXCLUSIVE MODE;
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM leave_notice) THEN
    RAISE EXCEPTION 'đường lùi từ chối: leave_notice đang giữ báo nghỉ'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'leave_notice_rollback_check';
  END IF;
END $$;
DROP TRIGGER attendance_day_on_leave_trg ON attendance_day;
DROP FUNCTION attendance_day_on_leave_guard();
DROP TRIGGER leave_notice_guard_trg ON leave_notice;
DROP TRIGGER leave_notice_record_revision_trg ON leave_notice;
DROP FUNCTION leave_notice_guard();
DROP FUNCTION leave_notice_day_lock_key(bigint, date);
DROP TABLE leave_notice;
