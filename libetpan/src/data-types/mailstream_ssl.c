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
 * $Id: mailstream_ssl.c,v 1.75 2011/04/15 09:21:49 hoa Exp $
 */

/*
  NOTE :

  The user has to call himself SSL_library_init() if he wants to
  use SSL.
*/

#ifdef HAVE_CONFIG_H
#	include <config.h>
#endif

#include "mailstream_ssl.h"
#include "mailstream_ssl_private.h"

#ifdef HAVE_UNISTD_H
#	include <unistd.h>
#endif
#ifdef HAVE_STDLIB_H
#	include <stdlib.h>
#endif
#ifdef HAVE_STRING_H
#	include <string.h>
#endif
#include <fcntl.h>

/*
  these 3 headers MUST be included before <sys/select.h>
  to insure compatibility with Mac OS X (this is true for 10.2)
*/
#ifdef WIN32
#	include <win_etpan.h>
#else
#	include <sys/time.h>
#	include <sys/types.h>
#	ifdef HAVE_SYS_SELECT_H
#		include <sys/select.h>
#	endif
#endif

/* mailstream_low, ssl */

#ifdef USE_SSL
# ifndef USE_GNUTLS
#  include <openssl/ssl.h>
# else
#  include <errno.h>
#  include <gnutls/gnutls.h>
#  include <gnutls/x509.h>
# endif
# ifdef LIBETPAN_REENTRANT
#	if HAVE_PTHREAD_H
#	  include <pthread.h>
#	endif
# endif
#endif

#include "mailstream_cancel.h"

struct mailstream_ssl_context
{
  int fd;
#ifdef USE_SSL
#ifndef USE_GNUTLS
  SSL_CTX * openssl_ssl_ctx;
  X509* client_x509;
  EVP_PKEY *client_pkey;
#else
  gnutls_session session;
  gnutls_x509_crt client_x509;
  gnutls_x509_privkey client_pkey;
  gnutls_certificate_credentials_t gnutls_credentials;
#endif
#endif
};

#ifdef USE_SSL
#ifndef USE_GNUTLS
struct mailstream_ssl_data {
  int fd;
  SSL * ssl_conn;
  SSL_CTX * ssl_ctx;
  struct mailstream_cancel * cancel;
};

#else
struct mailstream_ssl_data {
  int fd;
  gnutls_session session;
  gnutls_certificate_credentials_t xcred;
  struct mailstream_cancel * cancel;
};
#endif
#endif

#ifdef USE_SSL
#ifdef LIBETPAN_REENTRANT
#	if HAVE_PTHREAD_H
#		define MUTEX_LOCK(x) pthread_mutex_lock(x)
#		define MUTEX_UNLOCK(x) pthread_mutex_unlock(x)
		static pthread_mutex_t ssl_lock = PTHREAD_MUTEX_INITIALIZER;
#	elif (defined WIN32)
#		define MUTEX_LOCK(x) EnterCriticalSection(x);
#		define MUTEX_UNLOCK(x) LeaveCriticalSection(x);
		static CRITICAL_SECTION ssl_lock;
#	else
#		error "What are your threads?"
#	endif
#else
#	define MUTEX_LOCK(x)
#	define MUTEX_UNLOCK(x)
#endif
static int gnutls_init_done = 0;
static int openssl_init_done = 0;
#endif

void mailstream_ssl_init_lock(void)
{
#if !defined (HAVE_PTHREAD_H) && defined (WIN32) && defined (USE_SSL)
  InitializeCriticalSection(&ssl_lock);
#endif
}

void mailstream_gnutls_init_not_required(void)
{
#ifdef USE_SSL
  MUTEX_LOCK(&ssl_lock);
  gnutls_init_done = 1;
  MUTEX_UNLOCK(&ssl_lock);
#endif
}

void mailstream_openssl_init_not_required(void)
{
#ifdef USE_SSL
  MUTEX_LOCK(&ssl_lock);
  openssl_init_done = 1;
  MUTEX_UNLOCK(&ssl_lock);
#endif
}

void mailstream_ssl_init_not_required(void)
{
  mailstream_gnutls_init_not_required();
  mailstream_openssl_init_not_required();
}

