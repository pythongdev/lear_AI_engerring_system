-- I-031 — các tập phải rỗng của 03-bao-ve-invariant.md §5; ADR-105 · ADR-107.
-- Vết sửa dùng câu chung I-018/1; chỗ trỏ tệp và phần đã mất không có tập.

-- @@ I-031/1 — hướng dẫn không gắn đúng một việc giao có thật
SELECT g.id AS huong_dan
FROM assigned_task_guide g LEFT JOIN assigned_task t ON t.id = g.assigned_task_id
WHERE t.id IS NULL

-- @@ I-031/2 — ghi nhận thiếu người được ghi nhận, người ghi hoặc lúc ghi
SELECT t.id AS ghi_nhan
FROM training_record t
LEFT JOIN person a ON a.id = t.trainee_person_id
LEFT JOIN person p ON p.id = t.person_id
WHERE a.id IS NULL OR p.id IS NULL OR t.created_at IS NULL

-- @@ I-031/3 — người ghi không là chủ quán và không đứng quầy lúc ấy
SELECT t.id AS ghi_nhan, t.person_id, t.created_at
FROM training_record t JOIN person p ON p.id = t.person_id
WHERE NOT p.is_owner
  -- Thiếu lúc thuộc I-031/2; chỉ xét dòng có lúc để không kêu oan cùng câu đủ dấu.
  AND t.created_at IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM counter_duty d WHERE d.person_id = t.person_id
                  AND d.started_at <= t.created_at AND (d.ended_at IS NULL OR t.created_at < d.ended_at))

-- @@ I-031/4 — ghi nhận rỗng cả nhận xét lẫn đánh giá
SELECT id AS ghi_nhan FROM training_record
WHERE btrim(coalesce(remark, '')) = '' AND rating_code IS NULL

-- @@ I-031/5 — đánh giá khác đạt và chưa
SELECT id AS ghi_nhan FROM training_record
WHERE rating_code IS NOT NULL AND rating_code NOT IN ('pass', 'not_yet')

-- @@ I-031/6 — hướng dẫn hoặc ghi nhận ẩn thiếu người ẩn hay lúc ẩn
WITH dau_an AS (
  SELECT 'assigned_task_guide' AS loai, id, hidden_at, hidden_by_person_id FROM assigned_task_guide
  UNION ALL
  SELECT 'training_record', id, hidden_at, hidden_by_person_id FROM training_record
)
SELECT x.loai, x.id FROM dau_an x LEFT JOIN person p ON p.id = x.hidden_by_person_id
WHERE (x.hidden_at IS NOT NULL AND p.id IS NULL)
   OR (x.hidden_at IS NULL AND x.hidden_by_person_id IS NOT NULL)
