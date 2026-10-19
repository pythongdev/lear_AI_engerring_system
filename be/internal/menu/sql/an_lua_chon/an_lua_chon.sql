-- Cửa menu/an_lua_chon (T-210, lớp chu_quan): ẩn ($2 = true) hoặc bật lại ($2 = false) — một cửa cho hai cột ẩn
-- (Gate 1f: một ô một cửa). Người và lý do đã khai trong giao dịch.
-- name: DatAnLuaChon :one
UPDATE menu_option SET hidden_at = CASE WHEN $2::boolean THEN now() END,
                       hidden_by_person_id = CASE WHEN $2::boolean THEN actor_person_id() END
 WHERE id = $1
RETURNING id;
