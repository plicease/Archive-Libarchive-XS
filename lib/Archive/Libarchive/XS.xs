#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <string.h>
#include <archive.h>
#include <archive_entry.h>

MODULE = Archive::Libarchive::XS   PACKAGE = Archive::Libarchive::XS

=head2 archive_read_new

Allocates and initializes a archive object suitable for reading from an archive.
Returns an instance of L<Archive::Libarchive::XS::archive>, which can be passed
into any function documented here with a <$archive> argument.

TODO: handle the unusual circumstance when this would return C NULL pointer.

=cut

struct archive *
archive_read_new();

=head2 archive_read_free($archive)

Invokes C<archive_read_close> if it was not invoked manually, then
release all resources.

=cut

int
archive_read_free(archive)
    struct archive *archive;

=head2 archive_error_string($archive)

Returns a textual error message suitable for display.  The error
message here is usually more specific than that obtained from
passing the result of C<archive_errno> to C<strerror>.

Return type is a string.

=cut

const char *
archive_error_string(archive)
    struct archive *archive;

=head2 archive_errno($archive)

Returns a numeric error code indicating the reason for the most
recent error return.

Return type is an errno integer value.

=cut

int
archive_errno(archive)
    struct archive *archive;

=head2 archive_clear_error($archive)

Clears any error information left over from a previous call Not
generally used in client code.

=cut

void
archive_clear_error(archive)
    struct archive *archive;

=head2 archive_copy_error($archive1, $archive2)

Copies error information from one archive to another.

=cut

void
archive_copy_error(archive1, archive2)
    struct archive *archive1;
    struct archive *archive2;

=head2 archive_compression($archive)

Return the compression code for the given archive.

FIXME: deprecated in favor of archive_filter_code

=cut

int
archive_compression(archive)
    struct archive *archive;

=head2 archive_compression_name($archive)

Returns a text description of the current compression suitable for display.

FIXME: deprecated in favor of archive_filter_name

=cut

const char *
archive_compression_name(archive);
    struct archive *archive;

=head2 archive_format($archive)

Returns a numeric code indicating the format of the current archive
entry.  This value is set by a successful call to
C<archive_read_next_header>.  Note that it is common for this value
to change from entry to entry.  For example, a tar archive might
have several entries that utilize GNU tar extensions and several
entries that do not.  These entries will have different format
codes.

=cut

int
archive_format(archive)
    struct archive *archive;

=head2 archive_format_name($archive)

A textual description of the format of the current entry.

=cut

const char *
archive_format_name(archive)
    struct archive *archive;

=head2 archive_read_support_filter_all($archive)

Enable all available decompression filters.

=cut

int
archive_read_support_filter_all(archive)
    struct archive *archive;

=head2 archive_read_support_filter_program(archive, command)

Data is feed through the specified external program before being
dearchived.  Note that this disables automatic detection of the
compression format, so it makes no sense to specify this in
conjunction with any other decompression option.

TODO: also support archive_read_support_filter_program_signature

=cut

int
archive_read_support_filter_program(archive, command)
    struct archive *archive;
    const char *command;

=head2 archive_read_support_format_all($archive)

Enable all available archive formats.

=cut

int
archive_read_support_format_all(archive)
    struct archive *archive;

=head2 archive_read_support_format_by_code($archive, $code)

Enables a single format specified by the format code.

=cut

int
archive_read_support_format_by_code(archive, code)
    struct archive *archive;
    int code;

=head2 archive_read_open_filename($archive, $filename, $block_size)

Like C<archive_read_open>, except that it accepts a simple filename
and a block size.  This function is safe for use with tape drives
or other blocked devices.

TODO: a NULL filename represents standard input.

=cut

int
archive_read_open_filename(archive, filename, block_size)
    struct archive *archive;
    const char *filename;
    size_t block_size;

=head2 archive_read_open_memory($archive, $buffer)

Like C<archive_read_open>, except that it uses a Perl scalar that holds the content of the
archive.  This function does not make a copy of the data stored in C<$buffer>, so you should
not modify the buffer until you have free the archive using C<archive_read_free>.

=cut

int
archive_read_open_memory(archive, input)
    struct archive *archive;
    SV *input;
  CODE:
    void *buff = NULL;
    size_t size = 0;
    buff = SvPV(input, size);
    RETVAL = archive_read_open_memory(archive, buff, size);
  OUTPUT:
    RETVAL


=head2 archive_read_next_header($archive, $entry)

Read the header for the next entry and return an entry object
($entry will be an instance of L<Archive::Libarchive::XS::archive_entry>).

TODO: maybe use archive_read_next_header2

=cut

int
archive_read_next_header(archive, output)
    struct archive *archive;
    SV *output;
  CODE:
    struct archive_entry *entry;
    RETVAL = archive_read_next_header(archive, &entry);
    /* Question: entry is probably not valid on EOF ? */
    sv_setref_pv(output, "Archive::Libarchive::XS::archive_entry", (void*) entry);
  OUTPUT:
    RETVAL
    out

=head2 archive_read_data_skip($archive)

A convenience function that repeatedly calls C<archive_read_data> to skip
all of the data for this archive entry.

=cut

int
archive_read_data_skip(archive)
    struct archive *archive;

