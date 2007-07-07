#import <Cocoa/Cocoa.h>
#import "CTMIME.h"


@interface CTMIME_MessagePart : CTMIME {
	CTMIME *myMessageContent;
	struct mailimf_fields *myFields;
}
+ (id)mimeMessagePartWithContent:(CTMIME *)mime;
- (id)initWithContent:(CTMIME *)messageContent;
- (void)setContent:(CTMIME *)aContent;
- (void)setIMFFields:(struct mailimf_fields *)imfFields;
@end
