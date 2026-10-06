#!/usr/bin/env perl
# P2-10 — dữ liệu mồi: menu thật, bàn, trạm của thành phần; người theo vai (P2-08). Ý định, lý do và chỗ trống:
# docs/product/2-db/08-du-lieu-moi.md.
#
# File này KHÔNG mang một con giá, một phụ thu, một số lượng thành phần hay số bàn nào của
# quán: nó ĐỌC master_plan/shop-facts.md lúc chạy (ADR-001, work/findings.md F-001) và in ra
# SQL. Cái duy nhất nó giữ là bảng %MENU dưới đây — tên gọi, không con số — và bảng ấy được
# đối chiếu hai chiều với §4.9 mỗi lần chạy.
#
#   perl db/seed/seed.pl                 # SQL dựng dữ liệu mồi (vai shop_app, một giao dịch)
#   perl db/seed/seed.pl --supply-names  # tên hàng mua vào sẽ chèn, mỗi dòng một tên
#   perl db/seed/seed.pl --price-cases   # SQL tính lại các ca giá của §4.8 từ database
#   perl db/seed/seed.pl --price-cases-tsv  # các ca §4.8 cho test cửa giá của pha 3 (P3-06), mỗi dòng:
#        số ca <TAB> dòng menu <TAB> số suất <TAB> nhóm=lựa chọn|… <TAB> giá kỳ vọng hoặc REJECT
#
# Owner đổi hình mà script không đọc được ⇒ in lỗi ra stderr, exit 1, không in nửa bộ SQL.
use strict;
use warnings;
use utf8;
use open qw(:std :encoding(UTF-8));

# SHOP_FACTS chỉ để thử bộ dựng biết kêu trên một bản sao hỏng; mặc định là owner.
my $FACTS = $ENV{SHOP_FACTS} // 'master_plan/shop-facts.md';

# Dòng menu của §4.9, theo tên chủ quán gọi (cột 2, phần trước " — ") ⇒
#   [tên dòng menu, dòng §4.5 (cột 1, bỏ ** và phần trong ngoặc), loại trứng, tên ở §4.8].
# Tên dòng menu là phiên chọn 2026-09-28 (08-du-lieu-moi.md §2). Thiếu hay thừa một dòng so
# với §4.9 ⇒ FAIL: menu thêm món thì dòng ấy phải được ánh xạ ở đây trước.
my %MENU = (
  'đầy đủ trứng chín' => ['Đầy đủ trứng chín', 'Combo "Đầy đủ"', 'chín', 'Combo Đầy đủ chín'],
  'đầy đủ trứng tái'  => ['Đầy đủ trứng tái',  'Combo "Đầy đủ"', 'tái',  'Combo Đầy đủ tái'],
  'đầy đủ trứng vàng' => ['Đầy đủ trứng vàng', 'Combo "Đầy đủ"', 'vàng', 'Combo Đầy đủ vàng'],
  'suất giò'          => ['Suất giò',          'Suất giò'],
  'suất trứng chín'   => ['Suất trứng chín',   'Suất trứng',     'chín'],
  'suất trứng tái'    => ['Suất trứng tái',    'Suất trứng',     'tái'],
  'suất trứng vàng'   => ['Suất trứng vàng',   'Suất trứng',     'vàng'],
  'bánh cuốn'         => ['Bánh cuốn',         'Suất bánh cuốn'],
  'giò'               => ['Giò bán rời',       'Giò bán rời'],
  'canh bánh cuốn'    => ['Canh bánh cuốn',    'Canh bánh cuốn'],
);

sub die_owner { print STDERR "seed.pl: $_[0] ($FACTS)\n"; exit 1 }

open my $fh, '<', $FACTS or die_owner("không mở được");
my @L = <$fh>;
close $fh;
chomp @L;

