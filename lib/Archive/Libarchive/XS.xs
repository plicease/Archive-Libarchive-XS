#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#define MATH_INT64_NATIVE_IF_AVAILABLE
#include "perl_math_int64.h"
#include "func.h"

#include <string.h>
#include <archive.h>
#include <archive_entry.h>

typedef const char *string_or_null;

static int
myopen(struct archive *archive, void *client_data)
{
  int count;
  int status;
  
  dSP;
  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(sv_2mortal(newSViv(PTR2IV((void*)archive))));
  PUTBACK;
  
  count = call_pv("Archive::Libarchive::XS::_myopen", G_SCALAR);
  
  SPAGAIN;
  
  status = POPi;
  
  PUTBACK;
  FREETMPS;
  LEAVE;
  
  return status;
}

static __LA_INT64_T
myread(struct archive *archive, void *client_data, const void **buffer)
{
  int count;
  int status;
  STRLEN len;
  SV *sv_buffer;
  
  dSP;
  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(sv_2mortal(newSViv(PTR2IV((void*)archive))));
  PUTBACK;
  
  count = call_pv("Archive::Libarchive::XS::_myread", G_ARRAY);

  SPAGAIN;
  
  sv_buffer = SvRV(POPs);
  status = POPi;
  if(status == ARCHIVE_OK)
  {
    *buffer = (void*) SvPV(sv_buffer, len);
  }
  
  PUTBACK;
  FREETMPS;
  LEAVE;

  if(status == ARCHIVE_OK)
    return len == 1 ? 0 : len;
  else
    return status;
}

static __LA_INT64_T
myskip(struct archive *archive, void *client_data, __LA_INT64_T request)
{
  int count;
  int status;
  
  dSP;
  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(sv_2mortal(newSViv(PTR2IV((void*)archive))));
  XPUSHs(sv_2mortal(newSVi64(request)));
  PUTBACK;
  
  count = call_pv("Archive::Libarchive::XS::_myskip", G_SCALAR);
  
  SPAGAIN;
  
  status = POPi;
  
  PUTBACK;
  FREETMPS;
  LEAVE;
  
  return status;
}


static int
myclose(struct archive *archive, void *client_data)
{
  int count;
  int status;
  
  dSP;
  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(sv_2mortal(newSViv(PTR2IV((void*)archive))));
  PUTBACK;
  
  count = call_pv("Archive::Libarchive::XS::_myclose", G_SCALAR);
  
  SPAGAIN;
  
  status = POPi;
  
  PUTBACK;
  FREETMPS;
  LEAVE;
  
  return status;
}

MODULE = Archive::Libarchive::XS   PACKAGE = Archive::Libarchive::XS

BOOT:
     PERL_MATH_INT64_LOAD_OR_CROAK;

=head2 archive_read_new

Allocates and initializes a archive object suitable for reading from an archive.
Returns an opaque archive which may be a perl style object, or a C pointer
(depending on the implementation), either way, it can be passed into
any of the read functions documented here with an <$archive> argument.

=cut

struct archive *
archive_read_new();

=head2 archive_read_close($archive)

Complete the archive and invoke the close callback.

=cut

int
archive_read_close(archive)
    struct archive *archive

=head2 archive_read_free($archive)

Invokes C<archive_read_close> if it was not invoked manually, then
release all resources.

=cut

int
_archive_read_free(archive)
    struct archive *archive;
  CODE:
    RETVAL = archive_read_free(archive);
  OUTPUT:
    RETVAL

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
generally used in client code.  Does not return a value.

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

=head2 archive_filter_code

Returns a numeric code identifying the indicated filter.  See C<archive_filter_count>
for details of the numbering.

=cut

#ifdef HAS_archive_filter_code

int 
archive_filter_code(archive, level);
    struct archive *archive;
    int level;

#endif

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

=cut

#ifdef HAS_archive_filter_count

int 
archive_filter_count(archive);
    struct archive *archive;

#endif

=head2 archive_filter_name

Returns a textual name identifying the indicated filter.  See L<#archive_filter_count> for
details of the numbering.

=cut

#ifdef HAS_archive_filter_name

const char * 
archive_filter_name(archive, level); 
    struct archive *archive;
    int level;

#endif

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

#ifdef HAS_archive_read_support_filter_all

int
archive_read_support_filter_all(archive)
    struct archive *archive;

#else

int
archive_read_support_filter_all(archive)
    struct archive *archive
  CODE:
    RETVAL = archive_read_support_compression_all(archive);
  OUTPUT:
    RETVAL

#endif

=head2 archive_read_support_filter_program(archive, command)

Data is feed through the specified external program before being
dearchived.  Note that this disables automatic detection of the
compression format, so it makes no sense to specify this in
conjunction with any other decompression option.

=cut

#ifdef HAS_archive_read_support_filter_program

int
archive_read_support_filter_program(archive, command)
    struct archive *archive;
    const char *command;

#endif

=head2 archive_read_support_format_all($archive)

Enable all available archive formats.

=cut

int
archive_read_support_format_all(archive)
    struct archive *archive;

=head2 archive_read_support_format_by_code($archive, $code)

Enables a single format specified by the format code.

=cut

#ifdef HAS_archive_read_support_format_by_code

int
archive_read_support_format_by_code(archive, code)
    struct archive *archive;
    int code;

#endif

=head2 archive_read_open_filename($archive, $filename, $block_size)

Like C<archive_read_open>, except that it accepts a simple filename
and a block size.  This function is safe for use with tape drives
or other blocked devices.

If you pass in C<undef> as the C<$filename>, libarchive will use
standard in as the input archive.

=cut

int
archive_read_open_filename(archive, filename, block_size)
    struct archive *archive;
    string_or_null filename;
    size_t block_size;

