-- Đường lùi của 20261001140000_khoang_chan_tao_don.up.sql (T-132; ADR-078).
-- KHOÁ CHẶN: một trong hai bảng có dòng thì từ chối trước khi gỡ gì (QD-50).
DO $$
DECLARE n bigint;
BEGIN
  SELECT (SELECT count(*) FROM order_intake_pause) + (SELECT count(*) FROM shop_blind_spell) INTO n;
  IF n > 0 THEN
    RAISE EXCEPTION 'đường lùi từ chối: order_intake_pause · shop_blind_spell đang giữ % giá trị đã ghi — gỡ nó là xoá dữ liệu', n
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;

DROP TRIGGER shop_blind_spell_record_revision_trg ON shop_blind_spell;
DROP TRIGGER order_intake_pause_record_revision_trg ON order_intake_pause;
DROP TABLE shop_blind_spell;
DROP TABLE order_intake_pause;
