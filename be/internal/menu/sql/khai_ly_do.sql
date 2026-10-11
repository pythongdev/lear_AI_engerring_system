-- Khai lý do sửa cho vết của giao dịch này (I-018); trigger ghi vết đọc shop.revision_reason.
-- name: KhaiLyDo :exec
SELECT set_config('shop.revision_reason', $1, true);
