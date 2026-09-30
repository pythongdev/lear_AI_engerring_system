-- I-015 — docs/product/1-system-design/03-bao-ve-invariant.md §1, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Một lần thu = một hoá đơn, mỗi phương thức một cột (04-luoc-do-duong-tien.md §1). Tập "một phần
-- không mang phương thức / ghi gộp" và tập "các phần rơi vào hai ngày" không có phần tử nào tồn tại
-- được trong hình ấy; tập tin nhắn báo có chưa có chỗ cất; tập két là I-021 — file 09 §2.

-- @@ I-015/1 — lần thu mà tổng các phần thiếu so với số phải trả và phần thiếu không đúng bằng khoản nợ
SELECT b.id AS hoa_don, b.due_vnd AS phai_tra,
       b.cash_vnd + b.transfer_vnd + b.prepaid_cash_vnd + b.prepaid_transfer_vnd AS cac_phan,
       b.debt_vnd AS no
FROM bill b
WHERE b.cash_vnd + b.transfer_vnd + b.prepaid_cash_vnd + b.prepaid_transfer_vnd < b.due_vnd
  AND b.debt_vnd <> b.due_vnd - (b.cash_vnd + b.transfer_vnd + b.prepaid_cash_vnd + b.prepaid_transfer_vnd)

-- @@ I-015/2 — lần thu mà tổng các phần vượt số phải trả
SELECT b.id AS hoa_don, b.due_vnd AS phai_tra,
       b.cash_vnd + b.transfer_vnd + b.prepaid_cash_vnd + b.prepaid_transfer_vnd AS cac_phan
FROM bill b
WHERE b.cash_vnd + b.transfer_vnd + b.prepaid_cash_vnd + b.prepaid_transfer_vnd > b.due_vnd
