#!/usr/bin/env bash
# Gate 1h — import Gin chỉ ở biên HTTP (ADR-093, QC-12).
# VÌ SAO CÓ: service và repository không phụ thuộc ngữ cảnh HTTP.
# ĐỌC GÌ: import một dòng/khối trong mọi .go dưới be/, kể cả bí danh;
#   che chú thích nhưng giữ chuỗi và số dòng. GIN_IMPORTS_BE_DIR đổi gốc cho test.
# ĐỎ KHI NÀO: import github.com/gin-gonic/gin hoặc gói con ngoài
#   internal/<miền>/handler.go, cmd/server/, internal/middleware/, *_test.go.
# KHÔNG BẮT: sử dụng kiểu Gin qua gói trung gian; không phân tích kiểu Go.
#   Chuỗi ngoài import và chú thích không phải import. Chỉ đọc file, không cần Go.
# EXIT: 0 = đạt (kể cả chưa có be/); 1 = vi phạm hoặc lỗi đọc.
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel)" || exit 1
cd "$ROOT" || exit 1
perl - "${GIN_IMPORTS_BE_DIR:-be}" <<'PERL'
use strict;
use warnings;
use utf8;
use File::Find;
binmode STDOUT, ':encoding(UTF-8)';
my $be = shift; $be =~ s{/+$}{};
my (@files, $failed);
find({wanted => sub { push @files, $File::Find::name if -f $_ && /\.go$/; }, no_chdir => 1}, $be) if -d $be;
for my $f (sort @files) {
    open my $h, '<:encoding(UTF-8)', $f or die "$f: $!\n";
    my $s = do { local $/; <$h> } // '';
    $s =~ s{"(?:\\.|[^"\\])*"|`[^`]*`|'(?:\\.|[^'\\])*'|//[^\n]*|/\*.*?\*/}{
        my $t = $&; $t =~ s/[^\n]/ /g if $t =~ m{^/}; $t;
    }gse;
    my $rel = substr($f, length($be) + 1);
    next if $rel =~ m{^(?:internal/[a-z][a-z0-9_]*/handler\.go$|cmd/server/|internal/middleware/)} || $rel =~ /_test\.go$/;
    # Token hoá để từ import trong literal không mở khai báo giả.
    while ($s =~ /"(?:\\.|[^"\\])*"|`[^`]*`|'(?:\\.|[^'\\])*'|\b(import)\b/g) {
        next unless defined $1;
        my $base = pos($s);
        my $rest = substr($s, $base);
        my $body;
        if ($rest =~ /^\s*\((.*?)\)/s) { $body = $1; $base += $-[1]; }
        elsif ($rest =~ /^(\s*(?:[\w.]+\s+)?(?:"(?:\\.|[^"\\])*"|`[^`]*`))/s) { $body = $1; }
        else { next; }
        while ($body =~ /["`](github\.com\/gin-gonic\/gin(?:\/[^"`]*)?)["`]/g) {
            my $line = 1 + (substr($s, 0, $base + $-[0]) =~ tr/\n/\n/);
            print "$f:$line: import Gin ngoài tầng được phép: $1\n";
            $failed = 1;
        }
    }
}
print $failed ? "check-gin-imports: FAIL — import sai tầng\n" : "check-gin-imports: PASS\n";
exit($failed ? 1 : 0);
PERL