=head2 archive_read_open_memory($archive, $buffer)

Like C<archive_read_open>, except that it uses a Perl scalar that holds the 
content of the archive.  This function does not make a copy of the data stored 
in C<$buffer>, so you should not modify the buffer until you have free the 
archive using C<archive_read_free>.

Bad things will happen if the buffer falls out of scope and is deallocated
before you free the archive, so make sure that there is a reference to the
buffer somewhere in your programmer until C<archive_read_free> is called.

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
Returns an opaque archive which may be a perl style object, or a C pointer
(depending on the implementation), either way, it can be passed into
any of the functions documented here with an <$entry> argument.

=cut

int
archive_read_next_header(archive, output)
    struct archive *archive;
    SV *output;
  CODE:
    struct archive_entry *entry;
    RETVAL = archive_read_next_header(archive, &entry);
    sv_setref_pv(output, "Archive::Libarchive::XS::archive_entry", (void*) entry);
  OUTPUT:
    RETVAL
    output

=head2 archive_read_data_skip($archive)

A convenience function that repeatedly calls C<archive_read_data> to skip
all of the data for this archive entry.

=cut

int
archive_read_data_skip(archive)
    struct archive *archive;

=head2 archive_file_count($archive)

Returns a count of the number of files processed by this archive object.  The count
is incremented by calls to C<archive_write_header> or C<archive_read_next_header>.

=cut

int
archive_file_count(archive)
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

=head2 archive_read_data($archive, $buffer, $max_size)

Read data associated with the header just read.  Internally, this is a
convenience function that calls C<archive_read_data_block> and fills
any gaps with nulls so that callers see a single continuous stream of
data.  Returns the actual number of bytes read, 0 on end of data and
a negative value on error.

=cut

int
archive_read_data(archive, buffer, max_size)
    struct archive *archive;
    SV *buffer;
    size_t max_size;
  CODE:
    if(!SvPOKp(buffer))
      sv_setpv(buffer, "");
    SvGROW(buffer, max_size);
    void *ptr = SvPV_nolen(buffer);
    int size = archive_read_data(archive, ptr, max_size);
    SvCUR_set(buffer, size);
    RETVAL = size;
  OUTPUT:
    RETVAL
    buffer

=head2 archive_read_data_block($archive, $buff, $offset)

Return the next available block of data for this entry.  Unlike
C<archive_read_data>, this function allows you to correctly
handle sparse files, as supported by some archive formats.  The
library guarantees that offsets will increase and that blocks
will not overlap.  Note that the blocks returned from this
function can be much larger than the block size read from disk,
due to compression and internal buffer optimizations.

=cut

int
archive_read_data_block(archive, sv_buff, sv_offset)
    struct archive *archive
    SV *sv_buff
    SV *sv_offset
  CODE:
    SV *tmp;
    const void *buff = NULL;
    size_t size = 0;
    __LA_INT64_T offset = 0;
    int r = archive_read_data_block(archive, &buff, &size, &offset);
    sv_setpvn(sv_buff, buff, size);
    tmp = newSVi64(offset);
    sv_setsv(sv_offset, tmp);
    RETVAL = r;
  OUTPUT:
    sv_buff
    sv_offset
    RETVAL

=head2 archive_write_data_block($archive, $buff, $offset)

Writes the buffer to the current entry in the given archive
starting at the given offset.

=cut

size_t
archive_write_data_block(archive, sv_buff, offset)
    struct archive *archive
    SV *sv_buff
    __LA_INT64_T offset
  CODE:
    void *buff = NULL;
    size_t size;
    buff = SvPV(sv_buff, size);
    RETVAL = archive_write_data_block(archive, buff, size, offset);
  OUTPUT:
    RETVAL

=head2 archive_write_disk_new

Allocates and initializes a struct archive object suitable for
writing objects to disk.

Returns an opaque archive which may be a perl style object, or a C pointer
(Depending on the implementation), either way, it can be passed into
any of the write functions documented here with an C<$archive> argument.

=cut

struct archive *
archive_write_disk_new()

=head2 archive_write_new

Allocates and initializes a archive object suitable for writing an new archive.
Returns an opaque archive which may be a perl style object, or a C pointer
(depending on the implementation), either way, it can be passed into
any of the write functions documented here with an C<$archive> argument.

=cut

struct archive *
archive_write_new()

=head2 archive_write_free($archive)

Invokes C<archive_write_close> if it was not invoked manually, then
release all resources.

=cut

int
_archive_write_free(archive)
    struct archive *archive
  CODE:
    RETVAL = archive_write_free(archive);
  OUTPUT:
    RETVAL

=head2 archive_write_add_filter($archive, $code)

A convenience function to set the filter based on the code.

=cut

#ifdef HAS_archive_write_add_filter

int
archive_write_add_filter(archive, code)
    struct archive *archive
    int code

#endif

=head2 archive_write_add_filter_by_name($archive, $name)

A convenience function to set the filter based on the name.

=cut

#ifdef HAS_archive_write_add_filter_by_name

int
archive_write_add_filter_by_name(archive, name)
    struct archive *archive
    const char *name

#endif

=head2 archive_write_add_filter_program($archive, $cmd)

The archive will be fed into the specified compression program. 
The output of that program is blocked and written to the client
write callbacks.

=cut

#ifdef HAS_archive_write_add_filter_program

int
archive_write_add_filter_program(archive, cmd)
    struct archive *archive
    const char *cmd

#endif

=head2 archive_write_set_format($archive, $code)

A convenience function to set the format based on the code.

=cut

int
archive_write_set_format(archive, code)
    struct archive *archive
    int code

