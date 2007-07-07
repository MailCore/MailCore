#import "CTMIMEFactory.h"

#import "MailCoreTypes.h"
#import "libetpan.h"
#import "CTMIME_SinglePart.h"
#import "CTMIME_MessagePart.h"
#import "CTMIME_MultiPart.h"
#import "CTMIME_TextPart.h"
#import "CTMIME.h"

@implementation CTMIMEFactory
+ (CTMIME *)createMIMEWithMIMEStruct:(struct mailmime *)mime forMessage:(struct mailmessage *)message {
	if (mime == NULL) {
		RaiseException(CTMIMEParseError, CTMIMEParseErrorDesc);
	}
	
	CTMIME *content = nil;
	switch (mime->mm_type) {
		case MAILMIME_SINGLE:
			content = [CTMIMEFactory createMIMESinglePartWithMIMEStruct:mime forMessage:message];;
		break;
		case MAILMIME_MULTIPLE:
			content = [[CTMIME_MultiPart alloc] initWithMIMEStruct:mime forMessage:message];
		break;
		case MAILMIME_MESSAGE:
			content = [[CTMIME_MessagePart alloc] initWithMIMEStruct:mime forMessage:message];
		break;
	}
	return content;
}

+ (CTMIME_SinglePart *)createMIMESinglePartWithMIMEStruct:(struct mailmime *)mime forMessage:(struct mailmessage *)message {
	struct mailmime_type *aType = mime->mm_content_type->ct_type;
	if (aType->tp_type != MAILMIME_TYPE_DISCRETE_TYPE) {
		/* What do you do with a composite single part? */
		return nil;
	}
	CTMIME_SinglePart *content = nil;
	switch (aType->tp_data.tp_discrete_type->dt_type) {
		case MAILMIME_DISCRETE_TYPE_TEXT:
			content = [[CTMIME_TextPart alloc] initWithMIMEStruct:mime forMessage:message];
		break;
	}
	return content;
}
@end 
