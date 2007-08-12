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

#import "CTCoreAttachmentTests.h"


@implementation CTCoreAttachmentTests
- (void)testJPEG {
	NSString *path = [NSString stringWithFormat:@"%@%@",filePrefix,@"TestData/DSC_6201.jpg"];
	CTCoreAttachment *attach = [[CTCoreAttachment alloc] initWithContentsOfFile:path];
	STAssertEqualObjects(@"image/jpeg", [attach contentType], @"The content-type should have been image/jpeg");
	STAssertTrue([attach data] != nil, @"Data should not have been nil");
	[attach release];
}

- (void)testPNG {
	NSString *path = [NSString stringWithFormat:@"%@%@",filePrefix,@"TestData/DSC_6202.png"];
	CTCoreAttachment *attach = [[CTCoreAttachment alloc] initWithContentsOfFile:path];
	STAssertEqualObjects(@"image/png", [attach contentType], @"The content-type should have been image/png");
	STAssertTrue([attach data] != nil, @"Data should not have been nil");
	[attach release];
}

- (void)testTIFF {
	NSString *path = [NSString stringWithFormat:@"%@%@",filePrefix,@"TestData/DSC_6193.tif"];
	CTCoreAttachment *attach = [[CTCoreAttachment alloc] initWithContentsOfFile:path];
	STAssertEqualObjects(@"image/tiff", [attach contentType], @"The content-type should have been image/TIFF");
	STAssertTrue([attach data] != nil, @"Data should not have been nil");
	[attach release];
}

- (void)testNEF {
	NSString *path = [NSString stringWithFormat:@"%@%@",filePrefix,@"TestData/DSC_6204.NEF"];
	CTCoreAttachment *attach = [[CTCoreAttachment alloc] initWithContentsOfFile:path];
	STAssertEqualObjects(@"application/octet-stream", [attach contentType], @"The content-type should have been application/octet-stream");
	STAssertTrue([attach data] != nil, @"Data should not have been nil");
	[attach release];
}
@end