=head2 archive_write_set_format_by_name($archive, $name)

A convenience function to set the format based on the name.

=cut

int
archive_write_set_format_by_name(archive, name)
    struct archive *archive
    const char *name

=head2 archive_write_open_filename($archive, $filename)

A convenience form of C<archive_write_open> that accepts a filename.  If you have 
not invoked C<archive_write_set_bytes_in_last_block>, then 
C<archive_write_open_filename> will adjust the last-block padding depending on the 
file: it will enable padding when writing to standard output or to a character or 
block device node, it will disable padding otherwise.  You can override this by 
manually invoking C<archive_write_set_bytes_in_last_block> before C<calling 
archive_write_open>.  The C<archive_write_open_filename> function is safe for use 
with tape drives or other block-oriented devices.

If you pass in C<undef> as the C<$filename>, libarchive will write the
archive to standard out.

=cut

int
archive_write_open_filename(archive, filename)
    struct archive *archive
    string_or_null filename;

=head2 archive_entry_clear

Erases the object, resetting all internal fields to the same state as a newly-created object.  This is provided
to allow you to quickly recycle objects without thrashing the heap.

=cut

void
archive_entry_clear(archive_entry)
    struct archive_entry *archive_entry

=head2 archive_entry_clone

A deep copy operation; all text fields are duplicated.

=cut

struct archive_entry *
archive_entry_clone(archive_entry)
    struct archive_entry *archive_entry

=head2 archive_entry_free

Releases the struct archive_entry object.

=cut

void
archive_entry_free(archive_entry)
    struct archive_entry *archive_entry


=head2 archive_entry_new

Allocate and return a blank struct archive_entry object.

=cut

struct archive_entry *
archive_entry_new()

=head2 archive_entry_new2($archive)

This form of C<archive_entry_new2> will pull character-set
conversion information from the specified archive handle.  The
older C<archive_entry_new> form will result in the use of an internal
default character-set conversion.

=cut

#ifdef HAS_archive_entry_new2

struct archive_entry *
archive_entry_new2(archive)
    struct archive *archive

#endif

=head2 archive_entry_set_pathname($entry, $name)

Sets the path in the archive as a string.

Does not return anything.

=cut

void
archive_entry_set_pathname(entry, name)
    struct archive_entry *entry
    const char *name
  CODE:
    archive_entry_copy_pathname(entry, name);

=head2 archive_entry_size($entry)

Returns the size of the entry in bytes.

=cut

__LA_INT64_T
archive_entry_size(entry)
    struct archive_entry *entry

=head2 archive_entry_set_size($entry, $size)

Sets the size of the file in the archive.

Does not return anything.

=cut

void
archive_entry_set_size(entry, size)
    struct archive_entry *entry
    __LA_INT64_T size

=head2 archive_entry_set_filetype($entry, $code)

Sets the filetype in the archive.  Code should be one of

=over 4

=item AE_IFMT

=item AE_IFREG

=item AE_IFLNK

=item AE_IFSOCK

=item AE_IFCHR

=item AE_IFBLK

=item AE_IFDIR

=item AE_IFIFO

=back

Does not return anything.

=cut

void
archive_entry_set_filetype(entry, code)
    struct archive_entry *entry
    unsigned int code

=head2 archive_entry_set_perm

Set the permission bits for the entry.  This is the usual UNIX octal permission thing.

Does not return anything.

=cut

void
archive_entry_set_perm(entry, perm)
    struct archive_entry *entry
    int perm

=head2 archive_write_header($archive, $entry)

Build and write a header using the data in the provided struct archive_entry structure.
You can use C<archive_entry_new> to create an C<$entry> object and populate it with
C<archive_entry_set*> functions.

=cut

int
archive_write_header(archive, entry)
    struct archive *archive
    struct archive_entry *entry

=head2 archive_write_data(archive, buffer)

Write data corresponding to the header just written.

This function returns the number of bytes actually written, or -1 on error.

=cut

int
archive_write_data(archive, input)
    struct archive *archive
    SV *input
  CODE:
    void *buff = NULL;
    size_t size = 0;
    buff = SvPV(input, size);
    RETVAL = archive_write_data(archive, buff, size);
  OUTPUT:
    RETVAL

=head2 archive_write_close(archive)

Complete the archive and invoke the close callback.

=cut

int
archive_write_close(archive)
    struct archive *archive

=head2 archive_write_disk_set_options($archive, $flags)

The options field consists of a bitwise OR of one or more of the 
following values:

=over 4

=item ARCHIVE_EXTRACT_OWNER

=item ARCHIVE_EXTRACT_PERM

=item ARCHIVE_EXTRACT_TIME

=item ARCHIVE_EXTRACT_NO_OVERWRITE

=item ARCHIVE_EXTRACT_UNLINK

=item ARCHIVE_EXTRACT_ACL

=item ARCHIVE_EXTRACT_FFLAGS

=item ARCHIVE_EXTRACT_XATTR

=item ARCHIVE_EXTRACT_SECURE_SYMLINKS

=item ARCHIVE_EXTRACT_SECURE_NODOTDOT

=item ARCHIVE_EXTRACT_SPARSE

=back

=cut

int
archive_write_disk_set_options(archive, flags)
    struct archive *archive
    int flags

=head2 archive_entry_set_mtime($entry, $sec, $nanosec)

Set the mtime for the entry object.

Does not return a value.

=cut

void
archive_entry_set_mtime(entry, sec, nanosec)
    struct archive_entry *entry
    time_t sec
    long nanosec

=head2 archive_write_finish_entry($archive)

