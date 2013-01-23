/*
 * MailCore
 *
 * Copyright (C) 2007 - Matt Ronge
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the MailCore project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#import "CTCoreMessageTests.h"
#import "CTMIMETests.h"
#import "CTCoreAddress.h"
#import "CTCoreAttachment.h"
#import "CTBareAttachment.h"

@implementation CTCoreMessageTests
- (void)setUp {
	myMsg = [[CTCoreMessage alloc] init];
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestData/kiwi-dev/1167196014.6158_0.theronge.com:2,Sab" ofType:@""];
	myRealMsg = [[CTCoreMessage alloc] initWithFileAtPath:filePath];
}

- (void)tearDown {
	[myMsg release];
	[myRealMsg release];
}

- (void)testBody {
    STAssertTrue([[myRealMsg body] rangeOfString:@"Kiwi-dev mailing list"].location != NSNotFound, @"Expect to pull out the right text");
    NSLog(@"Body is %@", [myRealMsg body]);
}

- (void)testHtmlBody {
    STAssertTrue([[myRealMsg htmlBody] rangeOfString:@"CTCoreMessage no longer depends"].location != NSNotFound, @"Expect to pull out the right text");
    NSLog(@"Html body is %@", [myRealMsg htmlBody]);
}

- (void)testBasicSubject {
	[myMsg setSubject:@"Test value1!"];
	STAssertEqualObjects(@"Test value1!", [myMsg subject], @"Basic set and get of subject failed.");
}

- (void)testBasicMessageId {
	STAssertEqualObjects(@"20061227050649.BEDF0B8563@theronge.com", [myRealMsg messageId], @"");
}


- (void)testReallyLongSubject {
	NSString *reallyLongStr = @"faldskjfalkdjfal;skdfjl;ksdjfl;askjdflsadjkfsldfkjlsdfjkldskfjlsdkfjlskdfjslkdfjsdlkfjsdlfkjsdlfkjsdlfkjsdlkfjsdlfkjsdlfkjsldfjksldkfjsldkfjsdlfkjdslfjdsflkjdsflkjdsfldskjfsdlkfjsdlkfjdslkfjsdlkfjdslfkjfaldskjfalkdjfal;skdfjl;ksdjfl;askjdflsadjkfsldfkjlsdfjkldskfjlsdkfjlskdfjslkdfjsdlkfjsdlfkjsdlfkjsdlfkjsdlkfjsdlfkjsdlfkjsldfjksldkfjsldkfjsdlfkjdslfjdsflkjdsflkjdsfldskjfsdlkfjsdlkfjdslkfjsdlkfjdslfkjfaldskjfalkdjfal;skdfjl;ksdjfl;askjdflsadjkfsldfkjlsdfjkldskfjlsdkfjlskdfjslkdfjsdlkfjsdlfkjsdlfkjsdlfkjsdlkfjsdlfkjsdlfkjsldfjksldkfjsldkfjsdlfkjdslfjdsflkjdsflkjdsfldskjfsdlkfjsdlkfjdslkfjsdlkfjdslfkjaskjdflsadjkfsldfkjlsdfjkldskfjlsdkfjlskdfjslkdfjsdlkfjsdlfkjsdlfkjsdlfkjsdlkfjsdlfkjsdlfkjsldfjksldkfjsldkfjsdlfkjdslfjdsflkjdsflkjdsfldskjfsdlkfjsdlkfjdslkfjsdlkfjdslfkjaskjdflsadjkfsldfkjlsdfjkldskfjlsdkfjlskdfjslkdfjsdlkfjsdlfkjsdlfkjsdlfkjsdlkfjsdlfkjsdlfkjsldfjksldkfjsldkfjsdlfkjdslfjdsflkjdsflkjdsfldskjfsdlkfjsdlkfjdslkfjsdlkfjdslfkj";
	[myMsg setSubject:reallyLongStr];
	STAssertEqualObjects(reallyLongStr, [myMsg subject], @"Failed to set and get a really long subject.");
}

- (void)testEmptySubject {
	[myMsg setSubject:@""];
	STAssertEqualObjects(@"", [myMsg subject], @"Failed to set and get an empty subject.");
}

- (void)testEmptyBody {
	[myMsg setBody:@""];
	STAssertEqualObjects(@"", [myMsg body], @"Failed to set and get an empty body.");
}

- (void)testBasicBody {
	[myMsg setBody:@"Test"];
	STAssertEqualObjects(@"Test", [myMsg body], @"Failed to set and get a message body.");
}

- (void)testSubjectOnData {
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestData/kiwi-dev/1167196014.6158_0.theronge.com:2,Sab" ofType:@""];
    CTCoreMessage *msg = [[CTCoreMessage alloc] initWithFileAtPath:filePath];
	[msg fetchBodyStructure];
	STAssertEqualObjects(@"[Kiwi-dev] Revision 16", [msg subject], @"");
	NSRange notFound = NSMakeRange(NSNotFound, 0);
	STAssertTrue(!NSEqualRanges([[msg body] rangeOfString:@"Kiwi-dev mailing list"],notFound), @"Body sanity check failed!");
	[msg release];
}

- (void)testRender {
	CTCoreMessage *msg = [[CTCoreMessage alloc] init];
	[msg setBody:@"test"];
	NSString *str = [msg render];
	/* Do a few sanity checks on the str */
	NSRange notFound = NSMakeRange(NSNotFound, 0);
	STAssertTrue(!NSEqualRanges([str rangeOfString:@"Date:"],notFound), @"Render sanity check failed!");
	STAssertTrue(!NSEqualRanges([str rangeOfString:@"Message-ID:"],notFound), @"Render sanity check failed!");
	STAssertTrue(!NSEqualRanges([str rangeOfString:@"MIME-Version: 1.0"],notFound), @"Render sanity check failed!");
	STAssertTrue(!NSEqualRanges([str rangeOfString:@"test"],notFound), @"Render sanity check failed!");
	STAssertTrue(!NSEqualRanges([str rangeOfString:@"Content-Transfer-Encoding:"],notFound), @"Render sanity check failed!");
	STAssertTrue(NSEqualRanges([str rangeOfString:@"not there"],notFound), @"Render sanity check failed!");
}

