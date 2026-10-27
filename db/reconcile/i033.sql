-- I-033 — các tập phải rỗng của 03-bao-ve-invariant.md §5; ADR-109.

-- @@ I-033/1 — tài khoản sai hình theo trạng thái, vai hoặc người quyết
SELECT a.id FROM account a
LEFT JOIN person p ON p.id = a.person_id
LEFT JOIN person d ON d.id = a.decided_by_person_id
WHERE NOT (
 (a.status = 'cho_duyet' AND a.person_id IS NULL AND a.role_code IS NULL AND a.decided_at IS NULL AND a.decided_by_person_id IS NULL)
 OR (a.status = 'tu_choi' AND a.person_id IS NULL AND a.role_code IS NULL AND a.decided_at IS NOT NULL AND d.id IS NOT NULL)
 OR (a.status IN ('hoat_dong', 'khoa') AND p.id IS NOT NULL AND a.role_code IS NOT NULL AND a.decided_at IS NOT NULL AND d.id IS NOT NULL))
 OR a.status IS NULL OR (a.role_code IS NOT NULL AND a.role_code NOT IN ('quay', 'trang_banh', 'gap_banh', 'canh_don_ban', 'owner'))
 OR btrim(coalesce(a.requested_display_name, '')) = '' OR a.created_at IS NULL
 OR (a.person_id IS NOT NULL AND EXISTS (SELECT 1 FROM account b WHERE b.id <> a.id AND b.person_id = a.person_id))

-- @@ I-033/2 — phiên còn hiệu lực của tài khoản không hoạt động
SELECT s.id FROM login_session s LEFT JOIN account a ON a.id = s.account_id
WHERE s.ended_at IS NULL AND s.expires_at > now() AND a.status IS DISTINCT FROM 'hoat_dong'

-- @@ I-033/3 — phiên gắn trực quầy của người khác hoặc không có thật
SELECT s.id FROM login_session s JOIN account a ON a.id = s.account_id
LEFT JOIN counter_duty d ON d.id = s.counter_duty_id
WHERE s.counter_duty_id IS NOT NULL AND (d.id IS NULL OR d.person_id IS DISTINCT FROM a.person_id
 OR EXISTS (SELECT 1 FROM login_session t WHERE t.id <> s.id AND t.counter_duty_id = s.counter_duty_id))

-- @@ I-033/4 — mật khẩu hiện hành không mang tiền tố argon2id
SELECT a.id FROM account a
JOIN LATERAL (SELECT password_hash FROM account_password WHERE account_id = a.id ORDER BY created_at DESC, id DESC LIMIT 1) p ON true
WHERE p.password_hash IS NULL OR p.password_hash NOT LIKE '$argon2id$%'

-- @@ I-033/5 — tài khoản vai owner nhưng người không có cờ chủ quán
SELECT a.id FROM account a JOIN person p ON p.id = a.person_id
WHERE a.role_code = 'owner' AND NOT p.is_owner

-- @@ I-033/6 — tài khoản hoạt động không có bản mật khẩu nào
SELECT a.id FROM account a WHERE a.status = 'hoat_dong'
AND NOT EXISTS (SELECT 1 FROM account_password p WHERE p.account_id = a.id)

-- @@ I-033/7 — định danh không chuẩn hoá hoặc không duy nhất
SELECT a.id FROM account a
WHERE a.username COLLATE "C" !~ '^[a-z0-9._-]{3,32}$'
 OR a.email <> lower(a.email) OR position('@' IN a.email) = 0
 OR EXISTS (SELECT 1 FROM account b WHERE b.id <> a.id AND (lower(b.username) = lower(a.username) OR lower(b.email) = lower(a.email)))

-- @@ I-033/8 — bản mật khẩu thiếu tài khoản, dấu tạo, người đặt hoặc cờ buộc đổi không khớp
SELECT p.id FROM account_password p LEFT JOIN account a ON a.id = p.account_id
LEFT JOIN person s ON s.id = p.set_by_person_id
WHERE a.id IS NULL OR p.created_at IS NULL OR p.must_change_password IS DISTINCT FROM (p.set_by_person_id IS NOT NULL)
 OR (p.set_by_person_id IS NOT NULL AND s.id IS NULL)

