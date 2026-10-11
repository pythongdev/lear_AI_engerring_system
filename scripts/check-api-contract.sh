#!/usr/bin/env bash
# Gate 1g — so hợp đồng API với code và migration (P3-04, ADR-084, ADR-082 điểm 5).
# VÌ SAO CÓ: pha 4 sinh type từ hợp đồng; hợp đồng thắng code, nên lệch nhau phải
#   đỏ ngay ở lượt gây lệch — kể cả lượt chỉ đổi tài liệu (Gate 1 bỏ qua lượt ấy).
# ĐỌC GÌ: docs/product/3-be/openapi.yaml theo khuôn ở 01-hop-dong-api.md §2 (YAML
#   thụt hai dấu cách; dòng # bỏ qua): openapi, info.version, paths (khoá mở đầu
#   bằng /, phương thức thụt bốn), components.schemas.ErrorCode (enum, x-http-status),
#   x-constraint-errors (tên: mã | internal | unreviewed). Ma trận 02-vai-va-quyen.md
#   cạnh hợp đồng: dòng | `gói/cửa` | `lớp` | (P3-05, ADR-085). Mọi .go dưới be/ trừ
#   _test.go: bỏ chú thích Go trước khi đọc route; .GET/.POST/.PUT/.PATCH/.DELETE
#   nhận chuỗi trần, đổi :tên thành {tên}; .HandleFunc/.Handle("PHƯƠNG THỨC /đường", …); be/internal/apierr/:
#   hằng `CodeX Code = "mã"`, dòng `CodeX: 500,` (status), dòng `"tên": CodeX,`
#   (bảng ánh xạ công khai); be/internal/authz/: hằng `NeedX Need = "lớp"`; mọi
#   authz.Door{Code: "gói/cửa", Need: authz.NeedX}; thư mục be/internal/*/sql/*/
#   là cửa (QC-13). *.up.sql theo tên file, bỏ chú thích --: CONSTRAINT x
#   <loại>, CREATE UNIQUE INDEX x ON t, CONSTRAINT = 'x' trong thân hàm (lời từ
#   chối của trigger, F-058); trừ đi DROP CONSTRAINT · DROP INDEX · DROP TABLE và
#   theo RENAME CONSTRAINT · ALTER INDEX … RENAME TO.
# ĐỎ KHI NÀO: đường gọi chỉ ở một phía, không nêu phương thức, mẫu không phải chuỗi
#   trần; tên ở migration thiếu dòng ánh xạ, dòng cho tên không còn; giá trị không
#   phải mã; mã chỉ ở một phía; status thiếu hay lệch; bảng ánh xạ công khai lệch;
#   không có internal_error; không phải OpenAPI 3.1; info.version sai khuôn; hợp
#   đồng khác HEAD mà info.version không lớn hơn bản ở HEAD; có be/ mà thiếu hợp đồng;
#   thư mục cửa · dòng ma trận · khai báo authz.Door không cùng một tập, một cửa hai
#   dòng hay hai khai báo, lớp ở ma trận khác code hoặc không phải lớp của authz,
#   có cửa mà không có file ma trận.
#   Group/Any, Handle của Gin, đường động/nối chuỗi/wildcard, {tên} trong đường Gin
#   (Gin đọc nó là chữ thường, phải viết :tên) và route trùng đều đỏ.
# KHÔNG BẮT: thân request/response so với struct Go; tên ràng buộc đặt ngầm (không
#   viết CONSTRAINT) — test TestQC10_ ở be/internal/apierr/ so với database sống;
#   tên ghép lúc chạy thì đỏ chứ không đoán. Không phải trình đọc YAML đầy đủ.
#   API_CONTRACT_FILE · API_CONTRACT_BE_DIR · API_CONTRACT_MIG_DIR đổi chỗ đọc cho
#   test. --list in từng dòng của mỗi danh sách. Không cần database hay Go.
# EXIT: 0 = đạt hoặc chưa có be/ lẫn hợp đồng (skipping); 1 = lệch hoặc lỗi đọc.
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 1
cd "$ROOT" || exit 1
CONTRACT="${API_CONTRACT_FILE:-docs/product/3-be/openapi.yaml}"
BE_DIR="${API_CONTRACT_BE_DIR:-be}"
MIG_DIR="${API_CONTRACT_MIG_DIR:-db/migrations}"
MATRIX="$(dirname "$CONTRACT")/02-vai-va-quyen.md"
if [ ! -f "$CONTRACT" ] && [ ! -d "$BE_DIR" ]; then
  echo "check-api-contract: không có be/ lẫn hợp đồng, skipping"
  exit 0
