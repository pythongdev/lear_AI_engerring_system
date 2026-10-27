-- kêu: I-035/1
ALTER TABLE customer_account DROP CONSTRAINT customer_account_contact_check;
INSERT INTO customer_account (display_name) VALUES ('Lỗi cài khách thiếu liên hệ');
