-- I-027 — docs/product/1-system-design/03-bao-ve-invariant.md §5, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.

-- @@ I-027/1 — ô thiếu hay lạ người được chấm, thiếu ngày, thiếu hay lạ người tick, thiếu lúc tick
SELECT a.id AS o
FROM attendance_day a
LEFT JOIN person w ON w.id = a.worker_person_id
LEFT JOIN person p ON p.id = a.person_id
WHERE w.id IS NULL OR a.work_date IS NULL OR p.id IS NULL OR a.created_at IS NULL

-- @@ I-027/2 — người, ngày có hơn một ô còn hiệu lực
SELECT worker_person_id AS nguoi, work_date AS ngay, count(*) AS so_o
FROM attendance_day
WHERE cancelled_at IS NULL
GROUP BY worker_person_id, work_date
HAVING count(*) > 1

-- @@ I-027/3 — ô huỷ thiếu hay lạ người huỷ, thiếu lúc huỷ, hoặc có ghi chú khi chưa huỷ
SELECT a.id AS o
FROM attendance_day a LEFT JOIN person p ON p.id = a.cancelled_by_person_id
WHERE (a.cancelled_at IS NOT NULL AND p.id IS NULL)
   OR (a.cancelled_at IS NULL AND (a.cancelled_by_person_id IS NOT NULL OR a.cancel_note IS NOT NULL))

-- @@ I-027/4 — người tick không phải chủ quán
SELECT a.id AS o, a.person_id AS nguoi_tick
FROM attendance_day a JOIN person p ON p.id = a.person_id
WHERE NOT p.is_owner
