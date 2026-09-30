-- kêu: I-014/8 QD-21
-- Trần số dư bị gỡ; khoản trả trước của đơn giao đã dùng hết cho hoá đơn mà còn trả lại thêm 1.000đ.
-- Gỡ trần ấy cũng làm các cột số dư mất ràng buộc không âm — QD-21 kêu cùng.
ALTER TABLE prepayment_use DROP CONSTRAINT prepayment_use_balance_check;
DO $$ DECLARE p bigint := (SELECT id FROM bc WHERE ten = 'tra_truoc_giao'); o bigint; r bigint; BEGIN
  SELECT sales_order_id INTO o FROM prepayment WHERE id = p;
  INSERT INTO refund (prepayment_id, amount_vnd, method_code, reason, booked_at, sale_date)
  VALUES (p, 1000, 'transfer', 'trả lại thêm', pg_temp.bc_luc('10:15'), pg_temp.bc_ngay()) RETURNING id INTO r;
  INSERT INTO prepayment_use (prepayment_id, sales_order_id, use_no, cash_before_vnd,
                              transfer_before_vnd, take_transfer_vnd, refund_id)
  VALUES (p, o, 2, 0, 0, 1000, r);
END $$;
