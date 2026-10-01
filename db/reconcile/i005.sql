-- I-005 — docs/product/1-system-design/03-bao-ve-invariant.md §1, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.

-- @@ I-005/1 — phiên đã đóng mà đã thu + đã ghi nợ khác số phải trả
SELECT b.table_session_id AS phien, b.id AS hoa_don, b.due_vnd AS phai_tra,
       b.cash_vnd + b.transfer_vnd + b.prepaid_cash_vnd + b.prepaid_transfer_vnd AS da_thu,
       b.debt_vnd AS no
FROM bill b
WHERE b.table_session_id IS NOT NULL
  AND b.cash_vnd + b.transfer_vnd + b.prepaid_cash_vnd + b.prepaid_transfer_vnd + b.debt_vnd
      <> b.due_vnd

-- @@ I-005/2 — khoản nợ không truy được về đúng một đơn vị tính tiền và đúng một người
SELECT b.id AS hoa_don, b.debt_vnd AS no, b.debtor_name AS nguoi_no,
       num_nonnulls(b.table_session_id, b.sales_order_id) AS so_don_vi
FROM bill b
WHERE b.debt_vnd > 0
  AND (btrim(coalesce(b.debtor_name, '')) = ''
       OR num_nonnulls(b.table_session_id, b.sales_order_id) <> 1)

-- @@ I-005/3 — ngày mà tiền thực nhận khác doanh thu sau khi trừ cộng đủ các dòng của công thức đối soát
-- architecture.md §6.4: tiền thực nhận = doanh thu − nợ ghi + nợ cũ thu + trả trước nhận − trả trước
-- thành doanh thu − trả lại trả trước − hoàn tiền. Hai vế đọc từ HAI nhóm cột khác nhau: vế trái
-- là tiền thật từng bảng nhận/trả; vế phải là số phải trả, số nợ và chuỗi dùng trả trước. Ngày của
-- mỗi hạng tử là sale_date của chính dòng ấy (04-luoc-do-duong-tien.md §3 bảng hạng tử).
WITH h AS (
  -- vế trái: tiền thực nhận
  SELECT sale_date AS ngay, cash_vnd + transfer_vnd AS nhan, 0::bigint AS cong_thuc FROM bill
  UNION ALL SELECT sale_date, cash_vnd + transfer_vnd, 0 FROM debt_collection
  UNION ALL SELECT sale_date, cash_vnd + transfer_vnd, 0 FROM prepayment
  UNION ALL SELECT sale_date, -amount_vnd, 0 FROM refund
  -- vế phải: doanh thu − nợ ghi, nợ cũ thu, trả trước nhận, − trả trước thành doanh thu, − trả lại, − hoàn
  UNION ALL SELECT sale_date, 0, due_vnd - debt_vnd FROM bill
  UNION ALL SELECT sale_date, 0, coalesce(remaining_before_vnd, debt_vnd) - remaining_vnd FROM debt_collection
  UNION ALL SELECT sale_date, 0, cash_vnd + transfer_vnd FROM prepayment
  UNION ALL SELECT b.sale_date, 0, -u.take_vnd FROM prepayment_use u JOIN bill b ON b.id = u.bill_id
  UNION ALL SELECT sale_date, 0, -amount_vnd FROM refund)
SELECT ngay, sum(nhan) AS tien_thuc_nhan, sum(cong_thuc) AS theo_cong_thuc,
       sum(nhan) - sum(cong_thuc) AS lech
FROM h
GROUP BY ngay
HAVING sum(nhan) <> sum(cong_thuc)
