#import <Cocoa/Cocoa.h>

//TODO put headers on all these files

//TODO Document me
@interface CTBareMessage : NSObject {
	NSString *mUid;
	NSUInteger mFlags;
}
@property(retain) NSString *uid;
@property NSUInteger flags;

- (id)init;
@end
