-- Câu đọc của cửa tạo lượt gọi, không phải cửa ghi riêng (QC-13).
-- name: TamDung :one
SELECT EXISTS (SELECT 1 FROM order_intake_pause
 WHERE tstzrange(started_at, ended_at, '[)') @> $1::timestamptz)::boolean;
