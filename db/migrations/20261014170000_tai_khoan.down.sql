-- Đường lùi của 20261014170000_tai_khoan.up.sql (P2A-14 — tài khoản).
-- Thứ tự dựng và luật lùi: docs/product/2-db/07-thu-tu-migration.md · docs/decisions.md ADR-065.
--
-- KHOÁ CHẶN: đường lùi chỉ gỡ chỗ cất còn RỖNG. Bảng sắp gỡ có dòng ⇒ từ chối,
-- không gỡ gì (cả file là một giao dịch, QC-05). Lùi trên dữ liệu đã ghi bằng migration mới đi tới.
DO $$
DECLARE
  target text;
  n      bigint;
BEGIN
  FOREACH target IN ARRAY ARRAY['password_reset', 'login_session', 'account_password', 'account'] LOOP
    EXECUTE format('SELECT count(*) FROM %I', target) INTO n;
    IF n > 0 THEN
      RAISE EXCEPTION 'đường lùi từ chối: % đang giữ % giá trị đã ghi — gỡ nó là xoá dữ liệu', target, n
        USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
    END IF;
  END LOOP;
END $$;

DROP TABLE password_reset;
DROP TABLE login_session;
DROP TABLE account_password;
DROP TABLE account;
DROP FUNCTION password_reset_used_guard();
DROP FUNCTION login_session_ended_guard();
DROP FUNCTION login_session_account_guard();
