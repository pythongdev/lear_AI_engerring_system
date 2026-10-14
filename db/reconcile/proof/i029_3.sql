-- kêu: I-029/3
-- Tắt vết rồi sửa khoản tiền riêng đã có vết; không làm đổi két.
DO $$ BEGIN PERFORM pg_temp.bc_vet('expense', false); END $$;
UPDATE expense SET amount_vnd = amount_vnd + 1
WHERE expense_category_id = (SELECT id FROM expense_category WHERE name = 'Marketing');
DO $$ BEGIN PERFORM pg_temp.bc_vet('expense', true); END $$;
