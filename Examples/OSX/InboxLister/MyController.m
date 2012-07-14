#import "MyController.h"

@implementation MyController
- (id)init
{
    self = [super init];
    if(self)
    {
        myAccount = [[CTCoreAccount alloc] init];
        myMessages = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)dealloc
{
    [myAccount release];
    [myMessages release];
    [super dealloc];
}


- (IBAction)connect:(id)sender
{
    NSLog(@"Connecting...");
    
    int portNumber = [port intValue];
    BOOL ssl = [useTLS state] == NSOnState;
    
    [myAccount connectToServer:[server stringValue]
                          port:portNumber > 0 ? portNumber : 993
                connectionType:ssl ? CONNECTION_TYPE_TLS : CONNECTION_TYPE_PLAIN
                      authType:IMAP_AUTH_TYPE_PLAIN
                         login:[username stringValue]
                      password:[password stringValue]];
    
    if(![myAccount isConnected]) {
        NSLog(@"NOT CONNECTED!");
        // return;
    }
    
    // NSLog(@"Folders %@", [myAccount allFolders]);
    
    CTCoreFolder *inbox = [myAccount folderWithPath:@"INBOX"];
    NSLog(@"INBOX %@", inbox);
    // set the toIndex to 0 so all messages are loaded
    NSArray *messageSet = [inbox messagesFromSequenceNumber:1 to:0 withFetchAttributes:CTFetchAttrEnvelope];
    NSLog(@"Done getting list of messages... %@", messageSet);
    
    NSMutableSet *messagesProxy = [self mutableSetValueForKey:@"messages"];
    NSEnumerator *objEnum = [messageSet objectEnumerator];
    id msg;
    
    while(msg = [objEnum nextObject]) {
        [msg fetchBodyStructure];
        [messagesProxy addObject:msg];
    }
    
    [myAccount disconnect];
}


- (NSMutableArray *)messages
{
    return myMessages;
}


- (void)setMessages:(NSMutableArray *)messages
{
    [messages retain];
    [myMessages release];
    myMessages = messages;
}
@end
