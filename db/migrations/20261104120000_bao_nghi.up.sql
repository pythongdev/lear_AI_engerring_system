-- CHAT-30 — ADR-138 điểm 1…5, 8; I-039.
-- Ý định và tầng bảo vệ: docs/product/2-db/27-luoc-do-bao-nghi.md.
CREATE TABLE leave_notice (
  id bigint GENERATED ALWAYS AS IDENTITY,
  person_id bigint NOT NULL DEFAULT actor_person_id(),
  leave_date date NOT NULL,
  submission_code text COLLATE "C" NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  acknowledged_at timestamptz,
  acknowledged_by_person_id bigint,
  cancelled_at timestamptz,
  cancelled_by_person_id bigint,
  CONSTRAINT leave_notice_pkey PRIMARY KEY (id),
  CONSTRAINT leave_notice_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT leave_notice_acknowledged_by_person_fkey FOREIGN KEY (acknowledged_by_person_id) REFERENCES person (id),
  CONSTRAINT leave_notice_cancelled_by_person_fkey FOREIGN KEY (cancelled_by_person_id) REFERENCES person (id),
  CONSTRAINT leave_notice_submission_code_check CHECK (submission_code ~ '[^[:space:]]'),
  CONSTRAINT leave_notice_person_submission_code_key UNIQUE (person_id, submission_code),
  CONSTRAINT leave_notice_acknowledged_pair_check CHECK ((acknowledged_at IS NULL) = (acknowledged_by_person_id IS NULL)),
  CONSTRAINT leave_notice_cancelled_pair_check CHECK ((cancelled_at IS NULL) = (cancelled_by_person_id IS NULL))
);
CREATE UNIQUE INDEX leave_notice_one_live_per_person_day_key
  ON leave_notice (person_id, leave_date) WHERE cancelled_at IS NULL;

-- Một công thức chung, không phụ thuộc DateStyle của kết nối. Va chạm băm chỉ
-- khiến hai cặp khác nhau đợi nhau, không làm mất khoá của cùng một cặp.
CREATE FUNCTION leave_notice_day_lock_key(bigint, date) RETURNS bigint
LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE AS $$
  SELECT hashtextextended('leave_notice:' || $1::text || ':' || ($2 - DATE '2000-01-01')::text, 0)
$$;

CREATE FUNCTION leave_notice_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path = shop, pg_temp AS $$
DECLARE today date := (now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date;
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF ROW(NEW.person_id, NEW.leave_date, NEW.submission_code, NEW.created_at)
         IS DISTINCT FROM ROW(OLD.person_id, OLD.leave_date, OLD.submission_code, OLD.created_at)
       OR (OLD.acknowledged_at IS NOT NULL AND
           ROW(NEW.acknowledged_at, NEW.acknowledged_by_person_id)
             IS DISTINCT FROM ROW(OLD.acknowledged_at, OLD.acknowledged_by_person_id))
       OR (OLD.cancelled_at IS NOT NULL AND
           ROW(NEW.cancelled_at, NEW.cancelled_by_person_id)
             IS DISTINCT FROM ROW(OLD.cancelled_at, OLD.cancelled_by_person_id)) THEN
      RAISE EXCEPTION 'leave_notice: người, ngày, mã gửi, lúc tạo và dấu đã ghi không được đổi'
        USING ERRCODE = 'check_violation', CONSTRAINT = 'leave_notice_stamps_once_check';
    END IF;
  ELSE
    IF NEW.leave_date < today THEN
      RAISE EXCEPTION 'leave_notice: không báo nghỉ cho ngày đã qua'
        USING ERRCODE = 'check_violation', CONSTRAINT = 'leave_notice_not_past_check';
    END IF;
    PERFORM pg_advisory_xact_lock(leave_notice_day_lock_key(NEW.person_id, NEW.leave_date));
    IF EXISTS (SELECT 1 FROM attendance_day
               WHERE worker_person_id = NEW.person_id AND work_date = NEW.leave_date AND cancelled_at IS NULL) THEN
      RAISE EXCEPTION 'leave_notice: ngày ấy đã có ô có đi làm còn hiệu lực'
        USING ERRCODE = 'check_violation', CONSTRAINT = 'leave_notice_attendance_ticked_check';
    END IF;
  END IF;

  -- Người không tồn tại để FK bắt; dấu lẻ đôi để CHECK đôi bắt.
  IF NEW.acknowledged_at IS NOT NULL AND NEW.acknowledged_by_person_id IS NOT NULL
     AND (TG_OP = 'INSERT' OR OLD.acknowledged_by_person_id IS NULL)
     AND EXISTS (SELECT 1 FROM person WHERE id = NEW.acknowledged_by_person_id AND NOT is_owner) THEN
    RAISE EXCEPTION 'leave_notice: chỉ chủ quán ghi đã biết'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'leave_notice_acknowledged_by_owner_check';
  END IF;
  IF NEW.cancelled_at IS NOT NULL AND NEW.cancelled_by_person_id IS NOT NULL
     AND (TG_OP = 'INSERT' OR OLD.cancelled_by_person_id IS NULL)
     AND EXISTS (SELECT 1 FROM person WHERE id = NEW.cancelled_by_person_id AND NOT is_owner)
     AND (NEW.cancelled_by_person_id <> NEW.person_id OR today >= NEW.leave_date) THEN
    RAISE EXCEPTION 'leave_notice: chỉ chủ quán hoặc chính người nghỉ trước ngày nghỉ được huỷ'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'leave_notice_cancel_allowed_check';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER leave_notice_guard_trg BEFORE INSERT OR UPDATE ON leave_notice
  FOR EACH ROW EXECUTE FUNCTION leave_notice_guard();

CREATE FUNCTION attendance_day_on_leave_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path = shop, pg_temp AS $$
BEGIN
  IF NEW.cancelled_at IS NULL THEN
    PERFORM pg_advisory_xact_lock(leave_notice_day_lock_key(NEW.worker_person_id, NEW.work_date));
    IF EXISTS (SELECT 1 FROM leave_notice
               WHERE person_id = NEW.worker_person_id AND leave_date = NEW.work_date AND cancelled_at IS NULL) THEN
      RAISE EXCEPTION 'attendance_day: ngày ấy đã có báo nghỉ còn hiệu lực'
        USING ERRCODE = 'check_violation', CONSTRAINT = 'attendance_day_on_leave_check';
    END IF;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER attendance_day_on_leave_trg BEFORE INSERT OR UPDATE ON attendance_day
  FOR EACH ROW EXECUTE FUNCTION attendance_day_on_leave_guard();

CREATE TRIGGER leave_notice_record_revision_trg AFTER UPDATE ON leave_notice
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
-- QC-03 cấp SELECT, INSERT và sequence; chỉ giữ quyền sửa bốn cột dấu.
REVOKE UPDATE, DELETE ON leave_notice FROM shop_app;
GRANT UPDATE (acknowledged_at, acknowledged_by_person_id, cancelled_at, cancelled_by_person_id)
  ON leave_notice TO shop_app;
