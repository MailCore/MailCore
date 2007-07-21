#import "CTBareMessage.h"

@implementation CTBareMessage
@synthesize uid=mUid, flags=mFlags;

- (id)init {
	self = [super init];
	if (self != nil) {
		self.uid = @"";
		self.flags = 0;
	}
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"UID: %@\n Flags: %d\n", self.uid, self.flags];
}
@end
