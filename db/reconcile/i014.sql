-- I-014 — docs/product/1-system-design/03-bao-ve-invariant.md §1, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Hai nguồn: nguồn phiên bàn = hoá đơn có table_session_id; nguồn đơn lẻ = hoá đơn có
-- sales_order_id (cả ba kênh mang đi). Ba tập của pha 1 KHÔNG có câu — tổng của báo cáo · con số
-- đã đối soát hôm ấy · lần trả lại làm giảm doanh thu: lược đồ không cất báo cáo, và dấu đối soát
-- xong (T-133) không mang con số nào — file 09 §2.

-- @@ I-014/5 — ngày đã đối soát xong mà còn lượt bán trên sổ giấy chưa nhập
-- Còn N = số lượt khai trên sổ − số hoá đơn nhập bù của sổ (06-luoc-do-nguoi-va-vet.md §2, ADR-037).
-- Vế "còn một khoản chạm tiền không có mốc" không có phần tử: mọi bảng tiền giữ booked_at NOT NULL.
SELECT r.sale_date AS ngay, p.entry_count AS so_luot_tren_giay,
       p.entry_count - (SELECT count(*) FROM bill b WHERE b.paper_ledger_id = p.id) AS con_chua_nhap
FROM reconciled_day r JOIN paper_ledger p ON p.sale_date = r.sale_date
WHERE p.entry_count > (SELECT count(*) FROM bill b WHERE b.paper_ledger_id = p.id)

-- @@ I-014/1 — khoản tiền đứng ở hơn một nguồn
SELECT b.id AS hoa_don, b.table_session_id AS phien, b.sales_order_id AS don
FROM bill b
WHERE num_nonnulls(b.table_session_id, b.sales_order_id) > 1

-- @@ I-014/2 — khoản tiền không đứng ở nguồn nào
SELECT b.id AS hoa_don, b.due_vnd AS phai_tra, b.sale_date AS ngay
FROM bill b
WHERE num_nonnulls(b.table_session_id, b.sales_order_id) = 0

-- @@ I-014/4 — lần trả nợ được đếm như một khoản bán mới
-- Một lần bán mới của chính đơn vị đã ghi nợ: hoá đơn thứ hai đứng tên đơn vị ấy.
SELECT b2.id AS hoa_don_them, coalesce(b2.table_session_id, b2.sales_order_id) AS don_vi,
       b1.id AS hoa_don_ghi_no, b1.debt_vnd AS no
FROM bill b1
JOIN bill b2
  ON b2.id <> b1.id
 AND (b2.table_session_id = b1.table_session_id OR b2.sales_order_id = b1.sales_order_id)
WHERE b1.debt_vnd > 0

-- @@ I-014/7 — khoản trả trước nằm trong doanh thu của một ngày mà đơn của nó không đóng ngày ấy
-- Trả trước vào doanh thu qua hoá đơn của chính đơn nó (04-luoc-do-duong-tien.md §3); hoá đơn ấy
-- chỉ đúng khi đơn đã Hoàn thành (hoặc Hoàn thành rồi huỷ — giữ hoá đơn).
SELECT b.id AS hoa_don, b.sales_order_id AS don, o.status, b.sale_date AS ngay,
       b.prepaid_cash_vnd + b.prepaid_transfer_vnd AS tra_truoc_thanh_doanh_thu
FROM bill b JOIN sales_order o ON o.id = b.sales_order_id
WHERE b.prepaid_cash_vnd + b.prepaid_transfer_vnd > 0
  AND o.status NOT IN ('completed', 'cancelled')

-- @@ I-014/8 — khoản trả trước mà phần đã thành doanh thu cộng phần đã trả lại vượt số đã nhận
SELECT p.id AS khoan_tra_truoc, p.cash_vnd AS nhan_tien_mat, p.transfer_vnd AS nhan_chuyen_khoan,
       sum(u.take_cash_vnd) AS dung_tien_mat, sum(u.take_transfer_vnd) AS dung_chuyen_khoan
FROM prepayment p JOIN prepayment_use u ON u.prepayment_id = p.id
GROUP BY p.id, p.cash_vnd, p.transfer_vnd
HAVING sum(u.take_cash_vnd) > p.cash_vnd OR sum(u.take_transfer_vnd) > p.transfer_vnd
