#import "CTMIME_MultiPart.h"
#import "libetpan.h"
#import "MailCoreTypes.h"
#import "CTMIMEFactory.h"


@implementation CTMIME_MultiPart
+ (id)mimeMultiPart {
	return [[[CTMIME_MultiPart alloc] init] autorelease];
}

- (id)initWithMIMEStruct:(struct mailmime *)mime forMessage:(struct mailmessage *)message {
	self = [super init];
	if (self) {
		myContentList = [[NSMutableArray alloc] init];
 		clistiter *cur = clist_begin(mime->mm_data.mm_multipart.mm_mp_list);
		for (; cur != NULL; cur=clist_next(cur)) {
			CTMIME *content = [CTMIMEFactory createMIMEWithMIMEStruct:clist_content(cur) forMessage:message];
			if (content != nil) {
				[myContentList addObject:[content autorelease]];
			}
		}
	}
	return self;			
}

- (id)init {
	self = [super init];
	if (self) {
		myContentList = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	[myContentList release];
	[super dealloc];
}

- (void)addMIMEPart:(CTMIME *)mime {
	[myContentList addObject:mime];
}

- (id)content {
	return myContentList;
}

- (struct mailmime *)buildMIMEStruct {
	//TODO make this smarter so it builds different types other than multipart/mixed
	struct mailmime *mime = mailmime_multiple_new("multipart/mixed");

	NSEnumerator *enumer = [myContentList objectEnumerator];
	CTMIME *part;
	int r;
	while ((part = [enumer nextObject])) {
		r = mailmime_add_part(mime, [part buildMIMEStruct]);
		assert(r == 0);
	}
	return mime;
}
@end
