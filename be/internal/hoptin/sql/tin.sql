-- name: Tin :one
SELECT jsonb_build_object('station_message_id', m.id, 'sender_person_id', m.sender_person_id,
'sender_name', s.display_name, 'recipient_person_id', m.recipient_person_id, 'recipient_name', r.display_name,
'work_code', m.work_code, 'body', m.body, 'dining_table_id', m.dining_table_id,
'reply_to_message_id', m.reply_to_message_id, 'created_at', m.created_at)::jsonb AS result FROM station_message m
JOIN person s ON s.id = m.sender_person_id LEFT JOIN person r ON r.id = m.recipient_person_id WHERE m.id = $1;
