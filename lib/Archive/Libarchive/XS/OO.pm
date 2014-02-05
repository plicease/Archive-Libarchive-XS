package Archive::Libarchive::XS::OO;

use strict;
use warnings;
use Archive::Libarchive::XS::ArchiveRead;

# ABSTRACT: OO interface to libarchive
# VERSION

sub new
{
  my($class, $ptr) = @_;
  bless \$ptr, $class;
}

1;
