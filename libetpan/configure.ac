#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

m4_define([maj_version], [0])
m4_define([min_version], [58])
m4_define([api_current], [14])
m4_define([api_revision], [3])
m4_define([api_compatibility], [13])
dnl API version
dnl 1. If you have changed any of the sources for this library, the revision
dnl    number must be incremented. This is a new revision of the current
dnl    interface.
dnl 2. If the interface has changed, then current must be incremented, and
dnl    revision reset to `0'. This is the first revision of a new interface.
dnl 3. If the new interface is a superset of the previous interface (that is,
dnl    if the previous interface has not been broken by the changes in this new
dnl    release), then age must be incremented. This release is backwards
dnl    compatible with the previous release.
dnl 4. If the new interface has removed elements with respect to the previous
dnl    interface, then you have broken backward compatibility and age must be
dnl    reset to `0'. This release has a new, but backwards incompatible
dnl    interface.
dnl age = api_current - api_compatiblity

AC_PREREQ(2.61)
AC_INIT([libetpan],[maj_version.min_version],[libetpan-devel@lists.sourceforge.net])
AC_CONFIG_SRCDIR([src/main/libetpan_version.h.in])
AC_CONFIG_MACRO_DIR([m4])
AM_CONFIG_HEADER([config.h])
AM_INIT_AUTOMAKE
AM_MAINTAINER_MODE
AC_CANONICAL_HOST

dnl Version major and minor
VERSION_MAJOR=maj_version
VERSION_MINOR=min_version

dnl required version of libcurl
libcurl_major_required=0
libcurl_minor_required=0

dnl API version
dnl 1. If you have changed any of the sources for this library, the revision
dnl    number must be incremented. This is a new revision of the current
dnl    interface.
dnl 2. If the interface has changed, then current must be incremented, and
dnl    revision reset to `0'. This is the first revision of a new interface.
dnl 3. If the new interface is a superset of the previous interface (that is,
dnl    if the previous interface has not been broken by the changes in this new
dnl    release), then age must be incremented. This release is backwards
dnl    compatible with the previous release.
dnl 4. If the new interface has removed elements with respect to the previous
dnl    interface, then you have broken backward compatibility and age must be
dnl    reset to `0'. This release has a new, but backwards incompatible
dnl    interface.
API_CURRENT=api_current
API_REVISION=api_revision
API_COMPATIBILITY=api_compatibility
AC_SUBST(API_CURRENT)
AC_SUBST(API_COMPATIBILITY)
AC_SUBST(API_REVISION)

API_AGE=`expr $API_CURRENT - $API_COMPATIBILITY`
API_VERSION="$API_CURRENT:$API_REVISION:$API_AGE"
AC_SUBST(API_VERSION)

dnl FIXME: This should be the CVS revision.
BUILD_REVISION=0
AC_SUBST(BUILD_REVISION)
BUILD_TIMESTAMP=`date +'%Y-%m-%dT%H:%M%z'`
AC_SUBST(BUILD_TIMESTAMP)
changequote(,)dnl 
BUILD_FILEVERSION=`echo "${VERSION_MAJOR}.${VERSION_MINOR}.0" | sed 's/\([0-9.]*\).*/\1./;s/\./,/g'`
changequote([,])dnl
BUILD_FILEVERSION="${BUILD_FILEVERSION}${BUILD_REVISION}"
AC_SUBST(BUILD_FILEVERSION)


# Architecture specific.
have_w32_system=no
case "${host}" in
    *-mingw32*)
        have_w32_system=yes
	CFLAGS="$CFLAGS -mms-bitfields -I\${top_srcdir}/src/windows"
	## Currently we export all symbols indiscriminately.
	## Eventually, this can be limited to those which should be
	## exported (which helps to hide our internal mmap stubs, for
	## example), but before this can happen, the missing export
	## declarations have to be added to all header files.  Also, it
	## should first be verified that exporting data members from a
	## DLL is safe.  To reenable discriminate exports, uncomment
	## the following line and replace the "@ifdef _MSC_VER" around the
	## export/import declaration stuff in libetpan.h.in by
	## "@if WIN32".
	# CFLAGS="$CFLAGS -DLIBETPAN_DLL"
        # We use winsock2.
    	LIBS="$LIBS -lws2_32"
        ;;
    *)
	;;
