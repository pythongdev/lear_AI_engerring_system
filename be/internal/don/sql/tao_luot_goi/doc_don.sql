-- Dấu là toàn cục: đơn ngoài bàn có hai cột NULL vẫn phải đọc được để từ chối khác nội dung.
SELECT o.id, coalesce(o.table_session_id, 0), coalesce(o.dining_table_id, 0), o.channel_code, o.status,
 coalesce(q.code,''),
 (SELECT coalesce(sum(l.line_total_vnd),0)::bigint FROM order_line l WHERE l.sales_order_id = o.id),
 (SELECT coalesce(jsonb_agg(jsonb_build_object(
  'menu_item_id',l.menu_item_id,'item_name',l.item_name,'quantity',l.quantity,
  'unit_price_vnd',l.unit_price_vnd,'line_total_vnd',l.line_total_vnd,
  'components',(SELECT coalesce(jsonb_agg(jsonb_build_object(
   'menu_component_id',c.menu_component_id,'component_name',c.component_name,'quantity',c.quantity,
   'takes_filling',c.takes_filling,'base_price_vnd',c.base_price_vnd) ORDER BY c.position),'[]'::jsonb)
   FROM order_line_component c WHERE c.order_line_id = l.id),
  'options',(SELECT coalesce(jsonb_agg(jsonb_build_object(
   'menu_option_id',p.menu_option_id,'option_group_name',p.option_group_name,
   'option_name',p.option_name,'surcharge_vnd',p.surcharge_vnd) ORDER BY p.menu_option_id),'[]'::jsonb)
   FROM order_line_option p WHERE p.order_line_id = l.id)
 ) ORDER BY l.id),'[]'::jsonb) FROM order_line l WHERE l.sales_order_id = o.id),
 (SELECT coalesce(jsonb_agg(l.is_takeaway ORDER BY l.id),'[]'::jsonb) FROM order_line l WHERE l.sales_order_id = o.id),
 coalesce(o.handover_code,''), coalesce(o.customer_phone,''), o.delivery_address, coalesce(to_jsonb(o.customer_needed_at), 'null'::jsonb), o.customer_name, o.contact_note
FROM sales_order o LEFT JOIN qr_code q ON q.id = o.qr_code_id
WHERE o.submission_code = $1
