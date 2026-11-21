-- YT-03 — QD-50, ADR-145: chỉ gỡ chỗ cất còn rỗng, kể cả dòng đã gỡ.
-- Khoá cả ba bảng trước phép đếm, không cho ghi chen giữa phép kiểm và DDL.
LOCK TABLE customer_favourite_set, customer_favourite_line, customer_favourite_line_option IN ACCESS EXCLUSIVE MODE;
DO $$
DECLARE stored_count bigint;
BEGIN
  SELECT (SELECT count(*) FROM customer_favourite_set)
       + (SELECT count(*) FROM customer_favourite_line)
       + (SELECT count(*) FROM customer_favourite_line_option) INTO stored_count;
  IF stored_count > 0 THEN
    RAISE EXCEPTION 'đường lùi từ chối: ba bảng yêu thích đang giữ % giá trị đã ghi', stored_count
      USING ERRCODE = 'check_violation', CONSTRAINT = 'customer_favourite_set_rollback_check';
  END IF;
END $$;

-- Trả đúng miền miễn người của bước 20261104180000_so_goi_model.
-- record_revision_target_table_code_check không đổi ở bước xuôi nên giữ nguyên.
ALTER TABLE record_revision DROP CONSTRAINT record_revision_person_check,
  ADD CONSTRAINT record_revision_person_check CHECK (person_id IS NOT NULL OR target_table_code IN
    ('customer_account', 'customer_password', 'customer_session', 'customer_password_reset', 'customer_email_verification',
     'model_call'));

DROP TRIGGER customer_favourite_line_option_record_revision_trg ON customer_favourite_line_option;
DROP TRIGGER customer_favourite_line_option_item_line_check ON customer_favourite_line_option;
DROP FUNCTION customer_favourite_line_option_item_line_guard();
DROP TABLE customer_favourite_line_option;

DROP TRIGGER customer_favourite_line_record_revision_trg ON customer_favourite_line;
DROP TRIGGER customer_favourite_line_removed_once_check ON customer_favourite_line;
DROP TRIGGER customer_favourite_line_shape_check ON customer_favourite_line;
DROP TRIGGER customer_favourite_line_limit_check ON customer_favourite_line;
DROP FUNCTION customer_favourite_line_removed_once_guard();
DROP FUNCTION customer_favourite_line_shape_guard();
DROP FUNCTION customer_favourite_line_limit_guard();
DROP TABLE customer_favourite_line;

DROP TRIGGER customer_favourite_set_record_revision_trg ON customer_favourite_set;
DROP TRIGGER customer_favourite_set_removed_once_check ON customer_favourite_set;
DROP TRIGGER customer_favourite_set_limit_check ON customer_favourite_set;
DROP FUNCTION customer_favourite_set_removed_once_guard();
DROP FUNCTION customer_favourite_set_limit_guard();
DROP TABLE customer_favourite_set;
