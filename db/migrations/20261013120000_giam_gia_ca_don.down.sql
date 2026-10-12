-- T-175: không bỏ phần giảm đã ghi.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM bill WHERE discount_vnd > 0) THEN
    RAISE EXCEPTION 'đường lùi từ chối: đang giữ giảm giá dương trên hoá đơn'
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;
ALTER TABLE bill
  DROP CONSTRAINT bill_parts_equal_due_check,
  DROP COLUMN discount_customer_name,
  DROP COLUMN discount_vnd,
  ADD CONSTRAINT bill_parts_equal_due_check
    CHECK (cash_vnd + transfer_vnd + prepaid_cash_vnd + prepaid_transfer_vnd + debt_vnd = due_vnd);
