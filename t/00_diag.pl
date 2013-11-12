use strict;
use warnings;
use Test::More;

diag "libarchive (str)  ", eval q{ 
  use Archive::Libarchive::XS qw( archive_version_string );
  archive_version_string();
} || '-';
diag "libarchive (int)  ", eval q{
  use Archive::Libarchive::XS qw( archive_version_number );
  archive_version_number();
} || '-';

1;