esac
if test "$have_w32_system" = yes; then
   AC_DEFINE(HAVE_MINGW32_SYSTEM, 1, [Defined if we run on a W32 API based system])
fi
AM_CONDITIONAL(HAVE_MINGW32_SYSTEM, test "$have_w32_system" = yes)

# Check the C compiler.
AC_PROG_CC
AC_PROG_CXX

# Compiler flags.
AC_ARG_ENABLE(debug,   [  --enable-debug          setup flags (gcc) for debugging (default=no)],
if test "x$GCC" = xyes; then
  CFLAGS="$CFLAGS -O2 -g"
fi
CPPFLAGS="$CPPFLAGS -DDEBUG"
LDFLAGS="$LDFLAGS",)
AC_ARG_ENABLE(optim,   [  --enable-optim          setup flags (gcc) for optimizations (default=no)],
if test "x$enable_debug" != "xyes" ; then
  if test "x$GCC" = xyes; then
    CFLAGS="$CFLAGS -O2 -ffast-math -funroll-loops -g0"
  fi
  CPPFLAGS="$CPPFLAGS"
  LDFLAGS="$LDFLAGS -s"
else
  AC_MSG_WARN([enable-optim and enable-debug are incompatible -- disabling optimizations])
fi,)
if test "x$GCC" = xyes; then
  CFLAGS="$CFLAGS -W -Wall"
fi
AC_ARG_ENABLE(syntax,   [  --enable-unstrict-syntax be lazy on syntax checking for protocols (default=no)], , [AC_DEFINE(UNSTRICT_SYNTAX, 1, [Define to be lazy on protocol syntax])])

AH_VERBATIM([CONFIG_H_FIRST], [/* Check for Linux's /usr/include/features.h
 */
#ifdef _FEATURES_H
#  error  config.h must be first file included
#endif])

AC_C_INLINE

# Checks for programs.
AC_LIBTOOL_WIN32_DLL
AC_LIBTOOL_RC
AC_PROG_LIBTOOL
AC_PROG_MKDIR_P

dnl Can't use AC_PROG_INSTALL
INSTALL='$(SHELL) $(top_srcdir)/install-sh -c'
AC_SUBST(INSTALL)

# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS(fcntl.h unistd.h ctype.h sys/types.h sys/stat.h sys/mman.h limits.h)
AC_CHECK_HEADERS(netdb.h netinet/in.h sys/socket.h)
AC_CHECK_HEADERS(sys/param.h sys/select.h inttypes.h)
AC_CHECK_HEADERS(arpa/inet.h winsock2.h)

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_FUNC_MMAP

dnl Network libs
AC_CHECK_FUNC(connect, checksocket=no, checksocket=yes)
if test "x$checksocket" = "xyes"; then 
case "x$LIBS" in
 *-lsocket*);;
 *) AC_CHECK_LIB(socket, connect) ;;
esac
fi
AC_CHECK_FUNC(inet_ntoa, checknsl=no, checknsl=yes)
if test "x$checknsl" = "xyes"; then 
case "x$LIBS" in
 *-lnsl*);;
 *) AC_CHECK_LIB(nsl, inet_ntoa) ;;
esac
fi

# Check for getopt_long; if not found, use included source.
AC_CHECK_FUNCS([getopt_long], has_getopt_long=no, has_getopt_long=yes)
if test "x$has_getoptlong" = "xyes"; then
  AC_DEFINE([HAVE_GETOPT_LONG], 1, [Define to use getopt_long])
fi

dnl OpenSSL -- very primitive right now
AC_ARG_WITH(openssl,   [  --with-openssl[=DIR]    include OpenSSL support (default=auto)],
            [], [with_openssl=yes])
