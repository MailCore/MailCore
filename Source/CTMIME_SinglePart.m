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

#import "CTMIME_SinglePart.h"

#import <libetpan/libetpan.h>
#import "MailCoreTypes.h"
#import "MailCoreUtilities.h"


static inline struct imap_session_state_data *
get_session_data(mailmessage * msg)
{
    return msg->msg_session->sess_data;
}

static inline mailimap * get_imap_session(mailmessage * msg)
{
    return get_session_data(msg)->imap_session;
}

static void download_progress_callback(size_t current, size_t maximum, void * context) {
    CTProgressBlock block = context;
    block(current, maximum);
}

@implementation CTMIME_SinglePart
@synthesize attached=mAttached;
@synthesize filename=mFilename;
@synthesize contentId=mContentId;
@synthesize data=mData;
@synthesize fetched=mFetched;

+ (id)mimeSinglePartWithData:(NSData *)data {
    return [[[CTMIME_SinglePart alloc] initWithData:data] autorelease];
}

- (id)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        self.data = data;
        self.fetched = YES;
    }
    return self;
}

- (id)initWithMIMEStruct:(struct mailmime *)mime 
        forMessage:(struct mailmessage *)message {
    self = [super initWithMIMEStruct:mime forMessage:message];
    if (self) {
        self.data = nil;
        mMime = mime;
        mMessage = message;
        self.fetched = NO;

        mMimeFields = mailmime_single_fields_new(mMime->mm_mime_fields, mMime->mm_content_type);
        if (mMimeFields != NULL) {
            struct mailmime_disposition *disp = mMimeFields->fld_disposition;
            if (disp != NULL) {
                if (disp->dsp_type != NULL) {
                    self.attached = (disp->dsp_type->dsp_type ==
                                        MAILMIME_DISPOSITION_TYPE_ATTACHMENT);

                    if (self.attached)
                    {
                        // MWA workaround for bug where specific emails look like this:
                        // Content-Type: application/vnd.ms-excel; name="=?UTF-8?B?TVhBVC0zMTFfcGFja2xpc3QxMTA0MDAueGxz?="
                        // Content-Disposition: attachment
                        // - usually they look like -
                        // Content-Type: image/jpeg; name="photo.JPG"
                        // Content-Disposition: attachment; filename="photo.JPG"
                        if (mMimeFields->fld_disposition_filename == NULL && mMimeFields->fld_content_name != NULL)
                            mMimeFields->fld_disposition_filename = mMimeFields->fld_content_name;
                    }
                }
            }

            if (mMimeFields->fld_disposition_filename != NULL) {
                self.filename = [NSString stringWithCString:mMimeFields->fld_disposition_filename encoding:NSUTF8StringEncoding];

                if (mMimeFields->fld_id != NULL)
                    self.contentId = [NSString stringWithCString:mMimeFields->fld_id encoding:NSUTF8StringEncoding]; 

                NSString* lowercaseName = [self.filename lowercaseString];
                if([lowercaseName hasSuffix:@".xls"] ||
                    [lowercaseName hasSuffix:@".xlsx"] ||
                    [lowercaseName hasSuffix:@".key.zip"] ||
                    [lowercaseName hasSuffix:@".numbers.zip"] ||
                    [lowercaseName hasSuffix:@".pages.zip"] ||
                    [lowercaseName hasSuffix:@".pdf"] ||
                    [lowercaseName hasSuffix:@".ppt"] ||
                    [lowercaseName hasSuffix:@".doc"] ||
                    [lowercaseName hasSuffix:@".docx"] ||
                    [lowercaseName hasSuffix:@".rtf"] ||
                    [lowercaseName hasSuffix:@".rtfd.zip"] ||
                    [lowercaseName hasSuffix:@".key"] ||
                    [lowercaseName hasSuffix:@".numbers"] ||
                    [lowercaseName hasSuffix:@".pages"] ||
                    [lowercaseName hasSuffix:@".png"] ||
                    [lowercaseName hasSuffix:@".gif"] ||
                    [lowercaseName hasSuffix:@".png"] ||
                    [lowercaseName hasSuffix:@".jpg"] ||
                    [lowercaseName hasSuffix:@".jpeg"] ||
                    [lowercaseName hasSuffix:@".tiff"]) { // hack by gabor, improved by waseem, based on http://developer.apple.com/iphone/library/qa/qa2008/qa1630.html
                    self.attached = YES;
                }
            }

        }
    }
    return self;
}