=head2 archive_version_string

Return the libarchive as a version.

Returns a string value.

=cut

const char *
archive_version_string();

=head2 archive_version_number

Return the libarchive version as an integer.

=cut

int
archive_version_number();

=head2 archive_entry_pathname($entry)

Retrieve the pathname of the entry.

Returns a string value.

=cut

const char *
archive_entry_pathname(archive_entry);
    struct archive_entry *archive_entry;

int
_constant(name)
        char *name
    CODE:
        if(!strcmp(name, "ARCHIVE_OK"))
          RETVAL = ARCHIVE_OK;
        /* CONSTANT AUTOGEN BEGIN */
#ifdef AE_IFBLK
        else if(!strcmp(name, "AE_IFBLK"))
          RETVAL = AE_IFBLK;
#endif
#ifdef AE_IFCHR
        else if(!strcmp(name, "AE_IFCHR"))
          RETVAL = AE_IFCHR;
#endif
#ifdef AE_IFDIR
        else if(!strcmp(name, "AE_IFDIR"))
          RETVAL = AE_IFDIR;
#endif
#ifdef AE_IFIFO
        else if(!strcmp(name, "AE_IFIFO"))
          RETVAL = AE_IFIFO;
#endif
#ifdef AE_IFLNK
        else if(!strcmp(name, "AE_IFLNK"))
          RETVAL = AE_IFLNK;
#endif
#ifdef AE_IFMT
        else if(!strcmp(name, "AE_IFMT"))
          RETVAL = AE_IFMT;
#endif
#ifdef AE_IFREG
        else if(!strcmp(name, "AE_IFREG"))
          RETVAL = AE_IFREG;
#endif
#ifdef AE_IFSOCK
        else if(!strcmp(name, "AE_IFSOCK"))
          RETVAL = AE_IFSOCK;
#endif
#ifdef ARCHIVE_COMPRESSION_BZIP2
        else if(!strcmp(name, "ARCHIVE_COMPRESSION_BZIP2"))
          RETVAL = ARCHIVE_COMPRESSION_BZIP2;
#endif
#ifdef ARCHIVE_COMPRESSION_COMPRESS
        else if(!strcmp(name, "ARCHIVE_COMPRESSION_COMPRESS"))
          RETVAL = ARCHIVE_COMPRESSION_COMPRESS;
#endif
#ifdef ARCHIVE_COMPRESSION_GZIP
        else if(!strcmp(name, "ARCHIVE_COMPRESSION_GZIP"))
          RETVAL = ARCHIVE_COMPRESSION_GZIP;
#endif
#ifdef ARCHIVE_COMPRESSION_LRZIP
        else if(!strcmp(name, "ARCHIVE_COMPRESSION_LRZIP"))
          RETVAL = ARCHIVE_COMPRESSION_LRZIP;
#endif
#ifdef ARCHIVE_COMPRESSION_LZIP
        else if(!strcmp(name, "ARCHIVE_COMPRESSION_LZIP"))
          RETVAL = ARCHIVE_COMPRESSION_LZIP;
#endif
#ifdef ARCHIVE_COMPRESSION_LZMA
        else if(!strcmp(name, "ARCHIVE_COMPRESSION_LZMA"))
          RETVAL = ARCHIVE_COMPRESSION_LZMA;
#endif
#ifdef ARCHIVE_COMPRESSION_NONE
        else if(!strcmp(name, "ARCHIVE_COMPRESSION_NONE"))
          RETVAL = ARCHIVE_COMPRESSION_NONE;
#endif
#ifdef ARCHIVE_COMPRESSION_PROGRAM
        else if(!strcmp(name, "ARCHIVE_COMPRESSION_PROGRAM"))
          RETVAL = ARCHIVE_COMPRESSION_PROGRAM;
#endif
#ifdef ARCHIVE_COMPRESSION_RPM
        else if(!strcmp(name, "ARCHIVE_COMPRESSION_RPM"))
          RETVAL = ARCHIVE_COMPRESSION_RPM;
#endif
#ifdef ARCHIVE_COMPRESSION_UU
        else if(!strcmp(name, "ARCHIVE_COMPRESSION_UU"))
          RETVAL = ARCHIVE_COMPRESSION_UU;
#endif
#ifdef ARCHIVE_COMPRESSION_XZ
        else if(!strcmp(name, "ARCHIVE_COMPRESSION_XZ"))
          RETVAL = ARCHIVE_COMPRESSION_XZ;
#endif
#ifdef ARCHIVE_ENTRY_ACL_ADD_FILE
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_ADD_FILE"))
          RETVAL = ARCHIVE_ENTRY_ACL_ADD_FILE;
#endif
#ifdef ARCHIVE_ENTRY_ACL_ADD_SUBDIRECTORY
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_ADD_SUBDIRECTORY"))
          RETVAL = ARCHIVE_ENTRY_ACL_ADD_SUBDIRECTORY;
#endif
#ifdef ARCHIVE_ENTRY_ACL_APPEND_DATA
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_APPEND_DATA"))
          RETVAL = ARCHIVE_ENTRY_ACL_APPEND_DATA;
#endif
#ifdef ARCHIVE_ENTRY_ACL_DELETE
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_DELETE"))
          RETVAL = ARCHIVE_ENTRY_ACL_DELETE;
