-- ADR-148: mốc trong phiên; lượt trước là đơn khác phiên, mọi kênh, trong ngày bán.
-- name: LuotTruoc :one
WITH moc AS (
 SELECT min(o.created_at) AS at
 FROM sales_order o
 WHERE o.table_session_id = $1::bigint
   AND o.id_if_approved IS NOT NULL AND o.status <> 'cancelled'
   AND EXISTS (SELECT 1 FROM station_job j WHERE j.sales_order_id = o.id AND j.status IN ('pending', 'made'))
)
SELECT (moc.at IS NOT NULL)::boolean AS has_anchor, (
 SELECT count(*) FROM sales_order o
 WHERE o.table_session_id IS DISTINCT FROM $1::bigint
   AND o.id_if_approved IS NOT NULL AND o.status NOT IN ('cancelled', 'delivering', 'completed')
   AND o.created_at < moc.at
   AND o.created_at >= $2::text::date
   AND o.created_at < $2::text::date + 1
   AND EXISTS (SELECT 1 FROM station_job j WHERE j.sales_order_id = o.id AND j.status IN ('pending', 'made'))
)::bigint AS orders_ahead FROM moc;
