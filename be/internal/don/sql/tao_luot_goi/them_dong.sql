-- Chỉ chép kết quả gia.Tinh; mốc khoá và thành tiền do database đặt (I-009 · I-013).
INSERT INTO order_line (sales_order_id, quantity, menu_item_id, item_name, unit_price_vnd, component_count)
VALUES ($1, $2, $3, $4, $5, $6)
RETURNING id
