#import <Cocoa/Cocoa.h>
#import "libetpan.h"

/*!
	@class	CTCoreMessage
	CTCoreMessage is how you work with messages. The easiest way to instantiate a CTCoreMessage
	is to first setup a CTCoreAccount object and then get a CTCoreFolder object and then use it's 
	convience method messageWithUID: to get a message object you can work with.
	
	Anything that begins with "fetch", requires that an active network connection is present.
*/

@class CTCoreFolder, CTCoreAddress, CTMIME;

@interface CTCoreMessage : NSObject {
	struct mailmessage *myMessage;
	struct mailimf_single_fields *myFields;
	CTMIME *myParsedMIME;
}
//TODO Parse this stuff: message_id, inReplyTo, references, comments, keywords, headers

/*!
	@abstract	Used to instantiate an empty message object.
*/
- (id)init;

/*!
	@abstract	Used to instantiate a message object with the contents of a mailmessage struct
				(a LibEtPan type). The mailmessage struct does not include any body information,
				so after calling this method the message will have a body which is NULL.
*/
- (id)initWithMessageStruct:(struct mailmessage *)message;

/*!
	@abstract	Used it instantiate a message object based off the contents of a file on disk.
				The file on disk must be a valid MIME message.
*/
- (id)initWithFileAtPath:(NSString *)path;

/*
	@abstract	Creates an empty message
*/
- (id)init;

/*!
	@abstract	This method fetches the message body off of the server, and places
				it in a local data structure which can later be returned by the
				method body. This method require that an active MailCore network
				connection is present.
*/
- (void)fetchBody;

/*!
	@abstract	This method returns the parsed message body as an NSString.
*/
- (NSString *)body;

/*!
	@abstract	This method sets the message body. Plaintext only please!
*/
- (void)setBody:(NSString *)body;

/*!
	@abstract	Returns the subject of the message.
*/
- (NSString *)subject;

/*!
	@abstract	Will set the subject of the message, use this when composing e-mail.
*/
- (void)setSubject:(NSString *)subject;

/*!
	@abstract	Return the date the message was sent. If a date wasn't included then
				a date from the distant past is used instead.
*/
- (NSCalendarDate *)sentDate;

/*!
	@abstract	Returns YES if the method is unread.
*/
- (BOOL)isNew;

/*!
	@abstract	Returns an NSString containing the messages UID.
*/
- (NSString *)uid;

/*!
	@abstract	Returns the message index, this number cannot be used across sessions
*/
- (NSUInteger)indexNumber;

/*!
	@abstract	Parses the from list, the result is an NSSet containing CTCoreAddress's
*/
- (NSSet *)from;

/*!
	@abstract	Sets the message's from addresses
	@param		addresses A NSSet containing CTCoreAddress's
*/
- (void)setFrom:(NSSet *)addresses;

/*!
	@abstract	Returns the sender, which isn't always the actual person who sent the message, it's usually the 
				address of the machine that sent the message. In reality, this method isn't very useful, use from: instead.
*/
- (CTCoreAddress *)sender;

/*!
	@abstract	Returns the list of people the message was sent to, returns an NSSet containing CTAddress's.
*/
- (NSSet *)to;

/*!
	@abstract	Sets the message's to addresses
	@param		addresses A NSSet containing CTCoreAddress's
*/
- (void)setTo:(NSSet *)addresses;

/*!
	@abstract	Returns the list of people the message was cced to, returns an NSSet containing CTAddress's.
*/
- (NSSet *)cc;

/*!
	@abstract	Sets the message's cc addresses
	@param		addresses A NSSet containing CTCoreAddress's
*/
- (void)setCc:(NSSet *)addresses;

/*!
	@abstract	Returns the list of people the message was bcced to, returns an NSSet containing CTAddress's.
*/
- (NSSet *)bcc;

/*!
	@abstract	Sets the message's bcc addresses
	@param		addresses A NSSet containing CTCoreAddress's
*/
- (void)setBcc:(NSSet *)addresses;

/*!
	@abstract	Returns the list of people the message was in reply-to, returns an NSSet containing CTAddress's.
*/
- (NSSet *)replyTo;

/*!
	@abstract	Sets the message's reply to addresses
	@param		addresses A NSSet containing CTCoreAddress's
*/
- (void)setReplyTo:(NSSet *)addresses;

/*!
	@abstract	Returns the message rendered as the appropriate MIME and IMF content. Use this only if you
				want the raw encoding of the message. Since the data is ASCII data, if you'd really like
				you can put this in a string and display it.
*/
- (NSString *)render;

/* Intended for advanced use only */
- (struct mailmessage *)messageStruct;
@end
