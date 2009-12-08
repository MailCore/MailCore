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
	maildriver.h maildriver_types.h maildriver_types_helper.h \
	maildriver_errors.h \
	mailmessage.h mailmessage_types.h \
	mailstorage.h \
	mailstorage_types.h \
	mailfolder.h

AM_CPPFLAGS = -I$(top_builddir)/include \
	-I$(top_srcdir)/src/low-level/imf \
	-I$(top_srcdir)/src/low-level/mime \
	-I$(top_srcdir)/src/data-types \
	-I$(top_srcdir)/src/interface/tools

noinst_LTLIBRARIES = libinterface.la

libinterface_la_SOURCES = \
	maildriver.c maildriver_types.c \
	maildriver_tools.h maildriver_tools.c \
	mailmessage.c \
	mailmessage_tools.h mailmessage_tools.c \
	mailmessage_types.c \
	maildriver_types_helper.c \
	mailstorage.c \
	mailstorage_tools.h mailstorage_tools.c \
	mailfolder.c
