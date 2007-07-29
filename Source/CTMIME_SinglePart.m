#import "CTMIME_SinglePart.h"

#import "libetpan.h"
#import "MailCoreTypes.h"

@implementation CTMIME_SinglePart
- (NSData *)parsePart:(struct mailmime *)mime forMessage:(struct mailmessage *)message {
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
	NSData *data = [NSData dataWithBytes:result length:result_len];
	mailmessage_fetch_result_free(message, fetchedData);
	mailmime_decoded_part_free(result);
	mailmime_single_fields_free(mimeFields);
	return data;
}
@end
