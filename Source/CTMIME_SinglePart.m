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

@implementation CTMIME_SinglePart
@synthesize attached=mAttached;
@synthesize filename=mFilename;
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
				}
			}
			
			if (mMimeFields->fld_disposition_filename != NULL) {
				self.filename = [NSString stringWithCString:mMimeFields->fld_disposition_filename encoding:NSUTF8StringEncoding];
				NSString* lowercaseName = [self.filename lowercaseString];
				if([lowercaseName hasSuffix:@".pdf"] ||
					[lowercaseName hasSuffix:@".jpg"] ||
					[lowercaseName hasSuffix:@".png"] ||
					[lowercaseName hasSuffix:@".gif"]) { // hack by gabor
					self.attached = YES;
				}
			}

		}
	}
	return self;
}

- (void)fetchPart {
	if (self.fetched == NO) {
		struct mailmime_single_fields *mimeFields = NULL;
		
		int encoding = MAILMIME_MECHANISM_8BIT;
		mimeFields = mailmime_single_fields_new(mMime->mm_mime_fields, mMime->mm_content_type);
		if (mimeFields != NULL && mimeFields->fld_encoding != NULL)
			encoding = mimeFields->fld_encoding->enc_type;
		
		char *fetchedData;
		size_t fetchedDataLen;
		int r;
		r = mailmessage_fetch_section(mMessage, mMime, &fetchedData, &fetchedDataLen);
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

//TODO need to do content disposition
- (struct mailmime *)buildMIMEStruct {
	struct mailmime_fields *mime_fields;
	struct mailmime *mime_sub;
	struct mailmime_content *content;
	int r;

	mime_fields = mailmime_fields_new_encoding(MAILMIME_MECHANISM_BASE64);
	assert(mime_fields != NULL);

	content = mailmime_content_new_with_str([self.contentType cStringUsingEncoding:NSUTF8StringEncoding]);
	assert(content != NULL);
	mime_sub = mailmime_new_empty(content, mime_fields);
	assert(mime_sub != NULL);
	r = mailmime_set_body_text(mime_sub, (char *)[self.data bytes], [self.data length]);
	assert(r == MAILIMF_NO_ERROR);
	return mime_sub;
}


- (void)dealloc {
	mailmime_single_fields_free(mMimeFields);
	[mData release];
	[mFilename release];
	//The structs are held by CTCoreMessage so we don't have to free them
	[super dealloc];
}
@end
