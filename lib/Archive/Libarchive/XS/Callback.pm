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
  CB_BUFFER      => 8,
};
    
my %callbacks;

sub ARCHIVE_FATAL ();

sub _myread
{
  my($archive) = @_;
  my ($status, $buffer) = eval { $callbacks{$archive}->[CB_READ]->($callbacks{$archive}->[CB_DATA]) };
  if($@)
  {
    warn $@;
    return (ARCHIVE_FATAL, undef);
  }
  $callbacks{$archive}->[CB_BUFFER] = \$buffer;
  ($status, $callbacks{$archive}->[CB_BUFFER]);
}

sub _myclose
{
  my($archive) = @_;
  my $status = eval { $callbacks{$archive}->[CB_CLOSE]->($callbacks{$archive}->[CB_DATA]) };
  if($@)
  {
    warn $@;
    return ARCHIVE_FATAL;
  }
  $status;
}

sub archive_read_open ($$$$$)
{
  my($archive, $data, $opencb, $readcb, $closecb) = @_;
  $callbacks{$archive}->[CB_DATA]  = $data    if defined $data;
  $callbacks{$archive}->[CB_OPEN]  = $opencb  if defined $opencb;
  $callbacks{$archive}->[CB_READ]  = $readcb  if defined $readcb;
  $callbacks{$archive}->[CB_CLOSE] = $closecb if defined $closecb;
  my $ret = _archive_read_open($archive, $data, $opencb, $readcb, $closecb);
  $ret;
}

sub archive_read_open2 ($$$$$$)
{
  my($archive, $data, $opencb, $readcb, $skipcb, $closecb) = @_;
  $callbacks{$archive}->[CB_DATA]  = $data    if defined $data;
  $callbacks{$archive}->[CB_OPEN]  = $opencb  if defined $opencb;
  $callbacks{$archive}->[CB_READ]  = $readcb  if defined $readcb;
  $callbacks{$archive}->[CB_SKIP]  = $skipcb  if defined $skipcb;
  $callbacks{$archive}->[CB_CLOSE] = $closecb if defined $closecb;
  my $ret = _archive_read_open2($archive, $data, $opencb, $readcb, $skipcb, $closecb);
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
