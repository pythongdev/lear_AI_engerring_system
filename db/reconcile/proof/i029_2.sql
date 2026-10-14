-- kêu: I-029/2
-- Loại tiền riêng mất nguồn; vẫn không có khoản nào vào két.
ALTER TABLE expense_category ALTER COLUMN paid_from_till DROP NOT NULL;
UPDATE expense_category SET paid_from_till = NULL WHERE name = 'Marketing';
