-- T-340 — gỡ đúng bảy chỉ mục đường đọc, theo thứ tự ngược bước xuôi.
-- Không có khoá chặn "đường lùi từ chối": luật 2 của 07-thu-tu-migration.md
-- chỉ chặn khi đường lùi gỡ chỗ đang cất dữ liệu, mà bước này chỉ dựng chỉ mục,
-- không dựng bảng, cột hay dòng nào.
DROP INDEX bill_sale_date_idx;
DROP INDEX station_job_of_sales_order_idx;
DROP INDEX order_line_of_parent_line_idx;
DROP INDEX order_line_of_sales_order_idx;
DROP INDEX sales_order_of_table_session_idx;
DROP INDEX record_revision_table_created_at_idx;
DROP INDEX record_revision_table_revised_at_idx;
