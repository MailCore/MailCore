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
