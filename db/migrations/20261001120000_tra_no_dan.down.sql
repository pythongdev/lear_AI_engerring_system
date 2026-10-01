-- Đường lùi của 20261001120000_tra_no_dan.up.sql (T-126; ADR-075 · U-063).
-- Luật lùi: docs/product/2-db/07-thu-tu-migration.md · ADR-065.
-- KHOÁ CHẶN: chỉ lùi khi hình cũ giữ nguyên được dữ liệu — mỗi hoá đơn một lần trả đủ.
DO $$
DECLARE n bigint;
BEGIN
  SELECT count(*) INTO n
  FROM debt_collection
  WHERE remaining_before_vnd IS NOT NULL OR remaining_vnd <> 0
     OR bill_id IN (SELECT bill_id FROM debt_collection GROUP BY bill_id HAVING count(*) > 1);
  IF n > 0 THEN
    RAISE EXCEPTION 'đường lùi từ chối: debt_collection đang giữ % giá trị đã ghi — gỡ nó là xoá dữ liệu', n
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;

ALTER TABLE debt_collection DROP CONSTRAINT debt_collection_follows_fkey;
DROP INDEX debt_collection_first_payment_key;
ALTER TABLE debt_collection DROP CONSTRAINT debt_collection_before_key;
ALTER TABLE debt_collection DROP CONSTRAINT debt_collection_after_key;
ALTER TABLE debt_collection DROP CONSTRAINT debt_collection_amounts_check;
ALTER TABLE debt_collection DROP COLUMN remaining_before_vnd, DROP COLUMN remaining_vnd;
ALTER TABLE debt_collection ADD CONSTRAINT debt_collection_one_per_debt_key UNIQUE (bill_id);
ALTER TABLE debt_collection ADD CONSTRAINT debt_collection_amounts_check
  CHECK (debt_vnd > 0 AND cash_vnd >= 0 AND transfer_vnd >= 0
         AND cash_vnd + transfer_vnd = debt_vnd);
