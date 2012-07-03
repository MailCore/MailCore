#import "CTMyController.h"

@implementation CTMyController

- (IBAction)sendMessage:(id)sender {
    CTCoreMessage *msg = [[CTCoreMessage alloc] init];
    
    CTCoreAddress *toAddr = [CTCoreAddress address];
    [toAddr setEmail:to.stringValue];
    [msg setTo:[NSSet setWithObject:toAddr]];
    
    CTCoreAddress *fromAddr = [CTCoreAddress address];
    [fromAddr setEmail:from.stringValue];
    [fromAddr setName:@""];
    [msg setFrom:[NSSet setWithObject:fromAddr]];
    
    [msg setSubject:subject.stringValue];
    [msg setBody:body.stringValue];

    BOOL auth = ([useAuth state] == NSOnState);
    BOOL tls = ([useTLS state] == NSOnState);
    
    NSString *serverValue = server.stringValue;
    NSString *usernameValue = username.stringValue;
    NSString *passwordValue = password.stringValue;
    int portValue = port.intValue;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        BOOL success = [CTSMTPConnection sendMessage:msg server:serverValue username:usernameValue
                                            password:passwordValue port:portValue useTLS:tls useAuth:auth error:&error];
        if (!success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSApp presentError:error];
            });
        }
    });
}
@end
