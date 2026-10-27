-- kêu: I-035/3
-- Bảng khách rỗng; cài sai lược đồ, không cần dữ liệu sai hay cột mới.
ALTER TABLE customer_account ADD CONSTRAINT customer_account_staff_fkey
  FOREIGN KEY (id) REFERENCES person (id);
