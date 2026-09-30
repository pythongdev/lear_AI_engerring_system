-- kêu: QD-30
-- Một cột mốc không mang múi giờ.
ALTER TABLE station_job_transfer ADD COLUMN confirmed_at timestamp;
