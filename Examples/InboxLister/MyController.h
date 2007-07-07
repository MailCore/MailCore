/* MyController */

#import <Cocoa/Cocoa.h>
#import <MailCore/MailCore.h>

@interface MyController : NSObject
{
    IBOutlet id password;
    IBOutlet id port;
    IBOutlet id server;
    IBOutlet id username;
	IBOutlet id useTLS;

	CTCoreAccount	*myAccount;
	NSMutableSet	*myMessages;
}
- (IBAction)connect:(id)sender;
- (NSMutableSet *)messages;
- (void)setMessages:(NSMutableSet *)messages;
@end
