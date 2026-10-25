-- T-239 — chỉ cho máy dev, KHÔNG BAO GIỜ chạy trên database của quán. Chạy sau make seed.
-- Thay mã QR hiện hành của mỗi bàn bằng chính tên bàn (1, 2, …) để thử trang khách bằng
-- http://localhost:3000/ban/<số bàn>. Cố ý bỏ vế "không đoán được" của I-023: mã là số bàn.
-- Đi qua đúng ràng buộc và trigger của lược đồ (vết đổi có lý do và người); mã cũ thành mã đã
-- thay, không xoá. Chạy lần hai: bàn đã từng có mã bằng tên bàn thì bỏ qua (mã là duy nhất suốt đời).
BEGIN;
DO $so_ban$
DECLARE
  owner_id bigint;
  t record;
  doi int := 0;
BEGIN
  PERFORM pg_advisory_xact_lock(hashtext('ma-qr-so-ban:T-239'));
  SELECT id INTO STRICT owner_id FROM person WHERE is_owner ORDER BY id LIMIT 1;
  PERFORM set_config('shop.actor_person_id', owner_id::text, true);
  PERFORM set_config('shop.revision_reason', 'Mã QR bằng số bàn cho máy dev (thử)', true);
  FOR t IN SELECT d.id, d.label FROM dining_table d
           WHERE NOT EXISTS (SELECT 1 FROM qr_code q WHERE q.code = d.label)
           ORDER BY d.id LOOP
    UPDATE qr_code SET replaced_at = now() WHERE dining_table_id = t.id AND replaced_at IS NULL;
    INSERT INTO qr_code (dining_table_id, code, issued_at) VALUES (t.id, t.label, now());
    doi := doi + 1;
  END LOOP;
  RAISE NOTICE 'ma-qr-so-ban: đổi % bàn', doi;
END
$so_ban$;
COMMIT;
