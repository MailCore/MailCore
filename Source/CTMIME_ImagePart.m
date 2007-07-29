#import "CTMIME_ImagePart.h"


@implementation CTMIME_ImagePart
- (id)initWithMIMEStruct:(struct mailmime *)mime forMessage:(struct mailmessage *)message {
	self = [super init];
	if (self) {
		NSData *data = [self parsePart:mime forMessage:message];
		mImage = [[NSImage alloc] initWithData:data];
	}
	return self;		
}

- (void)dealloc {
	[mImage release];
	[super dealloc];
}
@end
