#!/usr/bin/env perl
# T-236 — chỉ cho máy dev, KHÔNG phải sự thật của quán. Chạy sau make seed.
# Đọc nhóm §4.9 qua seed.pl để dùng chung ánh xạ tên dòng menu.
# Combo gồm hai món có giá gốc dương đầu tiên theo id; giá = tổng giá gốc
# món lẻ (chưa chọn tuỳ chọn), tính từ thành phần trong database bằng SQL.
# Lượng sổ, tiền khoản chi và ngày công là SỐ MINH HOẠ; tên tự đặt có (thử).
# Dùng ngày hiện tại của TimeZone kết nối (Makefile/db-check đặt PGTZ).
# Không đổi đồng hồ, tắt trigger hay mở khoá: lỗi ghi sẽ dừng và rollback cả bộ.
use strict;
use warnings;
use utf8;
use open qw(:std :encoding(UTF-8));

my $facts = $ENV{SHOP_FACTS} // 'master_plan/shop-facts.md';
sub fail { die "du-lieu-thu.pl: $_[0] ($facts)\n" }
sub sqlq { my $s = shift; $s =~ s/'/''/g; return "'$s'" }
# Gọi bằng danh sách đối số, không qua shell; SHOP_FACTS được kế thừa để thử owner hỏng.
use FindBin qw($Bin);
open my $seed, '-|', $^X, "$Bin/seed.pl", '--menu-groups-tsv'
    or fail('không chạy được seed.pl');
my (%mapping, %seen, @categories);
while (my $line = <$seed>) {
    chomp $line;
    my ($name, $category) = split /\t/, $line, -1;
    fail('§4.9: dòng thiếu tên món hoặc nhóm')
        unless defined $category && length $name && length $category;
    fail("§4.9: món lặp '$name'") if exists $mapping{$name};
    $mapping{$name} = $category;
    push @categories, $category unless $seen{$category}++;
}
close $seed or fail('seed.pl không đọc được nhóm menu');
fail('§4.9: không thấy nhóm menu') unless @categories;
# Đọc/kiểm hết owner trước khi in bất kỳ SQL nào.
print <<'SQL';
-- Dữ liệu thử máy dev T-236; không phải dữ kiện quán.
BEGIN;
SET LOCAL ROLE shop_app;
DO $trial$
DECLARE
  owner_id bigint;
  worker_id bigint;
  task_id bigint;
  combo_id bigint;
  item_categories jsonb;
  combo_item_ids bigint[];
  combo_price bigint;
  today date := (now() AT TIME ZONE current_setting('TimeZone'))::date;
BEGIN
  -- Khoá trong giao dịch để hai lượt dựng đồng thời không cùng vượt dấu hiệu.
  PERFORM pg_advisory_xact_lock(hashtext('seed-thu:T-236'));
  IF EXISTS (SELECT 1 FROM menu_category) THEN
    RAISE NOTICE 'seed-thu: đã có danh mục — bỏ qua';
    RETURN;
  END IF;
  -- Máy dev có thể có thêm chủ quán tạo theo tai-khoan-dev.md: lấy người đầu tiên.
  SELECT id INTO STRICT owner_id FROM person WHERE is_owner ORDER BY id LIMIT 1;
  PERFORM set_config('shop.actor_person_id', owner_id::text, true);
  PERFORM set_config('shop.revision_reason', 'Dựng dữ liệu máy dev (thử)', true);
  SELECT id INTO STRICT worker_id FROM person WHERE NOT is_owner ORDER BY id LIMIT 1;
  -- Biến trong khối DO: shop_app không cần quyền TEMP.
SQL
print "  SELECT jsonb_object_agg(item_name, category_name) INTO item_categories\n";
print "  FROM (VALUES\n";
print join(",\n", map { '    (' . sqlq($_) . ', ' . sqlq($mapping{$_}) . ')' } sort keys %mapping),
    "\n  ) AS mapping(item_name, category_name);\n";
print '  INSERT INTO menu_category (name) VALUES ',
    join(', ', map { '(' . sqlq($_) . ')' } @categories), ";\n";
print <<'SQL';
  -- Không âm thầm bỏ món khi database và owner lệch nhau.
  IF NOT EXISTS (SELECT 1 FROM menu_item WHERE discontinued_at IS NULL)
     OR EXISTS (
       SELECT 1 FROM menu_item i WHERE i.discontinued_at IS NULL
       AND item_categories ->> i.name IS NULL)
     OR EXISTS (
       SELECT 1 FROM jsonb_object_keys(item_categories) AS names(name)
       WHERE NOT EXISTS (SELECT 1 FROM menu_item i WHERE i.name = names.name
                         AND i.discontinued_at IS NULL)) THEN
    RAISE EXCEPTION 'seed-thu: menu rỗng hoặc tên món không khớp owner §4.9';
  END IF;
  INSERT INTO menu_item_category (menu_item_id, menu_category_id)
  SELECT i.id, cat.id FROM menu_item i
  JOIN menu_category cat ON cat.name = item_categories ->> i.name
  WHERE i.discontinued_at IS NULL;

  SELECT array_agg(chosen.id ORDER BY chosen.id), sum(chosen.price_vnd)
    INTO combo_item_ids, combo_price
  FROM (
    SELECT i.id, sum(ic.quantity * c.base_price_vnd)::bigint AS price_vnd
    FROM menu_item i
    JOIN menu_item_component ic ON ic.menu_item_id = i.id
    JOIN menu_component c ON c.id = ic.menu_component_id
    WHERE i.discontinued_at IS NULL
    GROUP BY i.id HAVING sum(ic.quantity * c.base_price_vnd) > 0
    ORDER BY i.id LIMIT 2
  ) chosen;
  IF coalesce(cardinality(combo_item_ids), 0) <> 2 THEN
    RAISE EXCEPTION 'seed-thu: cần hai món có giá gốc dương';
  END IF;
  INSERT INTO menu_combo (name, price_vnd)
    VALUES ('Combo ghép món (thử)', combo_price)
    RETURNING id INTO combo_id;
  INSERT INTO menu_combo_item (menu_combo_id, menu_item_id, quantity)
    SELECT combo_id, item_id, 1 FROM unnest(combo_item_ids) AS items(item_id);

  INSERT INTO assigned_task (content, assignee_person_id)
    VALUES ('Chuẩn bị khu vực làm việc (thử)', worker_id) RETURNING id INTO task_id;
  INSERT INTO assigned_task_guide (assigned_task_id, guide_kind_code, body)
    VALUES (task_id, 'text', 'Kiểm tra và sắp xếp dụng cụ trước ca (thử)');
  INSERT INTO training_record (trainee_person_id, remark, rating_code)
    VALUES (worker_id, 'Thực hành sắp xếp dụng cụ (thử)', 'pass');

  -- Số tiền và số lượng dưới đây chỉ là số minh hoạ, không phải giá menu.
  -- expense và supply_day_entry không có cột ghi chú; không tự thêm cột.
  INSERT INTO expense (expense_category_id, amount_vnd, paid_date)
    SELECT id, 12345, today FROM expense_category ORDER BY id LIMIT 1;
  IF NOT FOUND THEN RAISE EXCEPTION 'seed-thu: thiếu loại chi từ make seed'; END IF;
  INSERT INTO supply_day_entry (supply_item_id, entry_date, kind_code, entered_measure)
    SELECT s.id, today, v.kind, v.amount
    FROM (SELECT id FROM supply_item ORDER BY id LIMIT 1) s
    CROSS JOIN (VALUES ('purchased', 10), ('used', 3)) v(kind, amount);
  IF NOT FOUND THEN RAISE EXCEPTION 'seed-thu: thiếu nguyên liệu từ make seed'; END IF;
  -- Một ngày công minh hoạ, không phải ghi nhận người thực sự đi làm.
  INSERT INTO attendance_day (worker_person_id, work_date) VALUES (worker_id, today);
  RAISE NOTICE 'seed-thu: đã dựng dữ liệu (thử)';
END
$trial$;
COMMIT;
SQL
