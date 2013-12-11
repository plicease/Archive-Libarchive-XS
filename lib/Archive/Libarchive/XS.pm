package Archive::Libarchive::XS;

use strict;
use warnings;
use Alien::Libarchive;
use Encode qw( decode );

# note: this file is generated, the original
# template comes with the dist in
#  inc/XS.pm.template

BEGIN {

# ABSTRACT: Perl bindings to libarchive via XS
# VERSION

  require XSLoader;
  XSLoader::load('Archive::Libarchive::XS', $VERSION);

}

=head1 SYNOPSIS

list archive filenames

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

extract archive

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

write archive

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

=head1 DESCRIPTION

This module provides a functional interface to libarchive.  libarchive is a
C library that can read and write archives in a variety of formats and with a 
variety of compression filters, optimized in a stream oriented way.  A familiarity
with the libarchive documentation would be helpful, but may not be necessary
for simple tasks.  The documentation for this module is split into four separate
documents:

=over 4

=item L<Archive::Libarchive::XS>

This document, contains an overview and some examples.

=item L<Archive::Libarchive::XS::Callback>

Documents the callback interface, used for customizing input and output.

=item L<Archive::Libarchive::XS::Constant>

Documents the constants provided by this module.

=item L<Archive::Libarchive::XS::Function>

The function reference, includes a list of all functions provided by this module.

=back

