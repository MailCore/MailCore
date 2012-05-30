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


#import "CTCoreAddress.h"
#import "MailCoreUtilities.h"

@implementation CTCoreAddress
+ (id)address {
    CTCoreAddress *aAddress = [[CTCoreAddress alloc] init];
    return [aAddress autorelease];
}


+ (id)addressWithName:(NSString *)aName email:(NSString *)aEmail {
    CTCoreAddress *aAddress = [[CTCoreAddress alloc] initWithName:aName email:aEmail];
    return [aAddress autorelease];
}


- (id)initWithName:(NSString *)aName email:(NSString *)aEmail {
    self = [super init];
    if (self) {
        [self setName:aName];
        [self setEmail:aEmail];
    }
    return self;
}


- (id)init {
    self = [super init];
    if (self) {
        [self setName:@""];
        [self setEmail:@""];
    }
    return self;
}


-(NSString*)decodedName {
    return MailCoreDecodeMIMEPhrase((char *)[self.name UTF8String]);
}

- (NSString *)name {
    return name;
}


- (void)setName:(NSString *)aValue {
    NSString *oldName = name;
    name = [aValue retain];
    [oldName release];
}


- (NSString *)email {
    return email;
}


- (void)setEmail:(NSString *)aValue {
    NSString *oldEmail = email;
    email = [aValue retain];
    [oldEmail release];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<%@,%@>", [self name],[self email]];
}


- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[CTCoreAddress class]])
        return NO;
    return [[object name] isEqualToString:[self name]] && [[object email] isEqualToString:[self email]];
}

- (void)dealloc {
    [email release];
    [name release];
    [super dealloc];
}
@end
