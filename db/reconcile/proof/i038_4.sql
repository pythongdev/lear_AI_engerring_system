-- kêu: I-038/4
ALTER TABLE station_message DROP CONSTRAINT station_message_body_check;
INSERT INTO station_message (sender_person_id, work_code, body, submission_code)
VALUES (pg_temp.bc_nguoi('Chủ quán'), 'khac', '   ', 'proof-i038-4');
