-- T-132 — hai khoảng ngừng nhận đơn: tạm dừng nhận đơn và quán đang mù (YC-34 · I-008; F-050).
-- Ý định và bằng chứng: docs/product/2-db/02-luoc-do-ban-hang.md §7. Thiết kế: docs/decisions.md ADR-078.
-- Cửa tạo lượt gọi đọc hai bảng này tại mốc tạo là việc của pha 3 (tầng 3 của I-008).

-- Tạm dừng nhận đơn (shop-facts §6.8): nút của người, chặn cả năm kênh. Một lần bật là một khoảng
-- [bắt đầu, kết thúc); khoảng còn mở = đang tạm dừng. Không hai lần chồng nhau (cùng hình counter_duty).
CREATE TABLE order_intake_pause (
  id                   bigint GENERATED ALWAYS AS IDENTITY,
  started_at           timestamptz NOT NULL,
  started_by_person_id bigint NOT NULL DEFAULT actor_person_id(),
  ended_at             timestamptz,
  ended_by_person_id   bigint,
  created_at           timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT order_intake_pause_pkey PRIMARY KEY (id),
  CONSTRAINT order_intake_pause_started_by_person_fkey
    FOREIGN KEY (started_by_person_id) REFERENCES person (id),
  CONSTRAINT order_intake_pause_ended_by_person_fkey
    FOREIGN KEY (ended_by_person_id) REFERENCES person (id),
  CONSTRAINT order_intake_pause_ended_by_iff_ended_check
    CHECK ((ended_at IS NULL) = (ended_by_person_id IS NULL)),
  CONSTRAINT order_intake_pause_ended_after_started_check
    CHECK (ended_at IS NULL OR ended_at > started_at),
  CONSTRAINT order_intake_pause_one_at_a_time_excl
    EXCLUDE USING gist (tstzrange(started_at, ended_at, '[)') WITH &&)
);

-- Quán đang mù (shop-facts §6.11): ba kênh khách tự bấm ngừng. Bắt đầu tính từ lúc quán hết nhìn
-- thấy, không từ lúc có người bấm tắt (U-061) — nên started_at không có mặc định; declared_by trống
-- khi máy phát hiện, có tên khi người bấm tắt trước. Kết thúc chỉ bằng nút mở lại có người bấm
-- (U-043): kết thúc mà không người là không tồn tại được.
CREATE TABLE shop_blind_spell (
  id                    bigint GENERATED ALWAYS AS IDENTITY,
  started_at            timestamptz NOT NULL,
  declared_by_person_id bigint,
  ended_at              timestamptz,
  ended_by_person_id    bigint,
  created_at            timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT shop_blind_spell_pkey PRIMARY KEY (id),
  CONSTRAINT shop_blind_spell_declared_by_person_fkey
    FOREIGN KEY (declared_by_person_id) REFERENCES person (id),
  CONSTRAINT shop_blind_spell_ended_by_person_fkey
    FOREIGN KEY (ended_by_person_id) REFERENCES person (id),
  CONSTRAINT shop_blind_spell_ended_by_iff_ended_check
    CHECK ((ended_at IS NULL) = (ended_by_person_id IS NULL)),
  CONSTRAINT shop_blind_spell_ended_after_started_check
    CHECK (ended_at IS NULL OR ended_at > started_at),
  CONSTRAINT shop_blind_spell_one_at_a_time_excl
    EXCLUDE USING gist (tstzrange(started_at, ended_at, '[)') WITH &&)
);

-- QD-52: trigger vết như mọi bảng.
CREATE TRIGGER order_intake_pause_record_revision_trg AFTER UPDATE ON order_intake_pause
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
CREATE TRIGGER shop_blind_spell_record_revision_trg AFTER UPDATE ON shop_blind_spell
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();

-- Khoảng đã ghi chỉ được khép; lúc bắt đầu và người bật không dời (YC-34), dòng ở lại (QD-50).
REVOKE UPDATE ON order_intake_pause, shop_blind_spell FROM shop_app;
GRANT UPDATE (ended_at, ended_by_person_id) ON order_intake_pause TO shop_app;
GRANT UPDATE (ended_at, ended_by_person_id) ON shop_blind_spell TO shop_app;
