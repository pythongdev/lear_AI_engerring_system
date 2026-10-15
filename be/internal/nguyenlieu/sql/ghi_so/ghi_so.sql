-- name: GhiSo :one
INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
VALUES ($1, $2::text::date, $3, $4::text::numeric) RETURNING id;
