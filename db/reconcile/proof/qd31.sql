-- kêu: QD-31
-- Một bảng có mốc tính tiền mà không có ngày bán.
ALTER TABLE station_job_transfer ADD COLUMN booked_at timestamptz;
