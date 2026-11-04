-- kêu: I-039/4
ALTER TABLE leave_notice DISABLE TRIGGER leave_notice_guard_trg;
WITH worker AS (
  INSERT INTO person (display_name) VALUES ('proof-i039 người không phải chủ') RETURNING id
)
INSERT INTO leave_notice (person_id, leave_date, submission_code, acknowledged_at, acknowledged_by_person_id)
SELECT id, (now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date + 100, 'proof-i039-4', now(), id FROM worker;
