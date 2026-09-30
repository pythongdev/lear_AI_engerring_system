-- kêu: QD-20
-- Một cột tiền mang phần lẻ.
ALTER TABLE bill ADD COLUMN tip_vnd numeric(12, 2) CONSTRAINT bill_tip_non_negative_check CHECK (tip_vnd >= 0);