Close out the entry just written.  Ordinarily, 
clients never need to call this, as it is called 
automatically by C<archive_write_next_header> and 
C<archive_write_close> as needed.  However, some
file attributes are written to disk only after 
the file is closed, so this can be necessary 
if you need to work with the file on disk right away.

=cut

int
archive_write_finish_entry(archive)
    struct archive *archive

=head2 archive_write_disk_set_standard_lookup($archive)

This convenience function installs a standard set of user and
group lookup functions.  These functions use C<getpwnam> and
C<getgrnam> to convert names to ids, defaulting to the ids
if the names cannot be looked up.  These functions also implement
a simple memory cache to reduce the number of calls to 
C<getpwnam> and C<getgrnam>.

=cut

int
archive_write_disk_set_standard_lookup(archive)
    struct archive *archive

=head2 archive_write_zip_set_compression_store($archive)

Set the compression method for the zip archive to store.

=cut

#ifdef HAS_archive_write_zip_set_compression_store

int
archive_write_zip_set_compression_store(archive)
    struct archive *archive

#endif

=head2 archive_write_zip_set_compression_deflate($archive)

Set the compression method for the zip archive to deflate.

=cut

#ifdef HAS_archive_write_zip_set_compression_deflate

int
archive_write_zip_set_compression_deflate(archive)
    struct archive *archive

#endif

=head2 archive_write_set_skip_file($archive, $dev, $ino)

The dev/ino of a file that won't be archived.  This is used
to avoid recursively adding an archive to itself.

=cut

#ifdef HAS_archive_write_set_skip_file

int archive_write_set_skip_file(archive, dev, ino)
    struct archive *archive
    __LA_INT64_T dev
    __LA_INT64_T ino

#endif

=head2 archive_write_set_format_option($archive, $module, $option, $value)

Specifies an option that will be passed to currently-registered format 
readers.

If option and value are both C<undef>, these functions will do nothing 
and C<ARCHIVE_OK> will be returned.  If option is C<undef> but value
is not, these functions will do nothing and C<ARCHIVE_FAILED> will
be returned.

If module is not C<undef>, option and value will be provided to the
filter or reader named module.  The return value will be that of
the module.  If there is no such module, C<ARCHIVE_FAILED> will be
returned.

If module is C<undef>, option and value will be provided to every
registered module.  If any module returns C<ARCHIVE_FATAL>, this
value will be returned immediately.  Otherwise, C<ARCHIVE_OK> will
be returned if any module accepts the option, and C<ARCHIVE_FAILED>
in all other cases.

=cut

#ifdef HAS_archive_write_set_format_option

int
archive_write_set_format_option(archive, m, o, v)
    struct archive *archive
    string_or_null m
    string_or_null o
    string_or_null v

#endif

=head2 archive_write_set_filter_option($archive, $module, $option, $value)

Specifies an option that will be passed to currently-registered filters (including decompression filters).

If option and value are both C<undef>, these functions will do nothing 
and C<ARCHIVE_OK> will be returned.  If option is C<undef> but value
is not, these functions will do nothing and C<ARCHIVE_FAILED> will
be returned.

If module is not C<undef>, option and value will be provided to the
filter or reader named module.  The return value will be that of
the module.  If there is no such module, C<ARCHIVE_FAILED> will be
returned.

If module is C<undef>, option and value will be provided to every
registered module.  If any module returns C<ARCHIVE_FATAL>, this
value will be returned immediately.  Otherwise, C<ARCHIVE_OK> will
be returned if any module accepts the option, and C<ARCHIVE_FAILED>
in all other cases.

=cut

#ifdef HAS_archive_write_set_filter_option

int
archive_write_set_filter_option(archive, m, o, v)
    struct archive *archive
    string_or_null m
    string_or_null o
    string_or_null v

#endif

=head2 archive_write_set_option($archive, $module, $option, $value)

Calls C<archive_write_set_format_option>, then 
C<archive_write_set_filter_option>. If either function returns 
C<ARCHIVE_FATAL>, C<ARCHIVE_FATAL> will be returned immediately.  
Otherwise, greater of the two values will be returned.

=cut

#ifdef HAS_archive_write_set_option

int
archive_write_set_option(archive, m, o, v)
    struct archive *archive
    string_or_null m
    string_or_null o
    string_or_null v

#endif

=head2 archive_write_set_options($archive, $opts)

options is a comma-separated list of options.  If options is C<undef> or 
empty, C<ARCHIVE_OK> will be returned immediately.

Individual options have one of the following forms:

=over 4

=item option=value

The option/value pair will be provided to every module.  Modules that do 
not accept an option with this name will ignore it.

=item option

The option will be provided to every module with a value of "1".

=item !option

The option will be provided to every module with a NULL value.

=item module:option=value, module:option, module:!option

As above, but the corresponding option and value will be provided only 
to modules whose name matches module.

=back

=cut

#ifdef HAS_archive_write_set_options

int
archive_write_set_options(archive, opts)
    struct archive *archive
    string_or_null opts

#endif

=head2 archive_write_set_bytes_per_block($archive, $bytes_per_block)

Sets the block size used for writing the archive data.  Every call to 
the write callback function, except possibly the last one, will use this 
value for the length.  The default is to use a block size of 10240 
bytes.  Note that a block size of zero will suppress internal blocking 
and cause writes to be sent directly to the write callback as they 
occur.

=cut

#ifdef HAS_archive_write_set_bytes_per_block

int
archive_write_set_bytes_per_block(archive, bpb)
    struct archive *archive
    int bpb

#endif

=head2 archive_write_set_bytes_in_last_block($archive, $bytes_in_last_block)

