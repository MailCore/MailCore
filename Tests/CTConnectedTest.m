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
@synthesize account, folder, credentials;

/* Create a TestData/account.plist file to make these tests work. Start with this:
 
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>username</key>
    <string>username</string>
    <key>password</key>
    <string>password</string>
    <key>server</key>
    <string>server</string>
    <key>port</key>
    <integer>993</integer>
    <key>path</key>
    <string>MailCoreTests</string>
</dict>
</plist>

Because account.plist is included in the .gitignore file, your credentials won't be added
to source control.

*/
- (void)setUp {
    self.credentials = [NSDictionary dictionaryWithContentsOfFile:@"TestData/account.plist"];
    STAssertNotNil(self.credentials, @"These tests will fail anyway if they can't connect");
    
    self.account = [[CTCoreAccount alloc] init];
    [self connect];
    self.folder = [self.account folderWithPath:[self.credentials valueForKey:@"path"]];
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
    NSString *server = [self.credentials valueForKey:@"server"];
    int port = [[self.credentials objectForKey:@"port"] intValue];
    NSString *username = [self.credentials valueForKey:@"username"];
    NSString *password = [self.credentials valueForKey:@"password"];

    STAssertFalse([server isEqualToString:@"server"], @"You need to provide your own account info");
    STAssertFalse([username isEqualToString:@"username"], @"You need to provide your own account info");
    STAssertFalse([password isEqualToString:@"password"], @"You need to provide your own account info");
    /* Once you've provided your own account info, create a folder with six messages in it.
       The path key in the account.plist should point to this directory, and you're ready! */
    
                   
    BOOL success = [self.account connectToServer:server port:port connectionType:CTConnectionTypeTLS authType:CTImapAuthTypePlain
            login:username password:password];
    
    STAssertTrue(success, @"should successfully connect to email account");
    if (!success) {
        NSLog(@"!!!!!!! Can't connect to account !!!!!!! Error: %@", [[self.account lastError] localizedDescription]);
    }
}

- (void)disconnect {
    [self.folder disconnect];
    [self.account disconnect];
}
@end