#endif
#ifdef ARCHIVE_ENTRY_ACL_DELETE_CHILD
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_DELETE_CHILD"))
          RETVAL = ARCHIVE_ENTRY_ACL_DELETE_CHILD;
#endif
#ifdef ARCHIVE_ENTRY_ACL_ENTRY_DIRECTORY_INHERIT
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_ENTRY_DIRECTORY_INHERIT"))
          RETVAL = ARCHIVE_ENTRY_ACL_ENTRY_DIRECTORY_INHERIT;
#endif
#ifdef ARCHIVE_ENTRY_ACL_ENTRY_FAILED_ACCESS
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_ENTRY_FAILED_ACCESS"))
          RETVAL = ARCHIVE_ENTRY_ACL_ENTRY_FAILED_ACCESS;
#endif
#ifdef ARCHIVE_ENTRY_ACL_ENTRY_FILE_INHERIT
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_ENTRY_FILE_INHERIT"))
          RETVAL = ARCHIVE_ENTRY_ACL_ENTRY_FILE_INHERIT;
#endif
#ifdef ARCHIVE_ENTRY_ACL_ENTRY_INHERIT_ONLY
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_ENTRY_INHERIT_ONLY"))
          RETVAL = ARCHIVE_ENTRY_ACL_ENTRY_INHERIT_ONLY;
#endif
#ifdef ARCHIVE_ENTRY_ACL_ENTRY_NO_PROPAGATE_INHERIT
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_ENTRY_NO_PROPAGATE_INHERIT"))
          RETVAL = ARCHIVE_ENTRY_ACL_ENTRY_NO_PROPAGATE_INHERIT;
#endif
#ifdef ARCHIVE_ENTRY_ACL_ENTRY_SUCCESSFUL_ACCESS
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_ENTRY_SUCCESSFUL_ACCESS"))
          RETVAL = ARCHIVE_ENTRY_ACL_ENTRY_SUCCESSFUL_ACCESS;
#endif
#ifdef ARCHIVE_ENTRY_ACL_EVERYONE
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_EVERYONE"))
          RETVAL = ARCHIVE_ENTRY_ACL_EVERYONE;
#endif
#ifdef ARCHIVE_ENTRY_ACL_EXECUTE
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_EXECUTE"))
          RETVAL = ARCHIVE_ENTRY_ACL_EXECUTE;
#endif
#ifdef ARCHIVE_ENTRY_ACL_GROUP
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_GROUP"))
          RETVAL = ARCHIVE_ENTRY_ACL_GROUP;
#endif
#ifdef ARCHIVE_ENTRY_ACL_GROUP_OBJ
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_GROUP_OBJ"))
          RETVAL = ARCHIVE_ENTRY_ACL_GROUP_OBJ;
#endif
#ifdef ARCHIVE_ENTRY_ACL_INHERITANCE_NFS4
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_INHERITANCE_NFS4"))
          RETVAL = ARCHIVE_ENTRY_ACL_INHERITANCE_NFS4;
#endif
#ifdef ARCHIVE_ENTRY_ACL_LIST_DIRECTORY
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_LIST_DIRECTORY"))
          RETVAL = ARCHIVE_ENTRY_ACL_LIST_DIRECTORY;
#endif
#ifdef ARCHIVE_ENTRY_ACL_MASK
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_MASK"))
          RETVAL = ARCHIVE_ENTRY_ACL_MASK;
#endif
#ifdef ARCHIVE_ENTRY_ACL_OTHER
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_OTHER"))
          RETVAL = ARCHIVE_ENTRY_ACL_OTHER;
#endif
#ifdef ARCHIVE_ENTRY_ACL_PERMS_NFS4
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_PERMS_NFS4"))
          RETVAL = ARCHIVE_ENTRY_ACL_PERMS_NFS4;
#endif
#ifdef ARCHIVE_ENTRY_ACL_PERMS_POSIX1E
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_PERMS_POSIX1E"))
          RETVAL = ARCHIVE_ENTRY_ACL_PERMS_POSIX1E;
#endif
#ifdef ARCHIVE_ENTRY_ACL_READ
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_READ"))
          RETVAL = ARCHIVE_ENTRY_ACL_READ;
#endif
#ifdef ARCHIVE_ENTRY_ACL_READ_ACL
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_READ_ACL"))
          RETVAL = ARCHIVE_ENTRY_ACL_READ_ACL;
#endif
#ifdef ARCHIVE_ENTRY_ACL_READ_ATTRIBUTES
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_READ_ATTRIBUTES"))
          RETVAL = ARCHIVE_ENTRY_ACL_READ_ATTRIBUTES;
#endif
#ifdef ARCHIVE_ENTRY_ACL_READ_DATA
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_READ_DATA"))
          RETVAL = ARCHIVE_ENTRY_ACL_READ_DATA;
#endif
#ifdef ARCHIVE_ENTRY_ACL_READ_NAMED_ATTRS
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_READ_NAMED_ATTRS"))
          RETVAL = ARCHIVE_ENTRY_ACL_READ_NAMED_ATTRS;
