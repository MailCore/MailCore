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
	
	if ([useTLS state] == NSOnState )
	{
		[myAccount connectToServer:[server stringValue] port:[port intValue] connectionType:CONNECTION_TYPE_TLS
				authType:IMAP_AUTH_TYPE_PLAIN login:[username stringValue] password:[password stringValue]];
	}
	else
	{
		[myAccount connectToServer:[server stringValue] port:[port intValue] connectionType:CONNECTION_TYPE_PLAIN 
				authType:IMAP_AUTH_TYPE_PLAIN login:[username stringValue] password:[password stringValue]];
	}
	CTCoreFolder *inbox = [myAccount folderWithPath:@"INBOX"];
	NSLog(@"INBOX %@", inbox);
	// set the toIndex to 0 so all messages are loaded
	NSSet *messageSet = [inbox messageObjectsFromIndex:1 toIndex:0]; 
	NSLog(@"Done getting list of messages...");
	
	NSMutableSet *messagesProxy = [self mutableSetValueForKey:@"messages"];
	NSEnumerator *objEnum = [messageSet objectEnumerator];
	id msg;
	
	while(msg = [objEnum nextObject]) {
		[msg fetchBody];
		[messagesProxy addObject:msg];
	}
}


- (NSMutableSet *)messages
{
	return myMessages;
}


- (void)setMessages:(NSMutableSet *)messages
{
	[messages retain];
	[myMessages release];
	myMessages = messages;
}
@end