-- @@ I-033/9 — phiên sai hình băm, hạn, dấu kết thúc hoặc tài khoản
SELECT s.id FROM login_session s LEFT JOIN account a ON a.id = s.account_id
WHERE a.id IS NULL OR s.token_hash IS NULL OR octet_length(s.token_hash) <> 32
 OR s.created_at IS NULL OR s.expires_at IS NULL OR s.expires_at <= s.created_at OR s.expires_at > s.created_at + interval '7 days'
 OR (s.ended_at IS NULL) <> (s.end_reason IS NULL) OR s.ended_at < s.created_at
 OR s.end_reason NOT IN ('dang_xuat', 'doi_mat_khau', 'dat_lai_mat_khau', 'khoa_tai_khoan')
 OR EXISTS (SELECT 1 FROM login_session t WHERE t.id <> s.id AND t.token_hash = s.token_hash)

-- @@ I-033/10 — mã đặt lại sai hình băm, hạn hoặc lúc dùng
SELECT r.id FROM password_reset r LEFT JOIN account a ON a.id = r.account_id
WHERE a.id IS NULL OR r.token_hash IS NULL OR octet_length(r.token_hash) <> 32
 OR r.created_at IS NULL OR r.expires_at IS NULL OR r.expires_at <= r.created_at OR r.expires_at > r.created_at + interval '30 minutes'
 OR r.used_at < r.created_at OR r.used_at >= r.expires_at
 OR EXISTS (SELECT 1 FROM password_reset t WHERE t.id <> r.id AND t.token_hash = r.token_hash)

-- @@ I-033/11 — vết sửa phiên đã kết thúc
SELECT id FROM record_revision WHERE target_table_code = 'login_session'
AND before_image ->> 'ended_at' IS NOT NULL

-- @@ I-033/12 — vết sửa mã đặt lại đã dùng
SELECT id FROM record_revision WHERE target_table_code = 'password_reset'
AND before_image ->> 'used_at' IS NOT NULL

-- @@ I-033/13 — người duyệt, từ chối, khoá hoặc sửa một tài khoản không phải chủ quán
-- Tầng 3 (ADR-109 điểm 2; khuôn I-030/2 · I-032/8): đọc cờ chủ quán hiện hành. Thêm 2026-10-14, P2A-15, Claude Code.
WITH thao_tac AS (
  SELECT id AS dong, decided_by_person_id AS person_id FROM account WHERE decided_by_person_id IS NOT NULL
  UNION ALL SELECT target_row, person_id FROM record_revision WHERE target_table_code = 'account'
)
SELECT x.* FROM thao_tac x JOIN person p ON p.id = x.person_id WHERE NOT p.is_owner

-- @@ I-033/14 — phiên quầy lệch mốc khoảng trực nó mở, hoặc đăng xuất mà khoảng của nó chưa khép
-- Đăng nhập tại quầy mở khoảng và phiên trong cùng giao dịch; đăng xuất khép khoảng của chính phiên (ADR-109 điểm 7).
-- Khoảng đã bị lần đăng nhập quầy sau khép trước thì đăng xuất không đụng nó — khép sớm hơn không phải lệch.
SELECT s.id FROM login_session s JOIN counter_duty d ON d.id = s.counter_duty_id
WHERE d.started_at <> s.created_at
   OR (s.end_reason = 'dang_xuat' AND (d.ended_at IS NULL OR d.ended_at > s.ended_at))

-- @@ I-033/15 — mã đặt lại đã dùng mà thiếu bản mật khẩu mới, hoặc còn phiên mở từ trước lần dùng
-- Dùng mã, thêm bản mật khẩu và kết thúc mọi phiên là một giao dịch (ADR-109 điểm 8): cùng một mốc.
SELECT r.id FROM password_reset r
WHERE r.used_at IS NOT NULL
  AND (NOT EXISTS (SELECT 1 FROM account_password p WHERE p.account_id = r.account_id AND p.created_at = r.used_at)
       OR EXISTS (SELECT 1 FROM login_session s WHERE s.account_id = r.account_id AND s.created_at < r.used_at
                    AND (s.ended_at IS NULL OR s.ended_at > r.used_at)))
