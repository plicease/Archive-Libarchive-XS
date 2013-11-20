use strict;
use warnings;
use Test::More tests => 1;

use_ok 'Archive::Libarchive::XS';

# perl -MArchive::Libarchive::XS    -E 'for(@Archive::Libarchive::XS::EXPORT_OK) { say $_ unless Archive::Libarchive::XS->can($_) }'

my $not_first = 0;

diag '';
diag '';

foreach my $const (@{ $Archive::Libarchive::XS::EXPORT_TAGS{'const'} })
{
  unless(Archive::Libarchive::XS->can($const))
  {
    diag "missing constants:" unless $not_first++;
    diag " - $const";
  }
}

diag '';
diag '';

$not_first = 0;

foreach my $func (@{ $Archive::Libarchive::XS::EXPORT_TAGS{'func'} })
{
  unless(Archive::Libarchive::XS->can($func))
  {
    diag "missing functions:" unless $not_first++;
    diag " - $func";
  }
}

diag '';
diag '';
