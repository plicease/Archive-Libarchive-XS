package Archive::Libarchive::XS;

use strict;
use warnings;
use base qw( Exporter );
use Alien::Libarchive;

# ABSTRACT: Perl bindings to libarchive via XS
# VERSION

our @EXPORT_OK = qw(
  archive_read_new
  archive_read_support_filter_all
  archive_read_support_format_all
  archive_read_open_filename
  archive_error_string
  archive_read_next_header
  archive_entry_pathname
  archive_read_data_skip
  archive_read_free  
  archive_version_string
  archive_version_number
  archive_entry_pathname
  
  ARCHIVE_OK
  ARCHIVE_EOF
);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

require XSLoader;
XSLoader::load('Archive::Libarchive::XS', $VERSION);

sub ARCHIVE_OK  { constant("ARCHIVE_OK") }
sub ARCHIVE_EOF { constant("ARCHIVE_EOF") }

1;
