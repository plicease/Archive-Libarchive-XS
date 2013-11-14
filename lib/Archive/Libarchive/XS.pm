package Archive::Libarchive::XS;

use strict;
use warnings;
use base qw( Exporter );
use Alien::Libarchive;

# ABSTRACT: Perl bindings to libarchive via XS
# VERSION

=head1 SYNOPSIS

 use Archive::Libarchive::XS;

=head1 DESCRIPTION

This module provides a functional interface to C<libarchive>.  C<libarchive> is a
C library that can read and write archives in a variety of formats and with a 
variety of compression filters, optimized in a stream oriented way.  A familiarity
with the C<libarchive> documentation would be helpful, but may not be necessary
for simple tasks.

=head1 FUNCTIONS

Unless otherwise specified, each function will return an integer return code,
with one of the following values:

=over 4

=item ARCHIVE_OK

Operation was successful

=item ARCHIVE_EOF

Fond end of archive

=item ARCHIVE_RETRY

Retry might succeed

=item ARCHIVE_WARN

Partial success

=item ARCHIVE_FAILED

Current operation cannot complete

=item ARCHIVE_FATAL

No more operations are possible

=back

If you are linking against an older version of libarchive, some of these 
functions may not be available.  You can use the C<can> method to test if
a function or constant is available, for example:

 if(Archive::Libarchive::XS->can('archive_read_support_filter_grzip')
 {
   # grzip filter is available.
 }

You can use this one-liner to determine which functions and constants
are unavailable:

 % perl -MArchive::Libarchive::XS    -E 'for(@Archive::Libarchive::XS::EXPORT_OK) { say $_ unless Archive::Libarchive::XS->can($_) }'

=head2 archive_clear_error($archive)

Clears any error information left over from a previous call Not
generally used in client code.  Does not return a value.

=head2 archive_copy_error($archive1, $archive2)

Copies error information from one archive to another.

=head2 archive_entry_pathname($entry)

Retrieve the pathname of the entry.

Returns a string value.

=head2 archive_errno($archive)

Returns a numeric error code indicating the reason for the most
recent error return.

Return type is an errno integer value.

=head2 archive_error_string($archive)

Returns a textual error message suitable for display.  The error
message here is usually more specific than that obtained from
passing the result of C<archive_errno> to C<strerror>.

Return type is a string.

=head2 archive_file_count($archive)

Returns a count of the number of files processed by this archive object.  The count
is incremented by calls to C<archive_write_header> or C<archive_read_next_header>.

=head2 archive_filter_code

Returns a numeric code identifying the indicated filter.  See C<archive_filter_count>
for details of the numbering.

=head2 archive_filter_count

Returns the number of filters in the current pipeline. For read archive handles, these 
filters are added automatically by the automatic format detection. For write archive 
handles, these filters are added by calls to the various C<archive_write_add_filter_XXX>
functions. Filters in the resulting pipeline are numbered so that filter 0 is the filter 
closest to the format handler. As a convenience, functions that expect a filter number 
will accept -1 as a synonym for the highest-numbered filter. For example, when reading 
a uuencoded gzipped tar archive, there are three filters: filter 0 is the gunzip filter, 
filter 1 is the uudecode filter, and filter 2 is the pseudo-filter that wraps the archive 
read functions. In this case, requesting C<archive_position(a,(-1))> would be a synonym
for C<archive_position(a,(2))> which would return the number of bytes currently read from 
the archive, while C<archive_position(a,(1))> would return the number of bytes after
uudecoding, and C<archive_position(a,(0))> would return the number of bytes after decompression.

TODO: add bindings for archive_position

=head2 archive_filter_name

Returns a textual name identifying the indicated filter.  See L<#archive_filter_count> for
details of the numbering.

=head2 archive_format($archive)

Returns a numeric code indicating the format of the current archive
entry.  This value is set by a successful call to
C<archive_read_next_header>.  Note that it is common for this value
to change from entry to entry.  For example, a tar archive might
have several entries that utilize GNU tar extensions and several
entries that do not.  These entries will have different format
codes.

=head2 archive_format_name($archive)

A textual description of the format of the current entry.

=head2 archive_read_data($archive, $buffer, $max_size)

Read data associated with the header just read.  Internally, this is a
convenience function that calls C<archive_read_data_block> and fills
any gaps with nulls so that callers see a single continuous stream of
data.  Returns the actual number of bytes read, 0 on end of data and
a negative value on error.

=head2 archive_read_data_skip($archive)

A convenience function that repeatedly calls C<archive_read_data> to skip
all of the data for this archive entry.

=head2 archive_read_free($archive)

Invokes C<archive_read_close> if it was not invoked manually, then
release all resources.

=head2 archive_read_new

Allocates and initializes a archive object suitable for reading from an archive.
Returns an opaque archive which may be a perl style object, or a C pointer
(depending on the implementation), either way, it can be passed into
any of the functions documented here with an <$archive> argument.

TODO: handle the unusual circumstance when this would return C NULL pointer.

=head2 archive_read_next_header($archive, $entry)

Read the header for the next entry and return an entry object
Returns an opaque archive which may be a perl style object, or a C pointer
(depending on the implementation), either way, it can be passed into
any of the functions documented here with an <$entry> argument.

TODO: maybe use archive_read_next_header2

=head2 archive_read_open_filename($archive, $filename, $block_size)

Like C<archive_read_open>, except that it accepts a simple filename
and a block size.  This function is safe for use with tape drives
or other blocked devices.

TODO: a NULL filename represents standard input.

=head2 archive_read_open_memory($archive, $buffer)

Like C<archive_read_open>, except that it uses a Perl scalar that holds the 
content of the archive.  This function does not make a copy of the data stored 
in C<$buffer>, so you should not modify the buffer until you have free the 
archive using C<archive_read_free>.

Bad things will happen if the buffer falls out of scope and is deallocated
before you free the archive, so make sure that there is a reference to the
buffer somewhere in your programmer until C<archive_read_free> is called.

=head2 archive_read_support_filter_all($archive)

Enable all available decompression filters.

=head2 archive_read_support_filter_bzip2($archive)

Enable bzip2 decompression filter.

=head2 archive_read_support_filter_compress($archive)

Enable compress decompression filter.

=head2 archive_read_support_filter_grzip($archive)

Enable grzip decompression filter.

=head2 archive_read_support_filter_gzip($archive)

Enable gzip decompression filter.

=head2 archive_read_support_filter_lrzip($archive)

Enable lrzip decompression filter.

=head2 archive_read_support_filter_lzip($archive)

Enable lzip decompression filter.

=head2 archive_read_support_filter_lzma($archive)

Enable lzma decompression filter.

=head2 archive_read_support_filter_lzop($archive)

Enable lzop decompression filter.

=head2 archive_read_support_filter_none($archive)

Enable none decompression filter.

=head2 archive_read_support_filter_program(archive, command)

Data is feed through the specified external program before being
dearchived.  Note that this disables automatic detection of the
compression format, so it makes no sense to specify this in
conjunction with any other decompression option.

TODO: also support archive_read_support_filter_program_signature

=head2 archive_read_support_format_7zip($archive)

Enable 7zip archive format.

=head2 archive_read_support_format_all($archive)

Enable all available archive formats.

=head2 archive_read_support_format_ar($archive)

Enable ar archive format.

=head2 archive_read_support_format_by_code($archive, $code)

Enables a single format specified by the format code.

=head2 archive_read_support_format_cab($archive)

Enable cab archive format.

=head2 archive_read_support_format_cpio($archive)

Enable cpio archive format.

=head2 archive_read_support_format_empty($archive)

Enable empty archive format.

=head2 archive_read_support_format_gnutar($archive)

Enable gnutar archive format.

=head2 archive_read_support_format_iso9660($archive)

Enable iso9660 archive format.

=head2 archive_read_support_format_lha($archive)

Enable lha archive format.

=head2 archive_read_support_format_mtree($archive)

Enable mtree archive format.

=head2 archive_read_support_format_rar($archive)

Enable rar archive format.

=head2 archive_read_support_format_raw($archive)

Enable raw archive format.

=head2 archive_read_support_format_tar($archive)

Enable tar archive format.

=head2 archive_read_support_format_xar($archive)

Enable xar archive format.

=head2 archive_read_support_format_zip($archive)

Enable zip archive format.

=head2 archive_version_number

Return the libarchive version as an integer.

=head2 archive_version_string

Return the libarchive as a version.

Returns a string value.

=cut

our %EXPORT_TAGS = (
  all   => [],
  const => [qw(
    AE_IFBLK
    AE_IFCHR
    AE_IFDIR
    AE_IFIFO
    AE_IFLNK
    AE_IFMT
    AE_IFREG
    AE_IFSOCK
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
    ARCHIVE_WARN
  )],
  func  => [qw(
    archive_clear_error
    archive_copy_error
    archive_entry_pathname
    archive_errno
    archive_error_string
    archive_file_count
    archive_filter_code
    archive_filter_count
    archive_filter_name
    archive_format
    archive_format_name
    archive_read_data
    archive_read_data_skip
    archive_read_free
    archive_read_new
    archive_read_next_header
    archive_read_open_filename
    archive_read_open_memory
    archive_read_support_filter_all
    archive_read_support_filter_bzip2
    archive_read_support_filter_compress
    archive_read_support_filter_grzip
    archive_read_support_filter_gzip
    archive_read_support_filter_lrzip
    archive_read_support_filter_lzip
    archive_read_support_filter_lzma
    archive_read_support_filter_lzop
    archive_read_support_filter_none
    archive_read_support_filter_program
    archive_read_support_format_7zip
    archive_read_support_format_all
    archive_read_support_format_ar
    archive_read_support_format_by_code
    archive_read_support_format_cab
    archive_read_support_format_cpio
    archive_read_support_format_empty
    archive_read_support_format_gnutar
    archive_read_support_format_iso9660
    archive_read_support_format_lha
    archive_read_support_format_mtree
    archive_read_support_format_rar
    archive_read_support_format_raw
    archive_read_support_format_tar
    archive_read_support_format_xar
    archive_read_support_format_zip
    archive_version_number
    archive_version_string
  )],
);

require XSLoader;
XSLoader::load('Archive::Libarchive::XS', $VERSION);

=head1 CONSTANTS

If provided by your libarchive library, these constants will be available and
exportable from the L<Archive::Libarchive::XS> (you may import all available
constants using the C<:const> export tag).

=over 4

=item AE_IFBLK

=item AE_IFCHR

=item AE_IFDIR

=item AE_IFIFO

=item AE_IFLNK

=item AE_IFMT

=item AE_IFREG

=item AE_IFSOCK

=item ARCHIVE_COMPRESSION_BZIP2

=item ARCHIVE_COMPRESSION_COMPRESS

=item ARCHIVE_COMPRESSION_GZIP

=item ARCHIVE_COMPRESSION_LRZIP

=item ARCHIVE_COMPRESSION_LZIP

=item ARCHIVE_COMPRESSION_LZMA

=item ARCHIVE_COMPRESSION_NONE

=item ARCHIVE_COMPRESSION_PROGRAM

=item ARCHIVE_COMPRESSION_RPM

=item ARCHIVE_COMPRESSION_UU

=item ARCHIVE_COMPRESSION_XZ

=item ARCHIVE_ENTRY_ACL_ADD_FILE

=item ARCHIVE_ENTRY_ACL_ADD_SUBDIRECTORY

=item ARCHIVE_ENTRY_ACL_APPEND_DATA

=item ARCHIVE_ENTRY_ACL_DELETE

=item ARCHIVE_ENTRY_ACL_DELETE_CHILD

=item ARCHIVE_ENTRY_ACL_ENTRY_DIRECTORY_INHERIT

=item ARCHIVE_ENTRY_ACL_ENTRY_FAILED_ACCESS

=item ARCHIVE_ENTRY_ACL_ENTRY_FILE_INHERIT

=item ARCHIVE_ENTRY_ACL_ENTRY_INHERIT_ONLY

=item ARCHIVE_ENTRY_ACL_ENTRY_NO_PROPAGATE_INHERIT

=item ARCHIVE_ENTRY_ACL_ENTRY_SUCCESSFUL_ACCESS

=item ARCHIVE_ENTRY_ACL_EVERYONE

=item ARCHIVE_ENTRY_ACL_EXECUTE

=item ARCHIVE_ENTRY_ACL_GROUP

=item ARCHIVE_ENTRY_ACL_GROUP_OBJ

=item ARCHIVE_ENTRY_ACL_INHERITANCE_NFS4

=item ARCHIVE_ENTRY_ACL_LIST_DIRECTORY

=item ARCHIVE_ENTRY_ACL_MASK

=item ARCHIVE_ENTRY_ACL_OTHER

=item ARCHIVE_ENTRY_ACL_PERMS_NFS4

=item ARCHIVE_ENTRY_ACL_PERMS_POSIX1E

=item ARCHIVE_ENTRY_ACL_READ

=item ARCHIVE_ENTRY_ACL_READ_ACL

=item ARCHIVE_ENTRY_ACL_READ_ATTRIBUTES

=item ARCHIVE_ENTRY_ACL_READ_DATA

=item ARCHIVE_ENTRY_ACL_READ_NAMED_ATTRS

=item ARCHIVE_ENTRY_ACL_STYLE_EXTRA_ID

=item ARCHIVE_ENTRY_ACL_STYLE_MARK_DEFAULT

=item ARCHIVE_ENTRY_ACL_SYNCHRONIZE

=item ARCHIVE_ENTRY_ACL_TYPE_ACCESS

=item ARCHIVE_ENTRY_ACL_TYPE_ALARM

=item ARCHIVE_ENTRY_ACL_TYPE_ALLOW

=item ARCHIVE_ENTRY_ACL_TYPE_AUDIT

=item ARCHIVE_ENTRY_ACL_TYPE_DEFAULT

=item ARCHIVE_ENTRY_ACL_TYPE_DENY

=item ARCHIVE_ENTRY_ACL_TYPE_NFS4

=item ARCHIVE_ENTRY_ACL_TYPE_POSIX1E

=item ARCHIVE_ENTRY_ACL_USER

=item ARCHIVE_ENTRY_ACL_USER_OBJ

=item ARCHIVE_ENTRY_ACL_WRITE

=item ARCHIVE_ENTRY_ACL_WRITE_ACL

=item ARCHIVE_ENTRY_ACL_WRITE_ATTRIBUTES

=item ARCHIVE_ENTRY_ACL_WRITE_DATA

=item ARCHIVE_ENTRY_ACL_WRITE_NAMED_ATTRS

=item ARCHIVE_ENTRY_ACL_WRITE_OWNER

=item ARCHIVE_EOF

=item ARCHIVE_EXTRACT_ACL

=item ARCHIVE_EXTRACT_FFLAGS

=item ARCHIVE_EXTRACT_HFS_COMPRESSION_FORCED

=item ARCHIVE_EXTRACT_MAC_METADATA

=item ARCHIVE_EXTRACT_NO_AUTODIR

=item ARCHIVE_EXTRACT_NO_HFS_COMPRESSION

=item ARCHIVE_EXTRACT_NO_OVERWRITE

=item ARCHIVE_EXTRACT_NO_OVERWRITE_NEWER

=item ARCHIVE_EXTRACT_OWNER

=item ARCHIVE_EXTRACT_PERM

=item ARCHIVE_EXTRACT_SECURE_NODOTDOT

=item ARCHIVE_EXTRACT_SECURE_SYMLINKS

=item ARCHIVE_EXTRACT_SPARSE

=item ARCHIVE_EXTRACT_TIME

=item ARCHIVE_EXTRACT_UNLINK

=item ARCHIVE_EXTRACT_XATTR

=item ARCHIVE_FAILED

=item ARCHIVE_FATAL

=item ARCHIVE_FILTER_BZIP2

=item ARCHIVE_FILTER_COMPRESS

=item ARCHIVE_FILTER_GRZIP

=item ARCHIVE_FILTER_GZIP

=item ARCHIVE_FILTER_LRZIP

=item ARCHIVE_FILTER_LZIP

=item ARCHIVE_FILTER_LZMA

=item ARCHIVE_FILTER_LZOP

=item ARCHIVE_FILTER_NONE

=item ARCHIVE_FILTER_PROGRAM

=item ARCHIVE_FILTER_RPM

=item ARCHIVE_FILTER_UU

=item ARCHIVE_FILTER_XZ

=item ARCHIVE_FORMAT_7ZIP

=item ARCHIVE_FORMAT_AR

=item ARCHIVE_FORMAT_AR_BSD

=item ARCHIVE_FORMAT_AR_GNU

=item ARCHIVE_FORMAT_BASE_MASK

=item ARCHIVE_FORMAT_CAB

=item ARCHIVE_FORMAT_CPIO

=item ARCHIVE_FORMAT_CPIO_AFIO_LARGE

=item ARCHIVE_FORMAT_CPIO_BIN_BE

=item ARCHIVE_FORMAT_CPIO_BIN_LE

=item ARCHIVE_FORMAT_CPIO_POSIX

=item ARCHIVE_FORMAT_CPIO_SVR4_CRC

=item ARCHIVE_FORMAT_CPIO_SVR4_NOCRC

=item ARCHIVE_FORMAT_EMPTY

=item ARCHIVE_FORMAT_ISO9660

=item ARCHIVE_FORMAT_ISO9660_ROCKRIDGE

=item ARCHIVE_FORMAT_LHA

=item ARCHIVE_FORMAT_MTREE

=item ARCHIVE_FORMAT_RAR

=item ARCHIVE_FORMAT_RAW

=item ARCHIVE_FORMAT_SHAR

=item ARCHIVE_FORMAT_SHAR_BASE

=item ARCHIVE_FORMAT_SHAR_DUMP

=item ARCHIVE_FORMAT_TAR

=item ARCHIVE_FORMAT_TAR_GNUTAR

=item ARCHIVE_FORMAT_TAR_PAX_INTERCHANGE

=item ARCHIVE_FORMAT_TAR_PAX_RESTRICTED

=item ARCHIVE_FORMAT_TAR_USTAR

=item ARCHIVE_FORMAT_XAR

=item ARCHIVE_FORMAT_ZIP

=item ARCHIVE_MATCH_CTIME

=item ARCHIVE_MATCH_EQUAL

=item ARCHIVE_MATCH_MTIME

=item ARCHIVE_MATCH_NEWER

=item ARCHIVE_MATCH_OLDER

=item ARCHIVE_OK

=item ARCHIVE_READDISK_HONOR_NODUMP

=item ARCHIVE_READDISK_MAC_COPYFILE

=item ARCHIVE_READDISK_NO_TRAVERSE_MOUNTS

=item ARCHIVE_READDISK_RESTORE_ATIME

=item ARCHIVE_RETRY

=item ARCHIVE_VERSION_NUMBER

=item ARCHIVE_WARN

=back

=cut

foreach my $const (@{ $EXPORT_TAGS{const} }) {
  my $value = eval { _constant($const) };
  next if $@;
  no strict 'refs';
  # what is the best way to do actually do this?
  *{"Archive::Libarchive::XS::$const"} = eval qq{ sub { $value } };
}


our @EXPORT_OK = (@{ $EXPORT_TAGS{const} }, @{ $EXPORT_TAGS{func} });
$EXPORT_TAGS{all} = \@EXPORT_OK;

1;
