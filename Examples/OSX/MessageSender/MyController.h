/* MyController */

#import <Cocoa/Cocoa.h>
#import <MailCore/MailCore.h>

@interface MyController : NSObject
{
    IBOutlet id password;
    IBOutlet id port;
    IBOutlet id server;
    IBOutlet id username;
    IBOutlet id useAuth;
    IBOutlet id useTLS;

    CTCoreMessage *myMessage;
}
- (IBAction)sendMessage:(id)sender;
- (NSString *)to;
- (void)setTo:(NSString *)aValue;
- (NSString *)from;
- (void)setFrom:(NSString *)aValue;
- (NSString *)subject;
- (void)setSubject:(NSString *)aValue;
- (NSString *)body;
- (void)setBody:(NSString *)aValue;

@end
