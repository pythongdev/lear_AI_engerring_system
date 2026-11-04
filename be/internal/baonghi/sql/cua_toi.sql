-- name: CuaToi :one
WITH page AS (
 SELECT m.id, jsonb_build_object(
 'leave_notice_id', m.id, 'person_id', m.person_id, 'person_name', p.display_name,
 'leave_date', to_char(m.leave_date, 'YYYY-MM-DD'),
 'notice_kind', CASE WHEN m.leave_date - (m.created_at AT TIME ZONE 'Asia/Ho_Chi_Minh')::date >= 3 THEN 'bao_truoc' ELSE 'dot_xuat' END,
 'created_at', m.created_at, 'acknowledged_at', m.acknowledged_at,
 'acknowledged_by_person_id', m.acknowledged_by_person_id, 'cancelled_at', m.cancelled_at,
 'cancelled_by_person_id', m.cancelled_by_person_id,
 'can_cancel', m.cancelled_at IS NULL AND ((SELECT is_owner FROM person WHERE id = actor_person_id())
 OR (m.person_id = actor_person_id() AND (now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date < m.leave_date))) AS notice
 FROM leave_notice m JOIN person p ON p.id = m.person_id
 WHERE m.person_id = actor_person_id() AND ($2::bigint = 0 OR m.id < $2)
 ORDER BY m.id DESC LIMIT $1::integer + 1
), visible AS (SELECT id, notice FROM page ORDER BY id DESC LIMIT $1::integer)
SELECT jsonb_build_object('leave_notices', coalesce((SELECT jsonb_agg(notice ORDER BY id DESC) FROM visible), '[]'::jsonb),
 'next_before_id', CASE WHEN (SELECT count(*) FROM page) > $1::integer THEN (SELECT min(id) FROM visible) END,
 'read_at', now())::jsonb AS result;
