use strict;
use warnings;
use Test::More;
use Archive::Libarchive::XS qw( :all );

plan skip_all => 'test requires archive_entry_linkify' unless Archive::Libarchive::XS->can('archive_entry_linkify');
plan tests => 17;

my $r;

my $lr = eval { archive_entry_linkresolver_new() };
diag $@ if $@;
ok $lr, 'archive_entry_linkresolver_new';

$r = eval { archive_entry_linkresolver_set_strategy($lr, ARCHIVE_FORMAT_TAR_USTAR) };
diag $@ if $@;
is $r, ARCHIVE_OK, 'archive_entry_linkresolver_set_strategy';

my $entry = archive_entry_new();
archive_entry_set_pathname($entry, "test1");
archive_entry_set_ino($entry, 1);
archive_entry_set_dev($entry, 2);
archive_entry_set_nlink($entry, 1);
archive_entry_set_size($entry, 10);

my $e2;
$r = eval { archive_entry_linkify($lr, $entry, $e2) };
diag $@ if $@;
is $r, ARCHIVE_OK, 'archive_entry_linkify';
is $e2, undef, 'e2 == undef';  
is archive_entry_size($entry), 10, 'size == 10';
is archive_entry_pathname($entry), 'test1', 'pathname = test1';

archive_entry_set_pathname($entry, "test2");
archive_entry_set_nlink($entry, 2);
archive_entry_set_ino($entry, 2);
$r = eval { archive_entry_linkify($lr, $entry, $e2) };
diag $@ if $@;
is $r, ARCHIVE_OK, 'archive_entry_linkify';
is $e2, undef, 'e2 == undef';
is archive_entry_pathname($entry), 'test2', 'pathname = test2';
is archive_entry_hardlink($entry), undef, 'hardlink = undef';
is archive_entry_size($entry), 10, 'size == 10';

$r = eval { archive_entry_linkify($lr, $entry, $e2) };
diag $@ if $@;
is $r, ARCHIVE_OK, 'archive_entry_linkify';
is $e2, undef, 'e2 == undef';
is archive_entry_pathname($entry), 'test2';
is archive_entry_hardlink($entry), 'test2';
is archive_entry_size($entry), 0;

archive_entry_free($entry);
archive_entry_free($e2) if $e2;

$r = eval { archive_entry_linkresolver_free($lr) };
diag $@ if $@;
is $r, ARCHIVE_OK, 'archive_entry_linkresolver_free';
