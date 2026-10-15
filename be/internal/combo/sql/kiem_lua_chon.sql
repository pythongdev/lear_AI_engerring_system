-- Lựa chọn có thật không, và có thuộc một nhóm mà món của dòng combo mang không (ADR-117 điểm 1).
-- name: KiemLuaChon :one
SELECT EXISTS (SELECT 1 FROM menu_option x WHERE x.id = $1::bigint)::boolean AS co,
       EXISTS (SELECT 1 FROM menu_combo_item ci
               JOIN menu_item_option_group g ON g.menu_item_id = ci.menu_item_id
               JOIN menu_option o ON o.option_group_id = g.option_group_id
               WHERE ci.id = $2::bigint AND o.id = $1::bigint)::boolean AS thuoc;
