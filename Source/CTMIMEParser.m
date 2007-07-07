#import "CTMIMEParser.h"

@implementation CTMIMEParser

+ (NSString *)decodeMIMEPhrase:(char *)data {
	int err;
	size_t currToken = 0;
	char *decodedSubject;
	NSString *result;
	
	err = mailmime_encoded_phrase_parse(DEST_CHARSET, data, strlen(data),
		&currToken, DEST_CHARSET, &decodedSubject);
		
	if (err != MAILIMF_NO_ERROR) {
		if (decodedSubject == NULL)
			free(decodedSubject);
		return nil;
	}
		
	result = [NSString stringWithCString:decodedSubject encoding:NSASCIIStringEncoding];
	free(decodedSubject);
	return result;
}


+ (BOOL)isMIMEText:(struct mailmime *)mimeStruct {
	/* Taken from Libetpan from ./tests/readmsg-common.c
	   Logic has been cleaned up */
	
	if (mimeStruct->mm_type != MAILMIME_SINGLE)
		return NO;

	if (mimeStruct->mm_content_type == NULL) 
		return YES;
		
	if (mimeStruct->mm_content_type->ct_type->tp_type == MAILMIME_TYPE_DISCRETE_TYPE) {
		if (mimeStruct->mm_content_type->ct_type->tp_data.tp_discrete_type->dt_type
				==MAILMIME_DISCRETE_TYPE_TEXT)
			return YES;
	}
	return NO;
}


+ (NSString *)decodeMIMESubType:(struct mailmime *)data {
	struct mailmime_content *content;
	char *subType;
	
	content = data->mm_content_type;
	if (content != NULL) {
		subType = content->ct_subtype;
		return [NSString stringWithCString:subType encoding:NSASCIIStringEncoding];
	}
	return nil;
}
@end
