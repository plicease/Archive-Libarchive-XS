use strict;
use warnings;
use Test::More tests => 19;
use Archive::Libarchive::XS qw( :all );

my $r;

my $e = archive_entry_new();
ok $e, 'archive_entry_new';

is archive_entry_pathname($e), undef, 'archive_entry_pathname = undef';

$r = archive_entry_set_pathname($e, 'hi.txt');
is $r, ARCHIVE_OK, 'archive_entry_set_pathname';

is archive_entry_pathname($e), 'hi.txt', 'archive_entry_pathname = hi.txt';

is eval { archive_entry_mode($e) }, 0, 'archive_entry_mode (0)';
diag $@ if $@;

$r = eval { archive_entry_set_mode($e, 0644) };
diag $@ if $@;
is $r, ARCHIVE_OK, 'archive_entry_set_mode';

is eval { archive_entry_mode($e) }, 0644, 'archive_entry_mode (0644)';
diag $@ if $@;

$r = eval { archive_entry_set_filetype($e, AE_IFREG) };
diag $@ if $@;
is $r, ARCHIVE_OK, 'archive_entry_set_filetype';

is eval { archive_entry_filetype($e) }, AE_IFREG, 'archive_entry_filetype';
diag $@ if $@;

is eval { archive_entry_strmode($e) }, '-rw-r--r-- ', 'archive_entry_strmode';

is archive_entry_uid($e), 0, 'archive_entry_uid = 0';
$r = archive_entry_set_uid($e, 101);
is $r, ARCHIVE_OK, 'archive_entry_set_uid';
is archive_entry_uid($e), 101, 'archive_entry_uid = 101';

is eval { archive_entry_gid($e) }, 0, 'archive_entry_gid = 0';
diag $@ if $@;
$r = eval { archive_entry_set_gid($e, 201) };
diag $@ if $@;
is $r, ARCHIVE_OK, 'archive_entry_set_gid';
is eval { archive_entry_gid($e) }, 201, 'archive_entry_gid = 201';
diag $@ if $@;

$r = archive_entry_set_nlink($e, 5);
is $r, ARCHIVE_OK, 'archive_entry_set_nlink';

is eval { archive_entry_nlink($e) }, 5, 'archive_entry_nlink';
diag $@ if $@;

$r = archive_entry_free($e);
is $r, ARCHIVE_OK, 'archive_entry_free';
