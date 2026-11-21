-- T-342, QD-31, ADR-146: gỡ bốn ràng buộc theo thứ tự ngược.
-- Không có khoá chặn "đường lùi từ chối": luật 2 của 07-thu-tu-migration.md
-- chỉ chặn khi đường lùi gỡ chỗ đang cất dữ liệu, mà bước này chỉ thêm bốn ràng buộc kiểm,
-- không dựng bảng, cột hay dòng nào.
SET search_path = shop, public;

ALTER TABLE refund DROP CONSTRAINT refund_sale_date_of_booked_at_check;
ALTER TABLE prepayment DROP CONSTRAINT prepayment_sale_date_of_booked_at_check;
ALTER TABLE debt_collection DROP CONSTRAINT debt_collection_sale_date_of_booked_at_check;
ALTER TABLE bill DROP CONSTRAINT bill_sale_date_of_booked_at_check;