static inline void mailstream_ssl_init(void)
{
#ifdef USE_SSL
  MUTEX_LOCK(&ssl_lock);
#ifndef USE_GNUTLS
  if (!openssl_init_done) {
    SSL_library_init();
    OpenSSL_add_all_digests();
    OpenSSL_add_all_algorithms();
    OpenSSL_add_all_ciphers();
    openssl_init_done = 1;
  }
#else
  if (!gnutls_init_done) {
    gnutls_global_init();
    gnutls_init_done = 1;
  }
#endif
  MUTEX_UNLOCK(&ssl_lock);
#endif
}

#ifdef USE_SSL
static inline int mailstream_prepare_fd(int fd)
{
#ifndef WIN32
  int fd_flags;
  int r;
  
  fd_flags = fcntl(fd, F_GETFL, 0);
  fd_flags |= O_NDELAY;
  r = fcntl(fd, F_SETFL, fd_flags);
  if (r < 0)
    return -1;
#endif
  
  return 0;
}
#endif

static int wait_SSL_connect(int s, int want_read)
{
  fd_set fds;
  struct timeval timeout;
  int r;
  
  FD_ZERO(&fds);
  FD_SET(s, &fds);
  timeout = mailstream_network_delay;
  /* TODO: how to cancel this ? */
  if (want_read)
    r = select(s + 1, &fds, NULL, NULL, &timeout);
  else
    r = select(s + 1, NULL, &fds, NULL, &timeout);
  if (r <= 0) {
    return -1;
  }
  
  if (!FD_ISSET(s, &fds)) {
    /* though, it's strange */
    return -1;
  }
  
  return 0;
}

#ifdef USE_SSL
static int mailstream_low_ssl_close(mailstream_low * s);
static ssize_t mailstream_low_ssl_read(mailstream_low * s,
				       void * buf, size_t count);
static ssize_t mailstream_low_ssl_write(mailstream_low * s,
					const void * buf, size_t count);
static void mailstream_low_ssl_free(mailstream_low * s);
static int mailstream_low_ssl_get_fd(mailstream_low * s);
static void mailstream_low_ssl_cancel(mailstream_low * s);

static mailstream_low_driver local_mailstream_ssl_driver = {
  /* mailstream_read */ mailstream_low_ssl_read,
  /* mailstream_write */ mailstream_low_ssl_write,
  /* mailstream_close */ mailstream_low_ssl_close,
  /* mailstream_get_fd */ mailstream_low_ssl_get_fd,
  /* mailstream_free */ mailstream_low_ssl_free,
  /* mailstream_cancel */ mailstream_low_ssl_cancel,
};

mailstream_low_driver * mailstream_ssl_driver = &local_mailstream_ssl_driver;
#endif

/* file descriptor must be given in (default) blocking-mode */

#ifdef USE_SSL
#ifndef USE_GNUTLS

static struct mailstream_ssl_context * mailstream_ssl_context_new(SSL_CTX * open_ssl_ctx, int fd);
static void mailstream_ssl_context_free(struct mailstream_ssl_context * ssl_ctx);

static int mailstream_openssl_client_cert_cb(SSL *ssl, X509 **x509, EVP_PKEY **pkey)
{
	struct mailstream_ssl_context * ssl_context = (struct mailstream_ssl_context *)SSL_CTX_get_app_data(ssl->ctx);
	
	if (x509 == NULL || pkey == NULL) {
		return 0;
	}

	if (ssl_context == NULL)
		return 0;

	*x509 = ssl_context->client_x509;
	*pkey = ssl_context->client_pkey;

	if (*x509 && *pkey)
		return 1;
	else
		return 0;
}

static struct mailstream_ssl_data * ssl_data_new_full(int fd, SSL_METHOD * method, void (* callback)(struct mailstream_ssl_context * ssl_context, void * cb_data), void * cb_data)
{
  struct mailstream_ssl_data * ssl_data;
  SSL * ssl_conn;
  int r;
  SSL_CTX * tmp_ctx;
  struct mailstream_cancel * cancel;
  struct mailstream_ssl_context * ssl_context = NULL;
  
  mailstream_ssl_init();
  
  tmp_ctx = SSL_CTX_new(method);
  if (tmp_ctx == NULL)
    goto err;
  
  if (callback != NULL) {
    ssl_context = mailstream_ssl_context_new(tmp_ctx, fd);
    callback(ssl_context, cb_data);
  }
  
  SSL_CTX_set_app_data(tmp_ctx, ssl_context);
  SSL_CTX_set_client_cert_cb(tmp_ctx, mailstream_openssl_client_cert_cb);
  ssl_conn = (SSL *) SSL_new(tmp_ctx);
  if (ssl_conn == NULL)
    goto free_ctx;
  
