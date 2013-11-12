# Archive::Libarchive::XS

Perl bindings to libarchive via XS

# SYNOPSIS

    use Archive::Libarchive::XS;

# DESCRIPTION

This module provides a functional interface to libarchive.

# FUNCTIONS

## archive\_entry\_pathname($entry)

Retrieve the pathname of the entry

## archive\_read\_data\_skip($archive)

FIXME

## archive\_read\_free($archive)

Invokes `archive_read_close` if it was not invoked manually, then
release all resources.

## archive\_read\_new

Allocates and initializes a archive object suitable for reading from an archive.
Returns an instance of [Archive::Libarchive::XS::archive](https://metacpan.org/pod/Archive::Libarchive::XS::archive)

TODO: handle the unusual circumstance when this would return C NULL pointer.

## archive\_read\_next\_header($archive, $entry)

Read the header for the next entry and return an entry object
($entry will be an instance of [Archive::Libarchive::XS::archive_entry](https://metacpan.org/pod/Archive::Libarchive::XS::archive_entry)).

TODO: maybe use archive\_read\_next\_header2

## archive\_read\_open\_filename($archive, $filename, $block\_size)

Like `archive_read_open`, except that it accepts a simple filename
and a block size.  This function is safe for use with tape drives
or other blocked devices.

TODO: a NULL filename represents standard input.

## archive\_read\_support\_filter\_all($archive)

FIXME

## archive\_read\_support\_format\_all($archive)

FIXME

## archive\_version\_number

Return the libarchive version as an integer

## archive\_version\_string

Return the libarchive as a version.

# CONSTANTS

If provided by your libarchive library, these constants will be available and
exportable from the [Archive::Libarchive::XS](https://metacpan.org/pod/Archive::Libarchive::XS) (you may import all available
constants using the `:const` export tag).

- AE\_IFBLK
- AE\_IFCHR
- AE\_IFDIR
- AE\_IFIFO
- AE\_IFLNK
- AE\_IFMT
- AE\_IFREG
- AE\_IFSOCK
- ARCHIVE\_COMPRESSION\_BZIP2
- ARCHIVE\_COMPRESSION\_COMPRESS
- ARCHIVE\_COMPRESSION\_GZIP
- ARCHIVE\_COMPRESSION\_LRZIP
- ARCHIVE\_COMPRESSION\_LZIP
- ARCHIVE\_COMPRESSION\_LZMA
- ARCHIVE\_COMPRESSION\_NONE
- ARCHIVE\_COMPRESSION\_PROGRAM
- ARCHIVE\_COMPRESSION\_RPM
- ARCHIVE\_COMPRESSION\_UU
- ARCHIVE\_COMPRESSION\_XZ
- ARCHIVE\_ENTRY\_ACL\_ADD\_FILE
- ARCHIVE\_ENTRY\_ACL\_ADD\_SUBDIRECTORY
- ARCHIVE\_ENTRY\_ACL\_APPEND\_DATA
- ARCHIVE\_ENTRY\_ACL\_DELETE
- ARCHIVE\_ENTRY\_ACL\_DELETE\_CHILD
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_DIRECTORY\_INHERIT
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_FAILED\_ACCESS
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_FILE\_INHERIT
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_INHERIT\_ONLY
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_NO\_PROPAGATE\_INHERIT
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_SUCCESSFUL\_ACCESS
- ARCHIVE\_ENTRY\_ACL\_EVERYONE
- ARCHIVE\_ENTRY\_ACL\_EXECUTE
- ARCHIVE\_ENTRY\_ACL\_GROUP
- ARCHIVE\_ENTRY\_ACL\_GROUP\_OBJ
- ARCHIVE\_ENTRY\_ACL\_INHERITANCE\_NFS4
- ARCHIVE\_ENTRY\_ACL\_LIST\_DIRECTORY
- ARCHIVE\_ENTRY\_ACL\_MASK
- ARCHIVE\_ENTRY\_ACL\_OTHER
- ARCHIVE\_ENTRY\_ACL\_PERMS\_NFS4
- ARCHIVE\_ENTRY\_ACL\_PERMS\_POSIX1E
- ARCHIVE\_ENTRY\_ACL\_READ
- ARCHIVE\_ENTRY\_ACL\_READ\_ACL
- ARCHIVE\_ENTRY\_ACL\_READ\_ATTRIBUTES
- ARCHIVE\_ENTRY\_ACL\_READ\_DATA
- ARCHIVE\_ENTRY\_ACL\_READ\_NAMED\_ATTRS
- ARCHIVE\_ENTRY\_ACL\_STYLE\_EXTRA\_ID
- ARCHIVE\_ENTRY\_ACL\_STYLE\_MARK\_DEFAULT
- ARCHIVE\_ENTRY\_ACL\_SYNCHRONIZE
- ARCHIVE\_ENTRY\_ACL\_TYPE\_ACCESS
- ARCHIVE\_ENTRY\_ACL\_TYPE\_ALARM
- ARCHIVE\_ENTRY\_ACL\_TYPE\_ALLOW
- ARCHIVE\_ENTRY\_ACL\_TYPE\_AUDIT
- ARCHIVE\_ENTRY\_ACL\_TYPE\_DEFAULT
- ARCHIVE\_ENTRY\_ACL\_TYPE\_DENY
- ARCHIVE\_ENTRY\_ACL\_TYPE\_NFS4
- ARCHIVE\_ENTRY\_ACL\_TYPE\_POSIX1E
- ARCHIVE\_ENTRY\_ACL\_USER
- ARCHIVE\_ENTRY\_ACL\_USER\_OBJ
- ARCHIVE\_ENTRY\_ACL\_WRITE
- ARCHIVE\_ENTRY\_ACL\_WRITE\_ACL
- ARCHIVE\_ENTRY\_ACL\_WRITE\_ATTRIBUTES
- ARCHIVE\_ENTRY\_ACL\_WRITE\_DATA
- ARCHIVE\_ENTRY\_ACL\_WRITE\_NAMED\_ATTRS
- ARCHIVE\_ENTRY\_ACL\_WRITE\_OWNER
- ARCHIVE\_EOF
- ARCHIVE\_EXTRACT\_ACL
- ARCHIVE\_EXTRACT\_FFLAGS
- ARCHIVE\_EXTRACT\_HFS\_COMPRESSION\_FORCED
- ARCHIVE\_EXTRACT\_MAC\_METADATA
- ARCHIVE\_EXTRACT\_NO\_AUTODIR
- ARCHIVE\_EXTRACT\_NO\_HFS\_COMPRESSION
- ARCHIVE\_EXTRACT\_NO\_OVERWRITE
- ARCHIVE\_EXTRACT\_NO\_OVERWRITE\_NEWER
- ARCHIVE\_EXTRACT\_OWNER
- ARCHIVE\_EXTRACT\_PERM
- ARCHIVE\_EXTRACT\_SECURE\_NODOTDOT
- ARCHIVE\_EXTRACT\_SECURE\_SYMLINKS
- ARCHIVE\_EXTRACT\_SPARSE
- ARCHIVE\_EXTRACT\_TIME
- ARCHIVE\_EXTRACT\_UNLINK
- ARCHIVE\_EXTRACT\_XATTR
- ARCHIVE\_FAILED
- ARCHIVE\_FATAL
- ARCHIVE\_FILTER\_BZIP2
- ARCHIVE\_FILTER\_COMPRESS
- ARCHIVE\_FILTER\_GRZIP
- ARCHIVE\_FILTER\_GZIP
- ARCHIVE\_FILTER\_LRZIP
- ARCHIVE\_FILTER\_LZIP
- ARCHIVE\_FILTER\_LZMA
- ARCHIVE\_FILTER\_LZOP
- ARCHIVE\_FILTER\_NONE
- ARCHIVE\_FILTER\_PROGRAM
- ARCHIVE\_FILTER\_RPM
- ARCHIVE\_FILTER\_UU
- ARCHIVE\_FILTER\_XZ
- ARCHIVE\_FORMAT\_7ZIP
- ARCHIVE\_FORMAT\_AR
- ARCHIVE\_FORMAT\_AR\_BSD
- ARCHIVE\_FORMAT\_AR\_GNU
- ARCHIVE\_FORMAT\_BASE\_MASK
- ARCHIVE\_FORMAT\_CAB
- ARCHIVE\_FORMAT\_CPIO
- ARCHIVE\_FORMAT\_CPIO\_AFIO\_LARGE
- ARCHIVE\_FORMAT\_CPIO\_BIN\_BE
- ARCHIVE\_FORMAT\_CPIO\_BIN\_LE
- ARCHIVE\_FORMAT\_CPIO\_POSIX
- ARCHIVE\_FORMAT\_CPIO\_SVR4\_CRC
- ARCHIVE\_FORMAT\_CPIO\_SVR4\_NOCRC
- ARCHIVE\_FORMAT\_EMPTY
- ARCHIVE\_FORMAT\_ISO9660
- ARCHIVE\_FORMAT\_ISO9660\_ROCKRIDGE
- ARCHIVE\_FORMAT\_LHA
- ARCHIVE\_FORMAT\_MTREE
- ARCHIVE\_FORMAT\_RAR
- ARCHIVE\_FORMAT\_RAW
- ARCHIVE\_FORMAT\_SHAR
- ARCHIVE\_FORMAT\_SHAR\_BASE
- ARCHIVE\_FORMAT\_SHAR\_DUMP
- ARCHIVE\_FORMAT\_TAR
- ARCHIVE\_FORMAT\_TAR\_GNUTAR
- ARCHIVE\_FORMAT\_TAR\_PAX\_INTERCHANGE
- ARCHIVE\_FORMAT\_TAR\_PAX\_RESTRICTED
- ARCHIVE\_FORMAT\_TAR\_USTAR
- ARCHIVE\_FORMAT\_XAR
- ARCHIVE\_FORMAT\_ZIP
- ARCHIVE\_MATCH\_CTIME
- ARCHIVE\_MATCH\_EQUAL
- ARCHIVE\_MATCH\_MTIME
- ARCHIVE\_MATCH\_NEWER
- ARCHIVE\_MATCH\_OLDER
- ARCHIVE\_OK
- ARCHIVE\_READDISK\_HONOR\_NODUMP
- ARCHIVE\_READDISK\_MAC\_COPYFILE
- ARCHIVE\_READDISK\_NO\_TRAVERSE\_MOUNTS
- ARCHIVE\_READDISK\_RESTORE\_ATIME
- ARCHIVE\_RETRY
- ARCHIVE\_VERSION\_NUMBER
- ARCHIVE\_WARN

# SEE ALSO

The intent of this module is to provide a low level fairly thin direct
interface to the libarchive interface, on which a more Perlish OO layer
could be written.

- [Archive::Peek::Libarchive](https://metacpan.org/pod/Archive::Peek::Libarchive)
- [Archive::Extract::Libarchive](https://metacpan.org/pod/Archive::Extract::Libarchive)

    Both of these provide a higher level perlish interface to libarchive.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