#endif
#ifdef ARCHIVE_ENTRY_ACL_STYLE_EXTRA_ID
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_STYLE_EXTRA_ID"))
          RETVAL = ARCHIVE_ENTRY_ACL_STYLE_EXTRA_ID;
#endif
#ifdef ARCHIVE_ENTRY_ACL_STYLE_MARK_DEFAULT
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_STYLE_MARK_DEFAULT"))
          RETVAL = ARCHIVE_ENTRY_ACL_STYLE_MARK_DEFAULT;
#endif
#ifdef ARCHIVE_ENTRY_ACL_SYNCHRONIZE
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_SYNCHRONIZE"))
          RETVAL = ARCHIVE_ENTRY_ACL_SYNCHRONIZE;
#endif
#ifdef ARCHIVE_ENTRY_ACL_TYPE_ACCESS
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_TYPE_ACCESS"))
          RETVAL = ARCHIVE_ENTRY_ACL_TYPE_ACCESS;
#endif
#ifdef ARCHIVE_ENTRY_ACL_TYPE_ALARM
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_TYPE_ALARM"))
          RETVAL = ARCHIVE_ENTRY_ACL_TYPE_ALARM;
#endif
#ifdef ARCHIVE_ENTRY_ACL_TYPE_ALLOW
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_TYPE_ALLOW"))
          RETVAL = ARCHIVE_ENTRY_ACL_TYPE_ALLOW;
#endif
#ifdef ARCHIVE_ENTRY_ACL_TYPE_AUDIT
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_TYPE_AUDIT"))
          RETVAL = ARCHIVE_ENTRY_ACL_TYPE_AUDIT;
#endif
#ifdef ARCHIVE_ENTRY_ACL_TYPE_DEFAULT
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_TYPE_DEFAULT"))
          RETVAL = ARCHIVE_ENTRY_ACL_TYPE_DEFAULT;
#endif
#ifdef ARCHIVE_ENTRY_ACL_TYPE_DENY
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_TYPE_DENY"))
          RETVAL = ARCHIVE_ENTRY_ACL_TYPE_DENY;
#endif
#ifdef ARCHIVE_ENTRY_ACL_TYPE_NFS4
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_TYPE_NFS4"))
          RETVAL = ARCHIVE_ENTRY_ACL_TYPE_NFS4;
#endif
#ifdef ARCHIVE_ENTRY_ACL_TYPE_POSIX1E
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_TYPE_POSIX1E"))
          RETVAL = ARCHIVE_ENTRY_ACL_TYPE_POSIX1E;
#endif
#ifdef ARCHIVE_ENTRY_ACL_USER
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_USER"))
          RETVAL = ARCHIVE_ENTRY_ACL_USER;
#endif
#ifdef ARCHIVE_ENTRY_ACL_USER_OBJ
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_USER_OBJ"))
          RETVAL = ARCHIVE_ENTRY_ACL_USER_OBJ;
#endif
#ifdef ARCHIVE_ENTRY_ACL_WRITE
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_WRITE"))
          RETVAL = ARCHIVE_ENTRY_ACL_WRITE;
#endif
#ifdef ARCHIVE_ENTRY_ACL_WRITE_ACL
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_WRITE_ACL"))
          RETVAL = ARCHIVE_ENTRY_ACL_WRITE_ACL;
#endif
#ifdef ARCHIVE_ENTRY_ACL_WRITE_ATTRIBUTES
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_WRITE_ATTRIBUTES"))
          RETVAL = ARCHIVE_ENTRY_ACL_WRITE_ATTRIBUTES;
#endif
#ifdef ARCHIVE_ENTRY_ACL_WRITE_DATA
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_WRITE_DATA"))
          RETVAL = ARCHIVE_ENTRY_ACL_WRITE_DATA;
#endif
#ifdef ARCHIVE_ENTRY_ACL_WRITE_NAMED_ATTRS
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_WRITE_NAMED_ATTRS"))
          RETVAL = ARCHIVE_ENTRY_ACL_WRITE_NAMED_ATTRS;
#endif
#ifdef ARCHIVE_ENTRY_ACL_WRITE_OWNER
        else if(!strcmp(name, "ARCHIVE_ENTRY_ACL_WRITE_OWNER"))
          RETVAL = ARCHIVE_ENTRY_ACL_WRITE_OWNER;
#endif
#ifdef ARCHIVE_EOF
        else if(!strcmp(name, "ARCHIVE_EOF"))
          RETVAL = ARCHIVE_EOF;
#endif
#ifdef ARCHIVE_EXTRACT_ACL
        else if(!strcmp(name, "ARCHIVE_EXTRACT_ACL"))
          RETVAL = ARCHIVE_EXTRACT_ACL;
#endif
#ifdef ARCHIVE_EXTRACT_FFLAGS
        else if(!strcmp(name, "ARCHIVE_EXTRACT_FFLAGS"))
          RETVAL = ARCHIVE_EXTRACT_FFLAGS;
#endif
#ifdef ARCHIVE_EXTRACT_HFS_COMPRESSION_FORCED
        else if(!strcmp(name, "ARCHIVE_EXTRACT_HFS_COMPRESSION_FORCED"))
          RETVAL = ARCHIVE_EXTRACT_HFS_COMPRESSION_FORCED;
