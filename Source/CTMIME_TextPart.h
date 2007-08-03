#import <Cocoa/Cocoa.h>
#import "CTMIME_SinglePart.h"

@interface CTMIME_TextPart : CTMIME_SinglePart {
	NSString *myString;
}
+ (id)mimeTextPartWithString:(NSString *)str;
- (id)initWithString:(NSString *)string;
- (void)setString:(NSString *)str;
- (id)content;
@end
