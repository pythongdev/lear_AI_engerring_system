-- name: DocDauNgay :many
SELECT r.id, r.previous_reconciled_day_id, r.person_id, r.created_at, r.gap_vnd, r.gap_explanation,
       o.reason, o.person_id AS reopening_person_id, o.created_at AS reopened_at
FROM reconciled_day r
LEFT JOIN reconciled_day_reopening o ON o.reconciled_day_id = r.id
WHERE r.sale_date = $1::text::date
ORDER BY r.id;
