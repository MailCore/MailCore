/* MyController */

#import <Cocoa/Cocoa.h>
#import <MailCore/MailCore.h>

@interface CTMyController : NSObject
{
    IBOutlet NSTextField *password;
    IBOutlet NSTextField *port;
    IBOutlet NSTextField *server;
    IBOutlet NSTextField *username;
    IBOutlet NSButton *useAuth;
    IBOutlet NSButton *useTLS;
    
    IBOutlet NSTextField *to;
    IBOutlet NSTextField *from;
    IBOutlet NSTextField *subject;
    IBOutlet NSTextField *body;
}
- (IBAction)sendMessage:(id)sender;

@end
