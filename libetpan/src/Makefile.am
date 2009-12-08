# libEtPan! -- a mail stuff library
#
# Copyright (C) 2007 g10 Code GmbH
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the libEtPan! project nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

include $(top_srcdir)/rules.mk

EXTRA_DIST = versioninfo.rc.in

if HAVE_MINGW32_SYSTEM

LTRCCOMPILE = $(LIBTOOL) --mode=compile $(RC) \
     `echo $(DEFS) $(DEFAULT_INCLUDES) $(INCLUDES) | \
     sed -e 's/-I/--include-dir /g;s/-D/--define /g'`

SUFFIXES: .rc .lo

.rc.lo:
	$(LTRCCOMPILE) -i $< -o $@

libetpan_res = versioninfo.lo
no_undefined = -no-undefined

libetpan_deps = $(libetpan_res)

else

libetpan_res =
libetpan_res_ldflag =
no_undefined =

libetpan_deps =
endif


if HAVE_MINGW32_SYSTEM
  arch_sources = dummy.cpp
  arch_dir = windows
  arch_lib = windows/libarch.la
else
  arch_sources =
  arch_dir =
  arch_lib =
endif

SUBDIRS = bsd $(arch_dir) data-types low-level driver main engine


lib_LTLIBRARIES = libetpan@LIBSUFFIX@.la
libetpan@LIBSUFFIX@_la_LDFLAGS = $(no_undefined) -version-info @API_VERSION@
libetpan@LIBSUFFIX@_la_SOURCES = $(arch_sources)
libetpan@LIBSUFFIX@_la_LIBADD = \
	$(libetpan_res) \
	data-types/libdata-types.la \
	low-level/liblow-level.la \
	driver/libdriver.la \
	main/libmain.la \
	engine/libengine.la \
        $(arch_lib) \
	@LIBS@ @SSLLIBS@ @LIBICONV@ @DBLIB@ @GNUTLSLIB@ @SASLLIBS@

