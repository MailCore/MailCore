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
 * 3. Neither the name of the libEtPan! project nor the names of its
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

#import "CTMIME_ImagePart.h"


@implementation CTMIME_ImagePart
- (id)initWithMIMEStruct:(struct mailmime *)mime forMessage:(struct mailmessage *)message {
	self = [super init];
	if (self) {
		NSData *data = [self parsePart:mime forMessage:message];
		mImage = [[NSImage alloc] initWithData:data];
	}
	return self;		
}

- (id)content {
	return mImage;
}

- (void)setImage:(NSImage *)image {
	[image release];
	[mImage release];
	mImage = image;
}

- (struct mailmime *)buildMIMEStruct {
//	struct mailmime_fields *mime_fields;
//	struct mailmime *mime_sub;
//	struct mailmime_content *content;
//	struct mailmime_parameter *param;
//	int r;
//
//	/* text/plain part */
//
//	mime_fields = mailmime_fields_new_encoding(MAILMIME_MECHANISM_8BIT);
//	assert(mime_fields != NULL);
//
//	content = mailmime_content_new_with_str("image/jpeg");
//	assert(content != NULL);
//
//	param = mailmime_parameter_new(strdup("charset"), strdup(DEST_CHARSET));
//	assert(param != NULL);
//	
//	r = clist_append(content->ct_parameters, param);
//	assert(r >= 0);
//
//	mime_sub = mailmime_new_empty(content, mime_fields);
//	assert(mime_sub != NULL);
//	r = mailmime_set_body_text(mime_sub, strdup([myString cStringUsingEncoding:NSASCIIStringEncoding]), [myString length]);
//	assert(r == MAILIMF_NO_ERROR);
//	return mime_sub;
}

- (void)dealloc {
	[mImage release];
	[super dealloc];
}
@end
