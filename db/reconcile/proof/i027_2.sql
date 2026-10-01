-- kêu: I-027/2
-- Gỡ chỉ mục duy nhất của ô còn hiệu lực rồi tick trùng người, ngày.
DROP INDEX attendance_day_one_live_per_worker_day_key;
INSERT INTO attendance_day (worker_person_id, work_date, person_id)
SELECT worker_person_id, work_date, person_id FROM attendance_day
WHERE cancelled_at IS NULL ORDER BY id LIMIT 1;
