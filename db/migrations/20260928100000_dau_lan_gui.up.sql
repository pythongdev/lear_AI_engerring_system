-- T-116 — dấu lần gửi trên mọi đơn và mọi lượt gọi (I-024, YC-25), thêm vào lát bán hàng lõi.
-- Ý định, lý do và ánh xạ: docs/product/2-db/02-luoc-do-ban-hang.md §2 hàng I-024.
-- File này thắng về tên · kiểu · ràng buộc (docs/decisions.md ADR-053 luật 2).
-- Quy ước: docs/product/2-db/01-quy-uoc-du-lieu.md (QD-XX) · 10-quy-uoc-code.md (QC-XX).

-- Một lượt gọi vào phiên bàn là một dòng sales_order (02-luoc-do-ban-hang.md §1), nên một
-- cột ở đây phủ cả đơn lẻ lẫn lượt gọi của cả năm kênh.
--
-- Dấu do PHÍA GỬI đặt một lần, lúc người bấm gửi, và giữ nguyên trên mọi lần gửi lại. Cố ý
-- KHÔNG có giá trị mặc định: một mặc định tự sinh cấp dấu MỚI cho mỗi lần gửi lại — đúng
-- đơn trùng mà I-024 chống. Kiểu là text: mệnh đề không nói dấu sinh bằng gì.
ALTER TABLE sales_order
  ADD COLUMN submission_code text NOT NULL;

ALTER TABLE sales_order
  -- Vế "không đơn nào thiếu dấu": NOT NULL ở trên, và chuỗi trắng cũng là thiếu.
  ADD CONSTRAINT sales_order_submission_code_not_blank_check
    CHECK (btrim(submission_code) <> ''),
  -- Vế "một lần gửi, nhiều nhất một đơn": trên MỌI đơn, không hạn thời gian, chỉ trên
  -- dấu — không trên nội dung, vì hai đơn giống hệt mang hai dấu là hai đơn thật.
  ADD CONSTRAINT sales_order_submission_code_key UNIQUE (submission_code);
