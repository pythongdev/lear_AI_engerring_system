-- name: SuaSo :exec
UPDATE supply_day_entry SET entered_measure = $2::text::numeric WHERE id = $1;
