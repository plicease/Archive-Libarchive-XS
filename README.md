# Archive::Libarchive::XS ![linux](https://github.com/plicease/Archive-Libarchive-XS/workflows/linux/badge.svg)

(Deprecated) Perl bindings to libarchive via XS

# SYNOPSIS

list archive filenames

```perl
use Archive::Libarchive::XS qw( :all );

my $archive = archive_read_new();
archive_read_support_filter_all($archive);
archive_read_support_format_all($archive);
# example is a tar file, but any supported format should work
# (zip, iso9660, etc.)
archive_read_open_filename($archive, 'archive.tar', 10240);

while(archive_read_next_header($archive, my $entry) == ARCHIVE_OK)
{
  print archive_entry_pathname($entry), "\n";
  archive_read_data_skip($archive);
}

archive_read_free($archive);
```

extract archive

```perl
use Archive::Libarchive::XS qw( :all );

my $archive = archive_read_new();
archive_read_support_filter_all($archive);
archive_read_support_format_all($archive);
my $disk = archive_write_disk_new();
archive_write_disk_set_options($disk,
  ARCHIVE_EXTRACT_TIME   |
  ARCHIVE_EXTRACT_PERM   |
  ARCHIVE_EXTRACT_ACL    |
  ARCHIVE_EXTRACT_FFLAGS
);
archive_write_disk_set_standard_lookup($disk);
archive_read_open_filename($archive, 'archive.tar', 10240);

while(1)
{
  my $r = archive_read_next_header($archive, my $entry);
  last if $r == ARCHIVE_EOF;

  archive_write_header($disk, $entry);

  while(1)
  {
    my $r = archive_read_data_block($archive, my $buffer, my $offset);
    last if $r == ARCHIVE_EOF;
    archive_write_data_block($disk, $buffer, $offset);
  }
}

archive_read_close($archive);
archive_read_free($archive);
archive_write_close($disk);
archive_write_free($disk);
```

write archive

```perl
use File::stat;
use File::Slurp qw( read_file );
use Archive::Libarchive::XS qw( :all );

my $archive = archive_write_new();
# many other formats are supported ...
archive_write_set_format_pax_restricted($archive);
archive_write_open_filename($archive, 'archive.tar');

foreach my $filename (@filenames)
{
  my $entry = archive_entry_new();
  archive_entry_set_pathname($entry, $filename);
  archive_entry_set_size($entry, stat($filename)->size);
  archive_entry_set_filetype($entry, AE_IFREG);
  archive_entry_set_perm($entry, 0644);
  archive_write_header($archive, $entry);
  archive_write_data($archive, scalar read_file($filename));
  archive_entry_free($entry);
}
archive_write_close($archive);
archive_write_free($archive);
```

# DESCRIPTION