  if (SSL_set_fd(ssl_conn, fd) == 0)
    goto free_ssl_conn;
  
again:
  r = SSL_connect(ssl_conn);

  switch(SSL_get_error(ssl_conn, r)) {
  	case SSL_ERROR_WANT_READ:
          r = wait_SSL_connect(fd, 1);
          if (r < 0)
            goto free_ssl_conn;
	  else
	    goto again;
	break;
	case SSL_ERROR_WANT_WRITE:
          r = wait_SSL_connect(fd, 0);
          if (r < 0)
            goto free_ssl_conn;
	  else
	    goto again;
	break;
  }
  if (r <= 0)
    goto free_ssl_conn;
  
  cancel = mailstream_cancel_new();
  if (cancel == NULL)
    goto free_ssl_conn;
  
  r = mailstream_prepare_fd(fd);
  if (r < 0)
    goto free_cancel;
  
  ssl_data = malloc(sizeof(* ssl_data));
  if (ssl_data == NULL)
    goto free_cancel;
  
  ssl_data->fd = fd;
  ssl_data->ssl_conn = ssl_conn;
  ssl_data->ssl_ctx = tmp_ctx;
  ssl_data->cancel = cancel;
  mailstream_ssl_context_free(ssl_context);

  return ssl_data;

 free_cancel:
  mailstream_cancel_free(cancel);
 free_ssl_conn:
  SSL_free(ssl_conn);
 free_ctx:
  SSL_CTX_free(tmp_ctx);
  mailstream_ssl_context_free(ssl_context);
 err:
  return NULL;
}

static struct mailstream_ssl_data * ssl_data_new(int fd, void (* callback)(struct mailstream_ssl_context * ssl_context, void * cb_data), void * cb_data)
{
  return ssl_data_new_full(fd, SSLv23_client_method(), callback, cb_data);
}

static struct mailstream_ssl_data * tls_data_new(int fd, void (* callback)(struct mailstream_ssl_context * ssl_context, void * cb_data), void * cb_data)
{
  return ssl_data_new_full(fd, TLSv1_client_method(), callback, cb_data);
}

#else

static struct mailstream_ssl_context * mailstream_ssl_context_new(gnutls_session session, int fd);
static void mailstream_ssl_context_free(struct mailstream_ssl_context * ssl_ctx);

static int mailstream_gnutls_client_cert_cb(gnutls_session session,
                               const gnutls_datum *req_ca_rdn, int nreqs,
                               const gnutls_pk_algorithm *sign_algos,
                               int sign_algos_length, gnutls_retr_st *st)
{
	struct mailstream_ssl_context * ssl_context = (struct mailstream_ssl_context *)gnutls_session_get_ptr(session);
	gnutls_certificate_type type = gnutls_certificate_type_get(session);

	st->ncerts = 0;

	if (ssl_context == NULL)
		return 0;

	if (type == GNUTLS_CRT_X509 && ssl_context->client_x509 && ssl_context->client_pkey) {
		st->ncerts = 1;
		st->type = type;
		st->cert.x509 = &(ssl_context->client_x509);
		st->key.x509 = ssl_context->client_pkey;
		st->deinit_all = 0;
	}
	return 0;
}

static struct mailstream_ssl_data * ssl_data_new(int fd, void (* callback)(struct mailstream_ssl_context * ssl_context, void * cb_data), void * cb_data)
{
  struct mailstream_ssl_data * ssl_data;
  gnutls_session session;
  struct mailstream_cancel * cancel;
  
  const int cipher_prio[] = { GNUTLS_CIPHER_AES_128_CBC,
		  		GNUTLS_CIPHER_3DES_CBC,
		  		GNUTLS_CIPHER_AES_256_CBC,
		  		GNUTLS_CIPHER_ARCFOUR_128, 0 };
  const int kx_prio[] = { GNUTLS_KX_DHE_RSA,
		  	   GNUTLS_KX_RSA, 
		  	   GNUTLS_KX_DHE_DSS, 0 };
  const int mac_prio[] = { GNUTLS_MAC_SHA1,
		  		GNUTLS_MAC_MD5, 0 };
  const int proto_prio[] = { GNUTLS_TLS1,
		  		  GNUTLS_SSL3, 0 };

  gnutls_certificate_credentials_t xcred;
  int r;
  struct mailstream_ssl_context * ssl_context = NULL;
  
  mailstream_ssl_init();
  
