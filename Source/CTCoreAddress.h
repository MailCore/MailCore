#import <Cocoa/Cocoa.h>

/*!
	@class	@CTCoreAddress
	This is a very simple class designed to make it easier to work with email addresses since many times
	the e-mail address and name are both encoded in the MIME e-mail fields. This class should be very straight
	forward, you can get and set a name and an e-mail address.
*/

@interface CTCoreAddress : NSObject {
	NSString *email;
	NSString *name;
}
/*!
	@abstract Returns a CTCoreAddress with the name and e-mail address set as an empty string.
*/
+ (id)address;

/*!
	@abstract Returns a CTCoreAddress set with the specified name and email.
*/
+ (id)addressWithName:(NSString *)aName email:(NSString *)aEmail;

/*!
	@abstract Returns a CTCoreAddress set with the specified name and email.
*/
- (id)initWithName:(NSString *)aName email:(NSString *)aEmail;

/*!
	@abstract Returns the name as a NSString
*/
- (NSString *)name;

/*!
	@abstract Sets the name.
*/
- (void)setName:(NSString *)aValue;

/*!
	@abstract Returns the e-mail as a NSString
*/
- (NSString *)email;

/*!
	@abstract Sets the e-mail.
*/
- (void)setEmail:(NSString *)aValue;

/*!
	@abstract Works like the typical isEqual: method
*/
- (BOOL)isEqual:(id)object;

/*!
	@abstract Standard description method
*/
- (NSString *)description;

//TODO Do I need to overide: - (bool)isEqualTo:(id)object
@end
