-- Phần dùng chung của bộ đối chiếu (P2-11, docs/product/2-db/09-doi-chieu-bat-bien.md) —
-- scripts/reconcile.sh nạp file này MỘT lần mỗi lần chạy, trước mọi câu. Chỉ bảng tạm và hàm tạm:
-- chạy xong không để lại gì trong database.

-- Ba bảng tạm điền lúc chạy từ owner — không chép một mã nào vào đây (work/findings.md F-001):
--   dc_transition  cặp (nguồn, đích) hợp lệ của ba vòng đời — 05-vong-doi.md §5.2 · §5.3 · §5.4,
--                  đổi tên sang mã qua bảng ánh xạ QD-40 của file lát (I-016);
--   dc_owner_code  mã kênh (shop-facts.md §2) và mã trạm (§3) — QD-02;
--   dc_status_map  mã trạng thái theo bảng ánh xạ QD-40 của file lát — QD-40(b).
CREATE TEMP TABLE dc_transition (table_name text, from_code text, to_code text);
CREATE TEMP TABLE dc_owner_code (column_name text, code text);
CREATE TEMP TABLE dc_status_map (table_name text, code text);

-- Giá trị một cột tiền của một dòng menu CÓ HIỆU LỰC tại mốc p_t: bản trước của lần sửa đầu tiên
-- sau p_t có đổi cột ấy (vết cập nhật, I-018), hoặc giá trị hiện hành nếu từ p_t tới nay không
-- lần sửa nào đổi nó. Lần sửa không khai lý do không để lại vết (chế độ mềm, work/findings.md
-- F-046) — với nó, hàm đọc giá hiện hành, và câu dùng hàm sẽ kêu ở dòng cũ.
CREATE FUNCTION pg_temp.gia_tai(p_bang text, p_id bigint, p_cot text, p_hien_hanh bigint,
                                p_t timestamptz) RETURNS bigint LANGUAGE sql STABLE AS $f$
  SELECT coalesce(
    (SELECT (r.before_image ->> p_cot)::bigint
     FROM record_revision r
     WHERE r.target_table_code = p_bang AND r.target_row = p_id AND r.revised_at > p_t
       AND r.before_image -> p_cot IS DISTINCT FROM r.after_image -> p_cot
     ORDER BY r.revised_at, r.id LIMIT 1),
    p_hien_hanh)
$f$;

-- Giá MỘT suất của một dòng đơn theo mức có hiệu lực tại mốc khoá giá của chính dòng ấy
-- (shop-facts.md §4.6 luật 1 · 5): Σ số lượng × giá gốc + (số phần nhận nhân) × Σ phụ thu đã
-- chọn. Thành phần và số lượng đọc từ ảnh chụp của dòng — thứ đã khoá; giá đọc từ menu tại mốc.
CREATE FUNCTION pg_temp.gia_dong_tai(p_dong bigint) RETURNS bigint LANGUAGE sql STABLE AS $f$
  SELECT (SELECT sum(c.quantity * pg_temp.gia_tai('menu_component', c.menu_component_id,
                                                  'base_price_vnd', mc.base_price_vnd, l.priced_at))
          FROM order_line_component c JOIN menu_component mc ON mc.id = c.menu_component_id
          WHERE c.order_line_id = l.id)
       + (SELECT coalesce(sum(c.quantity), 0) FROM order_line_component c
          WHERE c.order_line_id = l.id AND c.takes_filling)
       * (SELECT coalesce(sum(pg_temp.gia_tai('menu_option', x.menu_option_id, 'surcharge_vnd',
                                              mo.surcharge_vnd, l.priced_at)), 0)
          FROM order_line_option x JOIN menu_option mo ON mo.id = x.menu_option_id
          WHERE x.order_line_id = l.id)
  FROM order_line l WHERE l.id = p_dong
$f$;

-- Khoá gom của một đơn vị việc trạm (03-lat-cat.md §3.4.6): trạm + thành phần GỐC + tập MÃ tuỳ
-- chọn nhân của dòng khi thành phần nhận nhân. Nước chấm là việc cấp đơn, không thành phần nào.
CREATE FUNCTION pg_temp.khoa_gom(p_viec bigint) RETURNS text LANGUAGE sql STABLE AS $f$
  SELECT j.station_code || '/' || coalesce(c.menu_component_id::text, 'nuoc_cham') || '/' ||
         CASE WHEN c.takes_filling THEN
           coalesce((SELECT string_agg(x.menu_option_id::text, ',' ORDER BY x.menu_option_id)
                     FROM order_line_option x WHERE x.order_line_id = j.order_line_id), '')
         ELSE '' END
  FROM station_job j LEFT JOIN order_line_component c ON c.id = j.order_line_component_id
  WHERE j.id = p_viec
$f$;

-- Bảng trạm của một thành phần tại lúc đơn nổ: dòng tạo sau lần nổ không áp cho đơn ấy. Không dòng
-- nào bị xoá (QD-50), nên "có hiệu lực lúc nổ" = "đã tạo trước lúc nổ" (05-luoc-do-san-xuat.md §5).
CREATE FUNCTION pg_temp.luc_no(p_don bigint) RETURNS timestamptz LANGUAGE sql STABLE AS $f$
  SELECT coalesce(min(created_at), now()) FROM station_job WHERE sales_order_id = p_don
$f$;

-- Chuỗi vết đứt (P2A-07): chỉ đọc dòng đã có vết; thứ tự toàn phần là revised_at, id.
-- Không có vết thì không suy ra được lần sửa mất vết (F-046, file 09 §4).
-- So theo GIÁ TRỊ của dòng, không theo chữ của ảnh: mỗi ảnh đổi về đúng kiểu dòng của bảng bằng
-- jsonb_populate_record. Ảnh jsonb in timestamptz theo múi giờ của phiên GHI, nên so chữ thì một
-- phiên đọc đặt múi giờ khác làm mọi dòng có vết kêu oan.
CREATE FUNCTION pg_temp.chuoi_vet_dut(p_bang text, p_hien_tai anyelement)
RETURNS boolean LANGUAGE sql STABLE AS $f$
  WITH vet AS (
    SELECT jsonb_populate_record(p_hien_tai, before_image) AS ban_truoc,
           jsonb_populate_record(p_hien_tai, after_image) AS ban_sau,
           jsonb_populate_record(p_hien_tai, lag(after_image) OVER (ORDER BY revised_at, id))
             AS ban_sau_truoc,
           row_number() OVER (ORDER BY revised_at, id) AS thu_tu,
           row_number() OVER (ORDER BY revised_at DESC, id DESC) AS tu_cuoi
    FROM record_revision
    WHERE target_table_code = p_bang AND target_row = (to_jsonb(p_hien_tai) ->> 'id')::bigint
  )
  SELECT EXISTS (
    SELECT 1 FROM vet
    WHERE (tu_cuoi = 1 AND ban_sau IS DISTINCT FROM p_hien_tai)
       OR (thu_tu > 1 AND ban_truoc IS DISTINCT FROM ban_sau_truoc)
  )
$f$;