  if (gnutls_certificate_allocate_credentials (&xcred) != 0)
    return NULL;

  r = gnutls_init(&session, GNUTLS_CLIENT);
  if (session == NULL || r != 0)
    return NULL;
  
  if (callback != NULL) {
    ssl_context = mailstream_ssl_context_new(session, fd);
    callback(ssl_context, cb_data);
  }
  
  gnutls_session_set_ptr(session, ssl_context);
  gnutls_credentials_set(session, GNUTLS_CRD_CERTIFICATE, xcred);
  gnutls_certificate_client_set_retrieve_function(xcred, mailstream_gnutls_client_cert_cb);

  gnutls_set_default_priority(session);
  gnutls_protocol_set_priority (session, proto_prio);
  gnutls_cipher_set_priority (session, cipher_prio);
  gnutls_kx_set_priority (session, kx_prio);
  gnutls_mac_set_priority (session, mac_prio);
  gnutls_record_disable_padding(session);
  gnutls_dh_set_prime_bits(session, 512);

  gnutls_transport_set_ptr(session, (gnutls_transport_ptr) fd);

  /* lower limits on server key length restriction */
  gnutls_dh_set_prime_bits(session, 512);
  
  do {
    r = gnutls_handshake(session);
  } while (r == GNUTLS_E_AGAIN || r == GNUTLS_E_INTERRUPTED);

  if (r < 0) {
    gnutls_perror(r);
    goto free_ssl_conn;
  }
  
  cancel = mailstream_cancel_new();
  if (cancel == NULL)
    goto free_ssl_conn;
  
  r = mailstream_prepare_fd(fd);
  if (r < 0)
    goto free_cancel;
  
  ssl_data = malloc(sizeof(* ssl_data));
  if (ssl_data == NULL)
    goto err;
  
  ssl_data->fd = fd;
  ssl_data->session = session;
  ssl_data->xcred = xcred;
  ssl_data->cancel = cancel;
  
  mailstream_ssl_context_free(ssl_context);

  return ssl_data;
  
 free_cancel:
  mailstream_cancel_free(cancel);
 free_ssl_conn:
  gnutls_certificate_free_credentials(xcred);
  mailstream_ssl_context_free(ssl_context);
  gnutls_deinit(session);
 err:
  return NULL;
}
static struct mailstream_ssl_data * tls_data_new(int fd, void (* callback)(struct mailstream_ssl_context * ssl_context, void * cb_data), void * cb_data)
{
  return ssl_data_new(fd, callback, cb_data);
}
#endif

static void  ssl_data_free(struct mailstream_ssl_data * ssl_data)
{
  mailstream_cancel_free(ssl_data->cancel);
  free(ssl_data);
}

#ifndef USE_GNUTLS
static void  ssl_data_close(struct mailstream_ssl_data * ssl_data)
{
  SSL_free(ssl_data->ssl_conn);
  ssl_data->ssl_conn = NULL;
  SSL_CTX_free(ssl_data->ssl_ctx);
  ssl_data->ssl_ctx  = NULL;
#ifdef WIN32
  closesocket(ssl_data->fd);
#else
  close(ssl_data->fd);
#endif
  ssl_data->fd = -1;
}
#else
static void  ssl_data_close(struct mailstream_ssl_data * ssl_data)
{
  gnutls_certificate_free_credentials(ssl_data->xcred);
  gnutls_deinit(ssl_data->session);
  ssl_data->session = NULL;
#ifdef WIN32
  closesocket(socket_data->fd);
#else
  close(ssl_data->fd);
#endif
  ssl_data->fd = -1;
}
#endif

#endif

static mailstream_low * mailstream_low_ssl_open_full(int fd, int starttls, void (* callback)(struct mailstream_ssl_context * ssl_context, void * cb_data), void * cb_data)
{
#ifdef USE_SSL
  mailstream_low * s;
  struct mailstream_ssl_data * ssl_data;

  if (starttls)
    ssl_data = tls_data_new(fd, callback, cb_data);
  else
    ssl_data = ssl_data_new(fd, callback, cb_data);

  if (ssl_data == NULL)
    goto err;

  s = mailstream_low_new(ssl_data, mailstream_ssl_driver);
  if (s == NULL)
    goto free_ssl_data;

  return s;

 free_ssl_data:
  ssl_data_free(ssl_data);
 err:
  return NULL;
#else
  return NULL;
#endif
}

