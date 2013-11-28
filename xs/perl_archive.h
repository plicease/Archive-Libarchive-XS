#ifndef PERL_LIBARCHIVE_H
#define PERL_LIBARCHIVE_H

#define HAS_archive_perl_codeset        1
#define HAS_archive_perl_utf8_mode      1

const char *archive_perl_codeset(void);
int archive_perl_utf8_mode(void);

#endif
