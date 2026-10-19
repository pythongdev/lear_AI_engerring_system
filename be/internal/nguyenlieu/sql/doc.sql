-- name: Doc :many
SELECT i.id, i.name, i.purchase_unit,
       trim_scale(t.purchased)::text AS purchased_total,
       trim_scale(t.used)::text AS used_total,
       trim_scale(t.purchased - t.used)::text AS balance,
       trim_scale(i.reminder_ratio)::text AS reminder_ratio,
       COALESCE(last_purchase.entry_date::text, '')::text AS latest_purchase_date,
       COALESCE(trim_scale(last_purchase.entered_measure)::text, '')::text AS latest_purchase_measure,
       (CASE WHEN last_purchase.id IS NULL THEN 'no_purchase'
             WHEN last_purchase.entered_measure = 0 THEN 'latest_purchase_zero'
             WHEN t.first_used < t.first_purchase THEN 'usage_before_first_purchase'
             ELSE 'ready' END)::text AS reminder_status,
       -- U-102 (chủ repo 2026-10-19, T-204): chưa có mốc nhập thì luôn nhắc; dùng trước lần nhập đầu thì so tỉ lệ như thường.
       (CASE WHEN last_purchase.id IS NULL OR last_purchase.entered_measure = 0 THEN true
             ELSE t.purchased - t.used < i.reminder_ratio * last_purchase.entered_measure
        END)::boolean AS check_reminder
FROM supply_item i
CROSS JOIN LATERAL (
  SELECT COALESCE(sum(e.entered_measure) FILTER (WHERE e.kind_code = 'purchased'), 0)::numeric AS purchased,
         COALESCE(sum(e.entered_measure) FILTER (WHERE e.kind_code = 'used'), 0)::numeric AS used,
         min(e.entry_date) FILTER (WHERE e.kind_code = 'purchased') AS first_purchase,
         min(e.entry_date) FILTER (WHERE e.kind_code = 'used') AS first_used
  FROM supply_day_entry e WHERE e.supply_item_id = i.id
) t
LEFT JOIN LATERAL (
  SELECT e.id, e.entry_date, e.entered_measure FROM supply_day_entry e
  WHERE e.supply_item_id = i.id AND e.kind_code = 'purchased'
  ORDER BY e.entry_date DESC LIMIT 1
) last_purchase ON true
WHERE ($1::bigint = 0 OR i.id = $1)
ORDER BY i.name;