Sets the block size used for writing the last block.  If this value is 
zero, the last block will be padded to the same size as the other 
blocks.  Otherwise, the final block will be padded to a multiple of this 
size.  In particular, setting it to 1 will cause the final block to not 
be padded.  For compressed output, any padding generated by this option 
is applied only after the compression.  The uncompressed data is always 
unpadded.  The default is to pad the last block to the full block size 
(note that C<archive_write_open_filename> will set this based on the file 
type).  Unlike the other "set" functions, this function can be called 
after the archive is opened.

=cut

#ifdef HAS_archive_write_set_bytes_in_last_block

int
archive_write_set_bytes_in_last_block(archive, bpb)
    struct archive *archive
    int bpb

#endif

=head2 archive_write_get_bytes_per_block($archive)

Retrieve the block size to be used for writing.  A value of -1 here 
indicates that the library should use default values.  A value of zero 
indicates that internal blocking is suppressed.

=cut

#ifdef HAS_archive_write_get_bytes_per_block

int
archive_write_get_bytes_per_block(archive)
    struct archive *archive

#endif

=head2 archive_write_get_bytes_in_last_block($archive)

Retrieve the currently-set value for last block size.  A value of -1 
here indicates that the library should use default values.

=cut

#ifdef HAS_archive_write_get_bytes_in_last_block

int
archive_write_get_bytes_in_last_block(archive)
    struct archive *archive

#endif

=head2 archive_write_fail($archive)

Marks the archive as FATAL so that a subsequent C<free> operation
won't try to C<close> cleanly.  Provides a fast abort capability
when the client discovers that things have gone wrong.

=cut

#ifdef HAS_archive_write_fail

int
archive_write_fail(archive)
    struct archive *archive

#endif

=head2 archive_write_disk_uid($archive, $string, $int64)

Undocumented libarchive function.

=cut

#ifdef HAS_archive_write_disk_uid

__LA_INT64_T
archive_write_disk_uid(archive, a2, a3)
    struct archive *archive
    const char *a2
    __LA_INT64_T a3

#endif

=head2 archive_write_disk_gid($archive, $string, $int64)

Undocumented libarchive function.

=cut

#ifdef HAS_archive_write_disk_gid

__LA_INT64_T
archive_write_disk_gid(archive, a2, a3)
    struct archive *archive
    const char *a2
    __LA_INT64_T a3

#endif

=head2 archive_write_disk_set_skip_file($archive, $device, $inode)

Records the device and inode numbers of a file that should not be 
overwritten.  This is typically used to ensure that an extraction 
process does not overwrite the archive from which objects are being 
read.  This capability is technically unnecessary but can be a 
significant performance optimization in practice.

=cut

#ifdef HAS_archive_write_disk_set_skip_file

int
archive_write_disk_set_skip_file(archive, a2, a3)
    struct archive *archive
    __LA_INT64_T a2
    __LA_INT64_T a3

#endif

=head2 archive_seek_data($archive, $offset, $whence)

Seek within the body of an entry.  Similar to C<lseek>.

=cut

#ifdef HAS_archive_seek_data

__LA_INT64_T
archive_seek_data(archive, a2, a3)
    struct archive *archive
    __LA_INT64_T a2
    int a3

#endif

=head2 archive_read_set_format_option($archive, $module, $option, $value)

Specifies an option that will be passed to currently-registered format 
readers.

If option and value are both C<undef>, these functions will do nothing 
and C<ARCHIVE_OK> will be returned.  If option is C<undef> but value is 
not, these functions will do nothing and C<ARCHIVE_FAILED> will be 
returned.

If module is not C<undef>, option and value will be provided to the filter 
or reader named module.  The return value will be that of the module.  
If there is no such module, C<ARCHIVE_FAILED> will be returned.

If module is C<NULL>, option and value will be provided to every registered 
module.  If any module returns C<ARCHIVE_FATAL>, this value will be 
returned immediately.  Otherwise, C<ARCHIVE_OK> will be returned if any 
module accepts the option, and C<ARCHIVE_FAILED> in all other cases.

=cut

#ifdef HAS_archive_read_set_format_option

int
archive_read_set_format_option(archive, m, o, v)
    struct archive *archive
    string_or_null m
    string_or_null o
    string_or_null v

#endif

=head2 archive_read_set_filter_option($archive, $module, $option, $value)

Specifies an option that will be passed to currently-registered filters 
(including decompression filters).

If option and value are both C<undef>, these functions will do nothing 
and C<ARCHIVE_OK> will be returned.  If option is C<undef> but value is 
not, these functions will do nothing and C<ARCHIVE_FAILED> will be 
returned.

If module is not C<undef>, option and value will be provided to the filter 
or reader named module.  The return value will be that of the module.  
If there is no such module, C<ARCHIVE_FAILED> will be returned.

If module is C<NULL>, option and value will be provided to every registered 
module.  If any module returns C<ARCHIVE_FATAL>, this value will be 
returned immediately.  Otherwise, C<ARCHIVE_OK> will be returned if any 
module accepts the option, and C<ARCHIVE_FAILED> in all other cases.

=cut

#ifdef HAS_archive_read_set_filter_option

int
archive_read_set_filter_option(archive, m, o, v)
    struct archive *archive
    string_or_null m
    string_or_null o
    string_or_null v

#endif

=head2 archive_read_set_option($archive, $module, $option, $value)

Calls C<archive_read_set_format_option> then 
C<archive_read_set_filter_option>.  If either function returns 
C<ARCHIVE_FATAL>, C<ARCHIVE_FATAL> will be returned immediately.  
Otherwise, greater of the two values will be returned.

=cut

#ifdef HAS_archive_read_set_option

int
archive_read_set_option(archive, m, o, v)
    struct archive *archive
    string_or_null m
    string_or_null o
    string_or_null v

#endif

=head2 archive_read_set_options($archive, $opts)

