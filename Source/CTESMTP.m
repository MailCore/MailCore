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

- (BOOL)helo {
    int ret = mailesmtp_ehlo([self resource]);
    /* Return false if the server doesn't implement ehlo */
    return (ret != MAILSMTP_ERROR_NOT_IMPLEMENTED);
}


- (BOOL)startTLS {
    int ret = mailsmtp_socket_starttls([self resource]);
    if (ret != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromSMTPCode(ret);
        return NO;
    }

    ret = mailesmtp_ehlo([self resource]);
    if (ret != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromSMTPCode(ret);
        return NO;
    }
    return YES;
}


- (BOOL)authenticateWithUsername:(NSString *)username password:(NSString *)password server:(NSString *)server {
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

    char *authType = "PLAIN";
    mailsmtp *session = [self resource];
    if (session->auth & MAILSMTP_AUTH_CHECKED) {
        // If the server doesn't support PLAIN but does support the older LOGIN,
        // fall back to LOGIN. This can happen with older servers like Exchange 2003
        if (!(session->auth & MAILSMTP_AUTH_PLAIN) && session->auth & MAILSMTP_AUTH_LOGIN) {
            authType = "LOGIN";
        }
    }
    
    ret = mailesmtp_auth_sasl(session, authType, cServer, local_ip_port, remote_ip_port,
                            cUsername, cUsername, cPassword, cServer);
    if (ret != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromSMTPCode(ret);
        return NO;
    }
    return YES;
}


- (BOOL)setFrom:(NSString *)fromAddress {
    int ret = mailesmtp_mail([self resource], [fromAddress cStringUsingEncoding:NSUTF8StringEncoding], 1, "MailCoreSMTP");
    if (ret != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromSMTPCode(ret);
        return NO;
    }
    return YES;
}


- (BOOL)setRecipientAddress:(NSString *)recAddress {
    int ret = mailesmtp_rcpt([self resource], [recAddress cStringUsingEncoding:NSUTF8StringEncoding],
                        MAILSMTP_DSN_NOTIFY_FAILURE|MAILSMTP_DSN_NOTIFY_DELAY,NULL);
    if (ret != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromSMTPCode(ret);
        return NO;
    }
    return YES;
}
@end
