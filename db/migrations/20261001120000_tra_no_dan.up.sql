-- T-126 — khách trả nợ dần (docs/decisions.md ADR-075; lời đóng U-063,
-- master_plan/shop-facts.md §6.14). Mỗi lần trả là một dòng, số còn thiếu nối thành chuỗi.
-- Ý định và bằng chứng: docs/product/2-db/04-luoc-do-duong-tien.md §2.
-- Dòng cũ đã thu đủ một lần: trước NULL (đọc là debt_vnd), sau 0.
ALTER TABLE debt_collection DROP CONSTRAINT debt_collection_one_per_debt_key;
ALTER TABLE debt_collection DROP CONSTRAINT debt_collection_amounts_check;
ALTER TABLE debt_collection
  ADD COLUMN remaining_before_vnd bigint,
  ADD COLUMN remaining_vnd bigint NOT NULL DEFAULT 0;

-- Mỗi lần trả dương, còn thiếu giảm nghiêm ngặt; quên khai số còn thiếu khi trả thiếu bị chặn.
ALTER TABLE debt_collection ADD CONSTRAINT debt_collection_amounts_check
  CHECK (debt_vnd > 0 AND cash_vnd >= 0 AND transfer_vnd >= 0 AND cash_vnd + transfer_vnd > 0
         AND remaining_vnd >= 0 AND remaining_before_vnd <= debt_vnd
         AND remaining_vnd = coalesce(remaining_before_vnd, debt_vnd) - cash_vnd - transfer_vnd);
ALTER TABLE debt_collection ADD CONSTRAINT debt_collection_after_key UNIQUE (bill_id, remaining_vnd);
ALTER TABLE debt_collection ADD CONSTRAINT debt_collection_before_key UNIQUE (bill_id, remaining_before_vnd);
ALTER TABLE debt_collection ADD CONSTRAINT debt_collection_follows_fkey
  FOREIGN KEY (bill_id, remaining_before_vnd) REFERENCES debt_collection (bill_id, remaining_vnd);
CREATE UNIQUE INDEX debt_collection_first_payment_key ON debt_collection (bill_id)
  WHERE remaining_before_vnd IS NULL;
