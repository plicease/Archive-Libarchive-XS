#ifndef PERL_LIBARCHIVE_H
#define PERL_LIBARCHIVE_H

#define HAS_archive_perl_codeset        1
#define HAS_archive_perl_utf8_mode      1

const char *archive_perl_codeset(void);
int archive_perl_utf8_mode(void);

#if ARCHIVE_VERSION_NUMBER < 3000000

#define archive_read_support_filter_all(a) archive_read_support_compression_all(a)

#endif

#endif