- (void)fetchPartWithProgress:(CTProgressBlock)block {
    if (self.fetched == NO) {
        struct mailmime_single_fields *mimeFields = NULL;

        int encoding = MAILMIME_MECHANISM_8BIT;
        mimeFields = mailmime_single_fields_new(mMime->mm_mime_fields, mMime->mm_content_type);
        if (mimeFields != NULL && mimeFields->fld_encoding != NULL)
            encoding = mimeFields->fld_encoding->enc_type;

        char *fetchedData;
        size_t fetchedDataLen;
        int r;

        if (mMessage->msg_session != NULL) {
            mailimap_set_progress_callback(get_imap_session(mMessage), &download_progress_callback, NULL, block);  
        }
        r = mailmessage_fetch_section(mMessage, mMime, &fetchedData, &fetchedDataLen);
        if (mMessage->msg_session != NULL) {
            mailimap_set_progress_callback(get_imap_session(mMessage), NULL, NULL, NULL); 
        }
        if (r != MAIL_NO_ERROR) {
            mailmessage_fetch_result_free(mMessage, fetchedData);
            RaiseException(CTMIMEParseError, CTMIMEParseErrorDesc);
        }


        size_t current_index = 0;
        char * result;
        size_t result_len;
        r = mailmime_part_parse(fetchedData, fetchedDataLen, &current_index,
                                    encoding, &result, &result_len);
        if (r != MAILIMF_NO_ERROR) {
            mailmime_decoded_part_free(result);
            RaiseException(CTMIMEParseError, CTMIMEParseErrorDesc);
        }
        NSData *data = [NSData dataWithBytes:result length:result_len];
        mailmessage_fetch_result_free(mMessage, fetchedData);
        mailmime_decoded_part_free(result);
        mailmime_single_fields_free(mimeFields);
        self.data = data;
        self.fetched = YES;
    }
}

- (void)fetchPart {
    [self fetchPartWithProgress:^(size_t curr, size_t max){}];
}

- (struct mailmime *)buildMIMEStruct {
    struct mailmime_fields *mime_fields;
    struct mailmime *mime_sub;
    struct mailmime_content *content;
    int r;

    if( mFilename )
    {
        mime_fields = mailmime_fields_new_filename( MAILMIME_DISPOSITION_TYPE_ATTACHMENT, 
                                                    (char *)[mFilename cStringUsingEncoding:NSUTF8StringEncoding], 
                                                    MAILMIME_MECHANISM_BASE64 ); 
    }
    else 
    {
        mime_fields = mailmime_fields_new_encoding(MAILMIME_MECHANISM_BASE64);
    }

    assert(mime_fields != NULL);

    content = mailmime_content_new_with_str([self.contentType cStringUsingEncoding:NSUTF8StringEncoding]);
    assert(content != NULL);

    mime_sub = mailmime_new_empty(content, mime_fields);
    assert(mime_sub != NULL);

    // Add Data
    r = mailmime_set_body_text(mime_sub, (char *)[self.data bytes], [self.data length]);
    assert(r == MAILIMF_NO_ERROR);
    return mime_sub;
}

- (size_t)size {
    if (mMime) {
        return mMime->mm_length;
    }
    return 0;
}


- (void)dealloc {
    mailmime_single_fields_free(mMimeFields);
    [mData release];
    [mFilename release];
    [mContentId release];
    //The structs are held by CTCoreMessage so we don't have to free them
    [super dealloc];
}
@end
