-- ADR-121 điểm 1: mỗi lần khai thêm một dòng; người khai từ actor_person_id().
-- name: KhaiNguoi :one
WITH d AS (
 INSERT INTO workers_present_declaration (sale_date, worker_count)
 VALUES ($1::text::date, $2)
 RETURNING id, sale_date, worker_count, person_id, created_at
)
SELECT d.id, d.sale_date::text AS sale_date, d.worker_count, d.person_id, p.display_name AS person_name, d.created_at AS declared_at
FROM d JOIN person p ON p.id = d.person_id;
