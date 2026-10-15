-- name: ThemThu :one
INSERT INTO supply_item (name, purchase_unit) VALUES ($1, NULLIF($2::text, '')) RETURNING id;
