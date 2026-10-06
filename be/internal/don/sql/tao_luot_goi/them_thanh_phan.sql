-- Ảnh chụp thành phần, vị trí liền nhau 1…n; n bằng khai báo của dòng (I-009).
INSERT INTO order_line_component (order_line_id, position, line_component_count,
                                 menu_component_id, component_name, quantity, takes_filling, base_price_vnd)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
