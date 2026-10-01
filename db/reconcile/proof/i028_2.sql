-- kêu: I-028/2
-- Gỡ NOT NULL người duyệt; khoản không có người duyệt, không phải một người khác duyệt.
ALTER TABLE staff_advance ALTER COLUMN approver_person_id DROP NOT NULL;
UPDATE staff_advance SET approver_person_id = NULL;
