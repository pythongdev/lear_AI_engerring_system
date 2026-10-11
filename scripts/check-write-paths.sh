#!/usr/bin/env bash
# Gate 1f — liệt kê ô ghi → cửa (ADR-082 điểm 3, ADR-083, QC-13).
# VÌ SAO CÓ: mỗi ô đúng một cửa phải có máy chấm, chạy cả lượt chỉ đổi tài liệu.
# ĐỌC GÌ: mọi .go (trừ _test.go), .sql dưới be/; cửa là internal/<gói>/sql/<cửa>/,
#   tên gói/cửa [a-z][a-z0-9_]*. SQL bỏ --, /* */ và chuỗi đơn, giữ số dòng;
#   Go đọc cả file để bắt chuỗi ghi nhiều dòng. INSERT là ô thêm; UPDATE/ON
#   CONFLICT là ô sửa từng cột SET, kể cả bộ (a,b), tách ở ngoặc ngoài cùng.
#   *.up.sql theo tên: CREATE/DROP/RENAME xác định bảng còn tồn tại; bảng được
#   ghi trong thân hàm $$ thuộc migration; REVOKE INSERT/UPDATE FROM shop_app
#   giữ riêng loại ghi ấy; GRANT UPDATE (cột…) TO shop_app đứng sau trao lại
#   đúng các cột ấy, REVOKE đứng sau nữa rút cả quyền cột (như PostgreSQL). --list in bảng<TAB>loại<TAB>cột hoặc -<TAB>gói/cửa.
#   sqlc.yaml theo đúng khuôn ADR-093: mỗi mục một miền, đủ sql/ và các cửa;
#   nguồn đã chuyển có một annotation và một câu. Không chạy sqlc.
# ĐỎ KHI NÀO: hai cửa chung ô, tên cửa sai, câu ghi ngoài cửa, bảng đích không
#   nhận ra, SET không đọc ra cột, ghi ô thuộc migration; DELETE/TRUNCATE/MERGE/
#   COPY không có ô. Mỗi lỗi một dòng có file và dòng khi xác định được.
#   Cấu hình lệch khuôn, annotation/câu/tên sai; sqlcgen thiếu mục, thiếu nguồn
#   hoặc lệch nguồn. Chỉ từng hằng backtick khớp nguồn được miễn câu ghi ngoài cửa.
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
my (%tables, %owned, %granted, %cells, %doors);
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
# Khuôn sqlc duy nhất: đọc tuần tự, không chấp nhận khoá lạ hoặc lặp.
my (%converted, %sources);
my $config = "$be/sqlc.yaml";
if (-f $config) {
    my @lines = split /\n/, read_file($config);
    my @rows;
    for my $i (0..$#lines) {
        next if $lines[$i] =~ /^\s*(?:#.*)?$/;
        push @rows, [$lines[$i], $i + 1];
    }
    my $take = sub {
        my ($pattern, $label) = @_;
        my $row = shift @rows;
        if (!$row || $row->[0] !~ $pattern) {
            error_at($config, $row ? $row->[1] : scalar(@lines), "lệch khuôn sqlc.yaml: $label");
            return undef;
        }
        return $row;
    };
    $take->(qr/^version: "2"$/, 'version');
    $take->(qr/^sql:$/, 'sql');
    error_at($config, 2, 'lệch khuôn sqlc.yaml: thiếu mục') unless @rows;
    while (@rows) {
        my $entry = $take->(qr/^  - engine: postgresql$/, 'engine') or last;
        $take->(qr/^    schema: \.\.\/db\/migrations$/, 'schema') or last;
        $take->(qr/^    queries:$/, 'queries') or last;
        my (@queries, %queries);
        while (@rows && $rows[0][0] =~ /^      - (\S+)$/) {
            my $q = $1; my $row = shift @rows;
            push @queries, [$q, $row->[1]];
            error_at($config, $row->[1], "queries lặp $q") if $queries{$q}++;
        }
        $take->(qr/^    gen:$/, 'gen') or last;
        $take->(qr/^      go:$/, 'go') or last;
        $take->(qr/^        package: sqlcgen$/, 'package') or last;
        my $out = $take->(qr{^        out: internal/[a-z][a-z0-9_]*/internal/sqlcgen$}, 'out') or last;
        $out->[0] =~ m{out: internal/([^/]+)/};
        my $domain = $1;
        $take->(qr/^        sql_package: pgx\/v5$/, 'sql_package') or last;
        error_at($config, $entry->[1], "hai mục cùng miền $domain") if $converted{$domain}++;
        my $root = "internal/$domain/sql";
        for my $q (@queries) {
            error_at($config, $q->[1], "queries ngoài $root: $q->[0]")
                unless $q->[0] =~ m{^\Q$root\E(?:/[a-z][a-z0-9_]*)?$};
        }
        error_at($config, $entry->[1], "thiếu queries $root") unless $queries{$root};
        for my $dir (sort glob "$be/$root/*") {
            next unless -d $dir;
            my $q = substr($dir, length($be) + 1);
            error_at($config, $entry->[1], "thiếu thư mục cửa $q") unless $queries{$q};
        }
    }
}
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
        |GRANT\s+UPDATE\s*\(([^)]+)\)\s+ON\s+(?:TABLE\s+)?($target)\s+TO\s+shop_app\b
    )/gixs) {
        my ($create, $drop, $old, $new, $body, $rights, $names, $cols, $grant_on) = ($1, $2, $3, $4, $5, $6, $7, $8, $9);
        if (defined $create) { $tables{table_name($create)} = 1; }
        elsif (defined $drop) {
            $drop =~ s/\s+(CASCADE|RESTRICT)\s*$//i;
            for (split /,/, $drop) { my $t = table_name($_); delete $tables{$t}; delete $owned{$t}; delete $granted{$t}; }
        } elsif (defined $old) {
            ($old, $new) = (table_name($old), table_name($new));
            delete $tables{$old}; $tables{$new} = 1;
            $owned{$new} = delete $owned{$old} if exists $owned{$old};
            $granted{$new} = delete $granted{$old} if exists $granted{$old};
        } elsif (defined $body) {
            while ($body =~ /\b(?:INSERT\s+INTO|UPDATE(?:\s+ONLY)?)\s+($target)/gi) {
                $owned{table_name($1)}{'*'} = 1;
            }
        } elsif (defined $cols) {
            $granted{table_name($grant_on)}{lc $_} = 1 for split /\s*,\s*/, $cols =~ s/^\s+|\s+$//gr;
        } else {
            for my $t (split /,/, $names) {
                $owned{table_name($t)}{'thêm'} = 1 if $rights =~ /\bINSERT\b/i;
                if ($rights =~ /\bUPDATE\b/i) {
                    $owned{table_name($t)}{'sửa'} = 1;
                    delete $granted{table_name($t)};
                }
            }
        }
    }
}
sub add_cell {
    my ($f, $line, $door, $table, $kind, $col) = @_;
    if (!$tables{$table}) { error_at($f, $line, "không nhận ra bảng đích $table"); }
    my $regranted = $kind eq 'sửa' && $granted{$table}{$col};
    if ($owned{$table}{'*'} || ($owned{$table}{$kind} && !$regranted)) { error_at($f, $line, "ô $table $kind thuộc migration"); }
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
# Đọc nguồn trước code sinh: tên query là khoá, không phải tên file.
for my $f (sort @paths) {
    if (-d $f && $f =~ m{^\Q$be\E/internal/([^/]+)/internal/sqlcgen$} && !$converted{$1}) {
        error_at($f, 1, 'sqlcgen của miền không có mục trong sqlc.yaml');
    }
    next unless -f $f && $f =~ m{^\Q$be\E/internal/([^/]+)/sql/.*\.sql$} && $converted{$1};
    my $domain = $1;
    my $raw = read_file($f);
    my @names = ($raw =~ /^-- name: ([A-Za-z_][A-Za-z0-9_]*) :(?:one|many|exec|execrows|execresult|execlastid|copyfrom|batchexec|batchmany|batchone)[ \t]*$/mg);
    if (@names != 1) { error_at($f, 1, 'phải có đúng một dòng -- name:'); }
    my @stmts = grep { /\S/ } split /;/, clean($raw);
    error_at($f, 1, 'phải có đúng một câu SQL') if @stmts != 1;
    next unless @names == 1;
    my $name = $names[0];
    if (exists $sources{$domain}{$name}) { error_at($f, 1, "trùng tên query $name trong miền $domain"); next; }
    # sqlc bỏ phần trước annotation, dấu ; cuối và khoảng trắng ngoài câu.
    $raw =~ s/\A.*?(?=^-- name: )//ms;
    $raw =~ s/\s+\z//;
    $raw =~ s/;\z//;
    $raw .= "\n";
    $raw =~ s/[ \t]+$//mg;
    $sources{$domain}{$name} = $raw;
}
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
    if ($rel =~ m{^internal/([^/]+)/internal/sqlcgen/.*\.go$} && $converted{$1}) {
        my $domain = $1;
        # Chỉ che literal của hằng đã khớp; mọi phần còn lại vẫn bị luật cũ đọc.
        $s =~ s{//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"|`[^`]*`|'(?:\\.|[^'\\])*'|\bconst\s+[A-Za-z_]\w*\s*=\s*`(-- name: ([A-Za-z_]\w*)[^`]*)`}{
            my ($whole, $body, $name, $at) = ($&, $1, $2, $-[0]);
            my $norm = $body // ''; $norm =~ s/[ \t]+$//mg;
            if (!defined $body) { $whole; }
            elsif (!exists $sources{$domain}{$name}) {
                error_at($f, line_at($s, $at), "thiếu nguồn query $name"); $whole;
            } elsif ($norm ne $sources{$domain}{$name}) {
                error_at($f, line_at($s, $at), "lệch nguồn query $name"); $whole;
            } else { blank($whole); }
        }gse;
    }
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
