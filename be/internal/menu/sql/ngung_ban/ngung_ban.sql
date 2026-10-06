-- Cửa menu/ngung_ban (P3-06, lớp chu_quan); đã khoá dòng và kiểm mốc trước khi ghi.
UPDATE menu_item SET discontinued_at = now() WHERE id = $1
RETURNING id, to_char(discontinued_at, 'YYYY-MM-DD"T"HH24:MI:SS.USTZH:TZM')
