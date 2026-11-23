-- name: TimMua :one
SELECT id, entered_measure = $3::text::numeric AS same_measure
FROM supply_day_entry WHERE supply_item_id = $1 AND entry_date = $2::text::date
  AND kind_code = 'purchased' FOR UPDATE;
