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

#import "CTMIMETests.h"

#import "CTCoreMessage.h"
#import "CTMIME.h"
#import <libetpan/libetpan.h>
#import "CTMIMEFactory.h"
#import "CTMIME_MessagePart.h"
#import "CTMIME_MultiPart.h"
#import "CTMIME_SinglePart.h"
#import "CTMIME_TextPart.h"
#import "CTMIME_Enumerator.h"

@implementation CTMIMETests
- (void)testMIMETextPart {
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestData/kiwi-dev/1167196014.6158_0.theronge.com:2,Sab" ofType:@""];
	CTCoreMessage *msg = [[CTCoreMessage alloc] initWithFileAtPath:filePath];
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

        NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:[NSString stringWithFormat:@"TestData/kiwi-dev/%@",file] ofType:@""];
		CTCoreMessage *msg = [[CTCoreMessage alloc] initWithFileAtPath:filePath];
		NSLog(@"%@", [msg subject]);
		[msg fetchBodyStructure];
		NSString *stuff = [msg body];
		[stuff length]; //Get the warning to shutup about stuff not being used
		[msg release];
	}
}

- (void)testImageJPEGAttachment {
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestData/mime-tests/imagetest" ofType:@""];
    CTCoreMessage *msg = [[CTCoreMessage alloc] initWithFileAtPath:filePath];

	CTMIME *mime = [CTMIMEFactory createMIMEWithMIMEStruct:[msg messageStruct]->msg_mime forMessage:[msg messageStruct]];
	STAssertTrue([mime isKindOfClass:[CTMIME_MessagePart class]],@"Outmost MIME type should be Message but it's not!");
	STAssertTrue([[mime content] isKindOfClass:[CTMIME_MultiPart class]],@"Incorrect MIME structure found!");
	NSArray *multiPartContent = [[mime content] content];	
	STAssertTrue([multiPartContent count] == 3, @"Incorrect MIME structure found!");
	STAssertTrue([[multiPartContent objectAtIndex:0] isKindOfClass:[CTMIME_TextPart class]], @"Incorrect MIME structure found!");
	STAssertTrue([[multiPartContent objectAtIndex:1] isKindOfClass:[CTMIME_SinglePart class]], @"Incorrect MIME structure found!");
	CTMIME_SinglePart *img = [multiPartContent objectAtIndex:1];
	// For JPEG's we are ignoring the Content-Disposition: inline; not sure if we should be doing this?
	STAssertTrue(img.attached == TRUE, @"");
	STAssertEqualObjects(img.filename, @"mytestimage.jpg", @"Filename of inline image not correct");
	[msg release];
}

- (void)testImagePNGAttachment {
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestData/mime-tests/png_attachment" ofType:@""];
	CTCoreMessage *msg = [[CTCoreMessage alloc] initWithFileAtPath:filePath];

	CTMIME *mime = [CTMIMEFactory createMIMEWithMIMEStruct:
						[msg messageStruct]->msg_mime forMessage:[msg messageStruct]];
	STAssertTrue([mime isKindOfClass:[CTMIME_MessagePart class]],
					@"Outmost MIME type should be Message but it's not!");
	STAssertTrue([[mime content] isKindOfClass:[CTMIME_MultiPart class]],
					@"Incorrect MIME structure found!");
	NSArray *multiPartContent = [[mime content] content];	
	STAssertTrue([multiPartContent count] == 2, 
					@"Incorrect MIME structure found!");
	STAssertTrue([[multiPartContent objectAtIndex:0] isKindOfClass:[CTMIME_TextPart class]], 
					@"Incorrect MIME structure found!");
	STAssertTrue([[multiPartContent objectAtIndex:1] isKindOfClass:[CTMIME_SinglePart class]], 
					@"Incorrect MIME structure found!");
	CTMIME_SinglePart *img = [multiPartContent objectAtIndex:1];	
	STAssertTrue(img.attached == TRUE, @"Image is should be attached");
	STAssertEqualObjects(img.filename, @"Picture 1.png", @"Filename of inline image not correct");
	[msg release];
}

- (void)testEnumerator {
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestData/mime-tests/png_attachment" ofType:@""];
    CTCoreMessage *msg = [[CTCoreMessage alloc] initWithFileAtPath:filePath];

	CTMIME *mime = [CTMIMEFactory createMIMEWithMIMEStruct:
						[msg messageStruct]->msg_mime forMessage:[msg messageStruct]];
	CTMIME_Enumerator *enumerator = [mime mimeEnumerator];
	NSArray *allObjects = [enumerator allObjects];
	STAssertTrue([[allObjects objectAtIndex:0] isKindOfClass:[CTMIME_MessagePart class]], 
					@"Incorrect MIME structure found!");
	STAssertEqualObjects([[allObjects objectAtIndex:0] contentType], @"message/rfc822",
							@"found incorrect contentType");
	STAssertTrue([[allObjects objectAtIndex:1] isKindOfClass:[CTMIME_MultiPart class]], 
					@"Incorrect MIME structure found!");
	STAssertEqualObjects([[allObjects objectAtIndex:1] contentType], @"multipart/mixed",
							@"found incorrect contentType");					
	STAssertTrue([[allObjects objectAtIndex:2] isKindOfClass:[CTMIME_TextPart class]], 
					@"Incorrect MIME structure found!");
	STAssertEqualObjects([[allObjects objectAtIndex:2] contentType], @"text/plain",
							@"found incorrect contentType");					
	STAssertTrue([[allObjects objectAtIndex:3] isKindOfClass:[CTMIME_SinglePart class]], 
					@"Incorrect MIME structure found!");
	STAssertEqualObjects([[allObjects objectAtIndex:3] contentType], @"image/png",
							@"found incorrect contentType");															
	STAssertTrue([enumerator nextObject] == nil, @"Should have been nil");
	NSArray *fullAllObjects = allObjects;
	
	enumerator = [[mime content] mimeEnumerator];
	allObjects = [enumerator allObjects];
	STAssertTrue([[allObjects objectAtIndex:0] isKindOfClass:[CTMIME_MultiPart class]], 
					@"Incorrect MIME structure found!");
	STAssertTrue([[allObjects objectAtIndex:1] isKindOfClass:[CTMIME_TextPart class]], 
					@"Incorrect MIME structure found!");
	STAssertTrue([[allObjects objectAtIndex:2] isKindOfClass:[CTMIME_SinglePart class]], 
					@"Incorrect MIME structure found!");										
	STAssertTrue([enumerator nextObject] == nil, @"Should have been nil");
	
	enumerator = [[[[mime content] content] objectAtIndex:0] mimeEnumerator];
	allObjects = [enumerator allObjects];
	STAssertTrue([[allObjects objectAtIndex:0] isKindOfClass:[CTMIME_TextPart class]], 
					@"Incorrect MIME structure found!");	
	STAssertTrue([enumerator nextObject] == nil, @"Should have been nil");
	
	enumerator = [mime mimeEnumerator];
	NSMutableArray *objects = [NSMutableArray array];
	CTMIME *obj;
	while ((obj = [enumerator nextObject])) {
		[objects addObject:obj];
	}
	STAssertEqualObjects(objects, fullAllObjects, @"nextObject isn't iterating over the same objects ast allObjects");
}
@end
