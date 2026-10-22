-- Đọc ảnh chụp như DocDon, không tính lại giá theo menu hiện tại (I-009).
-- name: HangCho :one
WITH queue_orders AS (
 SELECT o.id, o.channel_code, o.status, o.table_session_id, o.dining_table_id,
 o.created_at, o.handover_code, o.customer_phone, o.delivery_address,
 o.customer_needed_at, o.customer_name, o.contact_note,
 (SELECT coalesce(sum(l.line_total_vnd),0)::bigint FROM order_line l WHERE l.sales_order_id = o.id) AS total_vnd,
 -- Bỏ khoá null như omitempty của gia.Dong: PriceLine không có trường nào được null (T-218).
 jsonb_strip_nulls((SELECT coalesce(jsonb_agg(jsonb_build_object(
  'menu_item_id',l.menu_item_id,'item_name',l.item_name,'quantity',l.quantity,
  'unit_price_vnd',l.unit_price_vnd,'line_total_vnd',l.line_total_vnd,
  'components',(SELECT coalesce(jsonb_agg(jsonb_build_object(
   'menu_component_id',c.menu_component_id,'component_name',c.component_name,'quantity',c.quantity,
   'takes_filling',c.takes_filling,'base_price_vnd',c.base_price_vnd) ORDER BY c.position),'[]'::jsonb)
   FROM order_line_component c WHERE c.order_line_id = l.id),
  'options',(SELECT coalesce(jsonb_agg(jsonb_build_object(
   'menu_option_id',p.menu_option_id,'option_group_name',p.option_group_name,
   'option_name',p.option_name,'surcharge_vnd',p.surcharge_vnd) ORDER BY p.menu_option_id),'[]'::jsonb)
   FROM order_line_option p WHERE p.order_line_id = l.id),
  -- Dòng combo (ADR-117): suất con lồng dưới nó theo thứ tự ghi; dòng món không có portions.
  'menu_combo_id',l.menu_combo_id,
  'portions',CASE WHEN l.menu_combo_id IS NOT NULL THEN (SELECT coalesce(jsonb_agg(jsonb_build_object(
  'menu_item_id',k.menu_item_id,'item_name',k.item_name,'quantity',k.quantity,
  'unit_price_vnd',k.unit_price_vnd,'line_total_vnd',k.line_total_vnd,
  'components',(SELECT coalesce(jsonb_agg(jsonb_build_object(
   'menu_component_id',c.menu_component_id,'component_name',c.component_name,'quantity',c.quantity,
   'takes_filling',c.takes_filling,'base_price_vnd',c.base_price_vnd) ORDER BY c.position),'[]'::jsonb)
   FROM order_line_component c WHERE c.order_line_id = k.id),
  'options',(SELECT coalesce(jsonb_agg(jsonb_build_object(
   'menu_option_id',p.menu_option_id,'option_group_name',p.option_group_name,
   'option_name',p.option_name,'surcharge_vnd',p.surcharge_vnd) ORDER BY p.menu_option_id),'[]'::jsonb)
   FROM order_line_option p WHERE p.order_line_id = k.id)
  ) ORDER BY k.id),'[]'::jsonb) FROM order_line k WHERE k.parent_order_line_id = l.id) END
 ) ORDER BY l.id),'[]'::jsonb) FROM order_line l WHERE l.sales_order_id = o.id AND l.parent_order_line_id IS NULL))::jsonb AS lines
 FROM sales_order o
 WHERE o.status = 'pending_confirmation'
    OR (o.table_session_id IS NULL AND o.status IN ('confirmed', 'in_progress', 'delivering'))
)
SELECT jsonb_build_object('read_at', now(), 'poll_interval_seconds', $1::integer,
 'paused_since', (SELECT started_at FROM order_intake_pause WHERE ended_at IS NULL),
 'blind_since', (SELECT started_at FROM shop_blind_spell WHERE ended_at IS NULL),
 'orders', coalesce((SELECT jsonb_agg(jsonb_build_object(
   'sales_order_id', id, 'channel_code', channel_code, 'dining_table_id', dining_table_id,
   'created_at', created_at, 'customer_phone', customer_phone, 'customer_needed_at', customer_needed_at,
   'total_vnd', total_vnd, 'lines', lines)
   ORDER BY created_at, id) FROM queue_orders WHERE status = 'pending_confirmation'), '[]'::jsonb),
 'active_orders', coalesce((SELECT jsonb_agg(jsonb_build_object(
   'sales_order_id', o.id, 'channel_code', o.channel_code, 'handover_code', o.handover_code,
   'status', o.status, 'created_at', o.created_at, 'customer_phone', o.customer_phone,
   'customer_name', o.customer_name, 'delivery_address', o.delivery_address,
   'customer_needed_at', o.customer_needed_at, 'contact_note', o.contact_note,
   'total_vnd', o.total_vnd, 'lines', o.lines,
   'unserved_jobs', (SELECT count(*) FROM station_job j WHERE j.sales_order_id = o.id AND j.status IN ('pending', 'made')))
   ORDER BY o.created_at, o.id) FROM queue_orders o
   WHERE o.table_session_id IS NULL AND o.status IN ('confirmed', 'in_progress', 'delivering')), '[]'::jsonb))::jsonb AS result;
