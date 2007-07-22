#import <Cocoa/Cocoa.h>

//TODO put headers on all these files

//TODO Document me
@interface CTBareMessage : NSObject {
	NSString *mUid;
	unsigned int mFlags;
}
@property(retain) NSString *uid;
@property unsigned int flags;

- (id)init;
- (unsigned int)hash;
- (BOOL)isEqual:(id)anObject;
@end
