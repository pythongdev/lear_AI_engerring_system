-- ADR-121 điểm 4: lần khai mới nhất của đúng ngày bán; không lấy ngày trước.
-- name: NguoiMoiNhat :many
SELECT d.id, d.sale_date::text AS sale_date, d.worker_count, d.person_id, p.display_name AS person_name, d.created_at AS declared_at
FROM workers_present_declaration d JOIN person p ON p.id = d.person_id
WHERE d.sale_date = $1::text::date
ORDER BY d.created_at DESC, d.id DESC
LIMIT 1;
