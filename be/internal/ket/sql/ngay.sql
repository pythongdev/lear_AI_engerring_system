-- name: NgaySoGiayTuongLai :one
SELECT $1::text::date > $2::timestamptz::date;
