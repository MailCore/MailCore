#import "CTMIME_MessagePart.h"
#import "libetpan.h"
#import "MailCoreTypes.h"
#import "CTMIMEFactory.h"

@implementation CTMIME_MessagePart
+ (id)mimeMessagePartWithContent:(CTMIME *)mime {
	return [[[CTMIME_MessagePart alloc] initWithContent:mime] autorelease];
}

- (id)initWithMIMEStruct:(struct mailmime *)mime 
		forMessage:(struct mailmessage *)message {
	self = [super init];
	if (self) {
		struct mailmime *content = mime->mm_data.mm_message.mm_msg_mime;
		myMessageContent = [CTMIMEFactory createMIMEWithMIMEStruct:content 
									forMessage:message];
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
