-- Combo, các món và mức phụ thu theo món của nó, đọc tại CÙNG mốc với menu (ADR-117 điểm 4): dòng tạo sau mốc chưa
-- có; có vết sau mốc thì dùng bản trước của vết sớm nhất — như doc_mon.sql.
-- name: DocCombo :one
WITH vet AS MATERIALIZED (
 SELECT DISTINCT ON (r.target_table_code, r.target_row) r.target_table_code, r.target_row, r.before_image
 FROM record_revision r
 WHERE r.revised_at > COALESCE($2::timestamptz, now())
   AND r.target_table_code IN ('menu_combo', 'menu_combo_item', 'menu_combo_item_option_surcharge')
 ORDER BY r.target_table_code, r.target_row, r.revised_at, r.id
),
combo_tai_moc AS (
 SELECT (COALESCE(v.before_image, to_jsonb(goc))->>'id')::bigint AS id,
 (COALESCE(v.before_image, to_jsonb(goc))->>'name')::text AS name,
 (COALESCE(v.before_image, to_jsonb(goc))->>'price_vnd')::bigint AS price_vnd,
 (COALESCE(v.before_image, to_jsonb(goc))->>'hidden_at')::timestamptz AS hidden_at
 FROM menu_combo goc
 LEFT JOIN vet v ON v.target_table_code = 'menu_combo' AND v.target_row = goc.id
 WHERE goc.created_at <= COALESCE($2::timestamptz, now())
),
mon_tai_moc AS (
 SELECT (COALESCE(v.before_image, to_jsonb(goc))->>'id')::bigint AS id,
 (COALESCE(v.before_image, to_jsonb(goc))->>'menu_combo_id')::bigint AS menu_combo_id,
 (COALESCE(v.before_image, to_jsonb(goc))->>'menu_item_id')::bigint AS menu_item_id,
 (COALESCE(v.before_image, to_jsonb(goc))->>'quantity')::integer AS quantity
 FROM menu_combo_item goc
 LEFT JOIN vet v ON v.target_table_code = 'menu_combo_item' AND v.target_row = goc.id
 WHERE goc.created_at <= COALESCE($2::timestamptz, now())
),
muc_tai_moc AS (
 SELECT (COALESCE(v.before_image, to_jsonb(goc))->>'menu_combo_item_id')::bigint AS menu_combo_item_id,
 (COALESCE(v.before_image, to_jsonb(goc))->>'menu_option_id')::bigint AS menu_option_id,
 (COALESCE(v.before_image, to_jsonb(goc))->>'surcharge_vnd')::bigint AS surcharge_vnd
 FROM menu_combo_item_option_surcharge goc
 LEFT JOIN vet v ON v.target_table_code = 'menu_combo_item_option_surcharge' AND v.target_row = goc.id
 WHERE goc.created_at <= COALESCE($2::timestamptz, now())
)
SELECT c.name, c.price_vnd, COALESCE(c.hidden_at <= COALESCE($2::timestamptz, now()), false)::boolean AS an,
 (SELECT COALESCE(jsonb_agg(jsonb_build_object('menu_item_id', x.menu_item_id, 'quantity', x.quantity) ORDER BY x.id),
  '[]'::jsonb) FROM mon_tai_moc x WHERE x.menu_combo_id = c.id)::jsonb AS mon,
 (SELECT COALESCE(jsonb_agg(jsonb_build_object('menu_item_id', x.menu_item_id, 'menu_option_id', s.menu_option_id,
  'surcharge_vnd', s.surcharge_vnd)), '[]'::jsonb)
  FROM muc_tai_moc s JOIN mon_tai_moc x ON x.id = s.menu_combo_item_id WHERE x.menu_combo_id = c.id)::jsonb AS muc
FROM combo_tai_moc c WHERE c.id = $1::bigint;
