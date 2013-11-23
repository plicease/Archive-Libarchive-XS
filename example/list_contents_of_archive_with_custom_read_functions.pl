use strict;
use warnings;
use Archive::Libarchive::XS qw( :all );

list_archive(shift @ARGV);

sub list_archive
{
  my $name = shift;
  my %mydata = {};
  my $a = archive_read_new();
  $mydata{name} = $name;
  open $mydata{fh}, '<', $name;
  archive_read_support_filter_all($a);
  archive_read_support_format_all($a);
  archive_read_open($a, \%mydata, undef, \&myread, \&myclose);
  while(archive_read_next_header($a, my $entry) == ARCHIVE_OK)
  {
    print archive_entry_pathname($entry);
  }
  archive_read_finish($a);
}

sub myread
{
  my $mydata = shift;
  my $br = read $mydata->{fh}, my $buffer, 10240;
  return (ARCHIVE_OK, $buffer);
}

sub myclose
{
  my $mydata = shift;
  close $mydata->{fh};
  %$mydata = ();
  return ARCHIVE_OK;
}
