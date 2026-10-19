-- Cửa menu/them_lua_chon (T-210, lớp chu_quan). Mặc định của nhóm không đổi: lựa chọn mới không là mặc định.
-- name: ThemLuaChon :one
INSERT INTO menu_option (option_group_id, name, surcharge_vnd) VALUES ($1, $2, $3)
RETURNING id, option_group_id, name, surcharge_vnd;
