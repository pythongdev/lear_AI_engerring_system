-- name: Them :one
INSERT INTO menu_category (name) VALUES ($1) RETURNING id;
