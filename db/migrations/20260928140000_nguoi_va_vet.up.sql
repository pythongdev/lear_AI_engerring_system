-- P2-08 — lát người · chỗ đứng theo thời điểm · vết: người · trực quầy · "ai bấm" trên các bảng
-- thao tác chạm tiền và sản xuất · vết cập nhật (bản trước, bản sau, lý do, người sửa) · sổ giấy
-- của ngày mất điện.
-- Ý định, lý do và ánh xạ I-0xx/YC-xx: docs/product/2-db/06-luoc-do-nguoi-va-vet.md.
-- File này thắng về tên · kiểu · ràng buộc (docs/decisions.md ADR-053 luật 2).
-- Quy ước: docs/product/2-db/01-quy-uoc-du-lieu.md (QD-XX) · 10-quy-uoc-code.md (QC-XX).
--
-- NGƯỜI THAO TÁC CỦA MỘT GIAO DỊCH là cài đặt giao dịch `shop.actor_person_id`
-- (set_config(..., true)). Mọi cột "ai bấm" lấy mặc định từ đó; giao dịch không khai thì cột ấy
-- trống và NOT NULL từ chối lần ghi (I-012 tầng 1). Ghi tường minh vẫn được — người đi giao do
-- POS khai tên (shop-facts §8.8, U-057).
-- Chấm công, lương, vai thường lệ của từng người: lane admin, không dựng ở đây.

-- ---------------------------------------------------------------------------
-- Người, và ai đứng quầy lúc nào
-- ---------------------------------------------------------------------------

-- Một người của quán — bốn vai và chủ quán (shop-facts §3). Chủ quán là một CỜ trên người, không
-- phải một chỗ đứng: đứng quầy thì có thêm quyền của quầy, cờ vẫn nguyên (YC-16).
CREATE TABLE person (
  id           bigint GENERATED ALWAYS AS IDENTITY,
  display_name text COLLATE "vi-x-icu" NOT NULL,
  is_owner     boolean NOT NULL DEFAULT false,
  created_at   timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT person_pkey PRIMARY KEY (id),
  CONSTRAINT person_display_name_not_blank_check CHECK (btrim(display_name) <> '')
);

-- Người thao tác đã khai cho giao dịch này, hoặc trống.
CREATE FUNCTION actor_person_id() RETURNS bigint LANGUAGE sql STABLE AS $$
  SELECT NULLIF(btrim(current_setting('shop.actor_person_id', true)), '')::bigint
$$;

-- Trực quầy (shop-facts §8.8, C36 · U-056): mỗi lần đổi người ở quầy là một mốc có giờ — người ra
-- khép khoảng của mình, người vào mở khoảng mới, POS khai. Khoảng không ghi đè nhau: một người
-- đứng quầy một lúc (§3 — trạm riêng, một người). Bốn trạm ngoài quầy KHÔNG ghi mốc đổi (U-055).
CREATE TABLE counter_duty (
  id         bigint GENERATED ALWAYS AS IDENTITY,
  person_id  bigint NOT NULL,
  started_at timestamptz NOT NULL,
  ended_at   timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT counter_duty_pkey PRIMARY KEY (id),
  CONSTRAINT counter_duty_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT counter_duty_ended_after_started_check
    CHECK (ended_at IS NULL OR ended_at > started_at),
  -- YC-15: ai đứng quầy tại một thời điểm có đúng một câu trả lời.
  CONSTRAINT counter_duty_one_at_a_time_excl
    EXCLUDE USING gist (tstzrange(started_at, ended_at, '[)') WITH &&)
);

-- ---------------------------------------------------------------------------
-- "Ai bấm" (I-012 tầng 1: thiếu ai bấm thì thao tác không tồn tại được)
-- ---------------------------------------------------------------------------

ALTER TABLE bill
  ADD COLUMN person_id bigint NOT NULL DEFAULT actor_person_id(),
  ADD CONSTRAINT bill_person_fkey FOREIGN KEY (person_id) REFERENCES person (id);
ALTER TABLE debt_collection
  ADD COLUMN person_id bigint NOT NULL DEFAULT actor_person_id(),
  ADD CONSTRAINT debt_collection_person_fkey FOREIGN KEY (person_id) REFERENCES person (id);
ALTER TABLE prepayment
  ADD COLUMN person_id bigint NOT NULL DEFAULT actor_person_id(),
  ADD CONSTRAINT prepayment_person_fkey FOREIGN KEY (person_id) REFERENCES person (id);
