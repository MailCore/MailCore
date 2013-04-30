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

#import <Foundation/Foundation.h>
#import "CTMIME.h"

typedef void (^CTProgressBlock)(size_t curr, size_t max);

typedef NS_OPTIONS(NSUInteger, CTMIMEAttachmentType) {
  CTMIMEAttachmentNonType = 0,
  CTMIMEAttachmentAttachedType = 1 << 0,
  CTMIMEAttachmentInlineType = 1 << 1
};


@interface CTMIME_SinglePart : CTMIME {
    struct mailmime *mMime;
    struct mailmessage *mMessage;
    struct mailmime_single_fields *mMimeFields;

    NSData *mData;
    BOOL mAttached;
    BOOL mInlined;
    BOOL mFetched;
    NSString *mFilename;
    NSString *mContentId;
    NSError *lastError;
}
@property(nonatomic) BOOL attached;
@property(nonatomic, getter = isInlined) BOOL inlined;
@property(nonatomic) BOOL fetched;
@property(nonatomic, retain) NSString *filename;
@property(nonatomic, retain) NSString *contentId;
@property(nonatomic, retain) NSData *data;
@property(nonatomic, readonly) size_t size;
@property(nonatomic, readonly) CTMIMEAttachmentType attachmentType;

/*
 If an error occurred (nil or return of NO) call this method to get the error
*/
@property(nonatomic, retain) NSError *lastError;

+ (id)mimeSinglePartWithData:(NSData *)data;
- (id)initWithData:(NSData *)data;
- (BOOL)fetchPart;
- (BOOL)fetchPartWithProgress:(CTProgressBlock)block;

// Advanced use only
- (struct mailmime_single_fields *)mimeFields;
@end
