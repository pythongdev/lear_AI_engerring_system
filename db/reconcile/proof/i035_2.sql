-- kêu: I-035/2
ALTER TABLE customer_account DROP CONSTRAINT customer_account_phone_check;
INSERT INTO customer_account (display_name, phone) VALUES ('Lỗi cài số khách', '+84912345678');