options is a comma-separated list of options.  If options is C<undef> or 
empty, C<ARCHIVE_OK> will be returned immediately.

Calls C<archive_read_set_option> with each option in turn.  If any 
C<archive_read_set_option> call returns C<ARCHIVE_FATAL>, 
C<ARCHIVE_FATAL> will be returned immediately.

=over 4

=item option=value

The option/value pair will be provided to every module.  Modules that do 
not accept an option with this name will ignore it.

=item option

The option will be provided to every module with a value of "1".

=item !option

The option will be provided to every module with an C<undef> value.

=item module:option=value, module:option, module:!option

As above, but the corresponding option and value will be provided only 
to modules whose name matches module.

=back

=cut

#ifdef HAS_archive_read_set_options

int
archive_read_set_options(archive, opts)
    struct archive *archive
    string_or_null opts

#endif

=head2 archive_read_set_format($archive, $format)

Undocumented libarchive function.

=cut

#ifdef HAS_archive_read_set_format

int
archive_read_set_format(archive, format)
    struct archive *archive
    int format

#endif

=head2 archive_read_header_position($archive)

Retrieve the byte offset in UNCOMPRESSED data where last-read
header started.

=cut

#ifdef HAS_archive_read_header_position

__LA_INT64_T
archive_read_header_position(archive)
    struct archive *archive

#endif

=head2 archive_read_open($archive, $data, $open_cb, $read_cb, $close_cb)

The same as C<archive_read_open2>, except that the skip callback is assumed to be C<undef>.

=cut

#ifdef HAS_archive_read_open

int
_archive_read_open(archive, data, open_cb, read_cb, close_cb)
    struct archive *archive
    SV *data
    SV *open_cb
    SV *read_cb
    SV *close_cb
  CODE:
    RETVAL = archive_read_open(
      archive,
      NULL,
      SvOK(open_cb)  ? myopen : NULL,
      SvOK(read_cb)  ? myread : NULL,
      SvOK(close_cb) ? myclose : NULL
    );
  OUTPUT:
    RETVAL

#endif

=head2 archive_read_open2($archive, $data, $open_cb, $read_cb, $skip_cb, $close_cb)

Freeze the settings, open the archive, and prepare for reading entries.  This is the most
generic version of this call, which accepts four callback functions.  Most clients will
want to use C<archive_read_open_filename>, C<archive_read_open_FILE>, C<archive_read_open_fd>,
or C<archive_read_open_memory> instead.  The library invokes the client-provided functions to 
obtain raw bytes from the archive.

=cut

#ifdef HAS_archive_read_open2

int
_archive_read_open2(archive, data, open_cb, read_cb, skip_cb, close_cb)
    struct archive *archive
    SV *data
    SV *open_cb
    SV *read_cb
    SV *skip_cb
    SV *close_cb
  CODE:
    RETVAL = archive_read_open2(
      archive,
      NULL,
      SvOK(open_cb)  ? myopen : NULL,
      SvOK(read_cb)  ? myread : NULL,
      SvOK(skip_cb)  ? myskip : NULL,
      SvOK(close_cb) ? myclose : NULL
    );
  OUTPUT:
    RETVAL

#endif

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
#ifdef ARCHIVE_API_FEATURE
        else if(!strcmp(name, "ARCHIVE_API_FEATURE"))
          RETVAL = ARCHIVE_API_FEATURE;
#endif
#ifdef ARCHIVE_API_VERSION
        else if(!strcmp(name, "ARCHIVE_API_VERSION"))
          RETVAL = ARCHIVE_API_VERSION;
#endif
#ifdef ARCHIVE_BYTES_PER_RECORD
        else if(!strcmp(name, "ARCHIVE_BYTES_PER_RECORD"))
          RETVAL = ARCHIVE_BYTES_PER_RECORD;
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
#ifdef ARCHIVE_DEFAULT_BYTES_PER_BLOCK
        else if(!strcmp(name, "ARCHIVE_DEFAULT_BYTES_PER_BLOCK"))
          RETVAL = ARCHIVE_DEFAULT_BYTES_PER_BLOCK;
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
#ifdef ARCHIVE_LIBRARY_VERSION
        else if(!strcmp(name, "ARCHIVE_LIBRARY_VERSION"))
          RETVAL = ARCHIVE_LIBRARY_VERSION;
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
#ifdef ARCHIVE_VERSION_STAMP
        else if(!strcmp(name, "ARCHIVE_VERSION_STAMP"))
          RETVAL = ARCHIVE_VERSION_STAMP;
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

#ifdef HAS_archive_read_support_filter_bzip2

int
archive_read_support_filter_bzip2(archive)
    struct archive *archive

#endif

=head2 archive_read_support_filter_compress($archive)

Enable compress decompression filter.

=cut

#ifdef HAS_archive_read_support_filter_compress

int
archive_read_support_filter_compress(archive)
    struct archive *archive

#endif

=head2 archive_read_support_filter_grzip($archive)

Enable grzip decompression filter.

=cut

#ifdef HAS_archive_read_support_filter_grzip

int
archive_read_support_filter_grzip(archive)
    struct archive *archive

#endif

=head2 archive_read_support_filter_gzip($archive)

Enable gzip decompression filter.

=cut

#ifdef HAS_archive_read_support_filter_gzip

int
archive_read_support_filter_gzip(archive)
    struct archive *archive

#endif

=head2 archive_read_support_filter_lrzip($archive)

Enable lrzip decompression filter.

=cut

#ifdef HAS_archive_read_support_filter_lrzip

int
archive_read_support_filter_lrzip(archive)
    struct archive *archive

#endif

=head2 archive_read_support_filter_lzip($archive)

