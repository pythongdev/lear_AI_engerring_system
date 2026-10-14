WITH a AS (
 INSERT INTO shop.account (username,email,requested_display_name,status,person_id,role_code,decided_at,decided_by_person_id)
 SELECT 'test.'||id,'test.'||id||'@session.test',display_name,'hoat_dong',id,
        CASE WHEN is_owner THEN 'owner' ELSE 'quay' END,now(),id
 FROM shop.person WHERE id=$1
 ON CONFLICT (person_id) DO NOTHING RETURNING id
), existing AS (
 SELECT id FROM shop.account WHERE person_id=$1 UNION ALL SELECT id FROM a
), pw AS (
 INSERT INTO shop.account_password (account_id,password_hash)
 SELECT id,'$argon2id$test-only' FROM existing
 WHERE NOT EXISTS (SELECT 1 FROM shop.account_password WHERE account_id=existing.id)
)
INSERT INTO shop.login_session (account_id,token_hash,expires_at)
SELECT id,$2,now()+interval '7 days' FROM existing;
