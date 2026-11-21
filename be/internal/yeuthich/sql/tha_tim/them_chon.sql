-- name: ThemChon :exec
INSERT INTO customer_favourite_line_option (favourite_line_id, menu_option_id)
SELECT $1, unnest($2::bigint[]);
