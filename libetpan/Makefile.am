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

ACLOCAL_AMFLAGS = -I m4

EXTRA_DIST = libetpan-config.in libetpan-config.h.in COPYRIGHT

bin_SCRIPTS = libetpan-config

# The file stamp-prepare is generated in the top build directory by
# rules defined in rules.mk.
CLEANFILES = stamp-prepare libetpan-config.h 

DISTCLEANFILES = libetpan-config

SUBDIRS = build-windows include src tests doc

BUILT_SOURCES += libetpan-config.h

etpaninclude_HEADERS = libetpan-config.h

# We need to build the header file before the link farm for VPATH
# builds.
$(top_builddir)/stamp-prepare: libetpan-config.h

libetpan-config.h: libetpan-config.h.in config.h
	cat $(srcdir)/libetpan-config.h.in | $(CPP) -I$(top_builddir) - \
	| sed -e '/^#/d;/^[ \t]*$$/d;s/^@/#/' > $@
