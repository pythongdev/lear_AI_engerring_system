-- T-264 — ADR-131 sửa đổi 2026-10-28, I-018: lần sửa trên bảng khách để lại vết với người sửa rỗng; ai sửa
-- đọc qua dòng đích (customer_account / customer_*.customer_account_id). Mọi bảng khác vẫn bắt buộc người của quán.
ALTER TABLE record_revision
  ALTER COLUMN person_id DROP NOT NULL,
  ADD CONSTRAINT record_revision_person_check
    CHECK (person_id IS NOT NULL OR target_table_code IN
      ('customer_account', 'customer_password', 'customer_session', 'customer_password_reset'));