# Các dòng của mục có tiêu đề bắt đầu bằng $head, tới tiêu đề cùng cấp hoặc cao hơn kế tiếp.
sub section {
  my ($head) = @_;
  my ($lvl, @out, $on) = (0);
  for (@L) {
    if (/^(#+) /) {
      my $n = length $1;
      if ($on && $n <= $lvl) { last }
      if (index($_, $head) == 0) { $on = 1; $lvl = $n; next }
    }
    push @out, $_ if $on;
  }
  die_owner("không thấy mục '$head'") unless @out;
  return @out;
}

sub clean { my $s = shift; $s =~ s/\*\*?|⚠️|⚠//g; $s =~ s/^\s+|\s+$//g; return $s }
sub cells { my $r = shift; $r =~ s/^\s*\|//; $r =~ s/\|\s*$//; return map { clean($_) } split /\|/, $r }

# Bảng đầu tiên của mục có cột $want ở hàng tiêu đề ⇒ danh sách hash theo tên cột.
sub table {
  my ($want, @sec) = @_;
  for (my $i = 0; $i < @sec; $i++) {
    next unless $sec[$i] =~ /^\|/;
    my @h = cells($sec[$i]);
    unless (grep { $_ eq $want } @h) {
      $i++ while $i + 1 < @sec && $sec[$i + 1] =~ /^\|/;
      next;
    }
    my @rows;
    for (my $j = $i + 2; $j < @sec && $sec[$j] =~ /^\|/; $j++) {
      my @c = cells($sec[$j]);
      push @rows, { map { $h[$_] => $c[$_] } 0 .. $#h };
    }
    return @rows;
  }
  die_owner("không thấy bảng có cột '$want'");
}

sub money {
  my ($s, $where) = @_;
  $s = clean($s);
  $s =~ s/^\+//;
  $s =~ s/\.//g;
  die_owner("'$s' không phải một số tiền ($where)") unless $s =~ /^\d+$/;
  return $s + 0;
}

sub sqlq { my $s = shift; $s =~ s/'/''/g; return "'$s'" }

# --- §1: số bàn -------------------------------------------------------------------------
my ($tables) = map { /\|\s*Số bàn\s*\|\s*\**(\d+)\**/ ? $1 : () } section('## 1.');
die_owner('§1: không đọc được dòng "| Số bàn |"') unless $tables;

# --- §4.2: thành phần và giá ------------------------------------------------------------
# Một hàng một HỌ thành phần; "trứng chín / tái / vàng" là một họ ba thành phần cùng giá.
my (@fam, %comp);
for my $r (table('Thành phần', section('### 4.2 '))) {
  my ($cls, $rest) = $r->{'Thành phần'} =~ /^1 (\S+) (.+)$/
    or die_owner("§4.2: không đọc được thành phần '$r->{'Thành phần'}'");
  my @p = split m{ / }, $rest;
  my ($base, @var) = ($p[0]);
  if (@p > 1) { ($base, my $v0) = $p[0] =~ /^(\S+) (.+)$/; @var = ($v0, @p[1 .. $#p]) }
  my %pr = map { $_ => money($r->{$_}, "§4.2 $rest") } grep { /^(Chay|Thịt .+)$/ } keys %$r;
  die_owner("§4.2: thiếu cột Chay ở '$rest'") unless exists $pr{'Chay'};
  my $f = { base => $base, var => \@var, price => \%pr, sec => '§4.2' };
  $f->{takes} = (grep { $pr{$_} != $pr{'Chay'} } keys %pr) ? 1 : 0;
  $f->{names} = [ @var ? map { ucfirst("$base $_") } @var : ucfirst($base) ];
  $comp{$_} = $f for @{ $f->{names} };
  push @fam, $f;
}

# --- §4.4: nhóm tuỳ chọn, phụ thu cho MỖI phần nhận nhân (cột "Món lẻ") -------------------
my (@grp, %grp);
for my $r (table('Nhóm tuỳ chọn', section('### 4.4 '))) {
  my ($g) = $r->{'Nhóm tuỳ chọn'} =~ /^(.+?)\s*(\(|$)/;
  my @o = split m{ / }, $r->{'Lựa chọn'};
  my @s = map { money($_, "§4.4 $g") } split m{ / }, $r->{'Món lẻ'};
  die_owner("§4.4: nhóm '$g' có " . @o . ' lựa chọn mà ' . @s . ' mức phụ thu') if @o != @s;
  my $x = { name => $g, opt => [ map { [ $o[$_], $s[$_] ] } 0 .. $#o ] };
  # "(chỉ hiện khi nhân ≠ Chay)" ⇒ tập điều kiện = mọi lựa chọn của nhóm ấy trừ Chay (§4.6 luật 3).
  @{$x}{qw(req_group req_not)} = ($1, $2) if $r->{'Nhóm tuỳ chọn'} =~ /khi (\S+) ≠ ([^)]+)\)/;
  push @grp, $x;
  $grp{ lc $g } = $x;
}
for my $x (grep { $_->{req_group} } @grp) {
  my $ref = $grp{ lc $x->{req_group} } or die_owner("§4.4: '$x->{name}' trỏ tới nhóm lạ '$x->{req_group}'");
  $x->{req} = [ grep { $_ ne $x->{req_not} } map { $_->[0] } @{ $ref->{opt} } ];
  die_owner("§4.4: '$x->{req_not}' không phải lựa chọn của '$ref->{name}'")
    if @{ $x->{req} } == @{ $ref->{opt} };
}

# Ba cột giá §4.2 phải là giá chay + phụ thu §4.4 (§4.6 luật 2 · 5); lệch ⇒ hai owner cãi nhau.
{
  my ($fill) = grep { !$_->{req_group} } @grp;
  my ($lvl)  = grep { $_->{req_group} } @grp;
  die_owner('§4.4: cần một nhóm nhân và một nhóm phụ thuộc nó') unless $fill && $lvl;
  for my $f (@fam) {
    for my $col (grep { $_ ne 'Chay' } keys %{ $f->{price} }) {
      my ($w) = lc($col) =~ /^thịt (\S+)/;
      my ($lo) = grep { index(lc $_->[0], $w) == 0 } @{ $lvl->{opt} }
        or die_owner("§4.2 cột '$col' không ứng với lựa chọn nào của '$lvl->{name}'");
      for my $fo (grep { my $n = $_->[0]; grep { $_ eq $n } @{ $lvl->{req} } } @{ $fill->{opt} }) {
        my $want = $f->{price}{'Chay'} + ($f->{takes} ? $fo->[1] + $lo->[1] : 0);
        die_owner("§4.2 '$f->{base}' cột '$col' = $f->{price}{$col}, chay + phụ thu §4.4 ($fo->[0], $lo->[0]) = $want")
          if $f->{price}{$col} != $want;
      }
    }
  }
}

# Thành phần mang tên $name (cột "Bếp làm ra" §4.5, hay một dòng §5.3) thuộc họ nào.
sub family_of {
  my ($name) = @_;
  $name = lc $name;
  for my $f (@fam) {
    return ($f, undef) if $name eq $f->{base} || index($f->{base}, "$name ") == 0;
    for my $v (@{ $f->{var} }) { return ($f, $v) if $name eq "$f->{base} $v" }
  }
  return;
}

# --- §4.5: thành phần của từng suất -------------------------------------------------------
my %recipe;
for my $r (table('Bếp làm ra', section('### 4.5 '))) {
  (my $k = $r->{'Suất bán'}) =~ s/\s*\(.*\)\s*$//;
  for my $part (split / \+ /, $r->{'Bếp làm ra'}) {
    my ($n, $name) = $part =~ /^(\d+) \S+ (.+)$/ or die_owner("§4.5 '$k': không đọc được '$part'");
    my ($f) = family_of($name) or die_owner("§4.5 '$k': '$name' không là thành phần nào của §4.2");
    push @{ $recipe{$k} }, [ $n + 0, $f ];
  }
}

# --- §4.9: dòng menu — đối chiếu hai chiều với %MENU --------------------------------------
my @items;
{
  my %seen;
  for my $r (table('Chủ quán gọi tên', section('### 4.9 '))) {
    (my $k = lc $r->{'Chủ quán gọi tên'}) =~ s/\*//g;
    $k =~ s/\s+—.*$//;
    $k =~ s/^\s+|\s+$//g;
    my $m = $MENU{$k} or die_owner("§4.9 dòng '$k' chưa có trong %MENU của db/seed/seed.pl");
    my $rows = $recipe{ $m->[1] } or die_owner("§4.9 '$k': §4.5 không có dòng '$m->[1]'");
    my @parts;
    for (@$rows) {
      my ($n, $f) = @$_;
      my $c = @{ $f->{var} }
        ? do {
            my $v = $m->[2] // die_owner("§4.9 '$k': '$f->{base}' có loại mà dòng menu không nói loại nào");
            grep({ $_ eq $v } @{ $f->{var} }) or die_owner("§4.9 '$k': '$f->{base}' không có loại '$v' ở §4.2");
            ucfirst("$f->{base} $v");
          }
        : $f->{names}[0];
      push @parts, [ $c, $n ];
    }
    push @items, { name => $m->[0], alias => $m->[3] // $m->[0], parts => \@parts,
                   takes => (grep { $comp{ $_->[0] }{takes} } @parts) ? 1 : 0 };
    $seen{$k} = 1;
  }
  my @gone = grep { !$seen{$_} } sort keys %MENU;
  die_owner("%MENU có dòng mà §4.9 không còn: @gone") if @gone;
}

# --- §5.3: thành phần xuống trạm nào ------------------------------------------------------
my (%stations, @order_level);
{
  my $in;
  for (section('### 5.3 ')) {
    if (/^```/) { last if $in; $in = 1; next }
    next unless $in && /^\s*([a-z_]+)\s*│\s*(.+)$/;
    my ($st, $rest) = ($1, $2);
    my ($thing) = $rest =~ /^(.+?)(?:\s+×\d+|\s+—|\s+←|\s*$)/;
    my ($f) = family_of($thing);
    if (!$f) { push @order_level, "$st: $thing"; next }
    $stations{$_}{$st} = 1 for @{ $f->{names} };
  }
  for my $c (sort keys %comp) {
    die_owner("§5.3: thành phần '$c' không xuống trạm nào") unless $stations{$c};
  }
}

# --- §3: người theo vai (P2-08) -----------------------------------------------------------
# Một người cho mỗi vai của bảng "Vai", cộng chủ quán — vai riêng ngoài năm trạm. Tên hiển thị
# là TÊN VAI, không phải tên người: quán chưa khai tên ai (08-du-lieu-moi.md §4 hàng Người).
my @roles = map { $_->{'Vai'} } table('Vai', section('## 3.'));
die_owner("bảng Vai ở §3 rỗng") unless @roles;
die_owner("§3 không còn câu về chủ quán (`owner`)")
  unless grep { /Chủ quán \(`owner`\)/ } section('## 3.');

# --- §8.4: danh mục hàng mua vào ---------------------------------------------------------
my @supplies;
{
  my @sec = section('### 8.4 ');
  my ($paragraph, $on) = ('', 0);
  for (@sec) {
    $on = 1 if /^\*\*Danh mục nguyên liệu — chủ quán bắt đầu liệt kê 2026-09-06/;
    next unless $on;
    last if /^\s*$/;
    $paragraph .= ($paragraph eq '' ? '' : ' ') . $_;
  }
  my ($list) = $paragraph =~ /\*"([^"\n]+)"\*/;
  die_owner('§8.4: không đọc được danh sách 2026-09-06') unless defined $list;
  my %merged;
  for my $name (split /, /, $list, -1) {
    $name = clean($name);
    die_owner('§8.4: tên rỗng trong danh sách 2026-09-06') if $name eq '';
    my $key = lc $name;
    die_owner("§8.4: tên lặp trong danh sách 2026-09-06: '$name'") if exists $merged{$key};
    $merged{$key} = [ucfirst($name), undef];
  }
  my @rows = table('Hàng mua vào', @sec);
  die_owner('§8.4: bảng Hàng mua vào rỗng') unless @rows;
  my %seen;
  for my $r (@rows) {
    my $name = clean($r->{'Hàng mua vào'} // '');
    my $unit = clean($r->{'Đơn vị mua'} // '');
    $unit =~ s/\s*\([^()]*\)\s*$//;
    $unit = clean($unit);
    die_owner('§8.4: tên rỗng trong bảng Hàng mua vào') if $name eq '';
    die_owner("§8.4: Đơn vị mua rỗng ở '$name'") if $unit eq '';
    my $key = lc $name;
    die_owner("§8.4: tên lặp trong bảng Hàng mua vào: '$name'") if $seen{$key}++;
    $merged{$key} = [$name, $unit];
  }
  @supplies = map { $merged{$_} } sort keys %merged;
}

# --- in SQL -----------------------------------------------------------------------------
my $mode = $ARGV[0] // '';

if ($mode eq '--supply-names') { print "$_->[0]\n" for @supplies; exit 0 }
if ($mode eq '--price-cases') { price_cases(); exit 0 }
if ($mode eq '--price-cases-tsv') { price_cases_tsv(); exit 0 }
die "seed.pl: tham số lạ '$mode'\n" if $mode ne '';

print "-- Dữ liệu mồi P2-10, sinh từ $FACTS lúc chạy — không sửa tay, không lưu lại.\n";
print "-- Ý định: docs/product/2-db/08-du-lieu-moi.md.\n";
print "BEGIN;\nSET LOCAL ROLE shop_app;\n\n";

print "-- §3 người theo vai, cộng chủ quán; chủ quán là người thao tác của lượt dựng (U-062: chủ\n";
print "-- quán đổi mã QR). Mọi cột \"ai bấm\" đọc shop.actor_person_id (06-luoc-do-nguoi-va-vet.md §0).\n";
printf "INSERT INTO person (display_name) VALUES (%s);\n", sqlq($_) for @roles;
print "INSERT INTO person (display_name, is_owner) VALUES ('Chủ quán', true);\n";
print "SELECT set_config('shop.actor_person_id', id::text, true) FROM person WHERE is_owner;\n\n";

print "-- §1 Số bàn = $tables; tên bàn 1…$tables. Mã QR qua cửa duy nhất qr_code_issue (I-023).\n";
print "INSERT INTO dining_table (label) SELECT n::text FROM generate_series(1, $tables) n;\n";
print "SELECT count(qr_code_issue(id)) FROM dining_table;\n\n";

print "-- §4.2 thành phần: giá gốc là cột Chay (§4.6 luật 2); nhận nhân khi ba cột khác nhau.\n";
for my $f (@fam) {
  for my $c (@{ $f->{names} }) {
    printf "INSERT INTO menu_component (name, base_price_vnd, takes_filling) VALUES (%s, %d, %s);\n",
      sqlq($c), $f->{price}{'Chay'}, $f->{takes} ? 'true' : 'false';
  }
}

print "\n-- §4.4 nhóm tuỳ chọn; phụ thu cột Món lẻ = cho MỖI phần nhận nhân (§4.6 luật 5).\n";
for my $g (@grp) {
  printf "INSERT INTO option_group (name) VALUES (%s);\n", sqlq($g->{name});
  for (@{ $g->{opt} }) {
    printf "INSERT INTO menu_option (option_group_id, name, surcharge_vnd)"
      . " SELECT id, %s, %d FROM option_group WHERE name = %s;\n", sqlq($_->[0]), $_->[1], sqlq($g->{name});
  }
}
print "-- §4.4 / §4.6 luật 3: nhóm phụ thuộc chỉ có khi một lựa chọn trong tập được chọn.\n";
for my $g (grep { $_->{req} } @grp) {
  my $ref = $grp{ lc $g->{req_group} };
  for (@{ $g->{req} }) {
    printf "INSERT INTO option_group_prerequisite (option_group_id, menu_option_id)"
      . " SELECT g.id, o.id FROM option_group g, menu_option o JOIN option_group r ON r.id = o.option_group_id"
      . " WHERE g.name = %s AND r.name = %s AND o.name = %s;\n", sqlq($g->{name}), sqlq($ref->{name}), sqlq($_);
  }
}

print "\n-- §4.9 dòng menu · §4.5 thành phần suất · nhóm tuỳ chọn cho suất có phần nhận nhân (§4.8 ca 12).\n";
for my $it (@items) {
  printf "INSERT INTO menu_item (name) VALUES (%s);\n", sqlq($it->{name});
  for (@{ $it->{parts} }) {
    printf "INSERT INTO menu_item_component (menu_item_id, menu_component_id, quantity)"
      . " SELECT i.id, c.id, %d FROM menu_item i, menu_component c WHERE i.name = %s AND c.name = %s;\n",
      $_->[1], sqlq($it->{name}), sqlq($_->[0]);
  }
  next unless $it->{takes};
  for my $g (@grp) {
    printf "INSERT INTO menu_item_option_group (menu_item_id, option_group_id)"
      . " SELECT i.id, g.id FROM menu_item i, option_group g WHERE i.name = %s AND g.name = %s;\n",
      sqlq($it->{name}), sqlq($g->{name});
  }
}

print "\n-- §5.3 (ví dụ nổ đơn) · §3: thành phần xuống trạm nào.\n";
print "-- Việc cấp đơn, không thành phần nào: $_\n" for @order_level;
for my $c (sort keys %stations) {
  for my $st (sort keys %{ $stations{$c} }) {
    printf "INSERT INTO menu_component_station (menu_component_id, station_code)"
      . " SELECT id, %s FROM menu_component WHERE name = %s;\n", sqlq($st), sqlq($c);
  }
}

print "\n-- §8.4 danh mục hàng mua vào; chưa có đơn vị thì để NULL.\n";
for my $r (@supplies) {
  printf "INSERT INTO supply_item (name, purchase_unit) VALUES (%s, %s);\n",
    sqlq($r->[0]), defined $r->[1] ? sqlq($r->[1]) : 'NULL';
}

print "\nCOMMIT;\n";

# --- §4.8: các ca giá, tính lại từ database --------------------------------------------------
# Các ca §4.8 đã đọc: [số ca, dòng menu, số suất, [[nhóm, lựa chọn], …], giá kỳ vọng | undef = từ chối].
sub read_price_cases {
  my %by_alias = map { $_->{alias} => $_ } @items;
  my @out;
  for my $r (table('Giá kỳ vọng', section('### 4.8 '))) {
    my ($name, $qty) = ($r->{'Món'}, 1);
    $qty = $1 if $name =~ s/\s*×(\d+)\s*$//;
    my $it = $by_alias{$name} or die_owner("§4.8 ca $r->{'#'}: món '$name' không là dòng menu nào");
    my @sel;
    for my $g (@grp) {
      my $v = $r->{ $g->{name} } // die_owner("§4.8: không có cột '$g->{name}'");
      next if $v eq '—' || $v eq '';
      my ($o) = grep { lc $_->[0] eq lc $v } @{ $g->{opt} };
      ($o) = grep { index(lc $_->[0], lc $v) == 0 } @{ $g->{opt} } unless $o;
      $o or die_owner("§4.8 ca $r->{'#'}: '$v' không là lựa chọn của '$g->{name}'");
      push @sel, [ $g->{name}, $o->[0] ];
    }
    my $want = $r->{'Giá kỳ vọng'} =~ /TỪ CHỐI/ ? undef : money($r->{'Giá kỳ vọng'}, "§4.8 ca $r->{'#'}");
    push @out, [ $r->{'#'} + 0, $it->{name}, $qty, \@sel, $want ];
  }
  die_owner('§4.8: bảng ca giá rỗng') unless @out;
  return @out;
}

sub price_cases_tsv {
  for my $c (read_price_cases()) {
    my ($no, $item, $qty, $sel, $want) = @$c;
    print join("\t", $no, $item, $qty, join('|', map { "$_->[0]=$_->[1]" } @$sel), $want // 'REJECT'), "\n";
  }
}

sub price_cases {
  my @case = map {
    my ($no, $item, $qty, $sel, $want) = @$_;
    sprintf "(%d, %s, %d, ARRAY[%s]::text[], ARRAY[%s]::text[], %s)",
      $no, sqlq($item), $qty,
      join(', ', map { sqlq($_->[0]) } @$sel), join(', ', map { sqlq($_->[1]) } @$sel), $want // 'NULL';
  } read_price_cases();
  print <<'SQL';
-- §4.8 tính lại từ dữ liệu mồi. Phép tính CHỈ để chứng minh dữ liệu đủ — hàm tính giá là của pha 3.
-- Giá một suất = Σ số lượng × giá gốc + (số phần nhận nhân) × Σ phụ thu đã chọn (§4.6 luật 1 · 5).
-- Không hợp lệ (NULL) khi một lựa chọn thuộc nhóm suất không mang, hay nhóm có điều kiện mà
-- không lựa chọn nào trong tập điều kiện được chọn (§4.6 luật 3).
CREATE FUNCTION pg_temp.seed_price(p_item text, p_groups text[], p_opts text[]) RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE it bigint; sel bigint[]; bad int; base bigint; n_fill bigint; sur bigint;
BEGIN
  SELECT id INTO STRICT it FROM menu_item WHERE name = p_item;
  SELECT coalesce(array_agg(o.id), '{}') INTO sel
    FROM unnest(p_groups, p_opts) u(g, o)
    JOIN option_group og ON og.name = u.g
    JOIN menu_option o ON o.option_group_id = og.id AND o.name = u.o;
  IF cardinality(sel) <> cardinality(p_opts) THEN RAISE EXCEPTION 'lựa chọn không có trong dữ liệu: %', p_opts; END IF;
  SELECT count(*) INTO bad FROM menu_option o
   WHERE o.id = ANY (sel)
     AND (NOT EXISTS (SELECT 1 FROM menu_item_option_group m
                       WHERE m.menu_item_id = it AND m.option_group_id = o.option_group_id)
          OR (EXISTS (SELECT 1 FROM option_group_prerequisite p WHERE p.option_group_id = o.option_group_id)
              AND NOT EXISTS (SELECT 1 FROM option_group_prerequisite p
                               WHERE p.option_group_id = o.option_group_id AND p.menu_option_id = ANY (sel))));
  IF bad > 0 THEN RETURN NULL; END IF;
  SELECT sum(mic.quantity * c.base_price_vnd), coalesce(sum(mic.quantity) FILTER (WHERE c.takes_filling), 0)
    INTO base, n_fill
    FROM menu_item_component mic JOIN menu_component c ON c.id = mic.menu_component_id
   WHERE mic.menu_item_id = it;
  SELECT coalesce(sum(surcharge_vnd), 0) INTO sur FROM menu_option WHERE id = ANY (sel);
  RETURN base + n_fill * sur;
END $$;

DO $$
DECLARE r record; got bigint; bad int := 0; n int := 0;
BEGIN
  FOR r IN SELECT * FROM (VALUES
SQL
  print '    ', join(",\n    ", @case), "\n";
  print <<'SQL';
  ) v(no, item, qty, groups, opts, want) ORDER BY no LOOP
    n := n + 1;
    got := pg_temp.seed_price(r.item, r.groups, r.opts) * r.qty;
    IF got IS NOT DISTINCT FROM r.want THEN
      RAISE NOTICE 'ca % khớp: % ×% [%] ⇒ %', r.no, r.item, r.qty, array_to_string(r.opts, ' · '),
        coalesce(got::text || 'đ', 'TỪ CHỐI');
    ELSE
      bad := bad + 1;
      RAISE NOTICE 'ca % LỆCH: % ×% [%] ⇒ tính ra %, §4.8 đòi %', r.no, r.item, r.qty,
        array_to_string(r.opts, ' · '), coalesce(got::text, 'TỪ CHỐI'), coalesce(r.want::text, 'TỪ CHỐI');
    END IF;
  END LOOP;
  IF bad > 0 THEN RAISE EXCEPTION '§4.8: % / % ca lệch', bad, n; END IF;
  RAISE NOTICE '§4.8: % / % ca khớp từng đồng', n, n;
END $$;
SQL
}