- (void)testRenderWithToField {
	CTCoreMessage *msg = [[CTCoreMessage alloc] init];
	[msg setBody:@"This is some kind of message."];
	[msg setTo:[NSArray arrayWithObjects:[CTCoreAddress addressWithName:@"Matt" email:@"test@test.com"],nil]];
	NSString *str = [msg render];
	/* Do a few sanity checks on the str */
	NSRange notFound = NSMakeRange(NSNotFound, 0);
	STAssertTrue(!NSEqualRanges([str rangeOfString:@"message"],notFound), @"Render sanity check failed!");
	STAssertTrue(!NSEqualRanges([str rangeOfString:@"To: Matt <test@test.com>"],notFound), @"Render sanity check failed!");
}

- (void)testTo {
	NSSet *to = [myRealMsg to];
	STAssertTrue([to count] == 1, @"To should only contain 1 address!");
	CTCoreAddress *addr = [CTCoreAddress addressWithName:@"" email:@"kiwi-dev@lists.theronge.com"];
	STAssertEqualObjects(addr, [to anyObject], @"The only address object should have been kiwi-dev@lists.theronge.com");
}

- (void)testFrom {
	NSSet *from = [myRealMsg from];
	STAssertTrue([from count] == 1, @"To should only contain 1 address!");
	CTCoreAddress *addr = [CTCoreAddress addressWithName:@"" email:@"kiwi-dev@lists.theronge.com"];
	STAssertEqualObjects(addr, [from anyObject], @"The only address object should have been kiwi-dev@lists.theronge.com");
}

- (void)testFromSpecialChar {
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestData/kiwi-dev/1162094633.15211_0.randymail-mx2:2,RSab" ofType:@""];
	CTCoreMessage *msg = [[CTCoreMessage alloc] initWithFileAtPath:filePath];
	CTCoreAddress *addr = [[msg from] anyObject];
	STAssertEqualObjects(@"Joachim Mårtensson", [addr name], @"");
	[msg release];
}

- (void)testEmptyBcc {
	STAssertTrue([myRealMsg bcc] == nil, @"Shouldn't have been nil");
}

- (void)testEmptyCc {
	STAssertTrue([myRealMsg cc] == nil, @"Shouldn't have been nil");
}

- (void)testSender {
	STAssertEqualObjects([myRealMsg sender], [CTCoreAddress addressWithName:@"" email:@"kiwi-dev-bounces@lists.theronge.com"], @"Sender returned is incorrect!");
}

- (void)testReplyTo {
	NSSet *replyTo = [myRealMsg replyTo];
	STAssertTrue([replyTo count] == 1, @"To should only contain 1 address!");
	CTCoreAddress *addr = [CTCoreAddress addressWithName:@"" email:@"kiwi-dev@lists.theronge.com"];
	STAssertEqualObjects(addr, [replyTo anyObject], @"The only address object should have been kiwi-dev@lists.theronge.com");
}

- (void)testSentDate {
    NSTimeInterval sentSince1970 = [[myRealMsg senderDate] timeIntervalSince1970];

    NSTimeInterval actualSince1970 = 1167196009;
    /*
      you can get this value by typing this into your browser console

      > date = new Date('Tue, 26 Dec 2006 21:06:49 -0800 (PST)')
      Tue Dec 26 2006 21:06:49 GMT-0800 (PST)
      > date.getTime() / 1000
      1167196009
    */

    STAssertEquals(sentSince1970, actualSince1970, @"Dates should be equal!");
}

- (void)testSettingFromTwice {
	CTCoreMessage *msg = [[CTCoreMessage alloc] init];
	[msg setFrom:[NSSet setWithObject:[CTCoreAddress addressWithName:@"Matt P" email:@"mattp@p.org"]]];
	[msg setFrom:[NSSet setWithObject:[CTCoreAddress addressWithName:@"Matt R" email:@"mattr@r.org"]]];
	[msg release];
}

- (void)testAttachments {
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestData/mime-tests/png_attachment" ofType:@""];
	CTCoreMessage *msg = [[CTCoreMessage alloc] initWithFileAtPath:filePath];
	[msg fetchBodyStructure];
	NSArray *attachments = [msg attachments];
	STAssertTrue([attachments count] == 1, @"Count should have been 1");
	STAssertEqualObjects([[attachments objectAtIndex:0] filename], @"Picture 1.png", @"Incorrect filename");
	CTBareAttachment *bareAttach = [attachments objectAtIndex:0];
	CTCoreAttachment *attach = [bareAttach fetchFullAttachment];

    filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestData/Picture 1" ofType:@"png"];
	NSData *origData = [NSData dataWithContentsOfFile:filePath];
	STAssertEqualObjects(origData, attach.data, @"Original data and attach data should be the same");
	[msg release];
}
@end
