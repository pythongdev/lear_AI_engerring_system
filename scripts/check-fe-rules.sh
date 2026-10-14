#!/usr/bin/env bash
# VÌ SAO CÓ: cong-tien giữ số tiền ở backend (ADR-102 điểm 3);
#   bo-ui-ngoai theo ADR-100; cache-next theo ADR-102 điểm 3;
#   ghi-tay-cache theo ADR-102 điểm 2 · 3. Phép chặn tĩnh của Gate 1.
# ĐỌC GÌ: FE_RULES_DIR (mặc định fe, tương đối gốc repo), mọi TS/JS và
#   package.json; bỏ node_modules/, .next/, src/lib/api/schema.ts sinh tự động.
#   Che chú thích, giữ dòng; cong-tien bỏ literal và thẻ đóng JSX.
# ĐỎ KHI NÀO: mẫu số học với tên tiền, UI ngoài shadcn, cache Next,
#   hoặc gọi setQueryData/setQueriesData. Mỗi lỗi ghi đường tương đối và dòng.
# KHÔNG BẮT: đây là mẫu chữ, không phân tích kiểu hay AST. Tên tiền không rõ,
#   Math.*, hàm cộng tự viết, alias, import tính động, biểu thức trong template
#   literal và cú pháp JS phức tạp có thể lọt; regex literal có thể báo nhầm.
#   Tên tiền khớp theo đoạn camelCase/snake_case (feedbackCount không phải tiền), nên
#   tên ghép không tách đoạn (unitprice) lọt; tên có đoạn total mà không phải tiền
#   (totalPages) bị báo — đổi tên biến.
#   Phần còn lại do mắt người ở Gate 4 (quality/review-gate.md).
# EXIT: 0 = đạt (kể cả thiếu gốc); 1 = vi phạm hoặc lỗi đọc. Không cần Node.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
perl - "${FE_RULES_DIR:-fe}" <<'PERL'
use strict;
use warnings;
use utf8;
use File::Find;
binmode STDOUT, ':encoding(UTF-8)';
my $root = shift; $root =~ s{/+$}{};
my (@files, $failed);
find({ no_chdir => 1, wanted => sub {
    if (-d $_ && m{(?:^|/)(?:node_modules|\.next)$}) { $File::Find::prune = 1; return; }
    return unless -f $_ && /(?:\.(?:ts|tsx|js|jsx|mjs|cjs)|(?:^|\/)package\.json)$/;
    return if substr($_, length($root) + 1) eq 'src/lib/api/schema.ts';
    push @files, $File::Find::name;
}}, $root) if -d $root;
my $ui = qr{^(?:\@(?:mui|material-ui|ant-design|chakra-ui|mantine|headlessui|nextui-org|heroui|blueprintjs|fluentui)/|(?:antd|react-bootstrap|bootstrap|semantic-ui-react|primereact|flowbite-react|\@radix-ui/themes|daisyui|rsuite|grommet|evergreen-ui)(?:/|$))};
my $literal = qr/"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|`(?:\\.|[^`\\])*`/s;
for my $f (sort @files) {
    open my $h, '<:encoding(UTF-8)', $f or die "$f: $!\n";
    my $s = do { local $/; <$h> } // '';
    $s =~ s{$literal|//[^\n]*|/\*.*?\*/}{
        my $t = $&; $t =~ s/[^\n]/ /g if $t =~ m{^/}; $t;
    }gse;
    my $rel = substr($f, length($root) + 1);
    my %seen;
    my $report = sub {
        my ($offset, $rule, $desc) = @_;
        my $line = 1 + (substr($s, 0, $offset) =~ tr/\n/\n/);
        return if $seen{"$line:$rule"}++;
        print "$rel:$line: $rule: $desc\n"; $failed = 1;
    };
    # Token giữ vị trí gốc; literal không thể mở import giả.
    my @tokens;
    while ($s =~ /$literal|[\w\$]+|[^\s]/g) { push @tokens, [$&, $-[0]]; }
    if ($rel =~ m{(?:^|/)package\.json$}) {
        my @stack;
        for (my $i = 0; $i < @tokens; $i++) {
            my $v = $tokens[$i][0];
            if ($v eq '{') {
                my $key = $i >= 2 && $tokens[$i-1][0] eq ':' ? $tokens[$i-2][0] : '';
                push @stack, $key;
            } elsif ($v eq '}') { pop @stack; }
            elsif (@stack && $stack[-1] =~ /^"(?:dependencies|devDependencies|peerDependencies)"$/
                && $v =~ /^"(.*)"$/ && $i+1 < @tokens && $tokens[$i+1][0] eq ':') {
                my $package = $1;
                $report->($tokens[$i][1], 'bo-ui-ngoai', "gói $package") if $package =~ $ui;
            }
        }
        next;
    }
    for (my $i = 0; $i < @tokens; $i++) {
        next unless $tokens[$i][0] =~ /^(?:import|require)$/;
        my $j = $i + 1;
        next if $j >= @tokens;
        if ($tokens[$j][0] eq '(') { $j++; }
        elsif ($tokens[$j][0] !~ /^["']/) {
            next if $tokens[$i][0] eq 'require';
            $j++ while $j < @tokens && $tokens[$j][0] !~ /^(?:from|;|import)$/;
            next unless $j < @tokens && $tokens[$j][0] eq 'from';
            $j++;
        }
        if ($j < @tokens && $tokens[$j][0] =~ /^["'](.*)["']$/s) {
            my $package = $1;
            $report->($tokens[$j][1], 'bo-ui-ngoai', "gói $package") if $package =~ $ui;
        }
    }
    while ($s =~ /["']use cache(?:\s*:[^"']*)?["']|\b(?:unstable_cache|cacheLife|cacheTag)\b|\bexport\s+const\s+revalidate\b|\bforce-(?:static|cache)\b|\bnext\s*:\s*\{\s*revalidate\b/g) {
        $report->($-[0], 'cache-next', 'cú pháp cache của Next');
    }
    my $code = $s;
    $code =~ s/$literal/my $t = $&; $t =~ s\/[^\n]\/ \/g; $t/gse;
    $code =~ s{</[\w.:-]+\s*>}{' ' x length($&)}ge;
    while ($code =~ /\bsetQuer(?:y|ies)Data\s*(?:\?\.)?\s*\(/g) {
        $report->($-[0], 'ghi-tay-cache', 'ghi trực tiếp cache dữ liệu server');
    }
    # Tên tiền khớp theo ĐOẠN của tên cuối trong chuỗi truy cập (camelCase · snake_case),
    # không theo chuỗi con: feedbackCount, patientIndex, giaiDoan không phải tiền.
    my %money = map { $_ => 1 } qw(price prices amount amounts total totals subtotal surcharge surcharges
        discount discounts vnd cost costs fee fees tien gia);
    my $is_money = sub {
        my ($last) = $_[0] =~ /([\w\$]+)\s*$/;
        (my $t = $last) =~ s/([a-z0-9])([A-Z])/$1_$2/g;
        return grep { $money{lc $_} } split /[_\$]+/, $t;
    };
    my $id = qr/[a-zA-Z_\$][\w\$]*(?:\s*(?:\?\.)?\.\s*[a-zA-Z_\$][\w\$]*)*/;
    while ($code =~ /(?=(?<![\w\$])($id)\s*([+*\/-]=?)(?![+*\/=\-])|(?<![+*\/<>=\-])([+*\/-]=?)\s*($id))/g) {
        my $offset = $-[0];
        my $name = defined $1 ? $1 : $4;
        $report->($offset, 'cong-tien', "số học với $name") if $is_money->($name);
    }
}
print $failed ? "check-fe-rules: FAIL — vi phạm luật frontend\n" : "check-fe-rules: PASS\n";
exit($failed ? 1 : 0);
PERL
