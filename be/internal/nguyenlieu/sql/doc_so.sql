-- name: DocSo :many
SELECT e.id, e.supply_item_id, e.entry_date::text, e.kind_code,
       trim_scale(e.entered_measure)::text AS measure,
       e.person_id, p.display_name AS person_name, e.created_at
FROM supply_day_entry e JOIN person p ON p.id = e.person_id
WHERE ($1::bigint = 0 OR e.supply_item_id = $1) AND ($2::bigint = 0 OR e.id = $2)
ORDER BY e.entry_date DESC, e.kind_code;
