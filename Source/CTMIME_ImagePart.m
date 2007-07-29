#import "CTMIME_ImagePart.h"


@implementation CTMIME_ImagePart
- (id)initWithMIMEStruct:(struct mailmime *)mime forMessage:(struct mailmessage *)message {
	self = [super init];
	if (self) {
		NSLog(@"Something is here!");
	}
	return self;		
}

@end
