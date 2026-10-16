-- name: DatTiLe :exec
UPDATE supply_item SET reminder_ratio = $2::text::numeric WHERE id = $1;
