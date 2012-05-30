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
    NSMutableArray	*myMessages;
}
- (IBAction)connect:(id)sender;
- (NSMutableArray *)messages;
- (void)setMessages:(NSMutableArray *)messages;
@end
