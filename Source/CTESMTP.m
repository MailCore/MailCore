/*
 * MailCore
 *
 * Copyright (C) 2007 - Matt Ronge
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
 * 3. Neither the name of the MailCore project nor the names of its
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

#import "CTESMTP.h"

#import "CTCoreAddress.h"
#import "CTCoreMessage.h"
#import "MailCoreTypes.h"
#import "MailCoreUtilities.h"

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

/* Code from Dinh Viet Hoa */
static int fill_remote_ip_port(mailstream * stream, char * remote_ip_port, size_t remote_ip_port_len) {
  mailstream_low * low;
  int fd;
  struct sockaddr_in name;
  socklen_t namelen;
  char remote_ip_port_buf[128];
  int r;

  low = mailstream_get_low(stream);
  fd = mailstream_low_get_fd(low);

  namelen = sizeof(name);
  r = getpeername(fd, (struct sockaddr *) &name, &namelen);
  if (r < 0)
    return -1;

  if (inet_ntop(AF_INET, &name.sin_addr, remote_ip_port_buf,
          sizeof(remote_ip_port_buf)))
    return -1;

  snprintf(remote_ip_port, remote_ip_port_len, "%s;%i",
      remote_ip_port_buf, ntohs(name.sin_port));

  return 0;
}


static int fill_local_ip_port(mailstream * stream, char * local_ip_port, size_t local_ip_port_len) {
  mailstream_low * low;
  int fd;
  struct sockaddr_in name;
  socklen_t namelen;
  char local_ip_port_buf[128];
  int r;

  low = mailstream_get_low(stream);
  fd = mailstream_low_get_fd(low);
  namelen = sizeof(name);
  r = getpeername(fd, (struct sockaddr *) &name, &namelen);
  if (r < 0)
    return -1;

  if (inet_ntop(AF_INET, &name.sin_addr, local_ip_port_buf, sizeof(local_ip_port_buf)))
    return -1;

  snprintf(local_ip_port, local_ip_port_len, "%s;%i", local_ip_port_buf, ntohs(name.sin_port));
  return 0;
}

@implementation CTESMTP
- (bool)helo {
    int ret = mailesmtp_ehlo([self resource]);
    /* Return false if the server doesn't implement ehlo */
    return (ret != MAILSMTP_ERROR_NOT_IMPLEMENTED);
}


- (void)startTLS {
    mailstream_low * low;
    int fd;
    mailstream_low * new_low;

    int ret = mailesmtp_starttls([self resource]);
    IfTrue_RaiseException(ret != MAILSMTP_NO_ERROR, CTSMTPTLS, CTSMTPTLSDesc);

    low = mailstream_get_low([self resource]->stream);
    fd = mailstream_low_get_fd(low);
    new_low = mailstream_low_tls_open(fd);
    mailstream_low_free(low);
    mailstream_set_low([self resource]->stream, new_low);

    ret = mailesmtp_ehlo([self resource]);
    IfTrue_RaiseException(ret != MAILSMTP_NO_ERROR, CTSMTPHello, CTSMTPHelloDesc);
}


- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password server:(NSString *)server {
    char *cUsername = (char *)[username cStringUsingEncoding:NSUTF8StringEncoding];
    char *cPassword = (char *)[password cStringUsingEncoding:NSUTF8StringEncoding];
    char *cServer = (char *)[server cStringUsingEncoding:NSUTF8StringEncoding];

    char local_ip_port_buf[128];
    char remote_ip_port_buf[128];
    char * local_ip_port;
    char * remote_ip_port;

    if (cPassword == NULL)
        cPassword = "";
    if (cUsername == NULL)
        cUsername = "";

    int ret = fill_local_ip_port([self resource]->stream, local_ip_port_buf, sizeof(local_ip_port_buf));
    if (ret < 0)
        local_ip_port = NULL;
    else
        local_ip_port = local_ip_port_buf;

    ret = fill_remote_ip_port([self resource]->stream, remote_ip_port_buf, sizeof(remote_ip_port_buf));
    if (ret < 0)
        remote_ip_port = NULL;
    else
        remote_ip_port = remote_ip_port_buf;
 /*
    in most case, login = auth_name = user@domain
    and realm = server hostname full qualified domain name

    int mailesmtp_auth_sasl(mailsmtp * session, const char * auth_type,
        const char * server_fqdn,
        const char * local_ip_port,
        const char * remote_ip_port,
        const char * login, const char * auth_name,
        const char * password, const char * realm);

 */		
    ret = mailesmtp_auth_sasl([self resource], "PLAIN", cServer, local_ip_port, remote_ip_port,
                            cUsername, cUsername, cPassword, cServer);
    IfTrue_RaiseException(ret != MAILSMTP_NO_ERROR, CTSMTPLogin, CTSMTPLoginDesc);
}


- (void)setFrom:(NSString *)fromAddress {
    int ret = mailesmtp_mail([self resource], [fromAddress cStringUsingEncoding:NSUTF8StringEncoding], 1, "MailCoreSMTP");
    IfTrue_RaiseException(ret != MAILSMTP_NO_ERROR, CTSMTPFrom, CTSMTPFromDesc);
}


- (void)setRecipientAddress:(NSString *)recAddress {
    int ret = mailesmtp_rcpt([self resource], [recAddress cStringUsingEncoding:NSUTF8StringEncoding],
                        MAILSMTP_DSN_NOTIFY_FAILURE|MAILSMTP_DSN_NOTIFY_DELAY,NULL);
    IfTrue_RaiseException(ret != MAILSMTP_NO_ERROR, CTSMTPRecipients, CTSMTPRecipientsDesc);
}
@end
