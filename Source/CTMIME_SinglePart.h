#import <Cocoa/Cocoa.h>
#import "CTMIME.h"

@interface CTMIME_SinglePart : CTMIME {
}
- (NSData *)parsePart:(struct mailmime *)mime forMessage:(struct mailmessage *)message;
@end
