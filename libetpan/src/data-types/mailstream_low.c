/*
 * libEtPan! -- a mail stuff library
 *
 * Copyright (C) 2001, 2005 - DINH Viet Hoa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the libEtPan! project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * $Id: mailstream_low.c,v 1.27 2011/05/04 16:09:54 hoa Exp $
 */

#ifdef HAVE_CONFIG_H
#	include <config.h>
#endif

#include "mailstream_low.h"
#include <stdlib.h>

#ifdef LIBETPAN_MAILSTREAM_DEBUG

#define STREAM_DEBUG

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#ifdef HAVE_UNISTD_H
#	include <unistd.h>
#endif
#include "maillock.h"
#ifdef WIN32
#	include "win_etpan.h"
#endif

#define LOG_FILE "libetpan-stream-debug.log"

LIBETPAN_EXPORT
int mailstream_debug = 0;

LIBETPAN_EXPORT
void (* mailstream_logger)(int direction,
    const char * str, size_t size) = NULL;
LIBETPAN_EXPORT
void (* mailstream_logger_id)(mailstream_low * s, int is_stream_data, int direction,
    const char * str, size_t size) = NULL;

#define STREAM_LOG_ERROR(low, direction, buf, size) \
  if (mailstream_debug) { \
	if (mailstream_logger_id != NULL) { \
	  mailstream_logger_id(low, 2, direction, buf, size); \
	} \
    else if (mailstream_logger != NULL) { \
      mailstream_logger(direction, buf, size); \
    } \
    else { \
      FILE * f; \
      mode_t old_mask; \
      \
      old_mask = umask(0077); \
      f = fopen(LOG_FILE, "a"); \
      umask(old_mask); \
      if (f != NULL) { \
        int nmemb; \
        maillock_write_lock(LOG_FILE, fileno(f)); \
        nmemb = fwrite((buf), 1, (size), f); \
        maillock_write_unlock(LOG_FILE, fileno(f)); \
        fclose(f); \
      } \
    } \
  }

#define STREAM_LOG_BUF(low, direction, buf, size) \
  if (mailstream_debug) { \
	if (mailstream_logger_id != NULL) { \
	  mailstream_logger_id(low, 1, direction, buf, size); \
	} \
    else if (mailstream_logger != NULL) { \
      mailstream_logger(direction, buf, size); \
    } \
    else { \
      FILE * f; \
      mode_t old_mask; \
      \
      old_mask = umask(0077); \
      f = fopen(LOG_FILE, "a"); \
      umask(old_mask); \
      if (f != NULL) { \
        int nmemb; \
        maillock_write_lock(LOG_FILE, fileno(f)); \
        nmemb = fwrite((buf), 1, (size), f); \
        maillock_write_unlock(LOG_FILE, fileno(f)); \
        fclose(f); \
      } \
    } \
  }

#define STREAM_LOG(low, direction, str) \
  if (mailstream_debug) { \
	if (mailstream_logger_id != NULL) { \
	  mailstream_logger_id(low, 0, direction, str, strlen(str)); \
	} \
    else if (mailstream_logger != NULL) { \
      mailstream_logger(direction, str, strlen(str)); \
    } \
    else { \
      FILE * f; \
      mode_t old_mask; \
      \
      old_mask = umask(0077); \
      f = fopen(LOG_FILE, "a"); \
      umask(old_mask); \
      if (f != NULL) { \
        int nmemb; \
        maillock_write_lock(LOG_FILE, fileno(f)); \
        nmemb = fputs((str), f); \
        maillock_write_unlock(LOG_FILE, fileno(f)); \
        fclose(f); \
      } \
    } \
  }

#else

#define STREAM_LOG_BUF(low, direction, buf, size) do { } while (0)
#define STREAM_LOG(low, direction, buf) do { } while (0)

#endif


/* general functions */

mailstream_low * mailstream_low_new(void * data,
				    mailstream_low_driver * driver)
{
  mailstream_low * s;

  s = malloc(sizeof(* s));
  if (s == NULL)
    return NULL;

  s->data = data;
  s->driver = driver;
  s->privacy = 1;
	s->identifier = NULL;
  
  return s;
}

int mailstream_low_close(mailstream_low * s)
{
  if (s == NULL)
    return -1;
  s->driver->mailstream_close(s);

  return 0;
}

int mailstream_low_get_fd(mailstream_low * s)
{
  if (s == NULL)
    return -1;
  return s->driver->mailstream_get_fd(s);
}

void mailstream_low_free(mailstream_low * s)
{
	free(s->identifier);
	s->identifier = NULL;
  s->driver->mailstream_free(s);
}

ssize_t mailstream_low_read(mailstream_low * s, void * buf, size_t count)
{
  ssize_t r;
  
  if (s == NULL)
    return -1;
  r = s->driver->mailstream_read(s, buf, count);
  
#ifdef STREAM_DEBUG
  if (r > 0) {
    STREAM_LOG(s, 0, "<<<<<<< read <<<<<<\n");
    STREAM_LOG_BUF(s, 0, buf, r);
    STREAM_LOG(s, 0, "\n");
    STREAM_LOG(s, 0, "<<<<<<< end read <<<<<<\n");
  }
#endif
  
  return r;
}

ssize_t mailstream_low_write(mailstream_low * s,
    const void * buf, size_t count)
{
  if (s == NULL)
    return -1;

#ifdef STREAM_DEBUG
  STREAM_LOG(s, 1, ">>>>>>> send >>>>>>\n");
  if (s->privacy) {
    STREAM_LOG_BUF(s, 1, buf, count);
  }
  else {
    STREAM_LOG_BUF(s, 2, buf, count);
  }
  STREAM_LOG(s, 1, "\n");
  STREAM_LOG(s, 1, ">>>>>>> end send >>>>>>\n");
#endif

  return s->driver->mailstream_write(s, buf, count);
}

void mailstream_low_cancel(mailstream_low * s)
{
  if (s == NULL)
    return;
  
  if (s->driver->mailstream_cancel == NULL)
    return;
  
  s->driver->mailstream_cancel(s);
}

void mailstream_low_log_error(mailstream_low * s,
    const void * buf, size_t count)
{
	STREAM_LOG_ERROR(s, 0, buf, count);
}

void mailstream_low_set_privacy(mailstream_low * s, int can_be_public)
{
  s->privacy = can_be_public;
}

int mailstream_low_set_identifier(mailstream_low * s,
    char * identifier)
{
	free(s->identifier);
	s->identifier = NULL;
	
	if (identifier != NULL) {
		s->identifier = identifier;
  }

	return 0;
}

const char * mailstream_low_get_identifier(mailstream_low * s)
{
	return s->identifier;
}
