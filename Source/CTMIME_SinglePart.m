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

#import "libetpan.h"
#import "MailCoreTypes.h"

@implementation CTMIME_SinglePart
@synthesize attached=mAttached;
@synthesize filename=mFilename;
@synthesize data=mData;
@synthesize fetched=mFetched;

- (id)initWithMIMEStruct:(struct mailmime *)mime 
		forMessage:(struct mailmessage *)message {
	self = [super initWithMIMEStruct:mime forMessage:message];
	if (self) {
		self.data = nil;
		mMime = mime;
		mMessage = message;
		self.fetched = NO;
		
		struct mailmime_single_fields *mimeFields = NULL;		
		mimeFields = mailmime_single_fields_new(mMime->mm_mime_fields, mMime->mm_content_type);
		if (mimeFields != NULL) {
			struct mailmime_disposition *disp = mimeFields->fld_disposition;
			if (disp != NULL) {
				if (disp->dsp_type != NULL) {
					self.attached = (disp->dsp_type->dsp_type == 
										MAILMIME_DISPOSITION_TYPE_ATTACHMENT);
				}
			}
			
			if (mimeFields->fld_disposition_filename != NULL) {
				self.filename = [NSString stringWithCString:mimeFields->fld_disposition_filename 
									encoding:NSASCIIStringEncoding];
			}
			mailmime_single_fields_free(mimeFields);
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

- (void)dealloc {
	[mData release];
	[mFilename release];
	//The structs are held by CTCoreMessage so we don't have to free them
	[super dealloc];
}
@end
