use strict;
use warnings;
use Archive::Libarchive::XS::OO;
use Archive::Libarchive::XS qw( ARCHIVE_OK ARCHIVE_EOF );
use Test::More;
use FindBin ();
use File::Spec;

plan skip_all => 'requires archive_read_open'
  unless Archive::Libarchive::XS->can('archive_read_open');
plan tests => 4 * 6;

my %failures;

foreach my $mode (qw( memory filename callback fh ))
{
  # TODO: add xar back in if we can figure it out.
  foreach my $format (qw( tar tar.gz tar.Z tar.bz2 zip xar ))
  {
    my $testname = "$format $mode";
    my $ok = subtest $testname=> sub {
      plan skip_all => "$format not supported" if $format =~ /(\.gz|\.bz2|xar)$/;
      plan tests => 16;
    
      my $filename = File::Spec->catfile($FindBin::Bin, "foo.$format");
      my $r;
      my $entry;
    
      note "filename = $filename";

      my $a = Archive::Libarchive::XS::ArchiveRead->new;

      $r = $a->support_filter_all;
      is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_support_filter_all)";

      $r = $a->support_format_all;
      is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_support_format_all)";

      if($mode eq 'memory')
      {
        open my $fh, '<', $filename;
        my $buffer = do { local $/; <$fh> };
        close $fh;
        $r = $a->open_memory($buffer);
      }
      elsif($mode eq 'callback')
      {
        my %data = ( filename => $filename );
        $a->open(\%data, \&myopen, \&myread, \&myclose);
      }
      elsif($mode eq 'fh')
      {
        open my $fh, '<', $filename;
        $a->open_fh($fh);
      }
      else
      {
        $r = $a->open_filename($filename, 10240);
      }
      is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_open_$mode)";

      $entry = eval { $a->next_header };
      isa_ok $entry, 'Archive::Libarchive::XS::Entry';

      is $a->file_count, 1, "archive_file_count = 1";

      is $entry->pathname, "foo/foo.txt", 'archive_entry_pathname($entry) = foo/foo.txt';

      if(Archive::Libarchive::XS->can('archive_filter_count'))
      {
        note 'archive_filter_count     = ' . $a->filter_count;
        for(0..($a->filter_count-1)) {
          note "archive_filter_code($_)  = " . $a->filter_code($_);
          note "archive_filter_name($_)  = " . $a->filter_name($_);
        }
        note "archive_format           = " . $a->format;
        note "archive_format_name      = " . $a->format_name;
      }

      $r = $a->data_skip;
      is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_data_skip 1)";

      $entry = eval { $a->next_header };
      isa_ok $entry, 'Archive::Libarchive::XS::Entry';

      if(Archive::Libarchive::XS->can('archive_entry_atime_is_set'))
      {
        if($entry->atime_is_set)
        {
          note '+ atime      = ', $entry->atime;
          note '+ atime_nsec = ', $entry->atime_nsec;
        }
        else
        {
          note '+ no atime';
        }
      }

      is $a->file_count, 2, "archive_file_count = 2";

      is $entry->pathname, "foo/bar.txt", 'archive_entry_pathname($entry) = foo/bar.txt';

      $r = $a->data_skip;
      is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_data_skip 2)";

      $entry = eval { $a->next_header($entry) };
      isa_ok $entry, 'Archive::Libarchive::XS::Entry';

      is $a->file_count, 3, "archive_file_count = 3";

      is $entry->pathname, "foo/baz.txt", 'archive_entry_pathname($entry) = foo/baz.txt';

      $r = $a->data_skip;
      is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_data_skip 3)";

      $entry = eval { $a->next_header($entry) };
      is $entry, undef, 'end of the line';
 
    };
    $failures{$testname} = 1 unless $ok;
  }
}

if(%failures)
{
  diag "failure summary:";
  diag "  $_" for keys %failures;
}

sub myopen
{
  my($a, $d) = @_;
  open my $fh, '<', $d->{filename};
  $d->{fh} = $fh;
  note "callback: open ", $d->{filename};
  ARCHIVE_OK;
}

sub myread
{
  my($a, $d) = @_;
  my $br = read $d->{fh}, my $buffer, 100;
  note "callback: read ", $br;
  (ARCHIVE_OK, $buffer);
}

sub myclose
{
  my($a, $d) = @_;
  my $fh = $d->{fh};
  close $fh;
  note "callback: close";
  ARCHIVE_OK;
}
