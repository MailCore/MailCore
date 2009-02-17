/*
 * Mailcore
 *
 * Copyright (C) 2009 - Matt Ronge
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

#import "CTCoreAccountTests.h"

NSString *SERVER = @"192.168.1.106";
NSString *USERNAME = @"test";
NSString *PASSWORD = @"password";

@interface CTCoreAccountTests (CTCoreAccountTestsPrivate)
- (void)disconnect;
- (void)connect;
@end

@implementation CTCoreAccountTests
- (void)setUp {
    account = [[CTCoreAccount alloc] init];
    [self connect];
}

- (void)tearDown {
    [self disconnect];
    [account release];
}

- (void)testAllFolders {
    NSSet *folders = [account allFolders];
    NSSet *expectedFolders = [NSSet setWithObjects:@"ACM", @"Drafts", @"JDEE", @"Lucene", 
                                    @"Lucene-Dev", @"MacWarriors", @"Sent", @"Templates",
                                    @"TestMailbox", @"TestMailbox.SubMailbox", @"Trash", 
                                    @"INBOX", nil];
    STAssertEqualObjects(folders, expectedFolders, nil);
}

/*!
  Make sure every folder can be opened
*/
- (void)testOpenAllFolders {
    for (NSString *folderPath in [account allFolders]) {
        STAssertNotNil([account folderWithPath:folderPath], nil);
    }
}

- (void)testSubscribedFolders {
    NSSet *folders = [account subscribedFolders];
    NSSet *expectedFolders = [NSSet setWithObjects:@"Drafts", @"JDEE", @"Lucene", 
                                    @"Lucene-Dev", @"MacWarriors", @"Sent", @"Templates",
                                    @"TestMailbox", @"TestMailbox.SubMailbox", @"Trash", 
                                    @"INBOX", nil];
    STAssertEqualObjects(folders, expectedFolders, nil);
}

- (void)testIsConnected {
    STAssertEquals(YES, [account isConnected], nil);
    [self disconnect];
    STAssertEquals(NO, [account isConnected], nil);
    [self connect];
    STAssertEquals(YES, [account isConnected], nil);
}

- (void)connect {
    [account connectToServer:SERVER port:143 connectionType:CONNECTION_TYPE_PLAIN authType:IMAP_AUTH_TYPE_PLAIN
             login:USERNAME password:PASSWORD];
}

- (void)disconnect {
    [account disconnect];
}
@end
