#!/usr/bin/env bash
# Gate 1f — liệt kê ô ghi → cửa (ADR-082 điểm 3, ADR-083, QC-13).
# VÌ SAO CÓ: mỗi ô đúng một cửa phải có máy chấm, chạy cả lượt chỉ đổi tài liệu.
# ĐỌC GÌ: mọi .go (trừ _test.go), .sql dưới be/; cửa là internal/<gói>/sql/<cửa>/,
#   tên gói/cửa [a-z][a-z0-9_]*. SQL bỏ --, /* */ và chuỗi đơn, giữ số dòng;
#   Go đọc cả file để bắt chuỗi ghi nhiều dòng. INSERT là ô thêm; UPDATE/ON
#   CONFLICT là ô sửa từng cột SET, kể cả bộ (a,b), tách ở ngoặc ngoài cùng.
#   *.up.sql theo tên: CREATE/DROP/RENAME xác định bảng còn tồn tại; bảng được
#   ghi trong thân hàm $$ thuộc migration; REVOKE INSERT/UPDATE FROM shop_app
#   giữ riêng loại ghi ấy. --list in bảng<TAB>loại<TAB>cột hoặc -<TAB>gói/cửa.
# ĐỎ KHI NÀO: hai cửa chung ô, tên cửa sai, câu ghi ngoài cửa, bảng đích không
#   nhận ra, SET không đọc ra cột, ghi ô thuộc migration; DELETE/TRUNCATE/MERGE/
#   COPY không có ô. Mỗi lỗi một dòng có file và dòng khi xác định được.
# KHÔNG BẮT: SQL động ghép từ nhiều chuỗi; không phân tích ngữ nghĩa Go, không
#   chứng minh quyền hay giao dịch. Không kiểm cột có trong schema hay không.
#   Bỏ file Go test và SQL testdata ngoài cửa; SELECT FOR UPDATE là câu đọc.
#   Đây là bộ đọc khuôn QC-13, không phải trình phân tích toàn bộ PostgreSQL.
#   WRITE_PATHS_BE_DIR / WRITE_PATHS_MIG_DIR đổi thư mục cho test; mặc định từ
#   gốc repo là be / db/migrations. Không cần database hoặc Go.
# EXIT: 0 = đạt hoặc chưa có be/ (skipping); 1 = lỗi đọc hoặc vi phạm.
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 1
cd "$ROOT" || exit 1
BE_DIR="${WRITE_PATHS_BE_DIR:-be}"
MIG_DIR="${WRITE_PATHS_MIG_DIR:-db/migrations}"
if [ ! -d "$BE_DIR" ]; then
  echo "check-write-paths: không có be/, skipping"
  exit 0
