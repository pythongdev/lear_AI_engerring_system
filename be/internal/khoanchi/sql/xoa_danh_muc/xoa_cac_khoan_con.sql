-- name: XoaCacKhoanCon :exec
UPDATE expense_item SET deleted_at = now(), deleted_by_person_id = actor_person_id() WHERE expense_category_id = $1 AND deleted_at IS NULL;
