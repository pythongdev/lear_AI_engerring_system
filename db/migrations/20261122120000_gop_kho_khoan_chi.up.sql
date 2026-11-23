-- KC-02 — ADR-147 điểm 1–6, 12; phiếu Claude sửa 2026-11-22 theo QD-51.
-- Ý định và ánh xạ: docs/product/2-db/30-luoc-do-gop-kho-khoan-chi.md.
-- Không tạo danh mục hay ghép dữ liệu cũ; DEFAULT false giữ backend cũ chạy tới KC-06.
ALTER TABLE expense_category
  ADD COLUMN tracks_supply boolean NOT NULL DEFAULT false,
  ADD CONSTRAINT expense_category_id_tracks_supply_key UNIQUE (id, tracks_supply);

ALTER TABLE expense_item
  ADD COLUMN tracks_supply boolean NOT NULL DEFAULT false,
  ADD COLUMN supply_item_id bigint,
  ADD CONSTRAINT expense_item_category_tracks_supply_fkey
    FOREIGN KEY (expense_category_id, tracks_supply) REFERENCES expense_category (id, tracks_supply),
  ADD CONSTRAINT expense_item_supply_item_fkey FOREIGN KEY (supply_item_id) REFERENCES supply_item (id),
  ADD CONSTRAINT expense_item_supply_item_key UNIQUE (supply_item_id),
  ADD CONSTRAINT expense_item_supply_link_check CHECK (tracks_supply = (supply_item_id IS NOT NULL));
GRANT UPDATE (expense_category_id) ON expense_item TO shop_app;
-- expense_category và expense_item đã thu UPDATE cấp bảng ở hai lát cũ;
-- không cấp UPDATE tracks_supply hay supply_item_id.

-- Cửa chuyển mục phải đổi cả khoản con và khoản chi trong cùng giao dịch.
-- Giữ NO ACTION mặc định ở cả hai chiều; chỉ hoãn thời điểm kiểm.
ALTER TABLE expense DROP CONSTRAINT expense_item_fkey,
  ADD CONSTRAINT expense_item_fkey
    FOREIGN KEY (expense_item_id, expense_category_id) REFERENCES expense_item (id, expense_category_id)
    DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE supply_item
  ADD COLUMN deleted_at timestamptz,
  ADD COLUMN deleted_by_person_id bigint,
  ADD CONSTRAINT supply_item_deleted_by_person_fkey FOREIGN KEY (deleted_by_person_id) REFERENCES person (id),
  ADD CONSTRAINT supply_item_deleted_pair_check CHECK ((deleted_at IS NULL) = (deleted_by_person_id IS NULL));
-- name đã có UPDATE qua quyền cấp bảng từ QC-03; giữ quyền cũ để down trả đúng ảnh lược đồ.
GRANT UPDATE (deleted_at, deleted_by_person_id) ON supply_item TO shop_app;

-- Kiểm bản hiện hành khi sự kiện hoãn chạy, không so ảnh NEW của lần sửa trung gian.
-- Khoá thứ trong sổ trước, đọc cặp bằng câu riêng sau khi chờ khoá (READ COMMITTED).
CREATE FUNCTION expense_item_supply_match_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
DECLARE target_supply bigint; pair record;
BEGIN
  IF TG_TABLE_NAME = 'expense_item' THEN
    SELECT supply_item_id INTO target_supply FROM expense_item WHERE id = NEW.id;
  ELSE
    target_supply := NEW.id;
  END IF;

  PERFORM 1 FROM supply_item WHERE id = target_supply FOR NO KEY UPDATE;
  SELECT i.name AS item_name, s.name AS supply_name,
         i.deleted_at IS NOT NULL AS item_stopped, s.deleted_at IS NOT NULL AS supply_stopped
    INTO pair
    FROM expense_item i JOIN supply_item s ON s.id = i.supply_item_id
    WHERE s.id = target_supply;
  IF FOUND THEN
    IF pair.item_name IS DISTINCT FROM pair.supply_name THEN
      RAISE EXCEPTION 'khoản con và thứ nối trong sổ phải cùng tên'
        USING ERRCODE = 'check_violation', CONSTRAINT = 'expense_item_supply_name_match_check';
    END IF;
    IF pair.item_stopped IS DISTINCT FROM pair.supply_stopped THEN
      RAISE EXCEPTION 'khoản con và thứ nối trong sổ phải cùng trạng thái ngừng dùng'
        USING ERRCODE = 'check_violation', CONSTRAINT = 'expense_item_supply_stopped_match_check';
    END IF;
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION expense_item_supply_match_guard() FROM PUBLIC;
CREATE CONSTRAINT TRIGGER expense_item_supply_match_check AFTER INSERT OR UPDATE ON expense_item
  DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION expense_item_supply_match_guard();
CREATE CONSTRAINT TRIGGER supply_item_expense_match_check AFTER INSERT OR UPDATE ON supply_item
  DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION expense_item_supply_match_guard();

CREATE FUNCTION supply_day_entry_supply_item_stopped_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = shop, pg_temp AS $$
DECLARE prior_supply bigint;
BEGIN
  IF TG_OP = 'UPDATE' THEN prior_supply := OLD.supply_item_id; END IF;
  -- Khoá theo mã tăng dần cả thứ cũ và mới: không dời con số ra khỏi thứ đã ngừng.
  -- Khoá xung đột với UPDATE dấu ngừng, giữ tới hết giao dịch ghi lượng.
  PERFORM 1 FROM supply_item WHERE id IN (prior_supply, NEW.supply_item_id)
    ORDER BY id FOR NO KEY UPDATE;
  IF EXISTS (SELECT 1 FROM supply_item
             WHERE id IN (prior_supply, NEW.supply_item_id) AND deleted_at IS NOT NULL) THEN
    RAISE EXCEPTION 'không ghi mới hay sửa con số của thứ đã ngừng dùng'
      USING ERRCODE = 'check_violation', CONSTRAINT = 'supply_day_entry_supply_item_stopped_check';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION supply_day_entry_supply_item_stopped_guard() FROM PUBLIC;
CREATE TRIGGER supply_day_entry_supply_item_stopped_check BEFORE INSERT OR UPDATE ON supply_day_entry
  FOR EACH ROW EXECUTE FUNCTION supply_day_entry_supply_item_stopped_guard();

ALTER TABLE expense ADD COLUMN received_date date;
GRANT UPDATE (received_date) ON expense TO shop_app;
