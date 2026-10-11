-- T-140 — ADR-089 Sửa đổi; lời chủ quán 2026-10-09.
ALTER TABLE bill
  ADD COLUMN debt_note text COLLATE "vi-x-icu",
  ADD CONSTRAINT bill_standalone_debt_note_check
    CHECK (sales_order_id IS NULL OR debt_vnd = 0 OR (debt_note IS NOT NULL AND btrim(debt_note) <> '')),
  ADD CONSTRAINT bill_debt_note_only_with_debt_check CHECK (debt_vnd > 0 OR debt_note IS NULL);

ALTER TABLE reconciled_day
  ADD COLUMN gap_vnd bigint NOT NULL DEFAULT 0,
  ADD COLUMN gap_explanation text COLLATE "vi-x-icu",
  ADD CONSTRAINT reconciled_day_gap_explained_check
    CHECK (gap_vnd = 0 OR (gap_explanation IS NOT NULL AND btrim(gap_explanation) <> ''));
