use strict;
use warnings;
use Test::More;
use Archive::Libarchive::XS qw( archive_version_string archive_version_number );

diag "libarchive (str)  ", archive_version_string();
diag "libarchive (int)  ", archive_version_number();

1;
