package Archive::Libarchive::XS::Callback;

use strict;
use warnings;

# ABSTRACT: libarchive callback functions
# VERSION

=head1 SYNOPSIS

 # TODO

=head1 DESCRIPTION

This document provides information of callback routines for writing
custom input/output interfaces to the libarchive perl bindings.

=head2 data

=head2 open

=head2 read

=head2 write

=head2 skip

=head2 seek

=head2 close

=cut

package
  Archive::Libarchive::XS;

use constant {
  CB_DATA        => 0,
  CB_READ        => 1,
  CB_CLOSE       => 2,
  CB_OPEN        => 3,
  CB_WRITE       => 4,
  CB_SKIP        => 5,
  CB_SEEK        => 6,
  CB_BUFFER      => 7,
};
    
my %callbacks;

sub ARCHIVE_FATAL ();
sub ARCHIVE_OK    ();

sub archive_read_set_callback_data ($$)
{
  my($archive, $data) = @_;
  $callbacks{$archive}->[CB_DATA] = $data;
  ARCHIVE_OK;
}

foreach my $name (qw( open read skip close seek ))
{
  my $const = 'CB_' . uc $name;
  eval '# line '. __LINE__ . ' "' . __FILE__ . "\n" . qq{
    sub archive_read_set_$name\_callback (\$\$)
    {
      my(\$archive, \$callback) = \@_;
      \$callbacks{\$archive}->[$const] = \$callback;
      _archive_read_set_$name\_callback(\$archive, \$callback);
    }
  }; die $@ if $@;
}

foreach my $name (qw( open skip close seek ))
{
  my $uc_name = uc $name;
  eval '# line '. __LINE__ . ' "' . __FILE__ . "\n" . qq{
    sub _my$name
    {
      my \$archive = shift;
      my \$status = eval { \$callbacks{\$archive}->[CB_$uc_name]->(\$archive, \$callbacks{\$archive}->[CB_DATA],@_) };
      if(\$\@)
      {
        warn \$\@;
        return ARCHIVE_FATAL;
      }
      \$status;
    }
  }; die $@ if $@;
}

sub _myread
{
  my($archive) = @_;
  my ($status, $buffer) = eval {
    $callbacks{$archive}->[CB_READ]->(
      $archive, 
      $callbacks{$archive}->[CB_DATA],
    )
  };
  if($@)
  {
    warn $@;
    return (ARCHIVE_FATAL, undef);
  }
  $callbacks{$archive}->[CB_BUFFER] = \$buffer;
  ($status, $callbacks{$archive}->[CB_BUFFER]);
}

sub _mywrite
{
  my($archive, $buffer) = @_;
  my $status = eval {
    $callbacks{$archive}->[CB_WRITE]->(
      $archive, 
      $callbacks{$archive}->[CB_DATA],
      $buffer,
    )
  };
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

sub archive_read_open_fh ($$;$)
{
  my($archive, $fh, $bs) = @_;
  $bs ||= 10240;
  my $data = { bs => $bs, fh => $fh };
  archive_read_open($archive, $data, undef, \&_archive_read_open_fh_read, \&_archive_read_open_fh_close);
}

sub _archive_read_open_fh_read
{
  my($archive, $data) = @_;
  my $br = read $data->{fh}, my $buffer, $data->{bs};
  if(defined $br)
  {
    return (ARCHIVE_OK(), $buffer);
  }
  else
  {
    warn 'read error';
    return ARCHIVE_FAILED();
  }
}

sub _archive_read_open_fh_close
{
  my($archive, $data) = @_;
  my $status = close $data->{fh};
  if($status)
  {
    return ARCHIVE_OK();
  }
  else
  {
    warn 'close error';
    return ARCHIVE_FATAL();
  }
}

sub archive_write_open ($$$$$)
{
  my($archive, $data, $opencb, $writecb, $closecb) = @_;
  $callbacks{$archive}->[CB_DATA]  = $data    if defined $data;
  $callbacks{$archive}->[CB_OPEN]  = $opencb  if defined $opencb;
  $callbacks{$archive}->[CB_WRITE] = $writecb if defined $writecb;
  $callbacks{$archive}->[CB_CLOSE] = $closecb if defined $closecb;
  my $ret = _archive_write_open($archive, $data, $opencb, $writecb, $closecb);
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

=head1 SEE ALSO

=over 4

=item L<Archive::Libarchive::XS>

=item L<Archive::Libarchive::XS::Constant>

=item L<Archive::Libarchive::XS::Function>

=back

=cut

