-- T-342, QD-31, ADR-146: buộc ngày bán khớp mốc tính tiền ngay lúc ghi.
-- Múi giờ quán lấy từ master_plan/shop-facts.md §1; đổi múi giờ cần migration mới.
SET search_path = shop, public;

ALTER TABLE bill ADD CONSTRAINT bill_sale_date_of_booked_at_check
  CHECK (sale_date = (booked_at AT TIME ZONE 'Asia/Ho_Chi_Minh')::date);
ALTER TABLE debt_collection ADD CONSTRAINT debt_collection_sale_date_of_booked_at_check
  CHECK (sale_date = (booked_at AT TIME ZONE 'Asia/Ho_Chi_Minh')::date);
ALTER TABLE prepayment ADD CONSTRAINT prepayment_sale_date_of_booked_at_check
  CHECK (sale_date = (booked_at AT TIME ZONE 'Asia/Ho_Chi_Minh')::date);
ALTER TABLE refund ADD CONSTRAINT refund_sale_date_of_booked_at_check
  CHECK (sale_date = (booked_at AT TIME ZONE 'Asia/Ho_Chi_Minh')::date);
