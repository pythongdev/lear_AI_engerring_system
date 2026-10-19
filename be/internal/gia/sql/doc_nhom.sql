-- name: DocNhom :one
SELECT COALESCE(jsonb_agg(jsonb_build_object(
 'option_group_id', g.id, 'option_group_name', g.name,
 'prerequisite_option_ids', (SELECT COALESCE(jsonb_agg(p.menu_option_id ORDER BY p.menu_option_id), '[]'::jsonb)
   FROM option_group_prerequisite p WHERE p.option_group_id = g.id),
 'options', (SELECT COALESCE(jsonb_agg(jsonb_build_object(
   'menu_option_id', o.id, 'option_name', o.name, 'is_default', o.is_default) ORDER BY o.id), '[]'::jsonb)
   FROM menu_option o WHERE o.option_group_id = g.id AND o.hidden_at IS NULL)) ORDER BY g.id), '[]'::jsonb)::jsonb AS nhom
 FROM menu_item_option_group ig JOIN option_group g ON g.id = ig.option_group_id
 WHERE ig.menu_item_id = $1;