fi
if [ ! -f "$CONTRACT" ]; then
  echo "check-api-contract: FAIL — có $BE_DIR/ mà không có hợp đồng $CONTRACT"
  exit 1
fi
# Bản ở HEAD (nếu file đã được commit) — để chấm luật tăng phiên bản.
HEAD_COPY="$(mktemp)"
trap 'rm -f "$HEAD_COPY"' EXIT
if ! git -C "$(dirname "$CONTRACT")" show "HEAD:./$(basename "$CONTRACT")" > "$HEAD_COPY" 2>/dev/null; then
  : > "$HEAD_COPY"
fi
perl - "$CONTRACT" "$BE_DIR" "$MIG_DIR" "$HEAD_COPY" "$MATRIX" "${1:-}" <<'PERL'
use strict;
use warnings;
use utf8;
use File::Find;
binmode STDOUT, ':encoding(UTF-8)';
my ($contract, $be, $mig, $head, $matrix, $flag) = @ARGV;
$flag //= '';
$be =~ s{/+$}{};
my $failed = 0;
sub bad { print "$_[0]\n"; $failed = 1; }
sub read_file {
    my ($f) = @_;
    open my $h, '<:encoding(UTF-8)', $f or die "$f: $!\n";
    local $/; return <$h> // '';
}
sub set_diff { my ($a, $b) = @_; return sort grep { !exists $b->{$_} } keys %$a; }

