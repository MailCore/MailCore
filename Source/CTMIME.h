#import <Cocoa/Cocoa.h>
#import "libetpan.h"

@interface CTMIME : NSObject {
}
- (id)initWithMIMEStruct:(struct mailmime *)mime forMessage:(struct mailmessage *)message;
- (id)content;
- (struct mailmime *)buildMIMEStruct;
- (NSString *)render;
@end
