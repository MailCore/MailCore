#import <Cocoa/Cocoa.h>

@class CTMIME, CTMIME_SinglePart;

@interface CTMIMEFactory : NSObject {

}
+ (CTMIME *)createMIMEWithMIMEStruct:(struct mailmime *)mime 
				forMessage:(struct mailmessage *)message;
+ (CTMIME_SinglePart *)createMIMESinglePartWithMIMEStruct:(struct mailmime *)mime
						forMessage:(struct mailmessage *)message;
@end
