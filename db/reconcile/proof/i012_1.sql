-- kêu: I-012/1
-- "Ai bấm" bị gỡ khỏi tiền đầu két; con số tiền đầu két của ngày mất tên người khai.
ALTER TABLE opening_float ALTER COLUMN person_id DROP NOT NULL;
UPDATE opening_float SET person_id = NULL WHERE sale_date = pg_temp.bc_ngay();
