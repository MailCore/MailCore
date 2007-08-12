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

#import "CTSMTP.h"
#import "CTCoreAddress.h"
#import "CTCoreMessage.h"
#import "MailCoreTypes.h"

@implementation CTSMTP
- (id)initWithResource:(mailsmtp *)smtp {
	self = [super init];
	if (self) {
		mySMTP = smtp;
	}
	return self;
}


- (void)connectToServer:(NSString *)server port:(unsigned int)port {
	/* first open the stream */
	int ret = mailsmtp_socket_connect([self resource], [server cStringUsingEncoding:NSASCIIStringEncoding], port);
	IfTrue_RaiseException(ret != MAILSMTP_NO_ERROR, CTSMTPSocket, CTSMTPSocketDesc);
}


- (bool)helo {
	/*  The server doesn't support esmtp, so try regular smtp */
	int ret = mailsmtp_helo([self resource]);
	IfTrue_RaiseException(ret != MAILSMTP_NO_ERROR, CTSMTPHello, CTSMTPHelloDesc);
	return YES; /* The server supports helo so return YES */
}


- (void)startTLS {
	//TODO Raise exception
}


- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password server:(NSString *)server {
	//TODO Raise exception
}


- (void)setFrom:(NSString *)fromAddress {
	int ret = mailsmtp_mail([self resource], [fromAddress cStringUsingEncoding:NSASCIIStringEncoding]);
	IfTrue_RaiseException(ret != MAILSMTP_NO_ERROR, CTSMTPFrom, CTSMTPFromDesc);
}


- (void)setRecipients:(id)recipients {
	NSEnumerator *objEnum = [recipients objectEnumerator];
	CTCoreAddress *rcpt;
	while(rcpt = [objEnum nextObject]) {
		[self setRecipientAddress:[rcpt email]];
	}
}


- (void)setRecipientAddress:(NSString *)recAddress {
	int ret = mailsmtp_rcpt([self resource], [recAddress cStringUsingEncoding:NSASCIIStringEncoding]);
	IfTrue_RaiseException(ret != MAILSMTP_NO_ERROR, CTSMTPRecipients, CTSMTPRecipientsDesc);
}


- (void)setData:(NSString *)data {
	NSData *dataObj = [data dataUsingEncoding:NSASCIIStringEncoding];
	int ret = mailsmtp_data([self resource]);
	IfTrue_RaiseException(ret != MAILSMTP_NO_ERROR, CTSMTPData, CTSMTPDataDesc);
  	ret = mailsmtp_data_message([self resource], [dataObj bytes], [dataObj length]);
	IfTrue_RaiseException(ret != MAILSMTP_NO_ERROR, CTSMTPData, CTSMTPDataDesc);
}


- (mailsmtp *)resource {
	return mySMTP;
}
@end
