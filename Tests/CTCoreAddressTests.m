#import "CTCoreAddressTests.h"


@implementation CTCoreAddressTests
- (void)testEquals {
	CTCoreAddress *addr1 = [CTCoreAddress addressWithName:@"Matt" email:@"test@test.com"];
	CTCoreAddress *addr2 = [CTCoreAddress addressWithName:@"Matt" email:@"test@test.com"];
	STAssertTrue([addr1 isEqual:addr2], @"CTCoreAddress should have been equal!");
}

- (void)testNotEqual {
	CTCoreAddress *addr1 = [CTCoreAddress addressWithName:@"" email:@"something@some.com"];
	CTCoreAddress *addr2 = [CTCoreAddress addressWithName:@"Something" email:@"something@some.com"];
	STAssertFalse([addr1 isEqual:addr2], @"CTCoreAddress should not have been equal!");
}
@end