#endif
#ifdef ARCHIVE_EXTRACT_MAC_METADATA
        else if(!strcmp(name, "ARCHIVE_EXTRACT_MAC_METADATA"))
          RETVAL = ARCHIVE_EXTRACT_MAC_METADATA;
#endif
#ifdef ARCHIVE_EXTRACT_NO_AUTODIR
        else if(!strcmp(name, "ARCHIVE_EXTRACT_NO_AUTODIR"))
          RETVAL = ARCHIVE_EXTRACT_NO_AUTODIR;
#endif
#ifdef ARCHIVE_EXTRACT_NO_HFS_COMPRESSION
        else if(!strcmp(name, "ARCHIVE_EXTRACT_NO_HFS_COMPRESSION"))
          RETVAL = ARCHIVE_EXTRACT_NO_HFS_COMPRESSION;
#endif
#ifdef ARCHIVE_EXTRACT_NO_OVERWRITE
        else if(!strcmp(name, "ARCHIVE_EXTRACT_NO_OVERWRITE"))
          RETVAL = ARCHIVE_EXTRACT_NO_OVERWRITE;
#endif
#ifdef ARCHIVE_EXTRACT_NO_OVERWRITE_NEWER
        else if(!strcmp(name, "ARCHIVE_EXTRACT_NO_OVERWRITE_NEWER"))
          RETVAL = ARCHIVE_EXTRACT_NO_OVERWRITE_NEWER;
#endif
#ifdef ARCHIVE_EXTRACT_OWNER
        else if(!strcmp(name, "ARCHIVE_EXTRACT_OWNER"))
          RETVAL = ARCHIVE_EXTRACT_OWNER;
#endif
#ifdef ARCHIVE_EXTRACT_PERM
        else if(!strcmp(name, "ARCHIVE_EXTRACT_PERM"))
          RETVAL = ARCHIVE_EXTRACT_PERM;
#endif
#ifdef ARCHIVE_EXTRACT_SECURE_NODOTDOT
        else if(!strcmp(name, "ARCHIVE_EXTRACT_SECURE_NODOTDOT"))
          RETVAL = ARCHIVE_EXTRACT_SECURE_NODOTDOT;
#endif
#ifdef ARCHIVE_EXTRACT_SECURE_SYMLINKS
        else if(!strcmp(name, "ARCHIVE_EXTRACT_SECURE_SYMLINKS"))
          RETVAL = ARCHIVE_EXTRACT_SECURE_SYMLINKS;
#endif
#ifdef ARCHIVE_EXTRACT_SPARSE
        else if(!strcmp(name, "ARCHIVE_EXTRACT_SPARSE"))
          RETVAL = ARCHIVE_EXTRACT_SPARSE;
#endif
#ifdef ARCHIVE_EXTRACT_TIME
        else if(!strcmp(name, "ARCHIVE_EXTRACT_TIME"))
          RETVAL = ARCHIVE_EXTRACT_TIME;
#endif
#ifdef ARCHIVE_EXTRACT_UNLINK
        else if(!strcmp(name, "ARCHIVE_EXTRACT_UNLINK"))
          RETVAL = ARCHIVE_EXTRACT_UNLINK;
#endif
#ifdef ARCHIVE_EXTRACT_XATTR
        else if(!strcmp(name, "ARCHIVE_EXTRACT_XATTR"))
          RETVAL = ARCHIVE_EXTRACT_XATTR;
#endif
#ifdef ARCHIVE_FAILED
        else if(!strcmp(name, "ARCHIVE_FAILED"))
          RETVAL = ARCHIVE_FAILED;
#endif
#ifdef ARCHIVE_FATAL
        else if(!strcmp(name, "ARCHIVE_FATAL"))
          RETVAL = ARCHIVE_FATAL;
#endif
#ifdef ARCHIVE_FILTER_BZIP2
        else if(!strcmp(name, "ARCHIVE_FILTER_BZIP2"))
          RETVAL = ARCHIVE_FILTER_BZIP2;
#endif
#ifdef ARCHIVE_FILTER_COMPRESS
        else if(!strcmp(name, "ARCHIVE_FILTER_COMPRESS"))
          RETVAL = ARCHIVE_FILTER_COMPRESS;
#endif
#ifdef ARCHIVE_FILTER_GRZIP
        else if(!strcmp(name, "ARCHIVE_FILTER_GRZIP"))
          RETVAL = ARCHIVE_FILTER_GRZIP;
#endif
#ifdef ARCHIVE_FILTER_GZIP
        else if(!strcmp(name, "ARCHIVE_FILTER_GZIP"))
          RETVAL = ARCHIVE_FILTER_GZIP;
#endif
#ifdef ARCHIVE_FILTER_LRZIP
        else if(!strcmp(name, "ARCHIVE_FILTER_LRZIP"))
          RETVAL = ARCHIVE_FILTER_LRZIP;
#endif
#ifdef ARCHIVE_FILTER_LZIP
        else if(!strcmp(name, "ARCHIVE_FILTER_LZIP"))
          RETVAL = ARCHIVE_FILTER_LZIP;
#endif
#ifdef ARCHIVE_FILTER_LZMA
        else if(!strcmp(name, "ARCHIVE_FILTER_LZMA"))
          RETVAL = ARCHIVE_FILTER_LZMA;
