-- T-175, ADR-098: tổng dòng giữ nguyên, doanh thu trừ giảm giá.
ALTER TABLE bill
  ADD COLUMN discount_vnd bigint NOT NULL DEFAULT 0,
  ADD COLUMN discount_customer_name text COLLATE "vi-x-icu",
  ADD CONSTRAINT bill_discount_not_negative_check CHECK (discount_vnd >= 0),
  ADD CONSTRAINT bill_discount_customer_name_check
    CHECK ((discount_vnd > 0) = (discount_customer_name IS NOT NULL)
       AND (discount_customer_name IS NULL OR btrim(discount_customer_name) <> '')),
  DROP CONSTRAINT bill_parts_equal_due_check,
  ADD CONSTRAINT bill_parts_equal_due_check
    CHECK (cash_vnd + transfer_vnd + prepaid_cash_vnd + prepaid_transfer_vnd + debt_vnd + discount_vnd = due_vnd);