mailstream_low * mailstream_low_ssl_open(int fd)
{
  return mailstream_low_ssl_open_full(fd, 0, NULL, NULL);
}

mailstream_low * mailstream_low_tls_open(int fd)
{
  return mailstream_low_ssl_open_full(fd, 1, NULL, NULL);
}

#ifdef USE_SSL
static int mailstream_low_ssl_close(mailstream_low * s)
{
  struct mailstream_ssl_data * ssl_data;

  ssl_data = (struct mailstream_ssl_data *) s->data;
  ssl_data_close(ssl_data);

  return 0;
}

static void mailstream_low_ssl_free(mailstream_low * s)
{
  struct mailstream_ssl_data * ssl_data;

  ssl_data = (struct mailstream_ssl_data *) s->data;
  ssl_data_free(ssl_data);
  s->data = NULL;

  free(s);
}

static int mailstream_low_ssl_get_fd(mailstream_low * s)
{
  struct mailstream_ssl_data * ssl_data;

  ssl_data = (struct mailstream_ssl_data *) s->data;
  return ssl_data->fd;
}

static int wait_read(mailstream_low * s)
{
  fd_set fds_read;
  struct timeval timeout;
  int fd;
  struct mailstream_ssl_data * ssl_data;
  int max_fd;
  int r;
  int cancelled;
  int got_data;
#ifdef WIN32
  HANDLE event;
#endif
  
  ssl_data = (struct mailstream_ssl_data *) s->data;
  timeout = mailstream_network_delay;
  
  FD_ZERO(&fds_read);
  fd = mailstream_cancel_get_fd(ssl_data->cancel);
  FD_SET(fd, &fds_read);
#ifdef WIN32
  event = CreateEvent(NULL, TRUE, FALSE, NULL);
  WSAEventSelect(ssl_data->fd, event, FD_READ | FD_CLOSE);
  FD_SET(event, &fds_read);
  r = WaitForMultipleObjects(fds_read.fd_count, fds_read.fd_array, FALSE, timeout.tv_sec * 1000 + timeout.tv_usec / 1000);
  if (WAIT_TIMEOUT == r)
    return -1;
  
  cancelled = (fds_read.fd_array[r - WAIT_OBJECT_0] == fd);
  got_data = (fds_read.fd_array[r - WAIT_OBJECT_0] == event);
#else
  FD_SET(ssl_data->fd, &fds_read);
  max_fd = ssl_data->fd;
  if (fd > max_fd)
    max_fd = fd;
  r = select(max_fd + 1, &fds_read, NULL, NULL, &timeout);
  if (r <= 0)
    return -1;
  
  cancelled = (FD_ISSET(fd, &fds_read));
  got_data = FD_ISSET(ssl_data->fd, &fds_read);
#endif
  if (cancelled) {
    /* cancelled */
    mailstream_cancel_ack(ssl_data->cancel);
    return -1;
  }
  
  return 0;
}

#ifndef USE_GNUTLS
static ssize_t mailstream_low_ssl_read(mailstream_low * s,
				       void * buf, size_t count)
{
  struct mailstream_ssl_data * ssl_data;
  int r;

  ssl_data = (struct mailstream_ssl_data *) s->data;
  
  if (mailstream_cancel_cancelled(ssl_data->cancel))
    return -1;
  
  while (1) {
    int ssl_r;
    
    r = SSL_read(ssl_data->ssl_conn, buf, count);
    if (r > 0)
      return r;
    
    ssl_r = SSL_get_error(ssl_data->ssl_conn, r);
    switch (ssl_r) {
    case SSL_ERROR_NONE:
      return r;
      
    case SSL_ERROR_ZERO_RETURN:
      return r;
      
    case SSL_ERROR_WANT_READ:
      r = wait_read(s);
      if (r < 0)
        return r;
      break;
      
    default:
      return -1;
    }
  }
}
#else
static ssize_t mailstream_low_ssl_read(mailstream_low * s,
				       void * buf, size_t count)
{
  struct mailstream_ssl_data * ssl_data;
  int r;

  ssl_data = (struct mailstream_ssl_data *) s->data;
  if (mailstream_cancel_cancelled(ssl_data->cancel))
    return -1;
  
  while (1) {
    r = gnutls_record_recv(ssl_data->session, buf, count);
    if (r > 0)
      return r;
    
    switch (r) {
    case 0: /* closed connection */
      return -1;
    
    case GNUTLS_E_REHANDSHAKE:
      do {
         r = gnutls_handshake(ssl_data->session); 
      } while (r == GNUTLS_E_AGAIN || r == GNUTLS_E_INTERRUPTED);
      break; /* re-receive */
    case GNUTLS_E_AGAIN:
    case GNUTLS_E_INTERRUPTED:
      r = wait_read(s);
      if (r < 0)
        return r;
      break;
      
    default:
      return -1;
    }
  }
}
#endif

