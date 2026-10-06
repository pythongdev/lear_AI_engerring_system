-- Ảnh chụp lựa chọn đã kiểm, không tra lại menu khi ghi (I-009 · I-010).
INSERT INTO order_line_option (order_line_id, menu_option_id, option_group_name, option_name, surcharge_vnd)
VALUES ($1, $2, $3, $4, $5)
