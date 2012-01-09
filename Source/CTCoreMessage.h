/*
 * MailCore
 *
 * Copyright (C) 2007 - Matt Ronge
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the MailCore project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#import <libetpan/libetpan.h>

/*!
	@class	CTCoreMessage
	CTCoreMessage is how you work with messages. The easiest way to instantiate a CTCoreMessage
	is to first setup a CTCoreAccount object and then get a CTCoreFolder object and then use it's 
	convience method messageWithUID: to get a message object you can work with.
	
	Anything that begins with "fetch", requires that an active network connection is present.
*/

@class CTCoreFolder, CTCoreAddress, CTCoreAttachment, CTMIME;

@interface CTCoreMessage : NSObject {
	struct mailmessage *myMessage;
	struct mailimf_single_fields *myFields;
	CTMIME *myParsedMIME;
	NSUInteger mySequenceNumber;
}
@property(retain) CTMIME *mime;

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
	@abstract	Used to instantiate a message object based off the contents of a file on disk.
				The file on disk must be a valid MIME message.
*/
- (id)initWithFileAtPath:(NSString *)path;

/*!
	@abstract Used to instantiate a message object based off a string
            	that contains a valid MIME message
*/
- (id)initWithString:(NSString *)msgData;

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
- (int)fetchBody;

/*!
	@abstract	This method returns the parsed message body as an NSString.
				This attempts to return a plain text body and skips HTML. If
				a plaintext body isn't found the HTML body is returned.
*/
- (NSString *)body;

/*!
 @abstract	This method returns the html body as an NSString.
 */
- (NSString *)htmlBody;

/*!
 @abstract	This method returns the editable html body as an NSString.
 */
- (NSString *)editableHtmlBody;

/*!  @abstract Returns a message body as an NSString. First attempts
               to retrieve a plain text body, if that fails then
               tries for an HTML body.
 */
- (NSString *)bodyPreferringPlainText;

/*!
	@abstract	This method sets the message body. Plaintext only please!
*/
- (void)setBody:(NSString *)body;

- (void) setHTMLBody:(NSString *)body

- (NSArray *)attachments;
- (void)addAttachment:(CTCoreAttachment *)attachment;

/*!
	@abstract	Returns the subject of the message.
*/
- (NSString *)subject;

/*!
	@abstract	Will set the subject of the message, use this when composing e-mail.
*/
- (void)setSubject:(NSString *)subject;

/*! returns the timezone of the sender of the message (got from the Date field timezone attribute) */
- (NSTimeZone*)senderTimeZone;

/*! @abstract returns the date as given in the Date mail field (no timezone is applied) */
- (NSDate *)senderDate; 

/*! @abstract returns the date in the Date field converted to GMT */
- (NSDate *)sentDateGMT; 

/*!
    @abstract returns the date in the Date field converted to the local timezone
    the local timezone is the one set in the device running this code
 */
- (NSDate *)sentDateLocalTimeZone; 

/*!
 @abstract	Returns YES if the message is unread.
 */
- (BOOL)isUnread;

/*!
 @abstract	Returns YES if the message is recent and unread.
*/
- (BOOL)isNew;

/*!
	@abstract A machine readable ID that is guaranteed unique by the
	host that generated the messaeg
*/
- (NSString *)messageId;

/*!
	@abstract	Returns an NSString containing the messages UID.
*/
- (NSString *)uid;

/*!
	@abstract	Returns the message sequence number, this number cannot be used across sessions
*/
- (NSUInteger)sequenceNumber;

/*!
 @abstract	Returns the message size
 */
- (NSUInteger)messageSize;

/*!
	@abstract	Set the message sequence number, this will NOT set any thing on the server.
				This is used to assign sequence numbers after retrieving the message list.
*/
- (void)setSequenceNumber:(NSUInteger)sequenceNumber;

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
				want the raw encoding of the message.
*/
- (NSString *)render;

/*!
    @abstract   Returns the message in the format Mail.app uses, Emlx. This format stores the message
                headers, body, and flags.
*/
- (NSData *)messageAsEmlx;

/*!
    @abstract   Fetches from the server the rfc822 content of the message, which is the headers and the message body.
*/
- (NSString *)rfc822;

/* Intended for advanced use only */
- (struct mailmessage *)messageStruct;
- (mailimap *)imapSession;
@end
