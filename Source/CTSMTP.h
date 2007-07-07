#import <Cocoa/Cocoa.h>
#import "libetpan.h"

/*!
	@class	CTSMTP
	This class is used internally by CTSMTPConnection for SMTP connections, clients
	should not use this directly.
*/

@interface CTSMTP : NSObject {
	mailsmtp *mySMTP; /* This resource is created and freed by CTSMTPConnection */
}
- (id)initWithResource:(mailsmtp *)smtp;
- (void)connectToServer:(NSString *)server port:(unsigned int)port;
- (bool)helo;
- (void)startTLS;
- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password server:(NSString *)server;
- (void)setFrom:(NSString *)fromAddress;
- (void)setRecipients:(id)recipients;
- (void)setRecipientAddress:(NSString *)recAddress;
- (void)setData:(NSString *)data;
- (mailsmtp *)resource;
@end
