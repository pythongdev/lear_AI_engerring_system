-- Đường lùi bước 33 (T-141). Gỡ CHECK ghi chú bắt buộc và trigger gác người huỷ — lùi chỉ NỚI luật, không gỡ
-- cột nào. KHOÁ CHẶN: đã có ô huỷ thì từ chối — các lần huỷ ấy được ghi dưới luật của U-071; lùi trên dữ liệu
-- đã ghi là việc của một migration mới đi tới (luật 2 của 07-thu-tu-migration.md). Database rỗng thì gỡ được.
DO $$
DECLARE n bigint;
BEGIN
  SELECT count(*) INTO n FROM attendance_day WHERE cancelled_at IS NOT NULL;
  IF n > 0 THEN
    RAISE EXCEPTION 'đường lùi từ chối: attendance_day đang giữ % ô đã huỷ dưới luật U-071', n
      USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
  END IF;
END $$;
DROP TRIGGER attendance_day_cancelled_by_owner_trg ON attendance_day;
DROP FUNCTION attendance_day_cancelled_by_owner();
ALTER TABLE attendance_day DROP CONSTRAINT attendance_day_cancel_note_required_check;