#endif
#ifdef ARCHIVE_FILTER_LZOP
        else if(!strcmp(name, "ARCHIVE_FILTER_LZOP"))
          RETVAL = ARCHIVE_FILTER_LZOP;
#endif
#ifdef ARCHIVE_FILTER_NONE
        else if(!strcmp(name, "ARCHIVE_FILTER_NONE"))
          RETVAL = ARCHIVE_FILTER_NONE;
#endif
#ifdef ARCHIVE_FILTER_PROGRAM
        else if(!strcmp(name, "ARCHIVE_FILTER_PROGRAM"))
          RETVAL = ARCHIVE_FILTER_PROGRAM;
#endif
#ifdef ARCHIVE_FILTER_RPM
        else if(!strcmp(name, "ARCHIVE_FILTER_RPM"))
          RETVAL = ARCHIVE_FILTER_RPM;
#endif
#ifdef ARCHIVE_FILTER_UU
        else if(!strcmp(name, "ARCHIVE_FILTER_UU"))
          RETVAL = ARCHIVE_FILTER_UU;
#endif
#ifdef ARCHIVE_FILTER_XZ
        else if(!strcmp(name, "ARCHIVE_FILTER_XZ"))
          RETVAL = ARCHIVE_FILTER_XZ;
#endif
#ifdef ARCHIVE_FORMAT_7ZIP
        else if(!strcmp(name, "ARCHIVE_FORMAT_7ZIP"))
          RETVAL = ARCHIVE_FORMAT_7ZIP;
#endif
#ifdef ARCHIVE_FORMAT_AR
        else if(!strcmp(name, "ARCHIVE_FORMAT_AR"))
          RETVAL = ARCHIVE_FORMAT_AR;
#endif
#ifdef ARCHIVE_FORMAT_AR_BSD
        else if(!strcmp(name, "ARCHIVE_FORMAT_AR_BSD"))
          RETVAL = ARCHIVE_FORMAT_AR_BSD;
#endif
#ifdef ARCHIVE_FORMAT_AR_GNU
        else if(!strcmp(name, "ARCHIVE_FORMAT_AR_GNU"))
          RETVAL = ARCHIVE_FORMAT_AR_GNU;
#endif
#ifdef ARCHIVE_FORMAT_BASE_MASK
        else if(!strcmp(name, "ARCHIVE_FORMAT_BASE_MASK"))
          RETVAL = ARCHIVE_FORMAT_BASE_MASK;
#endif
#ifdef ARCHIVE_FORMAT_CAB
        else if(!strcmp(name, "ARCHIVE_FORMAT_CAB"))
          RETVAL = ARCHIVE_FORMAT_CAB;
#endif
#ifdef ARCHIVE_FORMAT_CPIO
        else if(!strcmp(name, "ARCHIVE_FORMAT_CPIO"))
          RETVAL = ARCHIVE_FORMAT_CPIO;
#endif
#ifdef ARCHIVE_FORMAT_CPIO_AFIO_LARGE
        else if(!strcmp(name, "ARCHIVE_FORMAT_CPIO_AFIO_LARGE"))
          RETVAL = ARCHIVE_FORMAT_CPIO_AFIO_LARGE;
#endif
#ifdef ARCHIVE_FORMAT_CPIO_BIN_BE
        else if(!strcmp(name, "ARCHIVE_FORMAT_CPIO_BIN_BE"))
          RETVAL = ARCHIVE_FORMAT_CPIO_BIN_BE;
#endif
#ifdef ARCHIVE_FORMAT_CPIO_BIN_LE
        else if(!strcmp(name, "ARCHIVE_FORMAT_CPIO_BIN_LE"))
          RETVAL = ARCHIVE_FORMAT_CPIO_BIN_LE;
#endif
#ifdef ARCHIVE_FORMAT_CPIO_POSIX
        else if(!strcmp(name, "ARCHIVE_FORMAT_CPIO_POSIX"))
          RETVAL = ARCHIVE_FORMAT_CPIO_POSIX;
#endif
#ifdef ARCHIVE_FORMAT_CPIO_SVR4_CRC
        else if(!strcmp(name, "ARCHIVE_FORMAT_CPIO_SVR4_CRC"))
          RETVAL = ARCHIVE_FORMAT_CPIO_SVR4_CRC;
#endif
#ifdef ARCHIVE_FORMAT_CPIO_SVR4_NOCRC
        else if(!strcmp(name, "ARCHIVE_FORMAT_CPIO_SVR4_NOCRC"))
          RETVAL = ARCHIVE_FORMAT_CPIO_SVR4_NOCRC;
#endif
#ifdef ARCHIVE_FORMAT_EMPTY
        else if(!strcmp(name, "ARCHIVE_FORMAT_EMPTY"))
          RETVAL = ARCHIVE_FORMAT_EMPTY;
#endif
#ifdef ARCHIVE_FORMAT_ISO9660
        else if(!strcmp(name, "ARCHIVE_FORMAT_ISO9660"))
          RETVAL = ARCHIVE_FORMAT_ISO9660;
