package Archive::Libarchive::XS::Entry;

use strict;
use warnings;
use Archive::Libarchive::XS ();
use base qw( Archive::Libarchive::XS::OO );

# ABSTRACT: OO representation of an archive entry
# VERSION

sub new
{
  my($class, $entry) = @_;
  $class->SUPER::new($entry);
}

*pathname = \&Archive::Libarchive::XS::archive_entry_pathname;
*atime_is_set = \&Archive::Libarchive::XS::archive_entry_atime_is_set;
*atime = \&Archive::Libarchive::XS::archive_entry_atime;
*atime_nsec = \&Archive::Libarchive::XS::archive_entry_atime_nsec;

1;