**NOTE**: This module has been deprecated in favor of [Archive::Libarchive](https://metacpan.org/pod/Archive::Libarchive).
It provides a better thought out object-oriented interface and is easier
to maintain.

This module provides a functional interface to libarchive.  libarchive is a
C library that can read and write archives in a variety of formats and with a
variety of compression filters, optimized in a stream oriented way.  A familiarity
with the libarchive documentation would be helpful, but may not be necessary
for simple tasks.  The documentation for this module is split into four separate
documents:

- [Archive::Libarchive::XS](https://metacpan.org/pod/Archive::Libarchive::XS)

    This document, contains an overview and some examples.

- [Archive::Libarchive::XS::Callback](https://metacpan.org/pod/Archive::Libarchive::XS::Callback)

    Documents the callback interface, used for customizing input and output.

- [Archive::Libarchive::XS::Constant](https://metacpan.org/pod/Archive::Libarchive::XS::Constant)

    Documents the constants provided by this module.

- [Archive::Libarchive::XS::Function](https://metacpan.org/pod/Archive::Libarchive::XS::Function)

    The function reference, includes a list of all functions provided by this module.

If you are linking against an older version of libarchive, some functions
and constants may not be available.  You can use the `can` method to test if
a function or constant is available, for example:

```
if(Archive::Libarchive::XS->can('archive_read_support_filter_grzip')
{
  # grzip filter is available.
}

if(Archive::Libarchive::XS->can('ARCHIVE_OK'))
{
  # ... although ARCHIVE_OK should always be available.
}
```

# EXAMPLES

These examples are translated from equivalent C versions provided on the
libarchive website, and are annotated here with Perl specific details.
These examples are also included with the distribution.

## List contents of archive stored in file

```perl
use strict;
use warnings;
use Archive::Libarchive::XS qw( :all );

# this is a translation to perl for this:
#  https://github.com/libarchive/libarchive/wiki/Examples#wiki-List_contents_of_Archive_stored_in_File

my $a = archive_read_new();
archive_read_support_filter_all($a);
archive_read_support_format_all($a);

my $r = archive_read_open_filename($a, "archive.tar", 10240);
if($r != ARCHIVE_OK)
{
  die "error opening archive.tar: ", archive_error_string($a);
}

while (archive_read_next_header($a, my $entry) == ARCHIVE_OK)
{
  print archive_entry_pathname($entry), "\n";
  archive_read_data_skip($a);
}

$r = archive_read_free($a);
if($r != ARCHIVE_OK)
{
  die "error freeing archive";
}
```

## List contents of archive stored in memory

```perl
use strict;
use warnings;
use Archive::Libarchive::XS qw( :all );

# this is a translation to perl for this:
#  https://github.com/libarchive/libarchive/wiki/Examples#wiki-List_contents_of_Archive_stored_in_Memory

my $buff = do {
  open my $fh, '<', "archive.tar.gz";
  local $/;
  <$fh>
};

my $a = archive_read_new();
archive_read_support_filter_gzip($a);
archive_read_support_format_tar($a);
my $r = archive_read_open_memory($a, $buff);
if($r != ARCHIVE_OK)
{
  print "r = $r\n";
  die "error opening archive.tar: ", archive_error_string($a);
}

while (archive_read_next_header($a, my $entry) == ARCHIVE_OK) {
  print archive_entry_pathname($entry), "\n";
  archive_read_data_skip($a);
}

$r = archive_read_free($a);
if($r != ARCHIVE_OK)
{
  die "error freeing archive";
}
```

## List contents of archive with custom read functions

```perl
use strict;
use warnings;
use Archive::Libarchive::XS qw( :all );

list_archive(shift @ARGV);

sub list_archive
{
  my $name = shift;
  my %mydata;
  my $a = archive_read_new();
  $mydata{name} = $name;
  open $mydata{fh}, '<', $name;
  archive_read_support_filter_all($a);
  archive_read_support_format_all($a);
  archive_read_open($a, \%mydata, undef, \&myread, \&myclose);
  while(archive_read_next_header($a, my $entry) == ARCHIVE_OK)
  {
    print archive_entry_pathname($entry), "\n";
  }
  archive_read_free($a);
}

sub myread
{
  my($archive, $mydata) = @_;
  my $br = read $mydata->{fh}, my $buffer, 10240;
  return (ARCHIVE_OK, $buffer);
}

sub myclose
{
  my($archive, $mydata) = @_;
  close $mydata->{fh};
  %$mydata = ();
  return ARCHIVE_OK;
}
```

## A universal decompressor

```perl
use strict;
use warnings;
use Archive::Libarchive::XS qw( :all );

# this is a translation to perl for this:
#  https://github.com/libarchive/libarchive/wiki/Examples#a-universal-decompressor

my $r;

my $a = archive_read_new();
archive_read_support_filter_all($a);
archive_read_support_format_raw($a);
$r = archive_read_open_filename($a, "hello.txt.gz.uu", 16384);
if($r != ARCHIVE_OK)
{
  die archive_error_string($a);
}

$r = archive_read_next_header($a, my $ae);
if($r != ARCHIVE_OK)
{
  die archive_error_string($a);
}

while(1)
{
  my $size = archive_read_data($a, my $buff, 1024);
  if($size < 0)
  {
    die archive_error_string($a);
  }
  if($size == 0)
  {
    last;
  }
  print $buff;
}

archive_read_free($a);
```

## A basic write example

```perl
use strict;
use warnings;
use autodie;
use File::stat;
use Archive::Libarchive::XS qw( :all );

# this is a translation to perl for this:
#  https://github.com/libarchive/libarchive/wiki/Examples#wiki-A_Basic_Write_Example

sub write_archive
{
  my($outname, @filenames) = @_;

  my $a = archive_write_new();

  archive_write_add_filter_gzip($a);
  archive_write_set_format_pax_restricted($a);
  archive_write_open_filename($a, $outname);

  foreach my $filename (@filenames)
  {
    my $st = stat $filename;
    my $entry = archive_entry_new();
    archive_entry_set_pathname($entry, $filename);
    archive_entry_set_size($entry, $st->size);
    archive_entry_set_filetype($entry, AE_IFREG);
    archive_entry_set_perm($entry, 0644);
    archive_write_header($a, $entry);
    open my $fh, '<', $filename;
    my $len = read $fh, my $buff, 8192;
    while($len > 0)
    {
      archive_write_data($a, $buff);
      $len = read $fh, $buff, 8192;
    }
    close $fh;

    archive_entry_free($entry);
  }
  archive_write_close($a);
  archive_write_free($a);
}

unless(@ARGV > 0)
{
  print "usage: perl basic_write.pl archive.tar.gz file1 [ file2 [ ... ] ]\n";
  exit 2;
}

unless(@ARGV > 1)
{
  print "Cowardly refusing to create an empty archive\n";
  exit 2;
}

write_archive(@ARGV);
```

## Constructing objects on disk

```perl
use strict;
use warnings;
use Archive::Libarchive::XS qw( :all );

# this is a translation to perl for this:
#  https://github.com/libarchive/libarchive/wiki/Examples#wiki-Constructing_Objects_On_Disk

my $a = archive_write_disk_new();
archive_write_disk_set_options($a, ARCHIVE_EXTRACT_TIME);

my $entry = archive_entry_new();
archive_entry_set_pathname($entry, "my_file.txt");
archive_entry_set_filetype($entry, AE_IFREG);
archive_entry_set_size($entry, 5);
archive_entry_set_mtime($entry, 123456789, 0);
archive_entry_set_perm($entry, 0644);
archive_write_header($a, $entry);
archive_write_data($a, "abcde");
archive_write_finish_entry($a);
archive_write_free($a);
archive_entry_free($entry);
```

## A complete extractor

```perl
use strict;
use warnings;
use Archive::Libarchive::XS qw( :all );

# this is a translation to perl for this:
#  https://github.com/libarchive/libarchive/wiki/Examples#wiki-A_Complete_Extractor

my $filename = shift @ARGV;

unless(defined $filename)
{
  warn "reading archive from standard in";
}

my $r;

my $flags = ARCHIVE_EXTRACT_TIME
          | ARCHIVE_EXTRACT_PERM
          | ARCHIVE_EXTRACT_ACL
          | ARCHIVE_EXTRACT_FFLAGS;

my $a = archive_read_new();
archive_read_support_filter_all($a);
archive_read_support_format_all($a);
my $ext = archive_write_disk_new();
archive_write_disk_set_options($ext, $flags);
archive_write_disk_set_standard_lookup($ext);

$r = archive_read_open_filename($a, $filename, 10240);
if($r != ARCHIVE_OK)
{
  die "error opening $filename: ", archive_error_string($a);
}

while(1)
{
  $r = archive_read_next_header($a, my $entry);
  if($r == ARCHIVE_EOF)
  {
    last;
  }
  if($r != ARCHIVE_OK)
  {
    print archive_error_string($a), "\n";
  }
  if($r < ARCHIVE_WARN)
  {
    exit 1;
  }
  $r = archive_write_header($ext, $entry);
  if($r != ARCHIVE_OK)
  {
    print archive_error_string($ext), "\n";
  }
  elsif(archive_entry_size($entry) > 0)
  {
    copy_data($a, $ext);
  }
}

archive_read_close($a);
archive_read_free($a);
archive_write_close($ext);
archive_write_free($ext);

sub copy_data
{
  my($ar, $aw) = @_;
  my $r;
  while(1)
  {
    $r = archive_read_data_block($ar, my $buff, my $offset);
    if($r == ARCHIVE_EOF)
    {
      return;
    }
    if($r != ARCHIVE_OK)
    {
      die archive_error_string($ar), "\n";
    }
    $r = archive_write_data_block($aw, $buff, $offset);
    if($r != ARCHIVE_OK)
    {
      die archive_error_string($aw), "\n";
    }
  }
}
```

## Unicode

Libarchive deals with two types of string like data.  Pathnames, user and
group names are proper strings and are encoded in the codeset for the
current POSIX locale.  Content data for files stored and retrieved from in
raw bytes.

The usual operational procedure in Perl is to convert everything on input
into UTF-8, operate on the UTF-8 data and then convert (if necessary)
everything on output to the desired output format.

In order to get useful string data out of libarchive, this module translates
its input/output using the codeset for the current POSIX locale.  So you must
be using a POSIX locale that supports the characters in the pathnames of
the archives you are going to process, and it is highly recommend that you
use a UTF-8 locale, which should cover everything.

```perl
use strict;
use warnings;
use utf8;
use Archive::Libarchive::XS qw( :all );
use POSIX qw( setlocale LC_ALL );

# substitute en_US.utf8 for the correct UTF-8 locale for your region.
setlocale(LC_ALL, "en_US.utf8"); # or 'export LANG=en_US.utf8' from your shell.

my $entry = archive_entry_new();

archive_entry_set_pathname($entry, "привет.txt");
my $string = archive_entry_pathname($entry); # "привет.txt"

archive_entry_free($entry);
```

If you try to pass a string with characters unsupported by your
current locale, the behavior is undefined.  If you try to retrieve
strings with characters unsupported by your current locale you will
get `undef`.

Unfortunately locale names are not portable across systems, so you should
probably not hard code the locale as shown here unless you know the correct
locale name for all the platforms that your script will run.

There are two Perl only functions that give information about the
current codeset as understood by libarchive.
[archive\_perl\_utf8\_mode](https://metacpan.org/pod/Archive::Libarchive::XS::Function#archive_perl_utf8_mode)
if the currently selected codeset is UTF-8.

```perl
use strict;
use warnings;
use Archive::Libarchive::XS qw( :all );

die "must use UTF-8 locale" unless archive_perl_utf8_mode();
```

[archive\_perl\_codeset](https://metacpan.org/pod/Archive::Libarchive::XS::Function#archive_perl_codeset)
returns the currently selected codeset.

```perl
use strict;
use warnings;
use Archive::Libarchive::XS qw( :all );

my $entry = archive_entry_new();

if(archive_perl_codeset() =~ /^(ISO-8859-5|CP1251|KOI8-R|UTF-8)$/)
{
  archive_entry_set_pathname($entry, "привет.txt");
  my $string = archive_entry_pathname($entry); # "привет.txt"
}
else
{
  archive_entry_set_pathname($entry, "privet.txt");
  my $string = archive_entry_pathname($entry); # "privet.txt"
}
```

Because libarchive reads and writes file content within an archive using
raw bytes, if your file content has non ASCII characters in it, then
you need to encode them

```perl
use Encode qw( encode );

archive_write_data($archive, encode('UTF-8', "привет.txt");
# or
archive_write_data($archive, encode('KOI8-R', "привет.txt");
```

read:

```perl
use Encode qw( decode );

my $raw;
archive_read_data($archive, $raw, 10240);
my $decoded_content = decode('UTF-8', $raw);
# or
my $decoded_content = decode('KOI8-R', $raw);
```

# SUPPORT

If you find bugs, please open an issue on the project GitHub repository:

[https://github.com/plicease/Archive-Libarchive-XS/issues?state=open](https://github.com/plicease/Archive-Libarchive-XS/issues?state=open)

If you have a fix, please open a pull request.  You can see the CONTRIBUTING
file for traps, hints and pitfalls.

# CAVEATS

Archive and entry objects are really pointers to opaque C structures
and need to be freed using one of
[archive\_read\_free](https://metacpan.org/pod/Archive::Libarchive::XS::Function#archive_read_free),
[archive\_write\_free](https://metacpan.org/pod/Archive::Libarchive::XS::Function#archive_write_free) or
[archive\_entry\_free](https://metacpan.org/pod/Archive::Libarchive::XS::Function#archive_entry_free),
in order to free the resources associated with those objects.

Proper Unicode (or non-ASCII character support) depends on setting the
correct POSIX locale, which is system dependent.

The documentation that comes with libarchive is not that great (by its own
admission), being somewhat incomplete, and containing a few subtle errors.
In writing the documentation for this distribution, I borrowed heavily (read:
stole wholesale) from the libarchive documentation, making changes where
appropriate for use under Perl (changing `NULL` to `undef` for example, along
with the interface change to make that work).  I may and probably have introduced
additional subtle errors.  Patches to the documentation that match the
implementation, or fixes to the implementation so that it matches the
documentation (which ever is appropriate) would greatly appreciated.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
