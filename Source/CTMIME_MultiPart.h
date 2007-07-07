#import <Cocoa/Cocoa.h>
#import "CTMIME.h"

@interface CTMIME_MultiPart : CTMIME {
	NSMutableArray *myContentList;
}
+ (id)mimeMultiPart;
- (void)addMIMEPart:(CTMIME *)mime;
@end
