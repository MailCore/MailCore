#import "CTMIMETests.h"

#import "CTCoreMessage.h"
#import "CTMIME.h"
#import "libetpan.h"
#import "CTMIMEFactory.h"
#import "CTMIME_MessagePart.h"
#import "CTMIME_MultiPart.h"
#import "CTMIME_SinglePart.h"
#import "CTMIME_TextPart.h"

const NSString *filePrefix = @"/Users/local/Projects/MailCore/";

@implementation CTMIMETests
- (void)testMIMETextPart {
	CTCoreMessage *msg = [[CTCoreMessage alloc] initWithFileAtPath:[NSString stringWithFormat:@"%@%@",filePrefix,@"TestData/kiwi-dev/1167196014.6158_0.theronge.com:2,Sab"]];
	CTMIME *mime = [CTMIMEFactory createMIMEWithMIMEStruct:[msg messageStruct]->msg_mime forMessage:[msg messageStruct]];
	STAssertTrue([mime isKindOfClass:[CTMIME_MessagePart class]],@"Outmost MIME type should be Message but it's not!");
	STAssertTrue([[mime content] isKindOfClass:[CTMIME_MultiPart class]],@"Incorrect MIME structure found!");
	NSArray *multiPartContent = [[mime content] content];
	STAssertTrue([multiPartContent count] == 2, @"Incorrect MIME structure found!");
	STAssertTrue([[multiPartContent objectAtIndex:0] isKindOfClass:[CTMIME_TextPart class]], @"Incorrect MIME structure found!");
	STAssertTrue([[multiPartContent objectAtIndex:1] isKindOfClass:[CTMIME_TextPart class]], @"Incorrect MIME structure found!");	
	[msg release];
}

- (void)testSmallMIME {
	CTMIME_TextPart *text1 = [CTMIME_TextPart mimeTextPartWithString:@"Hello there!"];
	CTMIME_TextPart *text2 = [CTMIME_TextPart mimeTextPartWithString:@"This is part 2"];
	CTMIME_MultiPart *multi = [CTMIME_MultiPart mimeMultiPart];
	[multi addMIMEPart:text1];
	[multi addMIMEPart:text2];
	CTMIME_MessagePart *messagePart = [CTMIME_MessagePart mimeMessagePartWithContent:multi];
	NSString *str = [messagePart render];
	[str writeToFile:@"/tmp/mailcore_test_output" atomically:NO encoding:NSASCIIStringEncoding error:NULL];
	
	CTCoreMessage *msg = [[CTCoreMessage alloc] initWithFileAtPath:@"/tmp/mailcore_test_output"];
	CTMIME *mime = [CTMIMEFactory createMIMEWithMIMEStruct:[msg messageStruct]->msg_mime forMessage:[msg messageStruct]];
	STAssertTrue([mime isKindOfClass:[CTMIME_MessagePart class]],@"Outmost MIME type should be Message but it's not!");
	STAssertTrue([[mime content] isKindOfClass:[CTMIME_MultiPart class]],@"Incorrect MIME structure found!");
	NSArray *multiPartContent = [[mime content] content];	
	STAssertTrue([multiPartContent count] == 2, @"Incorrect MIME structure found!");
	STAssertTrue([[multiPartContent objectAtIndex:0] isKindOfClass:[CTMIME_TextPart class]], @"Incorrect MIME structure found!");
	STAssertTrue([[multiPartContent objectAtIndex:1] isKindOfClass:[CTMIME_TextPart class]], @"Incorrect MIME structure found!");
	[msg release];
}

- (void)testBruteForce {
	// run it on a bunch of the files in the test data directory and see if we can get it to crash
	NSDirectoryEnumerator *dirEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:[filePrefix stringByAppendingString:@"TestData/kiwi-dev/"]];
	NSString *file;
	NSRange notFound = NSMakeRange(NSNotFound, 0);
	while ((file = [dirEnumerator nextObject])) {
		if (!NSEqualRanges([file rangeOfString:@".svn"],notFound))
			continue;
		CTCoreMessage *msg = [[CTCoreMessage alloc] initWithFileAtPath:[NSString stringWithFormat:@"%@TestData/kiwi-dev/%@",filePrefix,file]];
		NSLog([msg subject]);
		[msg fetchBody];
		NSString *stuff = [msg body];
		[stuff length]; //Get the warning to shutup about stuff not being used
		[msg release];
	}
}
@end
