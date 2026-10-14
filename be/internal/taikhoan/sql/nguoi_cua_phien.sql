-- name: NguoiCuaPhien :one
SELECT a.person_id FROM login_session s JOIN account a ON a.id = s.account_id
WHERE s.token_hash = $1 AND s.ended_at IS NULL AND s.expires_at > now() AND a.status = 'hoat_dong' AND a.person_id IS NOT NULL;