ALTER TABLE refund
  ADD COLUMN person_id bigint NOT NULL DEFAULT actor_person_id(),
  ADD CONSTRAINT refund_person_fkey FOREIGN KEY (person_id) REFERENCES person (id);
ALTER TABLE opening_float
  ADD COLUMN person_id bigint NOT NULL DEFAULT actor_person_id(),
  ADD CONSTRAINT opening_float_person_fkey FOREIGN KEY (person_id) REFERENCES person (id);
ALTER TABLE station_job_transfer
  ADD COLUMN person_id bigint NOT NULL DEFAULT actor_person_id(),
  ADD CONSTRAINT station_job_transfer_person_fkey FOREIGN KEY (person_id) REFERENCES person (id);
-- Ai cấp / đổi mã QR (I-023 · YC-24; chỉ chủ quán — U-062, quyền theo vai là pha 3). Cửa
-- qr_code_issue không đổi chữ ký: nó ghi người của giao dịch.
ALTER TABLE qr_code
  ADD COLUMN person_id bigint NOT NULL DEFAULT actor_person_id(),
  ADD CONSTRAINT qr_code_person_fkey FOREIGN KEY (person_id) REFERENCES person (id);

-- Mẻ: ai bấm "đã làm xong"; và nếu lùi — ai lùi (YC-07: lùi mẻ nào · mấy giờ · ai).
ALTER TABLE production_batch
  ADD COLUMN made_by_person_id bigint NOT NULL DEFAULT actor_person_id(),
  ADD COLUMN rolled_back_by_person_id bigint,
  ADD CONSTRAINT production_batch_made_by_person_fkey
    FOREIGN KEY (made_by_person_id) REFERENCES person (id),
  ADD CONSTRAINT production_batch_rolled_back_by_person_fkey
    FOREIGN KEY (rolled_back_by_person_id) REFERENCES person (id),
  ADD CONSTRAINT production_batch_rolled_back_by_iff_rolled_back_check
    CHECK ((rolled_back_at IS NULL) = (rolled_back_by_person_id IS NULL));

-- ---------------------------------------------------------------------------
-- Sổ giấy của ngày mất điện (YC-08, shop-facts §6.11, ADR-037)
-- ---------------------------------------------------------------------------

-- Người giữ sổ (POS hoặc chủ quán) khai ngày bán và số lượt đã ghi trên giấy. "Còn N lượt chưa
-- nhập" = số khai − số hoá đơn nhập bù của sổ ấy; mỗi lượt là một vị trí 1…số khai.
CREATE TABLE paper_ledger (
  id          bigint GENERATED ALWAYS AS IDENTITY,
  sale_date   date NOT NULL,
  entry_count integer NOT NULL,
  person_id   bigint NOT NULL DEFAULT actor_person_id(),
  declared_at timestamptz NOT NULL DEFAULT now(),
  created_at  timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT paper_ledger_pkey PRIMARY KEY (id),
  CONSTRAINT paper_ledger_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT paper_ledger_one_per_day_key UNIQUE (sale_date),
  CONSTRAINT paper_ledger_entry_count_positive_check CHECK (entry_count > 0),
  -- Đích của khoá ngoại ba cột ở bill.
  CONSTRAINT paper_ledger_id_day_count_key UNIQUE (id, sale_date, entry_count)
);

-- Hoá đơn nhập bù: sổ nào, lượt thứ mấy. Khoá ngoại ba cột buộc ngày bán của hoá đơn BẰNG ngày của
-- sổ (lượt nhập bù không rơi vào ngày gõ) và vị trí không vượt số đã khai. booked_at · sale_date
-- là ngày quán bán thật; created_at là lúc gõ; person_id là người nhập bù.
ALTER TABLE bill
  ADD COLUMN paper_ledger_id     bigint,
  ADD COLUMN paper_entry_count integer,
  ADD COLUMN paper_position    integer,
  ADD CONSTRAINT bill_paper_ledger_fkey
    FOREIGN KEY (paper_ledger_id, sale_date, paper_entry_count)
    REFERENCES paper_ledger (id, sale_date, entry_count)
    DEFERRABLE INITIALLY DEFERRED,
  ADD CONSTRAINT bill_paper_columns_check
    CHECK (num_nonnulls(paper_ledger_id, paper_entry_count, paper_position) IN (0, 3)),
  ADD CONSTRAINT bill_paper_position_in_range_check
    CHECK (paper_position BETWEEN 1 AND paper_entry_count),
  ADD CONSTRAINT bill_paper_position_key UNIQUE (paper_ledger_id, paper_position);