static int wait_write(mailstream_low * s)
{
  fd_set fds_read;
  fd_set fds_write;
  struct timeval timeout;
  int r;
  int fd;
  struct mailstream_ssl_data * ssl_data;
  int max_fd;
  int cancelled;
  int write_enabled;
#ifdef WIN32
  HANDLE event;
#endif
  
  ssl_data = (struct mailstream_ssl_data *) s->data;
  if (mailstream_cancel_cancelled(ssl_data->cancel))
    return -1;
  
  timeout = mailstream_network_delay;
  
  FD_ZERO(&fds_read);
  fd = mailstream_cancel_get_fd(ssl_data->cancel);
  FD_SET(fd, &fds_read);
  FD_ZERO(&fds_write);
#ifdef WIN32
  event = CreateEvent(NULL, TRUE, FALSE, NULL);
  WSAEventSelect(ssl_data->fd, event, FD_WRITE | FD_CLOSE);
  FD_SET(event, &fds_read);
  r = WaitForMultipleObjects(fds_read.fd_count, fds_read.fd_array, FALSE, timeout.tv_sec * 1000 + timeout.tv_usec / 1000);
  if (r < 0)
    return -1;
  
  cancelled = (fds_read.fd_array[r - WAIT_OBJECT_0] == fd) /* SEB 20070709 */;
  write_enabled = (fds_read.fd_array[r - WAIT_OBJECT_0] == event);
#else
  FD_SET(ssl_data->fd, &fds_write);
  
  max_fd = ssl_data->fd;
  if (fd > max_fd)
    max_fd = fd;
  
  r = select(max_fd + 1, &fds_read, &fds_write, NULL, &timeout);
  if (r <= 0)
    return -1;
  
  cancelled = FD_ISSET(fd, &fds_read);
  write_enabled = FD_ISSET(ssl_data->fd, &fds_write);
#endif
  
  if (cancelled) {
    /* cancelled */
    mailstream_cancel_ack(ssl_data->cancel);
    return -1;
  }
  
  if (!write_enabled)
    return 0;
  
  return 1;
}

#ifndef USE_GNUTLS
static ssize_t mailstream_low_ssl_write(mailstream_low * s,
					const void * buf, size_t count)
{
  struct mailstream_ssl_data * ssl_data;
  int ssl_r;
  int r;
  
  ssl_data = (struct mailstream_ssl_data *) s->data;
  r = wait_write(s);
  if (r <= 0)
    return r;
  
  r = SSL_write(ssl_data->ssl_conn, buf, count);
  if (r > 0)
    return r;
  
  ssl_r = SSL_get_error(ssl_data->ssl_conn, r);
  switch (ssl_r) {
  case SSL_ERROR_NONE:
    return r;
    
  case SSL_ERROR_ZERO_RETURN:
    return -1;
    
  case SSL_ERROR_WANT_WRITE:
    return 0;
    
  default:
    return r;
  }
}
#else
static ssize_t mailstream_low_ssl_write(mailstream_low * s,
					const void * buf, size_t count)
{
  struct mailstream_ssl_data * ssl_data;
  int r;
  
  ssl_data = (struct mailstream_ssl_data *) s->data;
  r = wait_write(s);
  if (r <= 0)
    return r;
  
  r = gnutls_record_send(ssl_data->session, buf, count);
  if (r > 0)
    return r;
  
  switch (r) {
  case 0:
    return -1;
    
  case GNUTLS_E_AGAIN:
  case GNUTLS_E_INTERRUPTED:
    return 0;
    
  default:
    return r;
  }
}
#endif
#endif

/* mailstream */

mailstream * mailstream_ssl_open(int fd)
{
  return mailstream_ssl_open_with_callback(fd, NULL, NULL);
}

mailstream * mailstream_ssl_open_with_callback(int fd,
    void (* callback)(struct mailstream_ssl_context * ssl_context, void * data), void * data)
{
#ifdef USE_SSL
  mailstream_low * low;
  mailstream * s;

  low = mailstream_low_ssl_open_with_callback(fd, callback, data);
  if (low == NULL)
    goto err;

  s = mailstream_new(low, 8192);
  if (s == NULL)
    goto free_low;

  return s;

 free_low:
  mailstream_low_close(low);
 err:
  return NULL;
#else
  return NULL;
#endif
}

