-- Cửa menu/doc_nhom (T-210, lớp chu_quan): mọi nhóm, mọi lựa chọn kể cả đã ẩn, và tập điều kiện của từng nhóm.
-- name: DocNhomLuaChon :one
SELECT COALESCE(jsonb_agg(jsonb_build_object(
 'option_group_id', g.id, 'name', g.name,
 'prerequisite_option_ids', (SELECT COALESCE(jsonb_agg(p.menu_option_id ORDER BY p.menu_option_id), '[]'::jsonb)
   FROM option_group_prerequisite p WHERE p.option_group_id = g.id),
 'options', (SELECT COALESCE(jsonb_agg(jsonb_build_object(
   'menu_option_id', o.id, 'name', o.name, 'surcharge_vnd', o.surcharge_vnd, 'is_default', o.is_default,
   'hidden_at', o.hidden_at) ORDER BY o.id), '[]'::jsonb)
   FROM menu_option o WHERE o.option_group_id = g.id)) ORDER BY g.id), '[]'::jsonb)::jsonb AS nhom
FROM option_group g;
