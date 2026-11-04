-- name: TinTraLoi :one
SELECT EXISTS (SELECT 1 FROM station_message WHERE id = $1
AND ($2::boolean OR sender_person_id = $3 OR recipient_person_id = $3))::boolean;
