-- T-141 — huỷ ô chấm công: ghi chú BẮT BUỘC, người huỷ là CHỦ QUÁN (chủ quán chốt 2026-10-09, đóng U-071;
-- master_plan/shop-facts.md §8.7; quality/invariants.md I-027 vế cuối).
-- Ý định và ánh xạ: docs/product/2-db/13-luoc-do-cham-cong.md §3 · §5.
-- File này thắng về tên · kiểu · ràng buộc (docs/decisions.md ADR-053 luật 2).
--
-- Bước 22 (P2A-03) nhận một lần huỷ không ghi chú và không xét người huỷ (ADR-072 điểm 4, khi U-071 còn mở).
-- Ghi chú trắng đã bị từ chối từ bước ấy (attendance_day_cancel_note_only_when_cancelled_check); bước này
-- thêm vế "có huỷ thì có ghi chú". Người huỷ là chủ quán: một CHECK không đọc được bảng khác, nên giữ bằng
-- trigger trước khi ghi, mang tên ràng buộc để cửa ghi ánh xạ được (QC-10). Người huỷ không tồn tại vẫn
-- để khoá ngoại attendance_day_cancelled_by_person_fkey từ chối.

ALTER TABLE attendance_day
  ADD CONSTRAINT attendance_day_cancel_note_required_check
    CHECK (cancelled_at IS NULL OR cancel_note IS NOT NULL);

CREATE FUNCTION attendance_day_cancelled_by_owner() RETURNS trigger
LANGUAGE plpgsql SET search_path = shop, pg_temp AS $$
BEGIN
  IF NEW.cancelled_by_person_id IS NOT NULL
     AND EXISTS (SELECT 1 FROM person p WHERE p.id = NEW.cancelled_by_person_id AND NOT p.is_owner) THEN
    RAISE EXCEPTION 'attendance_day: người huỷ % không phải chủ quán — chỉ chủ quán huỷ ô chấm công (U-071)',
      NEW.cancelled_by_person_id
      USING ERRCODE = 'check_violation', CONSTRAINT = 'attendance_day_cancelled_by_owner_check';
  END IF;
  RETURN NEW;
END $$;

CREATE TRIGGER attendance_day_cancelled_by_owner_trg
  BEFORE INSERT OR UPDATE OF cancelled_by_person_id ON attendance_day
  FOR EACH ROW EXECUTE FUNCTION attendance_day_cancelled_by_owner();
