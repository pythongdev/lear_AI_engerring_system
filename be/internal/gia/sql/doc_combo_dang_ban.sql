-- Combo đang bán cho GET /menu: chưa ẩn và mọi món còn bán; món theo thứ tự lập, mức theo lựa chọn (ADR-117 điểm 5).
-- name: DocComboDangBan :one
SELECT COALESCE(jsonb_agg(jsonb_build_object('menu_combo_id', c.id, 'name', c.name, 'price_vnd', c.price_vnd,
 'items', (SELECT jsonb_agg(jsonb_build_object('menu_item_id', m.id, 'item_name', m.name, 'quantity', x.quantity,
   'surcharges', COALESCE((SELECT jsonb_agg(jsonb_build_object('menu_option_id', s.menu_option_id,
     'surcharge_vnd', s.surcharge_vnd) ORDER BY s.menu_option_id)
     FROM menu_combo_item_option_surcharge s WHERE s.menu_combo_item_id = x.id), '[]'::jsonb)) ORDER BY x.id)
  FROM menu_combo_item x JOIN menu_item m ON m.id = x.menu_item_id WHERE x.menu_combo_id = c.id))
 ORDER BY c.name, c.id), '[]'::jsonb)::jsonb AS combos
FROM menu_combo c
WHERE c.hidden_at IS NULL
  AND NOT EXISTS (SELECT 1 FROM menu_combo_item x JOIN menu_item m ON m.id = x.menu_item_id
                  WHERE x.menu_combo_id = c.id AND m.discontinued_at IS NOT NULL AND m.discontinued_at <= now());