ssize_t mailstream_ssl_get_certificate(mailstream *stream, unsigned char **cert_DER)
{
#ifdef USE_SSL
  struct mailstream_ssl_data *data = NULL;
  ssize_t len = 0;
#ifndef USE_GNUTLS
  SSL *ssl_conn = NULL;
  X509 *cert = NULL;
#else
  gnutls_session session = NULL;
  const gnutls_datum *raw_cert_list;
  unsigned int raw_cert_list_length;
  gnutls_x509_crt cert = NULL;
  char output[10*1024];
  size_t cert_size;
#endif

  if (cert_DER == NULL || stream == NULL || stream->low == NULL)
    return -1;

  data = stream->low->data;
  if (data == NULL)
    return -1;

#ifndef USE_GNUTLS
  ssl_conn = data->ssl_conn;
  if (ssl_conn == NULL)
    return -1;
  
  cert = SSL_get_peer_certificate(ssl_conn);
  if (cert == NULL)
    return -1;
  
  *cert_DER = NULL;
  len = (ssize_t) i2d_X509(cert, cert_DER);
  
  return len;
#else
  session = data->session;
  raw_cert_list = gnutls_certificate_get_peers(session, &raw_cert_list_length);

  if (raw_cert_list 
  && gnutls_certificate_type_get(session) == GNUTLS_CRT_X509
  &&  gnutls_x509_crt_init(&cert) >= 0
  &&  gnutls_x509_crt_import(cert, &raw_cert_list[0], GNUTLS_X509_FMT_DER) >= 0) {
    cert_size = sizeof(output);
    if (gnutls_x509_crt_export(cert, GNUTLS_X509_FMT_DER, output, &cert_size) < 0)
      return -1;
    
    *cert_DER = malloc (cert_size + 1);
    if (*cert_DER == NULL)
      return -1;
    
    memcpy (*cert_DER, output, cert_size);
    len = (ssize_t)cert_size;
    gnutls_x509_crt_deinit(cert);
    
    return len;
  }
#endif
#endif
  return -1;
}

static void mailstream_low_ssl_cancel(mailstream_low * s)
{
#ifdef USE_SSL
  struct mailstream_ssl_data * data;
  
  data = s->data;
  mailstream_cancel_notify(data->cancel);
#endif
}

mailstream_low * mailstream_low_ssl_open_with_callback(int fd,
    void (* callback)(struct mailstream_ssl_context * ssl_context, void * data), void * data)
{
  return mailstream_low_ssl_open_full(fd, 0, callback, data);
}

mailstream_low * mailstream_low_tls_open_with_callback(int fd,
    void (* callback)(struct mailstream_ssl_context * ssl_context, void * data), void * data)
{
  return mailstream_low_ssl_open_full(fd, 1, callback, data);
}

int mailstream_ssl_set_client_certicate(struct mailstream_ssl_context * ssl_context,
    char * filename)
{
#ifdef USE_SSL
#ifdef USE_GNUTLS
  /* not implemented */
  return -1;
#else
  SSL_CTX * ctx = (SSL_CTX *)ssl_context->openssl_ssl_ctx;
  STACK_OF(X509_NAME) *cert_names;
  
  cert_names = SSL_load_client_CA_file(filename);
  if (cert_names != NULL) {
    SSL_CTX_set_client_CA_list(ctx, cert_names);
    return 0;
  }
  else {
    return -1;
  }
#endif /* USE_GNUTLS */
#else
  return -1;
#endif /* USE_SSL */
}

