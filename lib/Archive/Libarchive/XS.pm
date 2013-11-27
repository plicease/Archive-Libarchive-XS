package Archive::Libarchive::XS;

use strict;
use warnings;
use Alien::Libarchive;

BEGIN {

# ABSTRACT: Perl bindings to libarchive via XS
# VERSION

  require XSLoader;
  XSLoader::load('Archive::Libarchive::XS', $VERSION);

}

=head1 SYNOPSIS

 use Archive::Libarchive::XS;

=head1 DESCRIPTION

This module provides a functional interface to C<libarchive>.  C<libarchive> is a
C library that can read and write archives in a variety of formats and with a 
variety of compression filters, optimized in a stream oriented way.  A familiarity
with the C<libarchive> documentation would be helpful, but may not be necessary
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

eval q{
  use Exporter::Tidy
    func  => [grep /^archive_/,       keys %Archive::Libarchive::XS::],
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

=head1 CAVEATS

Archive and entry objects are really pointers to opaque C structures
and need to be freed using one of C<archive_read_free>, C<archive_write_free>
or C<archive_entry_free>, in order to free the resources associated
with those objects.

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
