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

etpaninclude_HEADERS = \
	mmapstring.h mailstream.h mailstream_helper.h mail.h \
        mailstream_low.h \
        mailstream_socket.h mailstream_ssl.h \
	mailstream_types.h \
	carray.h clist.h chash.h \
	charconv.h mailsem.h maillock.h

AM_CPPFLAGS = -I$(top_builddir)/include

noinst_LTLIBRARIES = libdata-types.la

libdata_types_la_SOURCES = connect.h connect.c base64.h hmac-md5.h	\
	md5global.h md5.h md5.c mmapstring.c mailstream_helper.c	\
	mailstream_low.c mailstream.c mailstream_socket.c		\
	mailstream_ssl.c carray.c clist.c chash.c		        \
	charconv.c maillock.c base64.c mail_cache_db_types.h		\
	mail_cache_db.h mail_cache_db.c mailsem.c mailsasl.h		\
	mailsasl.c mailstream_cancel_types.h mailstream_cancel.h	\
	mailstream_cancel.c timeutils.h timeutils.c