# --- hợp đồng ---------------------------------------------------------------
sub parse_contract {
    my ($text) = @_;
    my %c = (paths => {}, enum => {}, status => {}, rows => {}, openapi => '', version => '');
    my ($top, $path, $in_codes, $sub) = ('', '', 0, '');
    for my $line (split /\n/, $text) {
        next if $line =~ /^\s*(#|$)/;
        if ($line =~ /^(\S[^:]*):\s*(.*?)\s*$/) {
            ($top, $path, $in_codes, $sub) = ($1, '', 0, '');
            $c{openapi} = $2 if $top eq 'openapi';
            if ($top eq 'paths' && $2 ne '' && $2 ne '{}') { $c{errors}{"paths phải là {} hoặc một khối"} = 1; }
            next;
        }
        if ($top eq 'info' && $line =~ /^  version:\s*["']?([^"'\s]*)["']?\s*$/) { $c{version} = $1; next; }
        if ($top eq 'paths') {
            if ($line =~ /^  (\S[^:]*):\s*$/) {
                $path = $1; $path =~ s/^["']|["']$//g;
                $c{errors}{"khoá đường gọi không mở đầu bằng /: $path"} = 1 if $path !~ m{^/};
            } elsif ($line =~ /^    (get|put|post|delete|patch|head|options|trace):/ && $path ne '') {
                $c{paths}{uc($1) . " $path"} = 1;
            }
            next;
        }
        if ($top eq 'components') {
            if ($line =~ /^    (\S+):\s*$/) { $in_codes = ($1 eq 'ErrorCode'); $sub = ''; next; }
            next unless $in_codes;
            if ($line =~ /^      (\S+):/) { $sub = $1; next; }
            if ($sub eq 'enum' && $line =~ /^        -\s*["']?([^"'\s]+)["']?\s*$/) { $c{enum}{$1} = 1; }
            if ($sub eq 'x-http-status' && $line =~ /^        ([a-z0-9_]+):\s*(\d{3})\s*$/) { $c{status}{$1} = $2; }
            next;
        }
        if ($top eq 'x-constraint-errors') {
            if ($line =~ /^  ([a-z0-9_]+):\s*([A-Za-z0-9_]+)\s*$/) { $c{rows}{$1} = $2; }
            else { $c{errors}{"dòng ánh xạ không đọc được: $line"} = 1; }
        }
    }
    return \%c;
}
my $text = read_file($contract);
my $c = parse_contract($text);
bad("$contract: $_") for sort keys %{$c->{errors} // {}};
bad("$contract: openapi phải là 3.1.x, nhận '$c->{openapi}'") if $c->{openapi} !~ /^["']?3\.1\.\d+["']?$/;
my $ver = $c->{version};
if ($ver !~ /^(\d+)\.(\d+)\.(\d+)$/) {
    bad("$contract: info.version phải là MAJOR.MINOR.PATCH, nhận '$ver'");
} elsif (-s $head) {
    my $old = read_file($head);
    if ($old ne $text) {
        my $ov = parse_contract($old)->{version};
        if ($ov eq $ver) {
            bad("$contract: hợp đồng đổi so với HEAD mà info.version vẫn $ver — tăng theo 01-hop-dong-api.md §7");
        } elsif ($ov =~ /^(\d+)\.(\d+)\.(\d+)$/) {
            my @o = ($1, $2, $3); my @n = split /\./, $ver;
            my $cmp = ($n[0] <=> $o[0]) || ($n[1] <=> $o[1]) || ($n[2] <=> $o[2]);
            bad("$contract: info.version $ver không lớn hơn $ov ở HEAD") if $cmp <= 0;
        }
    }
}
bad("$contract: ErrorCode phải có internal_error (ADR-082 điểm 5.3)") unless $c->{enum}{internal_error};
bad("$contract: mã không có status ở hợp đồng: $_") for set_diff($c->{enum}, $c->{status});
bad("$contract: status cho mã không có trong enum: $_") for set_diff($c->{status}, $c->{enum});

# --- code -------------------------------------------------------------------
my (%routes, %consts, %gostatus, %gomap, $gofiles, @apierr_src, @authz_src, %decl);
my $apierr = "$be/internal/apierr";
my @gofiles;
find({wanted => sub { push @gofiles, $File::Find::name if -f $_ && /\.go$/ && !/_test\.go$/; }, no_chdir => 1}, $be) if -d $be;
for my $f (sort @gofiles) {
    $gofiles++;
    my $s = read_file($f);
    # Lexer giữ nguyên chuỗi, che chú thích và giữ số dòng.
    my $route_src = $s;
    $route_src =~ s{"(?:\\.|[^"\\])*"|`[^`]*`|'(?:\\.|[^'\\])*'|//[^\n]*|/\*.*?\*/}{
        my $token = $&;
        if ($token =~ m{^/}) { $token =~ s/[^\n]/ /g; }
        $token;
    }gse;
    # Bỏ qua literal ngoài lời gọi để chữ giống route trong chuỗi không thành route.
    while ($route_src =~ /"(?:\\.|[^"\\])*"|`[^`]*`|'(?:\\.|[^'\\])*'|\.\s*(HandleFunc|Handle|GET|POST|PUT|PATCH|DELETE|Group|Any)\s*\(/g) {
        next unless defined $1;
        my $method = $1;
        my $line = 1 + (substr($route_src, 0, $-[0]) =~ tr/\n/\n/);
        if ($method eq 'Group' || $method eq 'Any') {
            bad("$f:$line: không nhận .$method("); next;
        }
        my $rest = substr($route_src, pos($route_src));
        if ($rest !~ /^\s*"([^"\\]*)"\s*,/) {
            bad("$f:$line: không đọc được mẫu đường gọi — viết chuỗi trần, không nối chuỗi"); next;
        }
        my $pat = $1;
        my $route;
        if ($method eq 'Handle' || $method eq 'HandleFunc') {
            if ($pat =~ m{^(GET|POST|PUT|PATCH|DELETE) (/\S*)$}) { $route = "$1 $2"; }
            else { bad("$f:$line: đường gọi \"$pat\" không nêu phương thức (GET|POST|PUT|PATCH|DELETE /đường)"); next; }
        } else {
            if ($pat !~ m{^/\S*$} || $pat =~ /[*{}]/) {
                bad("$f:$line: đường Gin sai khuôn hoặc có wildcard: $pat"); next;
            }
            $pat =~ s{(^|/):([^/]+)}{$1 . "{" . $2 . "}"}ge;
            $route = "$method $pat";
        }
        bad("$f:$line: route đăng ký hai lần: $route (trước ở $routes{$route})") if exists $routes{$route};
        $routes{$route} = "$f:$line";
    }
    push @apierr_src, $s if index($f, "$apierr/") == 0;
    push @authz_src, $s if index($f, "$be/internal/authz/") == 0;
    while ($s =~ /\bauthz\.Door\s*\{\s*Code:\s*"([^"]*)"\s*,\s*Need:\s*authz\.(Need\w+)\s*,?\s*\}/g) {
        my $line = 1 + (substr($s, 0, $-[0]) =~ tr/\n/\n/);
        bad("$f:$line: authz.Door khai hai lần cho cửa $1") if exists $decl{$1};
        $decl{$1} = $2;
    }
}
# Hai lượt: hằng trước, rồi status và bảng ánh xạ — hằng có thể ở file khác.
my %value_of;
for my $s (@apierr_src) {
    while ($s =~ /^\s*(Code\w+)\s+Code\s*=\s*"([a-z0-9_]+)"/mg) { $consts{$2} = $1; $value_of{$1} = $2; }
}
for my $s (@apierr_src) {
    while ($s =~ /^\s*(Code\w+)\s*:\s*(\d{3})\s*,/mg) { $gostatus{$value_of{$1} // "?$1"} = $2; }
    while ($s =~ /^\s*"([a-z0-9_]+)"\s*:\s*(Code\w+)\s*,/mg) { $gomap{$1} = $value_of{$2} // "?$2"; }
}
if (-d $be && !-d $apierr) { bad("thiếu $apierr — hình lỗi chung và bảng ánh xạ của code (QC-14)"); }
my %goenum = map { $_ => 1 } keys %consts;
bad("mã chỉ ở hợp đồng: $_ — thiếu hằng Code ở $apierr") for set_diff($c->{enum}, \%goenum);
bad("mã chỉ ở code: $_ — thêm vào ErrorCode của hợp đồng trước") for set_diff(\%goenum, $c->{enum});
for my $code (sort keys %{$c->{status}}) {
    next unless exists $goenum{$code};
    my $gs = $gostatus{$code} // 'thiếu';
    bad("status của $code: hợp đồng $c->{status}{$code}, code $gs") if $gs ne $c->{status}{$code};
}
bad("route: chỉ ở hợp đồng: $_") for set_diff($c->{paths}, \%routes);
bad("route: chỉ ở code: $_") for set_diff(\%routes, $c->{paths});

# --- ma trận vai × cửa (P3-05, ADR-085) ---------------------------------------
# Ba tập phải bằng nhau: thư mục cửa be/internal/<gói>/sql/<cửa>/ · dòng ma trận ·
# khai báo authz.Door ngoài _test.go; lớp ở ma trận bằng lớp ở code.
my (%doors, %rows_m, %needs);
for my $s (@authz_src) {
    while ($s =~ /^\s*(Need\w+)\s+Need\s*=\s*"([a-z0-9_]+)"/mg) { $needs{$1} = $2; }
}
my %need_values = map { $_ => 1 } values %needs;
if (-d "$be/internal") {
    for my $d (glob("$be/internal/*/sql/*")) {
        next unless -d $d;
        $doors{"$1/$2"} = 1 if $d =~ m{/internal/([^/]+)/sql/([^/]+)$};
    }
}
if (-f $matrix) {
    my $n = 0;
    for my $line (split /\n/, read_file($matrix)) {
        $n++;
        next unless $line =~ /^\|\s*`([a-z][a-z0-9_]*\/[a-z][a-z0-9_]*)`\s*\|\s*`([^`]*)`\s*\|/;
        if (exists $rows_m{$1}) { bad("$matrix:$n: cửa có hơn một dòng ma trận: $1"); next; }
        $rows_m{$1} = $2;
        bad("$matrix:$n: lớp không có trong authz: $2") if !$need_values{$2};
    }
} elsif (%doors || %decl) {
    bad("có cửa ghi mà không có ma trận $matrix (ADR-085)");
}
bad("cửa không có dòng ma trận: $_") for set_diff(\%doors, \%rows_m);
bad("dòng ma trận không có cửa: $_") for set_diff(\%rows_m, \%doors);
bad("cửa không khai authz.Door: $_") for set_diff(\%doors, \%decl);
bad("khai authz.Door mà không có cửa: $_") for set_diff(\%decl, \%doors);
for my $door (sort keys %decl) {
    my $code_need = $needs{$decl{$door}} // "?$decl{$door}";
    next unless exists $rows_m{$door} && $need_values{$rows_m{$door}};
    bad("lớp quyền của $door: ma trận $rows_m{$door}, code $code_need") if $rows_m{$door} ne $code_need;
}

# --- migration --------------------------------------------------------------
my (%names, %table_of);
my @migs;
if (-d $mig) {
    opendir my $dh, $mig or die "$mig: $!\n";
    @migs = map { "$mig/$_" } sort grep { /\.up\.sql$/ } readdir $dh;
    closedir $dh;
}
my $id = qr/[a-z_][a-z0-9_]*/;
for my $f (@migs) {
    my $s = read_file($f);
    $s =~ s/--[^\n]*//g;
    # Thân hàm: chỉ đọc tên lời từ chối; dấu ; trong thân không cắt câu ngoài.
    my @bodies;
    $s =~ s/\$\$(.*?)\$\$/push @bodies, $1; ' $$ '/gse;
    for my $b (@bodies) {
        while ($b =~ /\bCONSTRAINT\s*(?::=|=)\s*('([a-z0-9_]+)'|[^,;\s]+)/gi) {
            if (defined $2) { $names{$2} = 1; $table_of{$2} = ''; }
            else { bad("$f: tên lời từ chối không đọc được: $1 — viết chuỗi trần (QC-10)"); }
        }
    }
    for my $stmt (split /;/, $s) {
        my $table = '';
        $table = $1 if $stmt =~ /^\s*(?:CREATE\s+TABLE(?:\s+IF\s+NOT\s+EXISTS)?|ALTER\s+TABLE(?:\s+IF\s+EXISTS)?(?:\s+ONLY)?)\s+(?:shop\.)?($id)/i;
        if ($stmt =~ /^\s*DROP\s+TABLE\s+(?:IF\s+EXISTS\s+)?([^;]+)/i) {
            for my $t (map { my $x = $_; $x =~ s/\s|^shop\.|CASCADE|RESTRICT//gi; $x } split /,/, $1) {
                for my $n (keys %names) { delete $names{$n} if $table_of{$n} eq $t; }
            }
            next;
        }
        if ($stmt =~ /^\s*CREATE\s+UNIQUE\s+INDEX\s+(?:CONCURRENTLY\s+)?(?:IF\s+NOT\s+EXISTS\s+)?($id)\s+ON\s+(?:ONLY\s+)?(?:shop\.)?($id)/i) {
            $names{$1} = 1; $table_of{$1} = $2; next;
        }
        if ($stmt =~ /^\s*DROP\s+INDEX\s+(?:CONCURRENTLY\s+)?(?:IF\s+EXISTS\s+)?(?:shop\.)?($id)/i) { delete $names{$1}; next; }
        if ($stmt =~ /^\s*ALTER\s+INDEX\s+(?:IF\s+EXISTS\s+)?(?:shop\.)?($id)\s+RENAME\s+TO\s+($id)/i) {
            if (delete $names{$1}) { $names{$2} = 1; $table_of{$2} = $table_of{$1}; }
            next;
        }
        while ($stmt =~ /\b(?:(DROP)\s+CONSTRAINT\s+(?:IF\s+EXISTS\s+)?($id)|RENAME\s+CONSTRAINT\s+($id)\s+TO\s+($id)|CONSTRAINT\s+($id)\s+(?:PRIMARY|UNIQUE|FOREIGN|CHECK|EXCLUDE)\b)/gi) {
            if (defined $1) { delete $names{$2}; }
            elsif (defined $3) { if (delete $names{$3}) { $names{$4} = 1; $table_of{$4} = $table; } }
            else { $names{$5} = 1; $table_of{$5} = $table; }
        }
    }
}
my %values = (internal => 1, unreviewed => 1);
bad("x-constraint-errors: chưa có dòng ánh xạ: $_") for set_diff(\%names, $c->{rows});
bad("x-constraint-errors: không có trong migration: $_") for set_diff($c->{rows}, \%names);
my (%public, %count);
for my $n (sort keys %{$c->{rows}}) {
    my $v = $c->{rows}{$n};
    if ($values{$v}) { $count{$v}++; next; }
    if (!$c->{enum}{$v}) { bad("x-constraint-errors: $n → không phải mã của ErrorCode: $v"); next; }
    $public{$n} = $v; $count{public}++;
}
for my $n (sort keys %public) {
    my $g = $gomap{$n};
    if (!defined $g) { bad("bảng ánh xạ của code thiếu: $n → $public{$n}"); }
    elsif ($g ne $public{$n}) { bad("bảng ánh xạ của code lệch: $n → hợp đồng $public{$n}, code $g"); }
}
for my $n (sort keys %gomap) {
    bad("bảng ánh xạ của code thừa: $n → $gomap{$n}") unless exists $public{$n};
}

# --- in ---------------------------------------------------------------------
if ($flag eq '--list') {
    print "hợp đồng\t$_\n" for sort keys %{$c->{paths}};
    print "code\t$_\n" for sort keys %routes;
    print "mã\t$_\t$c->{status}{$_}\n" for sort keys %{$c->{enum}};
    print "ánh xạ\t$_\t$c->{rows}{$_}\n" for sort keys %{$c->{rows}};
    print "ma trận\t$_\t$rows_m{$_}\n" for sort keys %rows_m;
    print "cửa\t$_\n" for sort keys %doors;
    print "khai báo\t$_\t" . ($needs{$decl{$_}} // "?$decl{$_}") . "\n" for sort keys %decl;
}
printf "  %d đường gọi ở hợp đồng, %d ở code (%d file .go đã soát)\n",
    scalar(keys %{$c->{paths}}), scalar(keys %routes), $gofiles // 0;
print "  hợp đồng: $_\n" for sort keys %{$c->{paths}};
print "  code:     $_\n" for sort keys %routes;
my $summary = sprintf "hợp đồng %s; %d đường gọi ở hợp đồng, %d ở code; %d mã lỗi; %d tên từ chối ở migration, %d dòng ánh xạ (%d internal, %d unreviewed, %d dòng mang mã công khai)",
    $ver, scalar(keys %{$c->{paths}}), scalar(keys %routes), scalar(keys %{$c->{enum}}),
    scalar(keys %names), scalar(keys %{$c->{rows}}), $count{internal} // 0, $count{unreviewed} // 0, $count{public} // 0;
$summary .= sprintf "; %d cửa, %d dòng ma trận, %d khai báo authz.Door",
    scalar(keys %doors), scalar(keys %rows_m), scalar(keys %decl);
if ($failed) { print "check-api-contract: FAIL — hợp đồng và code lệch; $summary\n"; exit 1; }
print "check-api-contract: PASS — $summary\n";
PERL