#endif
#ifdef ARCHIVE_FORMAT_ISO9660_ROCKRIDGE
        else if(!strcmp(name, "ARCHIVE_FORMAT_ISO9660_ROCKRIDGE"))
          RETVAL = ARCHIVE_FORMAT_ISO9660_ROCKRIDGE;
#endif
#ifdef ARCHIVE_FORMAT_LHA
        else if(!strcmp(name, "ARCHIVE_FORMAT_LHA"))
          RETVAL = ARCHIVE_FORMAT_LHA;
#endif
#ifdef ARCHIVE_FORMAT_MTREE
        else if(!strcmp(name, "ARCHIVE_FORMAT_MTREE"))
          RETVAL = ARCHIVE_FORMAT_MTREE;
#endif
#ifdef ARCHIVE_FORMAT_RAR
        else if(!strcmp(name, "ARCHIVE_FORMAT_RAR"))
          RETVAL = ARCHIVE_FORMAT_RAR;
#endif
#ifdef ARCHIVE_FORMAT_RAW
        else if(!strcmp(name, "ARCHIVE_FORMAT_RAW"))
          RETVAL = ARCHIVE_FORMAT_RAW;
#endif
#ifdef ARCHIVE_FORMAT_SHAR
        else if(!strcmp(name, "ARCHIVE_FORMAT_SHAR"))
          RETVAL = ARCHIVE_FORMAT_SHAR;
#endif
#ifdef ARCHIVE_FORMAT_SHAR_BASE
        else if(!strcmp(name, "ARCHIVE_FORMAT_SHAR_BASE"))
          RETVAL = ARCHIVE_FORMAT_SHAR_BASE;
#endif
#ifdef ARCHIVE_FORMAT_SHAR_DUMP
        else if(!strcmp(name, "ARCHIVE_FORMAT_SHAR_DUMP"))
          RETVAL = ARCHIVE_FORMAT_SHAR_DUMP;
#endif
#ifdef ARCHIVE_FORMAT_TAR
        else if(!strcmp(name, "ARCHIVE_FORMAT_TAR"))
          RETVAL = ARCHIVE_FORMAT_TAR;
#endif
#ifdef ARCHIVE_FORMAT_TAR_GNUTAR
        else if(!strcmp(name, "ARCHIVE_FORMAT_TAR_GNUTAR"))
          RETVAL = ARCHIVE_FORMAT_TAR_GNUTAR;
#endif
#ifdef ARCHIVE_FORMAT_TAR_PAX_INTERCHANGE
        else if(!strcmp(name, "ARCHIVE_FORMAT_TAR_PAX_INTERCHANGE"))
          RETVAL = ARCHIVE_FORMAT_TAR_PAX_INTERCHANGE;
#endif
#ifdef ARCHIVE_FORMAT_TAR_PAX_RESTRICTED
        else if(!strcmp(name, "ARCHIVE_FORMAT_TAR_PAX_RESTRICTED"))
          RETVAL = ARCHIVE_FORMAT_TAR_PAX_RESTRICTED;
#endif
#ifdef ARCHIVE_FORMAT_TAR_USTAR
        else if(!strcmp(name, "ARCHIVE_FORMAT_TAR_USTAR"))
          RETVAL = ARCHIVE_FORMAT_TAR_USTAR;
#endif
#ifdef ARCHIVE_FORMAT_XAR
        else if(!strcmp(name, "ARCHIVE_FORMAT_XAR"))
          RETVAL = ARCHIVE_FORMAT_XAR;
#endif
#ifdef ARCHIVE_FORMAT_ZIP
        else if(!strcmp(name, "ARCHIVE_FORMAT_ZIP"))
          RETVAL = ARCHIVE_FORMAT_ZIP;
#endif
#ifdef ARCHIVE_MATCH_CTIME
        else if(!strcmp(name, "ARCHIVE_MATCH_CTIME"))
          RETVAL = ARCHIVE_MATCH_CTIME;
#endif
#ifdef ARCHIVE_MATCH_EQUAL
        else if(!strcmp(name, "ARCHIVE_MATCH_EQUAL"))
          RETVAL = ARCHIVE_MATCH_EQUAL;
#endif
#ifdef ARCHIVE_MATCH_MTIME
        else if(!strcmp(name, "ARCHIVE_MATCH_MTIME"))
          RETVAL = ARCHIVE_MATCH_MTIME;
#endif
#ifdef ARCHIVE_MATCH_NEWER
        else if(!strcmp(name, "ARCHIVE_MATCH_NEWER"))
          RETVAL = ARCHIVE_MATCH_NEWER;
#endif
#ifdef ARCHIVE_MATCH_OLDER
        else if(!strcmp(name, "ARCHIVE_MATCH_OLDER"))
          RETVAL = ARCHIVE_MATCH_OLDER;
#endif
#ifdef ARCHIVE_READDISK_HONOR_NODUMP
        else if(!strcmp(name, "ARCHIVE_READDISK_HONOR_NODUMP"))
          RETVAL = ARCHIVE_READDISK_HONOR_NODUMP;
#endif
#ifdef ARCHIVE_READDISK_MAC_COPYFILE
        else if(!strcmp(name, "ARCHIVE_READDISK_MAC_COPYFILE"))
          RETVAL = ARCHIVE_READDISK_MAC_COPYFILE;
