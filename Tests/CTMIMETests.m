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
 * 3. Neither the name of the libEtPan! project nor the names of its
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

#import "CTMIMETests.h"

#import "CTCoreMessage.h"
#import "CTMIME.h"
#import "libetpan.h"
#import "CTMIMEFactory.h"
#import "CTMIME_MessagePart.h"
#import "CTMIME_MultiPart.h"
#import "CTMIME_SinglePart.h"
#import "CTMIME_TextPart.h"
#import "CTMIME_ImagePart.h"

const NSString *filePrefix = @"/Users/mronge/Projects/MailCore/";

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

- (void)testImageJPEGAttachment {
	CTCoreMessage *msg = [[CTCoreMessage alloc] initWithFileAtPath:[NSString stringWithFormat:@"%@%@",filePrefix,@"TestData/mime-tests/imagetest"]];
	CTMIME *mime = [CTMIMEFactory createMIMEWithMIMEStruct:[msg messageStruct]->msg_mime forMessage:[msg messageStruct]];
	STAssertTrue([mime isKindOfClass:[CTMIME_MessagePart class]],@"Outmost MIME type should be Message but it's not!");
	STAssertTrue([[mime content] isKindOfClass:[CTMIME_MultiPart class]],@"Incorrect MIME structure found!");
	NSArray *multiPartContent = [[mime content] content];	
	STAssertTrue([multiPartContent count] == 3, @"Incorrect MIME structure found!");
	STAssertTrue([[multiPartContent objectAtIndex:0] isKindOfClass:[CTMIME_TextPart class]], @"Incorrect MIME structure found!");
	STAssertTrue([[multiPartContent objectAtIndex:1] isKindOfClass:[CTMIME_ImagePart class]], @"Incorrect MIME structure found!");
	CTMIME_ImagePart *img = [multiPartContent objectAtIndex:1];	
	STAssertTrue(img.attached == FALSE, @"Image is should be inline");
	STAssertEqualObjects(img.filename, @"mytestimage.jpg", @"Filename of inline image not correct");
	[msg release];
}

- (void)testImagePNGAttachment {
	CTCoreMessage *msg = [[CTCoreMessage alloc] initWithFileAtPath:[NSString stringWithFormat:@"%@%@",filePrefix,@"TestData/mime-tests/png_attachment"]];
	CTMIME *mime = [CTMIMEFactory createMIMEWithMIMEStruct:[msg messageStruct]->msg_mime forMessage:[msg messageStruct]];
	STAssertTrue([mime isKindOfClass:[CTMIME_MessagePart class]],@"Outmost MIME type should be Message but it's not!");
	STAssertTrue([[mime content] isKindOfClass:[CTMIME_MultiPart class]],@"Incorrect MIME structure found!");
	NSArray *multiPartContent = [[mime content] content];	
	STAssertTrue([multiPartContent count] == 2, @"Incorrect MIME structure found!");
	STAssertTrue([[multiPartContent objectAtIndex:0] isKindOfClass:[CTMIME_TextPart class]], @"Incorrect MIME structure found!");
	STAssertTrue([[multiPartContent objectAtIndex:1] isKindOfClass:[CTMIME_ImagePart class]], @"Incorrect MIME structure found!");
	CTMIME_ImagePart *img = [multiPartContent objectAtIndex:1];	
	STAssertTrue(img.attached == TRUE, @"Image is should be attached");
	STAssertEqualObjects(img.filename, @"Picture 1.png", @"Filename of inline image not correct");
	[msg release];
}
@end
