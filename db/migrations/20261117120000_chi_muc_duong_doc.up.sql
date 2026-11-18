-- T-340 — chỉ mục cho đường đọc, theo phiếu giao việc của Claude ngày 2026-11-17.
-- Ý định và lý do ở ngay từng chỉ mục dưới đây; file này thắng về tên và định nghĩa.
-- Claude đã đo EXPLAIN ngày 2026-11-18: cả bảy chỉ mục đều vào kế hoạch của ít nhất
-- một câu đọc; số đo nằm ở work/backlog.md mục T-340.
-- Dùng CREATE INDEX thường, không CONCURRENTLY: mỗi file là một giao dịch (QC-05).
-- Lệnh khoá ghi bảng trong lúc dựng chỉ mục; chạy ngoài giờ bán.

-- be/internal/gia/sql/doc_mon.sql và be/internal/gia/sql/doc_combo.sql đọc vết sau mốc giá;
-- be/internal/tongket/sql/doc.sql đếm vết huỷ đơn theo bảng đích và ngày sửa.
CREATE INDEX record_revision_table_revised_at_idx ON record_revision (target_table_code, revised_at);

-- be/internal/tongquan/sql/bang_van_hanh.sql đọc lịch sử đem ra theo bảng đích và ngày tạo vết.
CREATE INDEX record_revision_table_created_at_idx ON record_revision (target_table_code, created_at);

-- be/internal/phien/sql/tong_tien.sql và be/internal/tongquan/sql/bang_van_hanh.sql tìm đơn của phiên bàn.
CREATE INDEX sales_order_of_table_session_idx ON sales_order (table_session_id);

-- be/internal/phien/sql/tong_tien.sql và be/internal/tongket/sql/doc.sql đọc dòng đơn theo đơn nguồn.
CREATE INDEX order_line_of_sales_order_idx ON order_line (sales_order_id);

-- be/internal/phien/sql/tong_tien.sql nối dòng con qua vế OR l.parent_order_line_id = g.id;
-- chỉ mục giúp gộp hai vế bằng BitmapOr, tránh quét cả order_line mỗi vòng.
CREATE INDEX order_line_of_parent_line_idx ON order_line (parent_order_line_id);

-- be/internal/sanxuat/sql/ra_ban/doc.sql kiểm các việc trạm của đơn đã ra hết chưa.
CREATE INDEX station_job_of_sales_order_idx ON station_job (sales_order_id);

-- be/internal/tongket/sql/doc.sql và be/internal/ket/sql/ket_ngay.sql đọc hoá đơn theo ngày bán.
CREATE INDEX bill_sale_date_idx ON bill (sale_date);
