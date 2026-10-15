-- name: DatDonVi :exec
UPDATE supply_item SET purchase_unit = $2::text WHERE id = $1;
