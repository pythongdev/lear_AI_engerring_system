-- name: DocDong :many
SELECT l.id, l.favourite_set_id, l.parent_line_id, l.menu_item_id, l.menu_combo_id, l.quantity,
  ARRAY(SELECT o.menu_option_id FROM customer_favourite_line_option o
        WHERE o.favourite_line_id = l.id ORDER BY o.menu_option_id)::bigint[] AS option_ids
FROM customer_favourite_line l
WHERE l.customer_account_id = $1 AND l.removed_at IS NULL
  AND (l.favourite_set_id IS NULL OR EXISTS (
    SELECT 1 FROM customer_favourite_set s
    WHERE s.id = l.favourite_set_id AND s.customer_account_id = l.customer_account_id AND s.removed_at IS NULL))
ORDER BY l.id;
