-- T-263 — ADR-131: bốn tập phải rỗng của phiếu lược đồ tài khoản khách.

-- @@ I-035/1 — tài khoản không có số điện thoại lẫn thư
SELECT 'account' AS loai, id FROM account WHERE phone IS NULL AND email IS NULL
UNION ALL
SELECT 'customer_account' AS loai, id FROM customer_account WHERE phone IS NULL AND email IS NULL

-- @@ I-035/2 — số điện thoại chưa chuẩn hoá
SELECT 'account' AS loai, id FROM account WHERE phone COLLATE "C" !~ '^0[1-9][0-9]{8,9}$'
UNION ALL
SELECT 'customer_account' AS loai, id FROM customer_account WHERE phone COLLATE "C" !~ '^0[1-9][0-9]{8,9}$'

-- @@ I-035/3 — khoá ngoại từ bảng khách tới người, trực quầy hoặc tài khoản người làm
SELECT c.conname, src.relname AS bang_khach, dst.relname AS bang_nguoi
FROM pg_constraint c
JOIN pg_class src ON src.oid = c.conrelid
JOIN pg_namespace sn ON sn.oid = src.relnamespace
JOIN pg_class dst ON dst.oid = c.confrelid
JOIN pg_namespace dn ON dn.oid = dst.relnamespace
WHERE c.contype = 'f' AND sn.nspname = 'shop' AND dn.nspname = 'shop'
  AND src.relname LIKE 'customer\_%'
  AND dst.relname IN ('person', 'counter_duty', 'account')

-- @@ I-035/4 — đơn không phải web mang tài khoản khách
SELECT id FROM sales_order
WHERE customer_account_id IS NOT NULL AND channel_code NOT IN ('delivery', 'pickup')
