#import "MyController.h"

@implementation MyController
- (id)init
{
	self = [super init];
	if(self)
	{
		myMessage = [[CTCoreMessage alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[myMessage release];
	[super dealloc];
}

- (IBAction)sendMessage:(id)sender
{
	CTCoreMessage *msg = [[CTCoreMessage alloc] init];
	[msg setTo:[myMessage to]];
	[msg setFrom:[myMessage from]];
	[msg setBody:[myMessage body]];
	[msg setSubject:[myMessage subject]];

	BOOL auth = ([useAuth state] == NSOnState);
	BOOL tls = ([useTLS state] == NSOnState);
	[CTSMTPConnection sendMessage:msg server:[server stringValue] username:[username stringValue]
		password:[password stringValue] port:[port intValue] useTLS:tls useAuth:auth];
	[msg release];
}

- (NSString *)to
{
	return [[[myMessage to] anyObject] email];
}

- (void)setTo:(NSString *)aValue
{
	CTCoreAddress *addr = [CTCoreAddress address];
	[addr setEmail:aValue];
	[myMessage setTo:[NSSet setWithObject:addr]];
}

- (NSString *)from
{
	return [[[myMessage from] anyObject] email];
}

- (void)setFrom:(NSString *)aValue
{
	CTCoreAddress *addr = [CTCoreAddress address];
	[addr setEmail:aValue];
	[addr setName:@""];
	[myMessage setFrom:[NSSet setWithObject:addr]];
}

- (NSString *)subject
{
	return [myMessage subject];
}

- (void)setSubject:(NSString *)aValue
{
	[myMessage setSubject:aValue];
}

- (NSString *)body
{
	return [myMessage body];
}

- (void)setBody:(NSString *)aValue
{
	[myMessage setBody:aValue];
}
@end