fi
perl - "$BE_DIR" "$MIG_DIR" "${1:-}" <<'PERL'
use strict;
use warnings;
use utf8;
use File::Find;
binmode STDOUT, ':encoding(UTF-8)';
my ($be, $mig, $flag) = @ARGV;
$be =~ s{/+$}{};
my (%tables, %owned, %cells, %doors);
my ($failed, $files) = (0, 0);
my $id = qr/[a-z_][a-z0-9_]*/i;
my $target = qr/$id(?:\s*\.\s*$id)?/;
sub read_file {
    my ($f) = @_;
    open my $h, '<:encoding(UTF-8)', $f or die "$f: $!\n";
    local $/; return <$h> // '';
}
sub blank { my $s = shift; $s =~ s/[^\n]/ /g; return $s; }
# Một lượt theo thứ tự token: dấu chú thích trong chuỗi không mở chú thích.
sub clean {
    my $s = shift;
    $s =~ s{--[^\n]*|/\*(?:[^*/]|/(?!\*)|\*(?!/)|(?R))*\*/|'(?:''|[^'])*'}{blank($&)}gse;
    return $s;
}
sub table_name { my $t = lc shift; $t =~ s/\s//g; $t =~ s/^shop\.//; return $t; }
sub error_at { my ($f, $line, $msg) = @_; print "$f:$line: $msg\n"; $failed = 1; }
sub line_at { my ($s, $at) = @_; return 1 + (substr($s, 0, $at) =~ tr/\n/\n/); }
my @migrations;
if (-d $mig) {
    opendir my $dh, $mig or die "$mig: $!\n";
    @migrations = map { "$mig/$_" } sort grep { /\.up\.sql$/ } readdir $dh;
    closedir $dh;
}
for my $f (@migrations) {
    my $s = clean(read_file($f));
    # Đọc sự kiện theo đúng vị trí, kể cả thu hồi quyền rồi đổi tên trong một file.
    while ($s =~ /\b(?:
        CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?($target)
        |DROP\s+TABLE\s+(?:IF\s+EXISTS\s+)?([^;]+)
        |ALTER\s+TABLE\s+(?:IF\s+EXISTS\s+)?($target)\s+RENAME\s+TO\s+($id)
        |CREATE\s+(?:OR\s+REPLACE\s+)?FUNCTION\b(?:(?!\$\$).)*\$\$(.*?)\$\$
        |REVOKE\s+([^;]+?)\s+ON\s+(?:TABLE\s+)?([^;]+?)\s+FROM\s+shop_app\b
    )/gixs) {
        my ($create, $drop, $old, $new, $body, $rights, $names) = ($1, $2, $3, $4, $5, $6, $7);
        if (defined $create) { $tables{table_name($create)} = 1; }
        elsif (defined $drop) {
            $drop =~ s/\s+(CASCADE|RESTRICT)\s*$//i;
            for (split /,/, $drop) { my $t = table_name($_); delete $tables{$t}; delete $owned{$t}; }
        } elsif (defined $old) {
            ($old, $new) = (table_name($old), table_name($new));
            delete $tables{$old}; $tables{$new} = 1;
            $owned{$new} = delete $owned{$old} if exists $owned{$old};
        } elsif (defined $body) {
            while ($body =~ /\b(?:INSERT\s+INTO|UPDATE(?:\s+ONLY)?)\s+($target)/gi) {
                $owned{table_name($1)}{'*'} = 1;
            }
        } else {
            for my $t (split /,/, $names) {
                $owned{table_name($t)}{'thêm'} = 1 if $rights =~ /\bINSERT\b/i;
                $owned{table_name($t)}{'sửa'} = 1 if $rights =~ /\bUPDATE\b/i;
            }
        }
    }
}
sub add_cell {
    my ($f, $line, $door, $table, $kind, $col) = @_;
    if (!$tables{$table}) { error_at($f, $line, "không nhận ra bảng đích $table"); }
    if ($owned{$table}{'*'} || $owned{$table}{$kind}) { error_at($f, $line, "ô $table $kind thuộc migration"); }
    $cells{join("\t", $table, $kind, $col)}{$door} = "$f:$line";
}
sub assignments {
    my ($s, $f, $line, $door, $table) = @_;
    my ($depth, $start, @parts) = (0, 0);
    for (my $i = 0; $i < length $s; $i++) {
        my $c = substr($s, $i, 1);
        if ($depth == 0 && ($c eq ';' || substr($s, $i) =~ /\A\b(?:WHERE|FROM|RETURNING)\b/i)) {
            $s = substr($s, 0, $i); last;
        }
        if ($c eq '(' || $c eq '[') { $depth++; }
        if ($c eq ')' || $c eq ']') { last if $depth == 0; $depth--; }
        if ($c eq ',' && $depth == 0) { push @parts, substr($s, $start, $i - $start); $start = $i + 1; }
    }
    push @parts, substr($s, $start);
    for my $part (@parts) {
        my @cols;
        if ($part =~ /^\s*($id)\s*=/i) { @cols = (lc $1); }
        elsif ($part =~ /^\s*\(\s*($id(?:\s*,\s*$id)*)\s*\)\s*=/i) { @cols = split /\s*,\s*/, lc $1; }
        else { error_at($f, $line, 'không nhận ra cột trong SET'); next; }
        add_cell($f, $line, $door, $table, 'sửa', $_) for @cols;
    }
}
my @paths;
find({wanted => sub { push @paths, $File::Find::name; }, no_chdir => 1}, $be);
for my $f (sort @paths) {
    next if $f eq $be;
    my $rel = substr($f, length($be) + 1);
    my $door;
    if ($rel =~ m{^internal/([^/]+)/sql/([^/]+)(?:/|$)} && (-d "$be/internal/$1/sql/$2")) {
        my ($pkg, $name) = ($1, $2);
        $door = "$pkg/$name";
        if ($pkg !~ /^[a-z][a-z0-9_]*$/ || $name !~ /^[a-z][a-z0-9_]*$/) {
            error_at($f, 1, "tên cửa không hợp lệ $door");
        }
        $doors{$door} = 1 if -d $f;
    }
    next unless -f $f && $f =~ /\.(?:go|sql)$/;
    next if $f =~ /_test\.go$/;
    next if !$door && $f =~ /\.sql$/ && $rel =~ m{(?:^|/)testdata/};
    $files++;
    my $s = read_file($f);
    $s = clean($s) if $f =~ /\.sql$/;
    my $write = qr/\b(?:INSERT\s+INTO|UPDATE\s+(?:ONLY\s+)?$target(?:\s+(?:AS\s+)?$id)?\s+SET|DELETE\s+FROM|TRUNCATE|MERGE\s+INTO|COPY\s+$target\s*(?:FROM\b|\()|CopyFrom\s*\()/i;
    if (!$door || $f =~ /\.go$/) {
        while ($s =~ /$write/g) { error_at($f, line_at($s, $-[0]), 'câu ghi ngoài mọi cửa'); }
        next;
    }
    while ($s =~ /\b(?:DELETE\b|TRUNCATE\b|MERGE\b|COPY\b|CopyFrom\s*\()/gi) {
        error_at($f, line_at($s, $-[0]), 'loại ghi không có ô');
    }
    # Tách theo câu; chuỗi/chú thích đã che nên dấu ; ở đó không cắt câu.
    while ($s =~ /([^;]+)(?:;|$)/g) {
        my ($stmt, $base) = ($1, $-[1]);
        my $insert;
        while ($stmt =~ /\bINSERT\s+INTO\s+($target)/gi) {
            $insert = table_name($1);
            add_cell($f, line_at($s, $base + $-[0]), $door, $insert, 'thêm', '-');
        }
        while ($stmt =~ /\bUPDATE\s+(?:ONLY\s+)?($target)(?:\s+(?:AS\s+)?$id)?\s+SET\b/gi) {
            my ($table, $at, $end) = (table_name($1), $-[0], $+[0]);
            assignments(substr($stmt, $end), $f, line_at($s, $base + $at), $door, $table);
        }
        while ($stmt =~ /\bON\s+CONFLICT\b.*?\bDO\s+UPDATE\s+SET\b/gis) {
            my ($at, $end) = ($-[0], $+[0]);
            if (defined $insert) { assignments(substr($stmt, $end), $f, line_at($s, $base + $at), $door, $insert); }
            else { error_at($f, line_at($s, $base + $at), 'không nhận ra bảng đích ON CONFLICT'); }
        }
    }
}
for my $cell (sort keys %cells) {
    my @owners = sort keys %{$cells{$cell}};
    if (@owners > 1) {
        print join(', ', map { $cells{$cell}{$_} } @owners), ": ô $cell có hai cửa trở lên: ", join(', ', @owners), "\n";
        $failed = 1;
    }
    if ($flag eq '--list') { print "$cell\t$_\n" for @owners; }
}
if ($failed) { print "check-write-paths: FAIL — có đường ghi vi phạm\n"; exit 1; }
printf "check-write-paths: PASS — %d ô ghi, %d cửa, %d file đã soát\n", scalar(keys %cells), scalar(keys %doors), $files;
PERL
