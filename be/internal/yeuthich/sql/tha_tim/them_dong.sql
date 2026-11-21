-- name: ThemDong :one
INSERT INTO customer_favourite_line
  (customer_account_id, favourite_set_id, parent_line_id, menu_item_id, menu_combo_id, quantity)
VALUES ($1, $2, $3, $4, $5, $6) RETURNING id;
