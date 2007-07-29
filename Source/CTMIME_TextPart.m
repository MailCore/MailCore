#import "CTMIME_TextPart.h"

#import "libetpan.h"
#import "MailCoreTypes.h"

@implementation CTMIME_TextPart
+ (id)mimeTextPartWithString:(NSString *)str {
	return [[[CTMIME_TextPart alloc] initWithString:str] autorelease];
}

- (id)initWithMIMEStruct:(struct mailmime *)mime forMessage:(struct mailmessage *)message {
	self = [super init];
	if (self) {
		struct mailmime_single_fields *mimeFields = NULL;
		
		int encoding = MAILMIME_MECHANISM_8BIT;
		mimeFields = mailmime_single_fields_new(mime->mm_mime_fields, mime->mm_content_type);
		if (mimeFields != NULL && mimeFields->fld_encoding != NULL)
			encoding = mimeFields->fld_encoding->enc_type;
		
		char *fetchedData;
		size_t fetchedDataLen;
		int r = mailmessage_fetch_section(message, mime, &fetchedData, &fetchedDataLen);
		if (r != MAIL_NO_ERROR) {
			mailmessage_fetch_result_free(message, fetchedData);
			RaiseException(CTMIMEParseError, CTMIMEParseErrorDesc);
		}

		size_t current_index = 0;
		char * result;
		size_t result_len;
		r = mailmime_part_parse(fetchedData, fetchedDataLen, &current_index, encoding, &result, &result_len);
		if (r != MAILIMF_NO_ERROR) {
			mailmime_decoded_part_free(result);
			RaiseException(CTMIMEParseError, CTMIMEParseErrorDesc);
		}
		myString = [[NSString alloc] initWithBytes:result length:result_len encoding:NSASCIIStringEncoding];
		mailmessage_fetch_result_free(message, fetchedData);
		mailmime_decoded_part_free(result);
		mailmime_single_fields_free(mimeFields);
	}
	return self;		
}

- (id)initWithString:(NSString *)string {
	self = [super init];
	if (self) {
		myString = [string retain];
	}
	return self;
}

- (void)dealloc {
	[myString release];
	[super dealloc];
}

- (id)content {
	return myString;
}

- (void)setString:(NSString *)str {
	[str retain];
	[myString release];
	myString = str;
}

- (struct mailmime *)buildMIMEStruct {
	struct mailmime_fields *mime_fields;
	struct mailmime *mime_sub;
	struct mailmime_content *content;
	struct mailmime_parameter *param;
	int r;

	/* text/plain part */

	mime_fields = mailmime_fields_new_encoding(MAILMIME_MECHANISM_8BIT);
	assert(mime_fields != NULL);

	content = mailmime_content_new_with_str("text/plain");
	assert(content != NULL);

	param = mailmime_parameter_new(strdup("charset"), strdup(DEST_CHARSET));
	assert(param != NULL);
	
	r = clist_append(content->ct_parameters, param);
	assert(r >= 0);

	mime_sub = mailmime_new_empty(content, mime_fields);
	assert(mime_sub != NULL);
	r = mailmime_set_body_text(mime_sub, strdup([myString cStringUsingEncoding:NSASCIIStringEncoding]), [myString length]);
	assert(r == MAILIMF_NO_ERROR);
	return mime_sub;
}
@end
