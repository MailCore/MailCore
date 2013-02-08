/*
 * Mailcore
 *
 * Copyright (C) 2012 - Matt Ronge
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

#import <MailCore/MailCore.h>
#import "CTCoreFolderTests.h"

@implementation CTCoreFolderTests {

}

- (void)testFetchOnlyDefaults {
    NSArray *messages = [self.folder messagesFromSequenceNumber:1 to:0 withFetchAttributes:CTFetchAttrDefaultsOnly];
    STAssertTrue(messages.count == 6, @"");
    CTCoreMessage *msg = [messages objectAtIndex:0];
    STAssertTrue([msg uid] > 0, @"We should have the UID");
    STAssertTrue([msg messageSize] > 0, @"We always download message size");

    STAssertNil([msg senderDate], @"We have no envelope so should be nil");
    STAssertNil([msg subject], @"We have no envelope so should be nil");
    STAssertNil([msg to], @"We have no envelope so should be nil");
    STAssertNil([msg cc], @"We have no envelope so should be nil");
    STAssertNil([msg sender], @"We have no envelope so should be nil");
    STAssertNil([msg from], @"We have no envelope so should be nil");
    STAssertNil([msg bcc], @"We have no envelope so should be nil");

    // This will force another download of message body data, checking to make sure it works
    NSString *body = [msg body];
    STAssertTrue(body.length > 0, @"");
}

- (void)testFetchEnvelope {
    NSArray *messages = [self.folder messagesFromSequenceNumber:1 to:0 withFetchAttributes:CTFetchAttrEnvelope];
    STAssertTrue(messages.count == 6, @"");
    CTCoreMessage *msg = [messages objectAtIndex:0];
    STAssertTrue([msg uid] > 0, @"We should have the UID");
    STAssertTrue([msg messageSize] > 0, @"We always download message size");

    STAssertNotNil([msg senderDate], @"We DO HAVE AN envelope so shouldn't be nil");
    STAssertNotNil([msg subject], @"We DO HAVE AN envelope so shouldn't be nil");
    STAssertNotNil([msg to], @"We DO HAVE AN envelope so shouldn't be nil");
    STAssertNotNil([msg sender], @"We DO HAVE AN envelope so shouldn't be nil");
    STAssertNotNil([msg from], @"We DO HAVE AN envelope so shouldn't be nil");

    // This will force another download of message body data, checking to make sure it works
    NSString *body = [msg body];
    STAssertTrue(body.length > 0, @"");
}

- (void)testFetchEnvelopeUsingUIDFetch {
    NSArray *messages = [self.folder messagesFromUID:1 to:0 withFetchAttributes:CTFetchAttrEnvelope];
    STAssertTrue(messages.count == 6, @"");
    CTCoreMessage *msg = [messages objectAtIndex:0];
    STAssertTrue([msg uid] > 0, @"We should have the UID");
    STAssertTrue([msg messageSize] > 0, @"We always download message size");

    STAssertNotNil([msg senderDate], @"We DO HAVE AN envelope so shouldn't be nil");
    STAssertNotNil([msg subject], @"We DO HAVE AN envelope so shouldn't be nil");
    STAssertNotNil([msg to], @"We DO HAVE AN envelope so shouldn't be nil");
    STAssertNotNil([msg sender], @"We DO HAVE AN envelope so shouldn't be nil");
    STAssertNotNil([msg from], @"We DO HAVE AN envelope so shouldn't be nil");

    // This will force another download of message body data, checking to make sure it works
    NSString *body = [msg body];
    STAssertTrue(body.length > 0, @"");
}

- (void)testFetchBodyStructure {
    NSArray *messages = [self.folder messagesFromSequenceNumber:1 to:0 withFetchAttributes:CTFetchAttrBodyStructure];
    STAssertTrue(messages.count == 6, @"");
    CTCoreMessage *msg = [messages objectAtIndex:0];
    STAssertTrue([msg uid] > 0, @"We should have the UID");
    STAssertTrue([msg messageSize] > 0, @"We always download message size");

    STAssertNil([msg senderDate], @"We have no envelope so should be nil");
    STAssertNil([msg subject], @"We have no envelope so should be nil");
    STAssertNil([msg to], @"We have no envelope so should be nil");
    STAssertNil([msg cc], @"We have no envelope so should be nil");
    STAssertNil([msg sender], @"We have no envelope so should be nil");
    STAssertNil([msg from], @"We have no envelope so should be nil");
    STAssertNil([msg bcc], @"We have no envelope so should be nil");

    // A second call to fetch the body structure shouldn't be needed, we only need to fetch body
    NSString *body = [msg body];
    STAssertTrue(body.length > 0, @"");
}

- (void)testFetchEverything {
    NSArray *messages = [self.folder messagesFromSequenceNumber:1 to:0 withFetchAttributes:CTFetchAttrEnvelope | CTFetchAttrBodyStructure];
    STAssertTrue(messages.count == 6, @"");
    CTCoreMessage *msg = [messages objectAtIndex:0];
    STAssertTrue([msg uid] > 0, @"We should have the UID");
    STAssertTrue([msg messageSize] > 0, @"We always download message size");

    STAssertNotNil([msg senderDate], @"We DO HAVE AN envelope so shouldn't be nil");
    STAssertNotNil([msg subject], @"We DO HAVE AN envelope so shouldn't be nil");
    STAssertNotNil([msg to], @"We DO HAVE AN envelope so shouldn't be nil");
    STAssertNotNil([msg sender], @"We DO HAVE AN envelope so shouldn't be nil");
    STAssertNotNil([msg from], @"We DO HAVE AN envelope so shouldn't be nil");

    // A second call to fetch the body structure shouldn't be needed, we only need to fetch body
    NSString *body = [msg body];
    STAssertTrue(body.length > 0, @"");
}
@end
