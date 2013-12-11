use strict;
use warnings;
use Test::More tests => 10;
use Archive::Libarchive::XS qw( :all );

my $r;
my $data = unpack 'u', do { local $/; <DATA> };
is length($data), 93, 'got data';
my $signature = substr $data, 0, 4;
is length($signature), 4, 'got signature';

my $a = archive_read_new();

$r = eval { archive_read_support_filter_program_signature($a, "gzip -d", $signature) };
diag $@ if $@;
is $r, ARCHIVE_OK, 'archive_read_support_filter_program_signature';


$r = archive_read_support_format_all($a);
is $r, ARCHIVE_OK, 'archive_read_support_format_all';

$r = archive_read_open_memory($a, $data);
is $r, ARCHIVE_OK, 'archive_read_open_memory';

$r = archive_read_next_header($a, my $ae);
is $r, ARCHIVE_OK, 'archive_read_open_memory';

is archive_filter_code($a, 0), ARCHIVE_FILTER_PROGRAM, 'archive_filter_code';
is archive_format($a), ARCHIVE_FORMAT_TAR_USTAR, 'archive_format';

$r = archive_read_close($a);
is $r, ARCHIVE_OK, 'archive_read_close';

$r = archive_read_free($a);
is $r, ARCHIVE_OK, 'archive_read_free';

__DATA__
M'XL(`-Y#<$,``]-CH#TP,#`P-S55`-*&YJ8&R#0<*!@:&!N;&)@8FAN;*1@8
M&IB:&3(HF-+!;0REQ26)14"GE&3FXE5'2![J#S@]"D;!*!@%@QP``!VL!?``
#!@``
`

