-- I-030 — các tập phải rỗng của 03-bao-ve-invariant.md §5; ADR-105.

-- @@ I-030/1 — việc thiếu nội dung, người nhận, người tạo hoặc lúc tạo
SELECT t.id AS viec
FROM assigned_task t
LEFT JOIN person a ON a.id = t.assignee_person_id
LEFT JOIN person p ON p.id = t.person_id
WHERE btrim(coalesce(t.content, '')) = '' OR a.id IS NULL OR p.id IS NULL OR t.created_at IS NULL

-- @@ I-030/2 — người tạo, sửa, ẩn hoặc đánh dấu không là chủ quán và không đứng quầy lúc ấy
WITH thao_tac AS (
  SELECT 'tao' AS loai, id AS dong, person_id, created_at AS luc FROM assigned_task
  UNION ALL
  SELECT 'an', id, hidden_by_person_id, hidden_at FROM assigned_task WHERE hidden_at IS NOT NULL
  UNION ALL
  SELECT 'danh_dau', id, person_id, created_at FROM assigned_task_mark
  UNION ALL
  SELECT 'sua', id, person_id, revised_at FROM record_revision
  WHERE target_table_code IN ('assigned_task', 'assigned_task_mark')
)
SELECT x.loai, x.dong, x.person_id, x.luc
FROM thao_tac x JOIN person p ON p.id = x.person_id
WHERE NOT p.is_owner
  -- Thao tác thiếu lúc là tập I-030/3 (sự kiện) hay I-030/1 (việc); câu này chỉ xét thao tác có lúc.
  AND x.luc IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM counter_duty d WHERE d.person_id = x.person_id
                  AND d.started_at <= x.luc AND (d.ended_at IS NULL OR x.luc < d.ended_at))

-- @@ I-030/3 — sự kiện thiếu người bấm hoặc lúc bấm
SELECT m.id AS su_kien
FROM assigned_task_mark m LEFT JOIN person p ON p.id = m.person_id
WHERE p.id IS NULL OR m.created_at IS NULL

-- @@ I-030/4 — việc ẩn thiếu người ẩn hoặc lúc ẩn
SELECT t.id AS viec
FROM assigned_task t LEFT JOIN person p ON p.id = t.hidden_by_person_id
WHERE (t.hidden_at IS NOT NULL AND p.id IS NULL)
   OR (t.hidden_at IS NULL AND t.hidden_by_person_id IS NOT NULL)