#endif
#ifdef ARCHIVE_READDISK_NO_TRAVERSE_MOUNTS
        else if(!strcmp(name, "ARCHIVE_READDISK_NO_TRAVERSE_MOUNTS"))
          RETVAL = ARCHIVE_READDISK_NO_TRAVERSE_MOUNTS;
#endif
#ifdef ARCHIVE_READDISK_RESTORE_ATIME
        else if(!strcmp(name, "ARCHIVE_READDISK_RESTORE_ATIME"))
          RETVAL = ARCHIVE_READDISK_RESTORE_ATIME;
#endif
#ifdef ARCHIVE_RETRY
        else if(!strcmp(name, "ARCHIVE_RETRY"))
          RETVAL = ARCHIVE_RETRY;
#endif
#ifdef ARCHIVE_VERSION_NUMBER
        else if(!strcmp(name, "ARCHIVE_VERSION_NUMBER"))
          RETVAL = ARCHIVE_VERSION_NUMBER;
#endif
#ifdef ARCHIVE_WARN
        else if(!strcmp(name, "ARCHIVE_WARN"))
          RETVAL = ARCHIVE_WARN;
#endif
        /* CONSTANT AUTOGEN END */
        else
          Perl_croak(aTHX_ "No such constant");
    OUTPUT:
        RETVAL


/* PURE AUTOGEN BEGIN */
/* Do not edit anything below this line as it is autogenerated
and will be lost the next time you run dzil build */

=head2 archive_read_support_filter_bzip2($archive)

Enable bzip2 decompression filter.

=cut

int
archive_read_support_filter_bzip2(archive)
    struct archive *archive

=head2 archive_read_support_filter_compress($archive)

Enable compress decompression filter.

=cut

int
archive_read_support_filter_compress(archive)
    struct archive *archive

=head2 archive_read_support_filter_grzip($archive)

Enable grzip decompression filter.

=cut

int
archive_read_support_filter_grzip(archive)
    struct archive *archive

=head2 archive_read_support_filter_gzip($archive)

Enable gzip decompression filter.

=cut

int
archive_read_support_filter_gzip(archive)
    struct archive *archive

=head2 archive_read_support_filter_lrzip($archive)

Enable lrzip decompression filter.

=cut

int
archive_read_support_filter_lrzip(archive)
    struct archive *archive

=head2 archive_read_support_filter_lzip($archive)

Enable lzip decompression filter.

=cut

int
archive_read_support_filter_lzip(archive)
    struct archive *archive

=head2 archive_read_support_filter_lzma($archive)

Enable lzma decompression filter.

=cut

int
archive_read_support_filter_lzma(archive)
    struct archive *archive

=head2 archive_read_support_filter_lzop($archive)

Enable lzop decompression filter.

=cut

int
archive_read_support_filter_lzop(archive)
    struct archive *archive

=head2 archive_read_support_filter_none($archive)

Enable none decompression filter.

=cut

int
archive_read_support_filter_none(archive)
    struct archive *archive

=head2 archive_read_support_format_7zip($archive)

Enable 7zip archive format.

=cut

int
archive_read_support_format_7zip(archive)
    struct archive *archive

=head2 archive_read_support_format_ar($archive)

Enable ar archive format.

=cut

int
archive_read_support_format_ar(archive)
    struct archive *archive

=head2 archive_read_support_format_cab($archive)

Enable cab archive format.

=cut

int
archive_read_support_format_cab(archive)
    struct archive *archive

=head2 archive_read_support_format_cpio($archive)

Enable cpio archive format.

=cut

int
archive_read_support_format_cpio(archive)
    struct archive *archive

=head2 archive_read_support_format_empty($archive)

Enable empty archive format.

=cut

int
archive_read_support_format_empty(archive)
    struct archive *archive

=head2 archive_read_support_format_gnutar($archive)

Enable gnutar archive format.

=cut

int
archive_read_support_format_gnutar(archive)
    struct archive *archive

=head2 archive_read_support_format_iso9660($archive)

Enable iso9660 archive format.

=cut

int
archive_read_support_format_iso9660(archive)
    struct archive *archive

=head2 archive_read_support_format_lha($archive)

Enable lha archive format.

=cut

int
archive_read_support_format_lha(archive)
    struct archive *archive

=head2 archive_read_support_format_mtree($archive)

Enable mtree archive format.

=cut

int
archive_read_support_format_mtree(archive)
    struct archive *archive

=head2 archive_read_support_format_rar($archive)

Enable rar archive format.

=cut

int
archive_read_support_format_rar(archive)
    struct archive *archive

=head2 archive_read_support_format_raw($archive)

Enable raw archive format.

=cut

int
archive_read_support_format_raw(archive)
    struct archive *archive

=head2 archive_read_support_format_tar($archive)

Enable tar archive format.

=cut

int
archive_read_support_format_tar(archive)
    struct archive *archive

=head2 archive_read_support_format_xar($archive)

Enable xar archive format.

=cut

int
archive_read_support_format_xar(archive)
    struct archive *archive

=head2 archive_read_support_format_zip($archive)

Enable zip archive format.

=cut

int
archive_read_support_format_zip(archive)
    struct archive *archive

