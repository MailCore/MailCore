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
#import "CTConnectedTest.h"
#import "CTCoreAccount.h"

@implementation CTConnectedTest {
}
@synthesize account, folder;
NSString *SERVER = @"imap.gmail.com";
NSString *USERNAME = @"mailcoretests@gmail.com";
NSString *PASSWORD = @"MailCoreRockz";

- (void)setUp {
    self.account = [[CTCoreAccount alloc] init];
    [self connect];
    self.folder = [self.account folderWithPath:@"Test"];
    [self.folder connect];
}

- (void)tearDown {
    [self disconnect];
    self.folder = nil;
    self.account = nil;
}

- (void)dealloc {
    self.folder = nil;
    self.account = nil;
    [super dealloc];
}

- (void)connect {
    [self.account connectToServer:SERVER port:993 connectionType:CTConnectionTypeTLS authType:CTImapAuthTypePlain
             login:USERNAME password:PASSWORD];
}

- (void)disconnect {
    [self.folder disconnect];
    [self.account disconnect];
}
@end