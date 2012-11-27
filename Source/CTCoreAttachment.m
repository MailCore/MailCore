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

#import "CTCoreAttachment.h"
#import "MailCoreTypes.h"


@implementation CTCoreAttachment
@synthesize data=mData;

- (id)initWithContentsOfFile:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *filePathExt = [path pathExtension];

    NSString *contentType = nil;
    NSString *typesPath = [[NSBundle mainBundle] pathForResource:@"types" ofType:@"plist"];
    NSDictionary *contentTypes = [NSDictionary dictionaryWithContentsOfFile:typesPath];
    for (NSString *key in [contentTypes allKeys]) {
        NSArray *fileExtensions = [contentTypes objectForKey:key];
        for (NSString *ext in fileExtensions) {
            if ([filePathExt isEqual:ext]) {
                contentType = key;
                break;
            }
        }
        if (contentType != nil)
            break;
    }

    // We couldn't find a content-type, set it to something generic
    if (contentType == nil) {
        contentType = @"application/octet-stream";
    }

    NSString *filename = [path lastPathComponent];
    return [self initWithData:data contentType:contentType filename:filename];
}

- (id)initWithData:(NSData *)data contentType:(NSString *)contentType 
        filename:(NSString *)filename {
    self = [super init];
    if (self) {
        self.data = data;
        self.contentType = contentType;
        self.filename = filename;
    }
    return self;
}

- (BOOL)writeToFile:(NSString *)path {
    return [mData writeToFile:path atomically:YES];
}

- (void)dealloc {
    [mData release];
    [super dealloc];
}
@end