Enable lzip decompression filter.

=cut

#ifdef HAS_archive_read_support_filter_lzip

int
archive_read_support_filter_lzip(archive)
    struct archive *archive

#endif

=head2 archive_read_support_filter_lzma($archive)

Enable lzma decompression filter.

=cut

#ifdef HAS_archive_read_support_filter_lzma

int
archive_read_support_filter_lzma(archive)
    struct archive *archive

#endif

=head2 archive_read_support_filter_lzop($archive)

Enable lzop decompression filter.

=cut

#ifdef HAS_archive_read_support_filter_lzop

int
archive_read_support_filter_lzop(archive)
    struct archive *archive

#endif

=head2 archive_read_support_filter_none($archive)

Enable none decompression filter.

=cut

#ifdef HAS_archive_read_support_filter_none

int
archive_read_support_filter_none(archive)
    struct archive *archive

#endif

=head2 archive_read_support_filter_rpm($archive)

Enable rpm decompression filter.

=cut

#ifdef HAS_archive_read_support_filter_rpm

int
archive_read_support_filter_rpm(archive)
    struct archive *archive

#endif

=head2 archive_read_support_filter_uu($archive)

Enable uu decompression filter.

=cut

#ifdef HAS_archive_read_support_filter_uu

int
archive_read_support_filter_uu(archive)
    struct archive *archive

#endif

=head2 archive_read_support_filter_xz($archive)

Enable xz decompression filter.

=cut

#ifdef HAS_archive_read_support_filter_xz

int
archive_read_support_filter_xz(archive)
    struct archive *archive

#endif

=head2 archive_read_support_format_7zip($archive)

Enable 7zip archive format.

=cut

#ifdef HAS_archive_read_support_format_7zip

int
archive_read_support_format_7zip(archive)
    struct archive *archive

#endif

=head2 archive_read_support_format_ar($archive)

Enable ar archive format.

=cut

#ifdef HAS_archive_read_support_format_ar

int
archive_read_support_format_ar(archive)
    struct archive *archive

#endif

=head2 archive_read_support_format_cab($archive)

Enable cab archive format.

=cut

#ifdef HAS_archive_read_support_format_cab

int
archive_read_support_format_cab(archive)
    struct archive *archive

#endif

=head2 archive_read_support_format_cpio($archive)

Enable cpio archive format.

=cut

#ifdef HAS_archive_read_support_format_cpio

int
archive_read_support_format_cpio(archive)
    struct archive *archive

#endif

=head2 archive_read_support_format_empty($archive)

Enable empty archive format.

=cut

#ifdef HAS_archive_read_support_format_empty

int
archive_read_support_format_empty(archive)
    struct archive *archive

#endif

=head2 archive_read_support_format_gnutar($archive)

Enable gnutar archive format.

=cut

#ifdef HAS_archive_read_support_format_gnutar

int
archive_read_support_format_gnutar(archive)
    struct archive *archive

#endif

=head2 archive_read_support_format_iso9660($archive)

Enable iso9660 archive format.

=cut

#ifdef HAS_archive_read_support_format_iso9660

int
archive_read_support_format_iso9660(archive)
    struct archive *archive

#endif

=head2 archive_read_support_format_lha($archive)

Enable lha archive format.

=cut

#ifdef HAS_archive_read_support_format_lha

int
archive_read_support_format_lha(archive)
    struct archive *archive

#endif

=head2 archive_read_support_format_mtree($archive)

Enable mtree archive format.

=cut

#ifdef HAS_archive_read_support_format_mtree

int
archive_read_support_format_mtree(archive)
    struct archive *archive

#endif

=head2 archive_read_support_format_rar($archive)

Enable rar archive format.

=cut

#ifdef HAS_archive_read_support_format_rar

int
archive_read_support_format_rar(archive)
    struct archive *archive

#endif

=head2 archive_read_support_format_raw($archive)

Enable raw archive format.

=cut

#ifdef HAS_archive_read_support_format_raw

int
archive_read_support_format_raw(archive)
    struct archive *archive

#endif

=head2 archive_read_support_format_tar($archive)

Enable tar archive format.

=cut

#ifdef HAS_archive_read_support_format_tar

int
archive_read_support_format_tar(archive)
    struct archive *archive

#endif

=head2 archive_read_support_format_xar($archive)

Enable xar archive format.

=cut

#ifdef HAS_archive_read_support_format_xar

int
archive_read_support_format_xar(archive)
    struct archive *archive

#endif

=head2 archive_read_support_format_zip($archive)

Enable zip archive format.

=cut

#ifdef HAS_archive_read_support_format_zip

int
archive_read_support_format_zip(archive)
    struct archive *archive

#endif

=head2 archive_write_add_filter_b64encode($archive)

Add b64encode filter

=cut

#ifdef HAS_archive_write_add_filter_b64encode

int
archive_write_add_filter_b64encode(archive)
    struct archive *archive

#endif

=head2 archive_write_add_filter_bzip2($archive)

Add bzip2 filter

=cut

#ifdef HAS_archive_write_add_filter_bzip2

int
archive_write_add_filter_bzip2(archive)
    struct archive *archive

#endif

=head2 archive_write_add_filter_compress($archive)

Add compress filter

=cut

#ifdef HAS_archive_write_add_filter_compress

int
archive_write_add_filter_compress(archive)
    struct archive *archive

#endif

=head2 archive_write_add_filter_grzip($archive)

Add grzip filter

=cut

#ifdef HAS_archive_write_add_filter_grzip

int
archive_write_add_filter_grzip(archive)
    struct archive *archive

#endif

=head2 archive_write_add_filter_gzip($archive)

Add gzip filter

=cut

