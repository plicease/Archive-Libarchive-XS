#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <archive.h>
#include <string.h>

MODULE = Archive::Libarchive::XS   PACKAGE = Archive::Libarchive::XS

struct archive *
archive_read_new();

int
archive_read_free(archive)
    struct archive *archive;

int
archive_read_support_filter_all(archive)
    struct archive *archive;

int
archive_read_support_format_all(archive)
    struct archive *archive;

int
archive_read_open_filename(archive, filename, block_size)
    struct archive *archive;
    const char *filename;
    size_t block_size;

int
archive_read_next_header(archive, out)
    struct archive *archive;
    SV *out;
  CODE:
    struct archive_entry *entry;
    RETVAL = archive_read_next_header(archive, &entry);
    /* Question: entry is probably not valid on EOF ? */
    sv_setref_pv(out, "Archive::Libarchive::XS::archive_entry", (void*) entry);
  OUTPUT:
    RETVAL
    out

int
archive_read_data_skip(archive)
    struct archive *archive;

const char *
archive_version_string();

int
archive_version_number();

const char *
archive_entry_pathname(archive_entry);
    struct archive_entry *archive_entry;

int
constant(name)
        char *name
    CODE:
        if(!strcmp(name, "ARCHIVE_OK"))
          RETVAL = ARCHIVE_OK;
        else if(!strcmp(name, "ARCHIVE_EOF"))
          RETVAL = ARCHIVE_EOF;
        else
          Perl_croak(aTHX_ "No such constant");
    OUTPUT:
        RETVAL
