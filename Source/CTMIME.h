#import <Cocoa/Cocoa.h>
#import "libetpan.h"

//TODO I need to use the mailmime_fields
@interface CTMIME : NSObject {
}
- (id)initWithMIMEStruct:(struct mailmime *)mime forMessage:(struct mailmessage *)message;
- (id)content;
- (struct mailmime *)buildMIMEStruct;
- (NSString *)render;
@end
