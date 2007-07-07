#import <Cocoa/Cocoa.h>
#import "CTSMTP.h"

/*!
	@class	CTESMTP
	This class is used internally by CTSMTPConnection for ESMTP connections, clients
	should not use this directly.
*/


@interface CTESMTP : CTSMTP {

}
- (bool)helo;
- (void)startTLS;
- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password server:(NSString *)server;
- (void)setFrom:(NSString *)fromAddress;
- (void)setRecipientAddress:(NSString *)recAddress;
@end
