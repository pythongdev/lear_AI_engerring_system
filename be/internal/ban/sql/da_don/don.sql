UPDATE table_session_member SET cleaned_at = now() WHERE id = ANY($1::bigint[])
