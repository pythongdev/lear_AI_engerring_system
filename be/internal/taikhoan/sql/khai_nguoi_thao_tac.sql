-- name: KhaiNguoiThaoTac :exec
SELECT set_config('shop.actor_person_id', $1::text, true);