-- ---------------------------------------------------------------------------
-- Vết cập nhật (I-018 · YC-13 · YC-14)
-- ---------------------------------------------------------------------------

-- Một lần sửa một bản ghi đã có: bảng nào, dòng nào, bản trước, bản sau, lý do, người sửa, lúc
-- nào. Không khoá ngoại về bản ghi gốc — vết sống độc lập với nó (YC-12, QD-03: cột trỏ tới nhiều
-- bảng không mang hậu tố _id). Thiếu một trong bốn thứ thì không tồn tại được (I-018 tầng 1).
CREATE TABLE record_revision (
  id                bigint GENERATED ALWAYS AS IDENTITY,
  target_table_code text NOT NULL,
  target_row        bigint NOT NULL,
  before_image      jsonb NOT NULL,
  after_image       jsonb NOT NULL,
  reason            text COLLATE "vi-x-icu" NOT NULL,
  person_id         bigint NOT NULL,
  revised_at        timestamptz NOT NULL DEFAULT clock_timestamp(),
  created_at        timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT record_revision_pkey PRIMARY KEY (id),
  CONSTRAINT record_revision_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT record_revision_reason_not_blank_check CHECK (btrim(reason) <> ''),
  CONSTRAINT record_revision_target_table_code_check
    CHECK (target_table_code ~ '^[a-z][a-z0-9_]*$'),
  -- Hai bản chụp là của đúng dòng ấy, và lần sửa đổi ít nhất một thứ.
  CONSTRAINT record_revision_images_of_target_check
    CHECK (COALESCE((before_image ->> 'id')::bigint = target_row
                    AND (after_image ->> 'id')::bigint = target_row, false)),
  CONSTRAINT record_revision_changes_something_check CHECK (before_image <> after_image)
);

-- Chụp vết trong CÙNG câu lệnh với lần sửa (I-018 tầng 2): giao dịch khai lý do ở
-- `shop.revision_reason` thì mỗi dòng nó sửa để lại một vết, người sửa là người của giao dịch —
-- khai lý do mà không khai người thì lần sửa bị từ chối cùng vết. CHẾ ĐỘ MỀM (chủ repo chọn
-- 2026-09-28): không khai lý do thì lần sửa đi qua mà không có vết — work/findings.md F-046.
-- SECURITY DEFINER: trigger ghi vết bằng quyền chủ lược đồ, nên vai ghi của hệ thống không cần —
-- và không có — quyền chèn thẳng vào bảng vết (review độc lập 2026-09-29: vết bịa chèn được).
CREATE FUNCTION record_revision_capture() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
DECLARE v_reason text := NULLIF(btrim(current_setting('shop.revision_reason', true)), '');
BEGIN
  IF v_reason IS NULL OR to_jsonb(OLD) = to_jsonb(NEW) THEN
    RETURN NULL;
  END IF;
  INSERT INTO record_revision (target_table_code, target_row, before_image, after_image, reason,
                               person_id)
  VALUES (TG_TABLE_NAME, NEW.id, to_jsonb(OLD), to_jsonb(NEW), v_reason, actor_person_id());
  RETURN NULL;
END $$;

-- Mọi bảng của schema, trừ chính bảng vết, mang trigger ấy. Bảng mới về sau phải mang nó —
-- phép kiểm QD-52 của 01-quy-uoc-du-lieu.md đỏ khi thiếu.
DO $$
DECLARE t text;
BEGIN
  FOR t IN
    SELECT table_name FROM information_schema.tables
    WHERE table_schema = 'shop' AND table_type = 'BASE TABLE' AND table_name <> 'record_revision'
  LOOP
    EXECUTE format('CREATE TRIGGER %I AFTER UPDATE ON %I FOR EACH ROW '
                   'EXECUTE FUNCTION record_revision_capture()', t || '_record_revision_trg', t);
  END LOOP;
END $$;

-- Vai ghi của hệ thống chỉ ĐỌC vết: vết sinh qua trigger ở trên, không sửa, không xoá (QD-50), và
-- không chèn thẳng được — một vết không đi kèm lần sửa nào là một lịch sử bịa.
REVOKE INSERT, UPDATE ON record_revision FROM shop_app;
REVOKE ALL ON FUNCTION record_revision_capture() FROM PUBLIC;
