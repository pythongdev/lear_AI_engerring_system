-- kêu: I-023/6
-- "Ai đổi" bị gỡ khỏi mã QR; lần đổi mã bàn 2 của ngày mẫu mất tên người đổi.
ALTER TABLE qr_code ALTER COLUMN person_id DROP NOT NULL;
UPDATE qr_code SET person_id = NULL
WHERE dining_table_id = pg_temp.bc_ban('2') AND replaced_at IS NULL;
