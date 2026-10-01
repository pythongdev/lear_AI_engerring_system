-- kêu: I-028/3
-- Tầng 3: không gỡ ràng buộc; người duyệt có trong quán nhưng không là chủ quán.
UPDATE staff_advance SET approver_person_id = pg_temp.bc_nguoi('Người đứng quầy');
