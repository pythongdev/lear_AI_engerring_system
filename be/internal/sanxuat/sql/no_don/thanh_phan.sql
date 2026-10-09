INSERT INTO station_job (sales_order_id, order_line_id, order_line_component_id, station_code,
 line_quantity, component_quantity, position)
SELECT $1, l.id, c.id, s.station_code, l.quantity, c.quantity, g.p
FROM order_line l JOIN order_line_component c ON c.order_line_id = l.id
JOIN menu_component_station s ON s.menu_component_id = c.menu_component_id
CROSS JOIN LATERAL generate_series(1, l.quantity * c.quantity) AS g(p)
WHERE l.sales_order_id = $1;
