package Archive::Libarchive::XS::Callback;

use strict;
use warnings;

# ABSTRACT: libarchive callback functions
# VERSION

package
  Archive::Libarchive::XS;

use constant {
  CB_DATA        => 0,
  CB_READ        => 1,
  CB_CLOSE       => 2,
  CB_OPEN        => 3,
  CB_SKIP        => 4,
  CB_SEEK        => 5,
  CB_WRITE       => 6,
  CB_SWITCH      => 7,
};
    
my %callbacks;

sub ARCHIVE_OK   ();
sub ARCHIVE_WARN ();

sub archive_read_open ($$$$$)
{
  my($archive, $data, $opencb, $readcb, $closecb) = @_;
  my $ret = _archive_read_open($archive, $data, $opencb, $readcb, $closecb);
  
  if($ret == ARCHIVE_OK || $ret == ARCHIVE_WARN)
  {
    $callbacks{$archive}->[CB_DATA]  = $data    if defined $data;
    $callbacks{$archive}->[CB_OPEN]  = $opencb  if defined $opencb;
    $callbacks{$archive}->[CB_READ]  = $readcb  if defined $readcb;
    $callbacks{$archive}->[CB_CLOSE] = $closecb if defined $closecb;
  }
  
  $ret;
}

sub archive_read_open2 ($$$$$$)
{
  my($archive, $data, $opencb, $readcb, $skipcb, $closecb) = @_;
  my $ret = _archive_read_open2($archive, $data, $opencb, $readcb, $skipcb, $closecb);
  
  if($ret == ARCHIVE_OK || $ret == ARCHIVE_WARN)
  {
    $callbacks{$archive}->[CB_DATA]  = $data    if defined $data;
    $callbacks{$archive}->[CB_OPEN]  = $opencb  if defined $opencb;
    $callbacks{$archive}->[CB_READ]  = $readcb  if defined $readcb;
    $callbacks{$archive}->[CB_SKIP]  = $skipcb  if defined $skipcb;
    $callbacks{$archive}->[CB_CLOSE] = $closecb if defined $closecb;
  }
  
  $ret;
}

sub archive_read_free ($)
{
  my($archive) = @_;
  my $ret = _archive_read_free($archive);
  delete $callbacks{$archive};
  $ret;
}

sub archive_write_free ($)
{
  my($archive) = @_;
  my $ret = _archive_write_free($archive);
  delete $callbacks{$archive};
  $ret;
}

1;
