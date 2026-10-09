SELECT coalesce(sum(line_total_vnd),0)::bigint FROM order_line WHERE sales_order_id = $1
