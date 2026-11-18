-- kêu: I-035/3
-- Ngày mẫu có dòng từ T-339 (2026-11-18), nên thêm khoá NOT VALID để không kiểm dữ liệu đang có; lỗi cài vẫn là sai lược đồ.
ALTER TABLE customer_account ADD CONSTRAINT customer_account_staff_fkey
  FOREIGN KEY (id) REFERENCES person (id) NOT VALID;
