#import "CTBareMessageTests.h"


@implementation CTBareMessageTests
- (void)testEquals {
	CTBareMessage *msg1 = [[CTBareMessage alloc] init];
	msg1.uid = @"11111-11111";
	msg1.flags = 2;
	CTBareMessage *msg2 = [[CTBareMessage alloc] init];
	msg2.uid = @"11111-11111";
	msg2.flags = 2;	
	STAssertTrue([msg1 isEqual:msg2], @"CTBareMessage should have been equal!");
	[msg1 release];
	[msg2 release];
}

- (void)testNotEqual {
	CTBareMessage *msg1 = [[CTBareMessage alloc] init];
	msg1.uid = @"11111-11111";
	msg1.flags = 3;
	CTBareMessage *msg2 = [[CTBareMessage alloc] init];
	msg2.uid = @"11111-11111";
	msg2.flags = 2;	
	STAssertFalse([msg1 isEqual:msg2], @"CTBareMessage should have been not equal!");
	msg1.flags = 2;
	msg2.uid = @"";
	STAssertFalse([msg1 isEqual:msg2], @"CTBareMessage should have been not equal!");
	[msg1 release];
	[msg2 release];
}

- (void)testHash {
	CTBareMessage *msg1 = [[CTBareMessage alloc] init];
	msg1.uid = @"11111-11111";
	msg1.flags = 2;
	CTBareMessage *msg2 = [[CTBareMessage alloc] init];
	msg2.uid = @"11111-11111";
	msg2.flags = 2;
	STAssertTrue([msg1 hash] == [msg2 hash], @"CTBareMessage hashes should have been equal!");
	[msg1 release];
	[msg2 release];
}
@end
