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


#import "CTMIME_MessagePart.h"
#import <libetpan/libetpan.h>
#import "MailCoreTypes.h"
#import "CTMIMEFactory.h"

@implementation CTMIME_MessagePart
+ (id)mimeMessagePartWithContent:(CTMIME *)mime {
	return [[[CTMIME_MessagePart alloc] initWithContent:mime] autorelease];
}

- (id)initWithMIMEStruct:(struct mailmime *)mime 
			  forMessage:(struct mailmessage *)message {
	self = [super initWithMIMEStruct:mime forMessage:message];
	if (self) {
		struct mailmime *content = mime->mm_data.mm_message.mm_msg_mime;
		myMessageContent = [[CTMIMEFactory createMIMEWithMIMEStruct:content 
														 forMessage:message] retain];
		myFields = mime->mm_data.mm_message.mm_fields;
	}
	return self;
}

- (id)initWithContent:(CTMIME *)messageContent {
	self = [super init];
	if (self) {
		[self setContent:messageContent];
	}
	return self;
}

- (void)dealloc {
	[myMessageContent release];
	[super dealloc];
}

- (void)setContent:(CTMIME *)aContent {
	[aContent retain];
	[myMessageContent release];
	myMessageContent = aContent;
}

- (id)content {
	return myMessageContent;
}

- (struct mailmime *)buildMIMEStruct {
	struct mailmime *mime = mailmime_new_message_data([myMessageContent buildMIMEStruct]);
  	mailmime_set_imf_fields(mime, myFields);
	return mime;
}

- (void)setIMFFields:(struct mailimf_fields *)imfFields {
	myFields = imfFields;
}
@end