If you are linking against an older version of libarchive, some functions
and constants may not be available.  You can use the C<can> method to test if
a function or constant is available, for example:

 if(Archive::Libarchive::XS->can('archive_read_support_filter_grzip')
 {
   # grzip filter is available.
 }
 
 if(Archive::Libarchive::XS->can('ARCHIVE_OK'))
 {
   # ... although ARCHIVE_OK should always be available.
 }

=cut

sub _define_constant ($) {
  my($name) = @_;
  my $value = eval { _constant($name) };
  return if $@;
  eval qq{ sub $name() { $value }; 1 };
}

require Archive::Libarchive::XS::Callback;
require Archive::Libarchive::XS::Common;

sub archive_entry_gname
{
  decode(archive_perl_codeset(),_archive_entry_gname(@_));
}

sub archive_entry_hardlink
{
  decode(archive_perl_codeset(),_archive_entry_hardlink(@_));
}

sub archive_entry_pathname
{
  decode(archive_perl_codeset(),_archive_entry_pathname(@_));
}

sub archive_entry_symlink
{
  decode(archive_perl_codeset(),_archive_entry_symlink(@_));
}

sub archive_entry_uname
{
  decode(archive_perl_codeset(),_archive_entry_uname(@_));
}

*archive_entry_copy_mac_metadata = \&archive_entry_set_mac_metadata
  if __PACKAGE__->can('archive_entry_set_mac_metadata');

eval q{
  use Exporter::Tidy
    func  => [grep /^archive_/, keys %Archive::Libarchive::XS::],
    const => [grep { _define_constant($_) } qw(
      AE_IFBLK
      AE_IFCHR
      AE_IFDIR
      AE_IFIFO
      AE_IFLNK
      AE_IFMT
      AE_IFREG
      AE_IFSOCK
      ARCHIVE_API_FEATURE
      ARCHIVE_API_VERSION
      ARCHIVE_BYTES_PER_RECORD
      ARCHIVE_COMPRESSION_BZIP2
      ARCHIVE_COMPRESSION_COMPRESS
      ARCHIVE_COMPRESSION_GZIP
      ARCHIVE_COMPRESSION_LRZIP
      ARCHIVE_COMPRESSION_LZIP
      ARCHIVE_COMPRESSION_LZMA
      ARCHIVE_COMPRESSION_NONE
      ARCHIVE_COMPRESSION_PROGRAM
      ARCHIVE_COMPRESSION_RPM
      ARCHIVE_COMPRESSION_UU
      ARCHIVE_COMPRESSION_XZ
      ARCHIVE_DEFAULT_BYTES_PER_BLOCK
      ARCHIVE_ENTRY_ACL_ADD_FILE
      ARCHIVE_ENTRY_ACL_ADD_SUBDIRECTORY
      ARCHIVE_ENTRY_ACL_APPEND_DATA
      ARCHIVE_ENTRY_ACL_DELETE
      ARCHIVE_ENTRY_ACL_DELETE_CHILD
      ARCHIVE_ENTRY_ACL_ENTRY_DIRECTORY_INHERIT
      ARCHIVE_ENTRY_ACL_ENTRY_FAILED_ACCESS
      ARCHIVE_ENTRY_ACL_ENTRY_FILE_INHERIT
      ARCHIVE_ENTRY_ACL_ENTRY_INHERIT_ONLY
      ARCHIVE_ENTRY_ACL_ENTRY_NO_PROPAGATE_INHERIT
      ARCHIVE_ENTRY_ACL_ENTRY_SUCCESSFUL_ACCESS
      ARCHIVE_ENTRY_ACL_EVERYONE
      ARCHIVE_ENTRY_ACL_EXECUTE
      ARCHIVE_ENTRY_ACL_GROUP
      ARCHIVE_ENTRY_ACL_GROUP_OBJ
      ARCHIVE_ENTRY_ACL_INHERITANCE_NFS4
      ARCHIVE_ENTRY_ACL_LIST_DIRECTORY
      ARCHIVE_ENTRY_ACL_MASK
      ARCHIVE_ENTRY_ACL_OTHER
      ARCHIVE_ENTRY_ACL_PERMS_NFS4
      ARCHIVE_ENTRY_ACL_PERMS_POSIX1E
      ARCHIVE_ENTRY_ACL_READ
      ARCHIVE_ENTRY_ACL_READ_ACL
      ARCHIVE_ENTRY_ACL_READ_ATTRIBUTES
      ARCHIVE_ENTRY_ACL_READ_DATA
      ARCHIVE_ENTRY_ACL_READ_NAMED_ATTRS
      ARCHIVE_ENTRY_ACL_STYLE_EXTRA_ID
      ARCHIVE_ENTRY_ACL_STYLE_MARK_DEFAULT
      ARCHIVE_ENTRY_ACL_SYNCHRONIZE
      ARCHIVE_ENTRY_ACL_TYPE_ACCESS
      ARCHIVE_ENTRY_ACL_TYPE_ALARM
      ARCHIVE_ENTRY_ACL_TYPE_ALLOW
      ARCHIVE_ENTRY_ACL_TYPE_AUDIT
      ARCHIVE_ENTRY_ACL_TYPE_DEFAULT
      ARCHIVE_ENTRY_ACL_TYPE_DENY
      ARCHIVE_ENTRY_ACL_TYPE_NFS4
      ARCHIVE_ENTRY_ACL_TYPE_POSIX1E
      ARCHIVE_ENTRY_ACL_USER
      ARCHIVE_ENTRY_ACL_USER_OBJ
      ARCHIVE_ENTRY_ACL_WRITE
      ARCHIVE_ENTRY_ACL_WRITE_ACL
      ARCHIVE_ENTRY_ACL_WRITE_ATTRIBUTES
      ARCHIVE_ENTRY_ACL_WRITE_DATA
      ARCHIVE_ENTRY_ACL_WRITE_NAMED_ATTRS
      ARCHIVE_ENTRY_ACL_WRITE_OWNER
      ARCHIVE_EOF
      ARCHIVE_EXTRACT_ACL
      ARCHIVE_EXTRACT_FFLAGS
      ARCHIVE_EXTRACT_HFS_COMPRESSION_FORCED
      ARCHIVE_EXTRACT_MAC_METADATA
      ARCHIVE_EXTRACT_NO_AUTODIR
      ARCHIVE_EXTRACT_NO_HFS_COMPRESSION
      ARCHIVE_EXTRACT_NO_OVERWRITE
      ARCHIVE_EXTRACT_NO_OVERWRITE_NEWER
      ARCHIVE_EXTRACT_OWNER
      ARCHIVE_EXTRACT_PERM
      ARCHIVE_EXTRACT_SECURE_NODOTDOT
      ARCHIVE_EXTRACT_SECURE_SYMLINKS
      ARCHIVE_EXTRACT_SPARSE
      ARCHIVE_EXTRACT_TIME
      ARCHIVE_EXTRACT_UNLINK
      ARCHIVE_EXTRACT_XATTR
      ARCHIVE_FAILED
      ARCHIVE_FATAL
      ARCHIVE_FILTER_BZIP2
      ARCHIVE_FILTER_COMPRESS
      ARCHIVE_FILTER_GRZIP
      ARCHIVE_FILTER_GZIP
      ARCHIVE_FILTER_LRZIP
      ARCHIVE_FILTER_LZIP
      ARCHIVE_FILTER_LZMA
      ARCHIVE_FILTER_LZOP
      ARCHIVE_FILTER_NONE
      ARCHIVE_FILTER_PROGRAM
      ARCHIVE_FILTER_RPM
      ARCHIVE_FILTER_UU
      ARCHIVE_FILTER_XZ
      ARCHIVE_FORMAT_7ZIP
      ARCHIVE_FORMAT_AR
      ARCHIVE_FORMAT_AR_BSD
      ARCHIVE_FORMAT_AR_GNU
      ARCHIVE_FORMAT_BASE_MASK
      ARCHIVE_FORMAT_CAB
      ARCHIVE_FORMAT_CPIO
      ARCHIVE_FORMAT_CPIO_AFIO_LARGE
      ARCHIVE_FORMAT_CPIO_BIN_BE
      ARCHIVE_FORMAT_CPIO_BIN_LE
      ARCHIVE_FORMAT_CPIO_POSIX
      ARCHIVE_FORMAT_CPIO_SVR4_CRC
      ARCHIVE_FORMAT_CPIO_SVR4_NOCRC
      ARCHIVE_FORMAT_EMPTY
      ARCHIVE_FORMAT_ISO9660
      ARCHIVE_FORMAT_ISO9660_ROCKRIDGE
      ARCHIVE_FORMAT_LHA
      ARCHIVE_FORMAT_MTREE
      ARCHIVE_FORMAT_RAR
      ARCHIVE_FORMAT_RAW
      ARCHIVE_FORMAT_SHAR
      ARCHIVE_FORMAT_SHAR_BASE
      ARCHIVE_FORMAT_SHAR_DUMP
      ARCHIVE_FORMAT_TAR
      ARCHIVE_FORMAT_TAR_GNUTAR
      ARCHIVE_FORMAT_TAR_PAX_INTERCHANGE
      ARCHIVE_FORMAT_TAR_PAX_RESTRICTED
      ARCHIVE_FORMAT_TAR_USTAR
      ARCHIVE_FORMAT_XAR
      ARCHIVE_FORMAT_ZIP
      ARCHIVE_LIBRARY_VERSION
      ARCHIVE_MATCH_CTIME
      ARCHIVE_MATCH_EQUAL
      ARCHIVE_MATCH_MTIME
      ARCHIVE_MATCH_NEWER
      ARCHIVE_MATCH_OLDER
      ARCHIVE_OK
      ARCHIVE_READDISK_HONOR_NODUMP
      ARCHIVE_READDISK_MAC_COPYFILE
      ARCHIVE_READDISK_NO_TRAVERSE_MOUNTS
      ARCHIVE_READDISK_RESTORE_ATIME
      ARCHIVE_RETRY
      ARCHIVE_VERSION_NUMBER
      ARCHIVE_VERSION_STAMP
      ARCHIVE_WARN
  )],
}; die $@ if $@;

1;

=head1 EXAMPLES

These examples are translated from equivalent C versions provided on the
libarchive website, and are annotated here with Perl specific details.
These examples are also included with the distribution.

=head2 List contents of archive stored in file

# EXAMPLE: example/list_contents_of_archive_stored_in_file.pl

=head2 List contents of archive stored in memory

# EXAMPLE: example/list_contents_of_archive_stored_in_memory.pl

=head2 List contents of archive with custom read functions

# EXAMPLE: example/list_contents_of_archive_with_custom_read_functions.pl

=head2 A universal decompressor

# EXAMPLE: example/universal_decompressor.pl

=head2 A basic write example

# EXAMPLE: example/basic_write.pl

=head2 Constructing objects on disk

# EXAMPLE: example/constructing_objects_on_disk.pl

=head2 A complete extractor

# EXAMPLE: example/complete_extractor.pl

=head2 Unicode

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

If you try to pass a string with characters unsupported by your
current locale, the behavior is undefined.  If you try to retrieve
strings with characters unsupported by your current locale you will
get C<undef>.

Unfortunately locale names are not portable across systems, so you should
probably not hard code the locale as shown here unless you know the correct
locale name for all the platforms that your script will run.

There are two Perl only functions that give information about the
current codeset as understood by libarchive.
L<archive_perl_utf8_mode|Archive::Libarchive::XS::Function#archive_perl_utf8_mode>
if the currently selected codeset is UTF-8.

 use strict;
 use warnings;
 use Archive::Libarchive::XS qw( :all );
 
 die "must use UTF-8 locale" unless archive_perl_utf8_mode();

L<archive_perl_codeset|Archive::Libarchive::XS::Function#archive_perl_codeset>
returns the currently selected codeset.

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

Because libarchive reads and writes file content within an archive using
raw bytes, if your file content has non ASCII characters in it, then
you need to encode them

 use Encode qw( encode );
 
 archive_write_data($archive, encode('UTF-8', "привет.txt");
 # or
 archive_write_data($archive, encode('KOI8-R', "привет.txt"); 

read:

 use Encode qw( decode );
 
 my $raw;
 archive_read_data($archive, $raw, 10240);
 my $decoded_content = decode('UTF-8', $raw);
 # or
 my $decoded_content = decode('KOI8-R', $raw);

=head1 CAVEATS

Archive and entry objects are really pointers to opaque C structures
and need to be freed using one of 
L<archive_read_free|Archive::Libarchive::XS::Function#archive_read_free>, 
L<archive_write_free|Archive::Libarchive::XS::Function#archive_write_free> or 
L<archive_entry_free|Archive::Libarchive::XS::Function#archive_entry_free>, 
in order to free the resources associated with those objects.

Proper Unicode (or non-ASCII character support) depends on setting the
correct POSIX locale, which is system dependent.

The documentation that comes with libarchive is not that great (by its own
admission), being somewhat incomplete, and containing a few subtle errors.
In writing the documentation for this distribution, I borrowed heavily (read:
stole wholesale) from the libarchive documentation, making changes where 
appropriate for use under Perl (changing C<NULL> to C<undef> for example, along 
with the interface change to make that work).  I may and probably have introduced 
additional subtle errors.  Patches to the documentation that match the
implementation, or fixes to the implementation so that it matches the
documentation (which ever is appropriate) would greatly appreciated.

=cut
