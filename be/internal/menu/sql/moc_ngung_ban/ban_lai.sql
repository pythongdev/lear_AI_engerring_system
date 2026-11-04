-- Cửa menu/moc_ngung_ban (ADR-126); cửa gọi đã khoá, kiểm mốc và khai lý do.
-- name: BanLai :one
UPDATE menu_item SET discontinued_at = NULL WHERE id = $1 RETURNING id;
