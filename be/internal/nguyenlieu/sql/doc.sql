-- name: Doc :many
SELECT i.id, i.name, i.purchase_unit,
       trim_scale(t.purchased)::text AS purchased_total,
       trim_scale(t.used)::text AS used_total,
       trim_scale(t.purchased - t.used)::text AS balance
FROM supply_item i
CROSS JOIN LATERAL (
  SELECT COALESCE(sum(e.entered_measure) FILTER (WHERE e.kind_code = 'purchased'), 0)::numeric AS purchased,
         COALESCE(sum(e.entered_measure) FILTER (WHERE e.kind_code = 'used'), 0)::numeric AS used
  FROM supply_day_entry e WHERE e.supply_item_id = i.id
) t
WHERE ($1::bigint = 0 OR i.id = $1)
ORDER BY i.name;
