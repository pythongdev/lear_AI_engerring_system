-- Giờ bán theo master_plan/shop-facts.md §1; hai đầu đều trong giờ (db/reconcile/i008.sql).
-- Phép đổi sang time dùng múi giờ phiên kết nối, không dùng múi giờ máy chạy Go.
-- name: NgoaiGio :one
SELECT ($1::timestamptz::time < TIME '06:00:00' OR $1::timestamptz::time > TIME '11:00:00')::boolean;
