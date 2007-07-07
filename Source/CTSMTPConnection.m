#import "CTSMTPConnection.h"
#import "libetpan.h"
#import "CTCoreAddress.h"
#import "CTCoreMessage.h"
#import "MailCoreTypes.h"

#import "CTSMTP.h"
#import "CTESMTP.h"

//TODO Add more descriptive error messages using mailsmtp_strerror
@implementation CTSMTPConnection
+ (void)sendMessage:(CTCoreMessage *)message server:(NSString *)server username:(NSString *)username
					password:(NSString *)password port:(unsigned int)port useTLS:(BOOL)tls useAuth:(BOOL)auth {
  	mailsmtp *smtp = NULL;
	smtp = mailsmtp_new(0, NULL);
	assert(smtp != NULL);

	CTSMTP *smtpObj = [[CTESMTP alloc] initWithResource:smtp];
	@try {
		[smtpObj connectToServer:server port:port];
		if ([smtpObj helo] == false) {
			/* The server didn't support ESMTP, so switching to STMP */
			[smtpObj release];
			smtpObj = [[CTSMTP alloc] initWithResource:smtp];
			[smtpObj helo];
		}
		if (tls)
			[smtpObj startTLS];
		if (auth)
			[smtpObj authenticateWithUsername:username password:password server:server];

		[smtpObj setFrom:[[[message from] anyObject] email]];

		/* recipients */
		NSMutableSet *rcpts = [NSMutableSet set];
		[rcpts unionSet:[message to]];
		[rcpts unionSet:[message bcc]];
		[rcpts unionSet:[message cc]];
		[smtpObj setRecipients:rcpts];
	 
		/* data */
		[smtpObj setData:[message render]];
	}
	@finally {
		[smtpObj release];	
		mailsmtp_free(smtp);
	}
}
@end