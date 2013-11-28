#include <langinfo.h>
#include <locale.h>
#include "perl_archive.h"

const char *
archive_perl_codeset(void)
{
  return nl_langinfo(CODESET);
}

int
archive_perl_utf8_mode(void)
{
  return strcmp(nl_langinfo(CODESET), "UTF-8") == 0;
}
