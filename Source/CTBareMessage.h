#import <Cocoa/Cocoa.h>


@interface CTBareMessage : NSObject {
	NSString *mUid;
	NSUInteger mFlags;
}
@property(retain) NSString *uid;
@property NSUInteger flags;

- (id)init;
@end
