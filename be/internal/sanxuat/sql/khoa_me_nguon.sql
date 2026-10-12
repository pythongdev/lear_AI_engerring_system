-- Mẻ được khoá trước phiên/đơn/việc ở cả lùi và chuyển.
-- name: KhoaMeNguon :many
SELECT b.id FROM production_batch b WHERE b.id IN (
 SELECT i.production_batch_id FROM production_batch_item i
 WHERE i.live_station_job_id = ANY($1::bigint[])) ORDER BY b.id FOR UPDATE;
