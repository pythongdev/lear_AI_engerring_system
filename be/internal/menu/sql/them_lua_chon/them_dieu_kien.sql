-- Lựa chọn mới mở nhóm khác (ví dụ Lượng nhân) — chủ quán tích lúc thêm (§8.9, luật 3 §4.6).
-- name: ThemDieuKien :exec
INSERT INTO option_group_prerequisite (option_group_id, menu_option_id) VALUES ($1, $2);
