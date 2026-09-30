-- kêu: I-004/2
-- Lần nổ đơn ghi một cái bánh của bàn 5 xuống nhầm trạm quầy thay vì trạm tráng.
UPDATE station_job SET station_code = 'quay'
WHERE id = (SELECT min(j.id) FROM station_job j JOIN order_line_component c ON c.id = j.order_line_component_id
            WHERE j.sales_order_id = (SELECT id FROM bc WHERE ten = 'don_5_qr')
              AND j.station_code = 'trang_banh' AND c.component_name = 'Bánh cuốn');
