-- CHAT-35 — ADR-139 điểm 5, 6, 11; I-040.
-- Ý định và tầng bảo vệ: docs/product/2-db/28-luoc-do-so-goi-model.md.
CREATE TABLE model_call (
  id bigint GENERATED ALWAYS AS IDENTITY,
  provider_code text COLLATE "C" NOT NULL,
  model_code text COLLATE "C" NOT NULL,
  reserved_microusd bigint NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  settled_at timestamptz,
  input_token_count integer,
  output_token_count integer,
  cost_microusd bigint,
  CONSTRAINT model_call_pkey PRIMARY KEY (id),
  CONSTRAINT model_call_provider_code_check CHECK (provider_code ~ '^[a-z][a-z0-9_]*$'),
  CONSTRAINT model_call_model_code_check CHECK (model_code ~ '[^[:space:]]'),
  CONSTRAINT model_call_reserved_check CHECK (reserved_microusd > 0),
  CONSTRAINT model_call_cost_check CHECK (cost_microusd >= 0),
  CONSTRAINT model_call_token_count_check CHECK (input_token_count >= 0 AND output_token_count >= 0),
  CONSTRAINT model_call_settlement_pair_check CHECK ((settled_at IS NULL) = (cost_microusd IS NULL)),
  CONSTRAINT model_call_tokens_settled_check CHECK (settled_at IS NOT NULL OR (input_token_count IS NULL AND output_token_count IS NULL)),
  CONSTRAINT model_call_settled_after_check CHECK (settled_at >= created_at)
);

CREATE FUNCTION model_call_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path = shop, pg_temp AS $$
DECLARE
  -- Trần cứng: master_plan/shop-facts.md §8.11 điểm 5 và ADR-139 điểm 6.
  month_limit CONSTANT bigint := 10000000;
  day_limit CONSTANT bigint := 1000000;
  local_created timestamp := NEW.created_at AT TIME ZONE 'Asia/Ho_Chi_Minh';
  month_total numeric;
  day_total numeric;
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF ROW(NEW.provider_code, NEW.model_code, NEW.reserved_microusd, NEW.created_at)
         IS DISTINCT FROM ROW(OLD.provider_code, OLD.model_code, OLD.reserved_microusd, OLD.created_at)
       OR (OLD.settled_at IS NOT NULL AND NEW IS DISTINCT FROM OLD) THEN
      RAISE EXCEPTION 'model_call: thông tin giữ chỗ và phần đã chốt không được đổi'
        USING ERRCODE = 'check_violation', CONSTRAINT = 'model_call_settle_once_check';
    END IF;
  ELSE
    -- Khoá cố định riêng cho toàn sổ; lấy trước khi đọc tổng. Hàm VOLATILE
    -- đọc ảnh mới sau khi đợi khoá ở READ COMMITTED của ứng dụng.
    PERFORM pg_advisory_xact_lock(20261104180000::bigint);
    SELECT coalesce(sum(coalesce(cost_microusd, reserved_microusd)), 0),
           coalesce(sum(coalesce(cost_microusd, reserved_microusd)) FILTER (
             WHERE (created_at AT TIME ZONE 'Asia/Ho_Chi_Minh')::date = local_created::date), 0)
      INTO month_total, day_total
    FROM model_call
    WHERE date_trunc('month', created_at AT TIME ZONE 'Asia/Ho_Chi_Minh') = date_trunc('month', local_created);
    IF month_total + NEW.reserved_microusd > month_limit THEN
      RAISE EXCEPTION 'model_call: giữ chỗ vượt trần tháng'
        USING ERRCODE = 'check_violation', CONSTRAINT = 'model_call_month_budget_check';
    END IF;
    IF day_total + NEW.reserved_microusd > day_limit THEN
      RAISE EXCEPTION 'model_call: giữ chỗ vượt trần ngày'
        USING ERRCODE = 'check_violation', CONSTRAINT = 'model_call_day_budget_check';
    END IF;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER model_call_guard_trg BEFORE INSERT OR UPDATE ON model_call
  FOR EACH ROW EXECUTE FUNCTION model_call_guard();
CREATE TRIGGER model_call_record_revision_trg AFTER UPDATE ON model_call
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
-- Chốt do máy ghi, không người của quán (ADR-139 điểm 5: sổ không cột người): vết mang người rỗng như các bảng khách.
ALTER TABLE record_revision DROP CONSTRAINT record_revision_person_check,
  ADD CONSTRAINT record_revision_person_check CHECK (person_id IS NOT NULL OR target_table_code IN
    ('customer_account', 'customer_password', 'customer_session', 'customer_password_reset', 'customer_email_verification',
     'model_call'));

-- QC-03 giữ SELECT và quyền sequence mặc định, thu hẹp quyền ghi theo cột.
REVOKE INSERT, UPDATE, DELETE ON model_call FROM shop_app;
GRANT INSERT (provider_code, model_code, reserved_microusd) ON model_call TO shop_app;
GRANT UPDATE (settled_at, input_token_count, output_token_count, cost_microusd) ON model_call TO shop_app;
