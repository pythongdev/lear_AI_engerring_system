-- kêu: I-016/1
-- Cùng cặp Chờ thanh toán → Đang phục vụ, nhưng không có đơn QR trong khoảng:
-- chỉ một khoảng hở của phiên mới, nên đúng một dòng I-016/1 (ADR-095, F-060).
DO $$ BEGIN PERFORM pg_temp.bc_f060(false); END $$;