LIBETPAN_EXPORT
int mailstream_ssl_set_client_certificate_data(struct mailstream_ssl_context * ssl_context,
    unsigned char *x509_der, size_t len)
{
#ifdef USE_SSL
#ifndef USE_GNUTLS
  X509 *x509 = NULL;
  if (x509_der != NULL && len > 0)
    x509 = d2i_X509(NULL, (const unsigned char **)&x509_der, len);
  ssl_context->client_x509 = (X509 *)x509;
  return 0;
#else
  gnutls_datum tmp;
  int r;
  ssl_context->client_x509 = NULL;
  if (len == 0)
    return 0;
  gnutls_x509_crt_init(&(ssl_context->client_x509));
  tmp.data = x509_der;
  tmp.size = len;
  if ((r = gnutls_x509_crt_import(ssl_context->client_x509, &tmp, GNUTLS_X509_FMT_DER)) < 0) {
    gnutls_x509_crt_deinit(ssl_context->client_x509); /* ici */
    ssl_context->client_x509 = NULL;
    return -1;
  }
  return 0;
#endif
#endif
  return -1;
}
int mailstream_ssl_set_client_private_key_data(struct mailstream_ssl_context * ssl_context,
    unsigned char *pkey_der, size_t len)
{
#ifdef USE_SSL
#ifndef USE_GNUTLS
  EVP_PKEY *pkey = NULL;
  if (pkey_der != NULL && len > 0)
    pkey = d2i_AutoPrivateKey(NULL, (const unsigned char **)&pkey_der, len);
  ssl_context->client_pkey = (EVP_PKEY *)pkey;
  return 0;
#else
  gnutls_datum tmp;
  int r;
  ssl_context->client_pkey = NULL;
  if (len == 0)
    return 0;
  gnutls_x509_privkey_init(&(ssl_context->client_pkey));
  tmp.data = pkey_der;
  tmp.size = len;
  if ((r = gnutls_x509_privkey_import(ssl_context->client_pkey, &tmp, GNUTLS_X509_FMT_DER)) < 0) {
    gnutls_x509_crt_deinit(ssl_context->client_pkey);
    ssl_context->client_pkey = NULL;
    return -1;
  }
  return 0;
#endif
#endif
  return -1;
}

int mailstream_ssl_set_server_certicate(struct mailstream_ssl_context * ssl_context, 
    char * CAfile, char * CApath)
{
#ifdef USE_SSL
#ifdef USE_GNUTLS
  /* not implemented */
  return -1;
#else
  SSL_CTX * ctx = (SSL_CTX *)ssl_context->openssl_ssl_ctx;
  SSL_CTX_set_verify(ctx, SSL_VERIFY_PEER, 0);
  if (!SSL_CTX_load_verify_locations(ctx, CAfile, CApath))
    return -1;
  else
    return 0;
#endif /* USE_GNUTLS */
#else
  return -1;
#endif /* USE_SSL */
}

#ifdef USE_SSL
#ifndef USE_GNUTLS
static struct mailstream_ssl_context * mailstream_ssl_context_new(SSL_CTX * open_ssl_ctx, int fd)
{
  struct mailstream_ssl_context * ssl_ctx;
  
  ssl_ctx = malloc(sizeof(* ssl_ctx));
  if (ssl_ctx == NULL)
    return NULL;
  
  ssl_ctx->openssl_ssl_ctx = open_ssl_ctx;
  ssl_ctx->client_x509 = NULL;
  ssl_ctx->client_pkey = NULL;
  ssl_ctx->fd = fd;
  
  return ssl_ctx;
}

static void mailstream_ssl_context_free(struct mailstream_ssl_context * ssl_ctx)
{
  if (ssl_ctx)
    free(ssl_ctx);
}
#else
static struct mailstream_ssl_context * mailstream_ssl_context_new(gnutls_session session, int fd)
{
  struct mailstream_ssl_context * ssl_ctx;
  
  ssl_ctx = malloc(sizeof(* ssl_ctx));
  if (ssl_ctx == NULL)
    return NULL;
  
  ssl_ctx->session = session;
  ssl_ctx->client_x509 = NULL;
  ssl_ctx->client_pkey = NULL;
  ssl_ctx->fd = fd;
  
  return ssl_ctx;
}

static void mailstream_ssl_context_free(struct mailstream_ssl_context * ssl_ctx)
{
  if (ssl_ctx) {
    if (ssl_ctx->client_x509)
      gnutls_x509_crt_deinit(ssl_ctx->client_x509);
    if (ssl_ctx->client_pkey)
      gnutls_x509_privkey_deinit(ssl_ctx->client_pkey);
    free(ssl_ctx);
  }
}
#endif
#endif

void * mailstream_ssl_get_openssl_ssl_ctx(struct mailstream_ssl_context * ssl_context)
{
#ifdef USE_SSL
#ifndef USE_GNUTLS
  return ssl_context->openssl_ssl_ctx;
#endif
#endif /* USE_SSL */
  return 0;
}

int mailstream_ssl_get_fd(struct mailstream_ssl_context * ssl_context)
{
  return ssl_context->fd;
}

