-- kêu: I-040/2
-- Ngày mẫu có dòng từ T-339 (2026-11-18), nên thêm khoá NOT VALID để không kiểm dữ liệu đang có; lỗi cài vẫn là sai lược đồ.
ALTER TABLE model_call ADD CONSTRAINT model_call_person_fkey
  FOREIGN KEY (id) REFERENCES person (id) NOT VALID;
