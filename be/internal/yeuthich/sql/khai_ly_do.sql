-- name: KhaiLyDo :exec
SELECT set_config('shop.revision_reason', $1::text, true);
