-- T-186 / P3A-08, I-025: tỉ lệ nhắc kiểm tra theo từng nguyên liệu, mặc định 20%.
-- Miền kỹ thuật: tỉ phần hữu hạn từ 0 đến 1, gồm hai đầu; không làm tròn số người nhập.
-- ADD COLUMN DEFAULT cấp 20% cho cả dòng cũ, không sửa con số ngày hay tạo vết người giả.
ALTER TABLE supply_item
  ADD COLUMN reminder_ratio numeric NOT NULL DEFAULT 0.2,
  ADD CONSTRAINT supply_item_reminder_ratio_range_check
    CHECK (reminder_ratio >= 0 AND reminder_ratio <= 1);
