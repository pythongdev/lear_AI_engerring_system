-- ADR-089 điểm 6: bản đọc của cửa, giữ từng hạng tử bằng test so với pg_temp.ket_ngay.
  WITH chi AS (
    SELECT paid_date AS ngay_khai, amount_vnd
    FROM staff_advance
    UNION ALL
    SELECT paid_date, amount_vnd FROM holiday_bonus),
  hang_tu(ngay, tien) AS (
    -- doanh thu TIỀN MẶT: phần tiền mặt của hoá đơn (kể cả trả trước nhận bằng tiền mặt) − hoàn cho
    -- khoản đã thu bằng tiền mặt
    SELECT sale_date, cash_vnd + prepaid_cash_vnd FROM bill
    UNION ALL SELECT sale_date, -amount_vnd FROM refund
      WHERE bill_id IS NOT NULL AND source_method_code = 'cash'
    -- − hoàn bằng tiền mặt cho khoản đã chuyển khoản · + hoàn bằng chuyển khoản cho khoản tiền mặt
    UNION ALL SELECT sale_date, -amount_vnd FROM refund
      WHERE bill_id IS NOT NULL AND method_code = 'cash' AND source_method_code = 'transfer'
    UNION ALL SELECT sale_date, amount_vnd FROM refund
      WHERE bill_id IS NOT NULL AND method_code = 'transfer' AND source_method_code = 'cash'
    -- + nợ cũ thu bằng tiền mặt · + trả trước nhận bằng tiền mặt
    UNION ALL SELECT sale_date, cash_vnd FROM debt_collection
    UNION ALL SELECT sale_date, cash_vnd FROM prepayment
    -- − phần tiền mặt của trả trước đã thành doanh thu · − trả trước trả lại bằng tiền mặt
    UNION ALL SELECT sale_date, -prepaid_cash_vnd FROM bill
    UNION ALL SELECT sale_date, -amount_vnd FROM refund
      WHERE prepayment_id IS NOT NULL AND method_code = 'cash'
    -- − chi từ két (paid_date — ngày người ghi khai)
    UNION ALL SELECT ngay_khai, -amount_vnd FROM chi),
  dem AS (
    SELECT c.sale_date AS ngay, coalesce(sum(x.amount_vnd), 0)::bigint AS tien
    FROM cash_count c LEFT JOIN cash_count_line x ON x.cash_count_id = c.id
    GROUP BY c.sale_date),
  dau AS (
    SELECT f.sale_date AS ngay, coalesce(sum(x.amount_vnd), 0)::bigint AS tien
    FROM opening_float f LEFT JOIN opening_float_line x ON x.opening_float_id = f.id
    GROUP BY f.sale_date)
  SELECT dem.ngay, dem.tien, dau.tien,
         coalesce((SELECT sum(h.tien) FROM hang_tu h WHERE h.ngay = dem.ngay), 0)::bigint
  FROM dem JOIN dau ON dau.ngay = dem.ngay
  WHERE dem.ngay = $1::date
