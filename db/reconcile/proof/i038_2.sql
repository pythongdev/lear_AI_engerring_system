-- kêu: I-038/2
ALTER TABLE station_message DROP CONSTRAINT station_message_different_people_check;
INSERT INTO station_message (sender_person_id, recipient_person_id, work_code, body, submission_code)
VALUES (pg_temp.bc_nguoi('Chủ quán'), pg_temp.bc_nguoi('Chủ quán'), 'khac', 'Lỗi cài gửi cho mình', 'proof-i038-2');
