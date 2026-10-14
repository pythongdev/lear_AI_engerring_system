-- name: DoiTrangThai :exec
UPDATE account SET status=$2, person_id=$3, role_code=$4, decided_at=now(), decided_by_person_id=$5 WHERE id=$1;
