-- kêu: I-003/2
-- Mốc đã dọn của bàn 5 bị xoá trắng, rồi bàn 5 nhận khách mới — bàn trống mà chưa ai dọn.
UPDATE table_session_member SET cleaned_at = NULL
WHERE table_session_id = (SELECT id FROM bc WHERE ten = 'phien_5');
DO $$ BEGIN PERFORM pg_temp.bc_phien(ARRAY[pg_temp.bc_ban('5')]); END $$;