if test "x$with_openssl" != "xno"; then
  OCPPFLAGS="$CPPFLAGS"
  OLDFLAGS="$LDFLAGS"
  if test "x$with_openssl" != "xyes" ; then
    CPPFLAGS="$CPPFLAGS -I$with_openssl/include"
    LDFLAGS="$LDFLAGS -L$with_openssl/lib"
  fi
  with_openssl=no
  SSLLIBS=""
  AC_CHECK_HEADER(openssl/ssl.h, [
   AC_CHECK_LIB(rsaref, main, [SSLLIBS="-lrsaref"])
   AC_CHECK_LIB(crypto, main, [SSLLIBS="-lcrypto $SSLLIBS"], [], [$SSLLIBS])
   AC_CHECK_LIB(ssl, SSL_library_init, with_openssl=yes, [], [$SSLLIBS])])
  if test "x$with_openssl" != "xyes"; then
    CPPFLAGS="$OCPPFLAGS"
    LDFLAGS="$OLDFLAGS"
  else
   with_gnutls="no"
  fi
fi
if test "x$with_openssl" = "xyes"; then
  AC_DEFINE([USE_SSL], 1, [Define to use OpenSSL])
  SSLLIBS="-lssl $SSLLIBS"
else
  SSLLIBS=""
fi
AC_SUBST(SSLLIBS)

dnl GNUTLS
AC_ARG_WITH(gnutls,    [ --with-gnutls[=DIR]      include GnuTLS support (default=auto)],
            [], [with_gnutls=no])
if test "x$with_gnutls" != "xno"; then
  OCPPFLAGS="$CPPFLAGS"
  OLDFLAGS="$LDFLAGS"
  if test "x$with_gnutls" != "xyes" ; then
    CPPFLAGS="CRPPFLAGS -I$with_gnutls/include"
    LDFLAGS="$LDFLAGS -L$with_gnutls/lib"
  fi
  GNUTLSLIB=""
  AC_CHECK_HEADER(gnutls/gnutls.h, [
   AC_CHECK_LIB(gnutls, gnutls_global_deinit, with_gnutls=yes, [GNUTLSLIB="-lgnutls"])
  ])
  if test "x$with_gnutls" != "xyes"; then
   CPPFLAGS="$OCPPFLAGS"
   LDFLAGS="$OLDFLAGS"
  else
   with_openssl="no"
  fi
fi
if test "x$with_gnutls" = "xyes"; then
  AC_DEFINE([USE_GNUTLS],1, [Define to use GnuTLS])
  AC_DEFINE([USE_SSL], 1, [Define to use OpenSSL])
  GNUTLSLIB="-lgnutls"
else
  GNUTLSLIB=""
fi
AC_SUBST(GNUTLSLIB)

if test "x$with_openssl" = "xno"; then
   if test "x$with_gnutls" = "xno"; then
      AC_MSG_WARN([OpenSSL support disabled.])
   fi
fi

dnl iconv
LIBICONV=""

AC_ARG_ENABLE(iconv,
	[ --disable-iconv	make a version not using iconv],
		enable_iconv=no, enable_iconv=yes)