#ifdef HAS_archive_write_add_filter_gzip

int
archive_write_add_filter_gzip(archive)
    struct archive *archive

#endif

=head2 archive_write_add_filter_lrzip($archive)

Add lrzip filter

=cut

#ifdef HAS_archive_write_add_filter_lrzip

int
archive_write_add_filter_lrzip(archive)
    struct archive *archive

#endif

=head2 archive_write_add_filter_lzip($archive)

Add lzip filter

=cut

#ifdef HAS_archive_write_add_filter_lzip

int
archive_write_add_filter_lzip(archive)
    struct archive *archive

#endif

=head2 archive_write_add_filter_lzma($archive)

Add lzma filter

=cut

#ifdef HAS_archive_write_add_filter_lzma

int
archive_write_add_filter_lzma(archive)
    struct archive *archive

#endif

=head2 archive_write_add_filter_lzop($archive)

Add lzop filter

=cut

#ifdef HAS_archive_write_add_filter_lzop

int
archive_write_add_filter_lzop(archive)
    struct archive *archive

#endif

=head2 archive_write_add_filter_none($archive)

Add none filter

=cut

#ifdef HAS_archive_write_add_filter_none

int
archive_write_add_filter_none(archive)
    struct archive *archive

#endif

=head2 archive_write_add_filter_uuencode($archive)

Add uuencode filter

=cut

#ifdef HAS_archive_write_add_filter_uuencode

int
archive_write_add_filter_uuencode(archive)
    struct archive *archive

#endif

=head2 archive_write_add_filter_xz($archive)

Add xz filter

=cut

#ifdef HAS_archive_write_add_filter_xz

int
archive_write_add_filter_xz(archive)
    struct archive *archive

#endif

=head2 archive_write_set_format_7zip($archive)

Set the archive format to 7zip

=cut

#ifdef HAS_archive_write_set_format_7zip

int
archive_write_set_format_7zip(archive)
    struct archive *archive

#endif

=head2 archive_write_set_format_ar_bsd($archive)

Set the archive format to ar_bsd

=cut

#ifdef HAS_archive_write_set_format_ar_bsd

int
archive_write_set_format_ar_bsd(archive)
    struct archive *archive

#endif

=head2 archive_write_set_format_ar_svr4($archive)

Set the archive format to ar_svr4

=cut

#ifdef HAS_archive_write_set_format_ar_svr4

int
archive_write_set_format_ar_svr4(archive)
    struct archive *archive

#endif

=head2 archive_write_set_format_cpio($archive)

Set the archive format to cpio

=cut

#ifdef HAS_archive_write_set_format_cpio

int
archive_write_set_format_cpio(archive)
    struct archive *archive

#endif

=head2 archive_write_set_format_cpio_newc($archive)

Set the archive format to cpio_newc

=cut

#ifdef HAS_archive_write_set_format_cpio_newc

int
archive_write_set_format_cpio_newc(archive)
    struct archive *archive

#endif

=head2 archive_write_set_format_gnutar($archive)

Set the archive format to gnutar

=cut

#ifdef HAS_archive_write_set_format_gnutar

int
archive_write_set_format_gnutar(archive)
    struct archive *archive

#endif

=head2 archive_write_set_format_iso9660($archive)

Set the archive format to iso9660

=cut

#ifdef HAS_archive_write_set_format_iso9660

int
archive_write_set_format_iso9660(archive)
    struct archive *archive

#endif

=head2 archive_write_set_format_mtree($archive)

Set the archive format to mtree

=cut

#ifdef HAS_archive_write_set_format_mtree

int
archive_write_set_format_mtree(archive)
    struct archive *archive

#endif

=head2 archive_write_set_format_mtree_classic($archive)

Set the archive format to mtree_classic

=cut

#ifdef HAS_archive_write_set_format_mtree_classic

int
archive_write_set_format_mtree_classic(archive)
    struct archive *archive

#endif

=head2 archive_write_set_format_pax($archive)

Set the archive format to pax

=cut

#ifdef HAS_archive_write_set_format_pax

int
archive_write_set_format_pax(archive)
    struct archive *archive

#endif

=head2 archive_write_set_format_pax_restricted($archive)

Set the archive format to pax_restricted

=cut

#ifdef HAS_archive_write_set_format_pax_restricted

int
archive_write_set_format_pax_restricted(archive)
    struct archive *archive

#endif

=head2 archive_write_set_format_shar($archive)

Set the archive format to shar

=cut

#ifdef HAS_archive_write_set_format_shar

int
archive_write_set_format_shar(archive)
    struct archive *archive

#endif

=head2 archive_write_set_format_shar_dump($archive)

Set the archive format to shar_dump

=cut

#ifdef HAS_archive_write_set_format_shar_dump

int
archive_write_set_format_shar_dump(archive)
    struct archive *archive

#endif

=head2 archive_write_set_format_ustar($archive)

Set the archive format to ustar

=cut

#ifdef HAS_archive_write_set_format_ustar

int
archive_write_set_format_ustar(archive)
    struct archive *archive

#endif

=head2 archive_write_set_format_v7tar($archive)

Set the archive format to v7tar

=cut

#ifdef HAS_archive_write_set_format_v7tar

int
archive_write_set_format_v7tar(archive)
    struct archive *archive

#endif

=head2 archive_write_set_format_xar($archive)

Set the archive format to xar

=cut

#ifdef HAS_archive_write_set_format_xar

int
archive_write_set_format_xar(archive)
    struct archive *archive

#endif

=head2 archive_write_set_format_zip($archive)

Set the archive format to zip

=cut

#ifdef HAS_archive_write_set_format_zip

int
archive_write_set_format_zip(archive)
    struct archive *archive

#endif

