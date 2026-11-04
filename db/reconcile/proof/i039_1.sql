-- kêu: I-039/1
ALTER TABLE leave_notice DISABLE TRIGGER leave_notice_guard_trg;
INSERT INTO attendance_day (worker_person_id, work_date, person_id)
VALUES (pg_temp.bc_nguoi('Chủ quán'), (now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date + 100, pg_temp.bc_nguoi('Chủ quán'));
INSERT INTO leave_notice (person_id, leave_date, submission_code)
VALUES (pg_temp.bc_nguoi('Chủ quán'), (now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date + 100, 'proof-i039-1');