if test x$enable_iconv = xyes; then
   dnl get prototype
   AC_CHECK_HEADER(iconv.h, [ICONV_HEADER=1], [ICONV_HEADER=0])
   
   ICONV_PROTO=no
   AC_MSG_CHECKING([checking iconv() prototype])
   if test "x$ICONV_HEADER" = x1 ; then
     SAVED_CPPFLAGS="$CPPFLAGS"
     CPPFLAGS="-std=c99 $CPPFLAGS"
     AC_TRY_COMPILE([#include <iconv.h>
       size_t iconv (iconv_t cd, char ** restrict inbuf,
                     size_t * restrict inbytesleft,
                     char ** restrict outbuf,
                     size_t * restrict outbytesleft);],
       [],
       [ICONV_PROTO=noconst]
       [])
     AC_TRY_COMPILE([#include <iconv.h>
       size_t iconv (iconv_t cd, const char ** restrict inbuf,
                     size_t * restrict inbytesleft,
                     char ** restrict outbuf,
                     size_t * restrict outbytesleft);],
       [],
       [ICONV_PROTO=const]
       [])
     CPPFLAGS="$SAVED_CPPFLAGS"
   fi

   dnl try to link
   ICONV_LINKED=NO
   if test "$ICONV_PROTO" != "xno" ; then
     AC_MSG_RESULT([ok])
     
     AC_MSG_CHECKING([for iconv])
     
     ICONV_LINKED=0
     AC_TRY_LINK([#include <stdlib.h>
#include <iconv.h>],
       [iconv_t cd = iconv_open("","");
        iconv(cd,NULL,NULL,NULL,NULL);
        iconv_close(cd);],
       [ICONV_LINKED=1],
       [])
     saved_LIBS="$LIBS"
     for lib in iconv ; do
       if test "x$ICONV_LINKED" = "x0" ; then
	 LIBS=-l$lib
         AC_TRY_LINK([#include <stdlib.h>
#include <iconv.h>],
         [iconv_t cd = iconv_open("","");
          iconv(cd,NULL,NULL,NULL,NULL);
          iconv_close(cd);],
         [LIBICONV="$LIBS" ; ICONV_LINKED=1],
         [])
       fi
     done
     LIBS="$saved_LIBS"
     
     if test "x$ICONV_LINKED" = "x1" ; then
       AC_MSG_RESULT([found])
     else
       AC_MSG_RESULT([not found])
     fi
   else
     AC_MSG_RESULT([failed])
   fi

   if test "x$ICONV_LINKED" = "x1" ; then
     AC_DEFINE(HAVE_ICONV, 1, [Define if you have the iconv() function.])
   fi
   
   ICONV_PROTO_CONST=0
   if test "x$ICONV_PROTO" = "xconst" ; then
     AC_DEFINE_UNQUOTED(HAVE_ICONV_PROTO_CONST, 1,
       [prototype of iconv() has const parameters])
   fi
fi
AC_SUBST(LIBICONV)

dnl Berkeley DB

DBVERS=0
DBLINKED=0
DBLIB=""

AC_ARG_ENABLE(db,   [  --disable-db            disable Berkeley DB (default=try to detect DB)],[enable_db=$enableval],[enable_db=yes])

dnl Check for a presence of Berkeley DB header
if test "x$enable_db" != "xyes"; then
   AC_MSG_WARN(cache support disabled)
else
   AC_CHECK_HEADER(db.h, [DB_HEADER=1], [DB_HEADER=0])
fi

if test "x$DB_HEADER" = "x1"; then
dnl Check for version of Berkeley DB
  AC_MSG_CHECKING([version of Berkeley DB])

dnl check for version 3 and above
  AC_TRY_COMPILE(
    [#include <db.h>],
    [#if DB_VERSION_MAJOR < 3
    #error DB version 3 or above needed
    #endif],
    [DBVERS=3]
    [])

dnl check for version 2
  if test "x$DBVERS" = "x0"; then
     AC_TRY_COMPILE([#include <db.h>],
       [#if DB_VERSION_MAJOR != 2
       #error DB version 2 needed
       #endif],
       [DBVERS=2]
       [])
  fi

  if test "x$DBVERS" = "x0"; then
dnl assume version 1
    DBVERS=1
  fi

dnl test linkage with Berkeley DB

dnl Look for db3 or superior with db_create call
  case "$DBVERS" in
    3)
    AC_MSG_RESULT([version 3.x or above])
    for lib in db-4.7 db-4.6 db-4.5 db-4.4 db-4.3 db-4.2 db-4.1 db-4.0 db-4 db4 db-3.2 db-3 db3 db; do
      if test "x$DBLINKED" = "x0"; then
dnl        AC_CHECK_LIB($lib, db_create, [DBLIB="-l$lib"; DBLINKED=1], [])
dnl installations of libdb4 function names are defined in db.h
dnl to other symbols
        AC_MSG_CHECKING([for db_create() in -l$lib])
	LIBS=-l$lib
	AC_TRY_LINK(
	   [#include <db.h>],
	   [db_create(0,0,0)],
	   [DBLIB="-l$lib"; DBLINKED=1; AC_MSG_RESULT([found])],
	   [AC_MSG_RESULT([not found])])
      fi
    done
    LIBS=""
    ;;

dnl Look for db2 with db_open call
    2)
    AC_MSG_RESULT([version 2.x])
    for lib in db2 db; do
      if test "x$DBLINKED" = "x0"; then 
        AC_CHECK_LIB($lib, db_open, [DBLIB="-l$lib"; DBLINKED=1], [])
      fi
    done
    ;;

    *)
dnl Look for db1 with dbopen call in -ldb or in libc (bsds)
    AC_MSG_RESULT([version 1.x])
    AC_CHECK_FUNC(dbopen, [DBLINKED=1], [])
    for lib in db-1 db1 db; do
      if test "x$DBLINKED" = "x0"; then
        AC_CHECK_LIB($lib, dbopen, [DBLIB="-l$lib"; DBLINKED=1], [])
      fi
    done
    ;;
dnl fi
  esac
fi

if test "x$DBLINKED" = "x0"; then
  DBVERS=0
  if test "x$enable_db" = "xyes"; then
    AC_MSG_WARN(cache support disabled (Berkeley DB is missing).)
  fi
fi

AC_DEFINE_UNQUOTED(DBVERS, $DBVERS,
  [Define to detected Berkeley DB major version number])
AC_SUBST(DBLIB)

dnl Threading support, if enabled
AC_ARG_ENABLE(threads,  [  --disable-threads        do not include multithreading support using pthread],,[enable_threads=yes])

if test "x$enable_threads" = "xyes"; then
  dnl Try to find a good CFLAGS/LDFLAGS for pthreads
  AC_CHECK_HEADERS(pthread.h, [], [AC_MSG_ERROR([pthread support required])])
  CPPFLAGS="$CPPFLAGS -D_REENTRANT"
  checkpthread=yes

  AC_MSG_CHECKING([for pthread_create with libc])
  AC_TRY_LINK([], [pthread_create();], 
                  [pthflag=yes; checkpthread=no], 
                  [pthflag=no])
  AC_MSG_RESULT($pthflag)

  for flag in "pthreads" "pthread"; do
    if test "x$checkpthread" = "xyes"; then
      AC_MSG_CHECKING([for pthread_create with -$flag])
      OLDFLAGS="$LDFLAGS"
      LDFLAGS="-$flag $LDFLAGS"
      AC_TRY_LINK([], [pthread_create();], 
                      [pthflag=yes; checkpthread=no], 
                      [pthflag=no; LDFLAGS="$OLDFLAGS"])
      AC_MSG_RESULT($pthflag)
    fi
  done

  # pthreadGC2 is provided by pthreads-w32 on mingw32 platforms.
  for lib in "c_r" "pthread" "pthreadGC2" ; do
    if test "x$checkpthread" = "xyes"; then
       case "x$LIBS" in
          *-l$lib*);;
          *) AC_CHECK_LIB($lib, pthread_create, [LIBS="$LIBS -l$lib"; checkpthread=no]) ;;
       esac
    fi
  done

  if test "x$checkpthread" = "xyes"; then
    AC_CHECK_FUNC(pthread_create, checkpthread=no)
    text "x$checkpthread" = "xyes" && AC_MSG_ERROR([pthread library required])
  fi
  AC_DEFINE([LIBETPAN_REENTRANT], 1, [Define to include multithreading support])
  LIBSUFFIX=
  REENTRANT=1
else
  REENTRANT=0
  LIBSUFFIX=-no-mt
fi
AC_SUBST(LIBSUFFIX)
AC_SUBST(REENTRANT)

dnl liblockfile on debian systems
AC_ARG_ENABLE(lockfile,  [  --disable-lockfile      do not use liblockfile for locking mailboxes])
if test "x$enable_lockfile" != "xno"; then
  AC_CHECK_LIB(lockfile, lockfile_create,, [
    if test "x$enable_lockfile" = "xyes"; then
      AC_MSG_ERROR([liblockfile not found])
    fi ])
fi

AC_DEFINE_UNQUOTED(LIBETPAN_VERSION_MAJOR, $VERSION_MAJOR,
  [Define this to the major version of libEtPan])
AC_DEFINE_UNQUOTED(LIBETPAN_VERSION_MINOR, $VERSION_MINOR,
  [Define this to the minor version of libEtPan])
AC_SUBST(VERSION_MAJOR)
AC_SUBST(VERSION_MINOR)

dnl Cyrus SASL
AC_ARG_WITH(sasl,   [  --with-sasl[=DIR]    include SASL support (default=auto)],
            [], [with_sasl=yes])
if test "x$with_sasl" != "xno"; then
  OCPPFLAGS="$CPPFLAGS"
  OLDFLAGS="$LDFLAGS"
  if test "x$with_sasl" != "xyes" ; then
    CPPFLAGS="$CPPFLAGS -I$with_sasl/include"
    LDFLAGS="$LDFLAGS -L$with_sasl/lib"
  fi
  with_sasl=no
  SASLLIBS=""
  AC_CHECK_HEADER(sasl/sasl.h, [
   AC_CHECK_LIB(sasl2, sasl_client_init, with_sasl=yes, [], [$SASLLIBS])])
  if test "x$with_sasl" != "xyes"; then
    CPPFLAGS="$OCPPFLAGS"
    LDFLAGS="$OLDFLAGS"
  fi
fi
if test "x$with_sasl" = "xyes"; then
  AC_DEFINE([USE_SASL], 1, [Define to use SASL])
  SASLLIBS="-lsasl2 $SASLLIBS"
else
  AC_MSG_WARN([SASL support disabled.])
  SASLLIBS=""
fi
AC_SUBST(SASLLIBS)

dnl IPv6 support
enable_ipv6=maybe
AC_ARG_ENABLE(ipv6, AC_HELP_STRING([--enable-ipv6], [enable IPv6 support]), enable_ipv6=$enableval)
AC_MSG_CHECKING([whether to use IPv6])
AC_MSG_RESULT($enable_ipv6)
if test "x$enable_ipv6" != "xno"; then
  dnl check for IPv6 support
  AC_MSG_CHECKING([for IPv6 support])
  AC_TRY_COMPILE([#define INET6
            #include <sys/types.h>
            #include <netinet/in.h>],
         [int x = IPPROTO_IPV6; struct in6_addr a;],
         ipv6_support=yes, ipv6_support=no)
  AC_MSG_RESULT($ipv6_support)

  if test "x$ipv6_support" = "xno"; then
    if test "x$enable_ipv6" = "xyes"; then
      AC_MSG_ERROR([cannot enable IPv6 support]) 
    fi
  else
    AC_DEFINE(HAVE_IPV6, 1, [Define to enable IPv6 support.])

    dnl check for getaddrinfo and freeaddrinfo function presence
    for func in "getaddrinfo" "freeaddrinfo"; do
      AC_MSG_CHECKING([for $func])
      AC_TRY_LINK([], [$func();], 
                      [func_present=yes], 
                      [func_present=no])
      AC_MSG_RESULT($func_present)

      if test "x$func_present" = "xno"; then
        AC_MSG_ERROR([$func function required for IPv6 support])
      fi
    done
  fi
fi

dnl libcurl
libcurl=no
AC_PATH_PROG(libcurlconfig, [curl-config])
if test "x$libcurlconfig" != "x"; then
  CPPFLAGS="$CPPFLAGS `$libcurlconfig --cflags 2>/dev/null`"
  AC_CHECK_HEADER(curl/curl.h, [libcurl=yes])
  if test "x$libcurl" = "xyes"; then
    AC_MSG_CHECKING([whether curl-config hints compiles and links fine])
    OLDFLAGS="$LDFLAGS"
    LDFLAGS="$LDFLAGS `$libcurlconfig --libs 2>/dev/null`"
    AC_TRY_LINK([], [curl_easy_init();], [libcurl=yes], [libcurl=no])
    AC_MSG_RESULT([$libcurl])
    if test "x$libcurl" = "xno"; then
      LDFLAGS="$OLDFLAGS"
    fi
  fi

  libcurl_major_version=`$libcurlconfig --version | \
    sed 's/^.* \([[0-9]]*\)\.\([[0-9]]*\).*$/\1/'`
  libcurl_minor_version=`$libcurlconfig --version | \
    sed 's/^.* \([[0-9]]*\)\.\([[0-9]]*\).*$/\2/'`
  if test "$libcurl_major_version" -lt "$libcurl_major_required" ; then
    libcurl=no
  fi
  if test "$libcurl_major_version" -eq "$libcurl_major_required" ; then
    if test "$libcurl_minor_version" -lt "$libcurl_minor_required" ; then
      libcurl=no
    fi
  fi
fi

if test "x$libcurl" = "xyes" ; then
  AC_DEFINE([HAVE_CURL], 1, [Define to use curl])
fi

dnl expat
libexpat=no
AC_CHECK_HEADER(expat.h, [libexpat=yes])
if test "x$libexpat" = "xyes"; then
  AC_MSG_CHECKING([whether libexpat compiles and links fine])
  OLDFLAGS="$LDFLAGS"
  LDFLAGS="$LDFLAGS -lexpat"
  AC_TRY_LINK([], [XML_SetElementHandler();], [libexpat=yes], [libexpat=no])
  AC_MSG_RESULT([$libexpat])
  if test "x$libexpat" = "xno"; then
    LDFLAGS="$OLDFLAGS"
  fi
fi

if test "x$libexpat" = "xyes" ; then
  AC_DEFINE([HAVE_EXPAT], 1, [Define to use expat])
fi

dnl Version
VERSION="$VERSION_MAJOR.$VERSION_MINOR"
test -d CVS && VERSION="$VERSION-dev-"`date +'%Y%m%d'`
AC_DEFINE_UNQUOTED(LIBETPAN_VERSION, "$VERSION",
  [Define this to the version of libEtPan])
AC_SUBST(VERSION)

# Further checks.

AC_CONFIG_FILES(libetpan-config
		Makefile
		build-windows/Makefile
                include/Makefile
                src/Makefile
		src/bsd/Makefile
		src/windows/Makefile
		src/data-types/Makefile
		src/low-level/Makefile
		src/low-level/feed/Makefile
		src/low-level/imap/Makefile
		src/low-level/imf/Makefile
		src/low-level/maildir/Makefile
		src/low-level/mbox/Makefile
		src/low-level/mh/Makefile
		src/low-level/mime/Makefile
		src/low-level/nntp/Makefile
		src/low-level/pop3/Makefile
		src/low-level/smtp/Makefile
		src/driver/Makefile
		src/driver/implementation/Makefile
		src/driver/implementation/data-message/Makefile
		src/driver/implementation/db/Makefile
		src/driver/implementation/feed/Makefile
		src/driver/implementation/hotmail/Makefile
		src/driver/implementation/imap/Makefile
		src/driver/implementation/maildir/Makefile
		src/driver/implementation/mbox/Makefile
		src/driver/implementation/mh/Makefile
		src/driver/implementation/mime-message/Makefile
		src/driver/implementation/nntp/Makefile
		src/driver/implementation/pop3/Makefile
		src/driver/interface/Makefile
		src/driver/tools/Makefile
		src/main/Makefile
		src/main/libetpan_version.h
		src/engine/Makefile
		src/versioninfo.rc
		doc/Makefile
		tests/Makefile)

# We collect all files which could potentially install public header
# files via HEADERS.  Updating any of these files will trigger
# rebuilding the header link farm.  See rules.mk for what we do with
# this information.  Because pmake does not support $(addprefix
# $(top_builddir), $(cfg_files), we need to calculate absolute path
# names here for automatic dependency tracking to work properly.
cfg_files=
crd="`pwd`"
for cfg_file in ${ac_config_files}; do
  cfg_files="${cfg_files} ${crd}/${cfg_file}"
done
AC_SUBST(cfg_files)

AC_OUTPUT

cp -f ${crd}/src/main/libetpan_version.h ${crd}/build-windows
