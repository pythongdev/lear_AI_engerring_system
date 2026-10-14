-- kêu: I-029/1
-- Khoản tiền riêng thiếu ngày: không làm đổi két; cập nhật vẫn có vết.
ALTER TABLE expense ALTER COLUMN paid_date DROP NOT NULL;
UPDATE expense SET paid_date = NULL
WHERE expense_category_id = (SELECT id FROM expense_category WHERE name = 'Marketing');
