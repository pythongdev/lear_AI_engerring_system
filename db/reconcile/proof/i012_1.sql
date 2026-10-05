-- kêu: I-012/1
-- "Ai bấm" bị gỡ khỏi tiền đầu két; con số tiền đầu két của ngày mất tên người khai.
-- T-134: lỗi cài cố ý vượt khoá ngày đã ký để dựng dữ liệu hỏng cho phép đối chiếu.
ALTER TABLE opening_float DISABLE TRIGGER opening_float_reconciled_guard_trg;
ALTER TABLE opening_float ALTER COLUMN person_id DROP NOT NULL;
UPDATE opening_float SET person_id = NULL WHERE sale_date = pg_temp.bc_ngay();
ALTER TABLE opening_float ENABLE TRIGGER opening_float_reconciled_guard_trg;
