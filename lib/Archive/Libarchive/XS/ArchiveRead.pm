package Archive::Libarchive::XS::ArchiveRead;

use strict;
use warnings;
use Archive::Libarchive::XS qw( ARCHIVE_OK ARCHIVE_WARN ARCHIVE_EOF );
use Archive::Libarchive::XS::Entry;
use base qw( Archive::Libarchive::XS::OO );

# ABSTRACT: OO representation of a stream oriented archive for reading
# VERSION

sub new
{
  my($class) = @_;
  $class->SUPER::new(Archive::Libarchive::XS::archive_read_new());
}

*support_filter_all = \&Archive::Libarchive::XS::archive_read_support_filter_all;
*support_format_all = \&Archive::Libarchive::XS::archive_read_support_format_all;
*open_memory = \&Archive::Libarchive::XS::archive_read_open_memory;
*open_filename = \&Archive::Libarchive::XS::archive_read_open_filename;
*open = \&Archive::Libarchive::XS::archive_read_open;
*open_fh = \&Archive::Libarchive::XS::archive_read_open_fh;
*file_count = \&Archive::Libarchive::XS::archive_file_count;
*error_string = \&Archive::Libarchive::XS::archive_error_string;
*filter_count = \&Archive::Libarchive::XS::archive_filter_count;
*filter_code = \&Archive::Libarchive::XS::archive_filter_code;
*filter_name = \&Archive::Libarchive::XS::archive_filter_name;
*format = \&Archive::Libarchive::XS::archive_format;
*format_name = \&Archive::Libarchive::XS::archive_format_name;
*data_skip = \&Archive::Libarchive::XS::archive_read_data_skip;

sub next_header
{
  my($self) = @_;
  my $r = Archive::Libarchive::XS::archive_read_next_header($self, my $entry);
  return Archive::Libarchive::XS::Entry->new($entry) if $r == ARCHIVE_OK || $r == ARCHIVE_WARN;
  return if $r == ARCHIVE_EOF;
  die $self->error_string;
}

sub DESTROY
{
  my($self) = @_;
  Archive::Libarchive::XS::archive_read_free($self);
}

1;
