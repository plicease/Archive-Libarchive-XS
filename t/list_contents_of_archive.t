use strict;
use warnings;
use Archive::Libarchive::XS qw( :all );
use Test::More tests => 18;
use FindBin ();
use File::Basename qw( basename );
use File::Spec;

my $filename = File::Spec->catfile($FindBin::Bin, 'foo.tar');
my $r;
my $entry;

my $a = archive_read_new();

isa_ok $a, "Archive::Libarchive::XS::archive";

$r = archive_read_support_filter_all($a);
is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_support_filter_all)";

$r = archive_read_support_format_all($a);
is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_support_format_all)";

$r = archive_read_open_filename($a, $filename, 10240);
is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_open_filename)";

$r = archive_read_next_header($a, $entry);
is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_next_header 1)";
isa_ok $entry, "Archive::Libarchive::XS::archive_entry";

is archive_entry_pathname($entry), "foo/foo.txt", 'archive_entry_pathname($entry) = foo/foo.txt';

$r = archive_read_data_skip($a);
is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_data_skip 1)";

$r = archive_read_next_header($a, $entry);
is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_next_header 2)";
isa_ok $entry, "Archive::Libarchive::XS::archive_entry";

is archive_entry_pathname($entry), "foo/bar.txt", 'archive_entry_pathname($entry) = foo/bar.txt';

$r = archive_read_data_skip($a);
is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_data_skip 2)";

$r = archive_read_next_header($a, $entry);
is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_next_header 3)";
isa_ok $entry, "Archive::Libarchive::XS::archive_entry";

is archive_entry_pathname($entry), "foo/baz.txt", 'archive_entry_pathname($entry) = foo/baz.txt';

$r = archive_read_data_skip($a);
is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_data_skip 3)";

$r = archive_read_next_header($a, $entry);
is $r, ARCHIVE_EOF, "r = ARCHIVE_EOF (archive_read_next_header 4)";

$r = archive_read_free($a);
is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_free)";
