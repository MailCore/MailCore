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

/**
 CTCoreMessage is how you work with messages. The easiest way to instantiate a CTCoreMessage
 is to first setup a CTCoreAccount object and then get a CTCoreFolder object and then use it's
 convenience method messageWithUID: to get a message object you can work with.

 Anything that begins with "fetch", requires that an active network connection is present.
*/

@class CTCoreFolder, CTCoreAddress, CTCoreAttachment, CTMIME;

@interface CTCoreMessage : NSObject {
    struct mailmessage *myMessage;
    struct mailimf_single_fields *myFields;
    CTMIME *myParsedMIME;
    NSUInteger mySequenceNumber;
    NSError *lastError;
    CTCoreFolder *parentFolder;
    NSString *rfc822Header;
}
/**
 If an error occurred (nil or return of NO) call this method to get the error
*/
@property (nonatomic, retain) NSError *lastError;

@property (nonatomic, retain) CTCoreFolder *parentFolder;


@property (nonatomic, copy) NSString *rfc822Header;

/**
 If the body structure has been fetched, this will contain the MIME structure
*/
@property(retain) CTMIME *mime;

/**
 Used to instantiate an empty message object.
*/
- (id)init;

/**
 Used to instantiate a message object with the contents of a mailmessage struct
 (a LibEtPan type). The mailmessage struct does not include any body information,
 so after calling this method the message will have a body which is NULL.
*/
- (id)initWithMessageStruct:(struct mailmessage *)message;

/**
 Used to instantiate a message object based off the contents of a file on disk.
 The file on disk must be a valid MIME message.
*/
- (id)initWithFileAtPath:(NSString *)path;

/**
 Used to instantiate a message object based off a string
 that contains a valid MIME message
*/
- (id)initWithString:(NSString *)msgData;

/**
 If a method returns nil or in the case of a BOOL returns NO, call this to get the error that occured
*/
- (NSError *)lastError;

/**
 Returns YES if this message body structure has been downloaded, and NO otherwise.
 */
- (BOOL)hasBodyStructure;

/**
 If the messages body structure hasn't been downloaded already it will be fetched from the server.

 The body structure is needed to get attachments or the message body
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
*/
- (BOOL)fetchBodyStructure;

/**
 This method returns the parsed plain text message body as an NSString.

 If a plaintext body isn't found an empty string is returned
*/
- (NSString *)body;

/**
 This method returns the html body as an NSString.
*/
- (NSString *)htmlBody;

/**  
 Returns a message body as an NSString. 

 @param isHTML Pass in a BOOL pointer that will be set to YES if an HTML body is loaded

 First attempts to retrieve a plain text body, if that fails then
 tries for an HTML body.
*/
- (NSString *)bodyPreferringPlainText:(BOOL *)isHTML;

/**
 This method sets the message body. Plaintext only please!
*/
- (void)setBody:(NSString *)body;

/**
 Use this method to set the body if you have HTML content.
*/
- (void)setHTMLBody:(NSString *)body;

/**
 A list of attachments this message has
*/
- (NSArray *)attachments;

/**
 Add an attachment to the message.
 
 Only used when sending e-mail
*/
- (void)addAttachment:(CTCoreAttachment *)attachment;

/**
 Returns the subject of the message.
*/
- (NSString *)subject;

/**
 Will set the subject of the message, use this when composing e-mail.
*/
- (void)setSubject:(NSString *)subject;

/**
 Returns the date as given in the Date mail field
*/
- (NSDate *)senderDate; 

/**
 Returns YES if the message is unread.
*/
- (BOOL)isUnread;

/**
 Returns YES if the message is recent and unread.
*/
- (BOOL)isNew;

/**
 Returns YES if the message is starred (flagged in IMAP terms).
*/
- (BOOL)isStarred;

/**
 A machine readable ID that is guaranteed unique by the
 host that generated the message
*/
- (NSString *)messageId;

/**
 Returns an NSUInteger containing the messages UID. This number is unique across sessions
*/
- (NSUInteger)uid;

/**
 Returns the message sequence number, this number cannot be used across sessions
*/
- (NSUInteger)sequenceNumber;

/**
 Returns the message size in bytes
*/
- (NSUInteger)messageSize;

/**
 Returns the message flags.
 
 The flags contain if there user has replied, forwarded, read, delete etc.
 See MailCoreTypes.h for a list of constants
*/
- (NSUInteger)flags;

/**
 Returns the message extionsion flags.
 
 The extension flags contain flags other than standard flags in flags property. This include "Draft" flag.
 See MailCoreTypes.h for a list of constants
 */
- (NSArray *)extionsionFlags;

/**
 Set the message sequence number.
 
 This will NOT set any thing on the server.
 This is used to assign sequence numbers after retrieving the message list.
*/
- (void)setSequenceNumber:(NSUInteger)sequenceNumber;

/**
 Parses the from list, the result is an NSSet containing CTCoreAddress's
*/
- (NSSet *)from;

/**
 Sets the message's from addresses
 @param addresses A NSSet containing CTCoreAddress's
*/
- (void)setFrom:(NSSet *)addresses;

/**
 Returns the sender.
 
 The sender which isn't always the actual person who sent the message, it's usually the
 address of the machine that sent the message. In reality, this method isn't very useful, use from: instead.
*/
- (CTCoreAddress *)sender;

/**
 Returns the list of people the message was sent to, returns an NSSet containing CTAddress's.
*/
- (NSSet *)to;

/**
 Sets the message's to addresses
 @param addresses A NSSet containing CTCoreAddress's
*/
- (void)setTo:(NSSet *)addresses;

/**
 Return the list of messageIds from the in-reply-to field
*/
- (NSArray *)inReplyTo;

/**
 Sets the message's in-reply-to messageIds
 @param messageIds A NSArray containing NSString messageId's
*/
- (void)setInReplyTo:(NSArray *)messageIds;

/**
 Return the list of messageIds from the references field
*/
- (NSArray *)references;

/**
 Sets the message's references
 @param messageIds A NSArray containing NSString messageId's
*/
- (void)setReferences:(NSArray *)messageIds;

/**
 Returns the list of people the message was cced to, returns an NSSet containing CTAddress's.
*/
- (NSSet *)cc;

/**
 Sets the message's cc addresses
 @param addresses A NSSet containing CTCoreAddress's
*/
- (void)setCc:(NSSet *)addresses;

/**
 Returns the list of people the message was bcced to, returns an NSSet containing CTAddress's.
*/
- (NSSet *)bcc;

/**
 Sets the message's bcc addresses
 @param addresses A NSSet containing CTCoreAddress's
*/
- (void)setBcc:(NSSet *)addresses;

/**
 Returns the list of people the message was in reply-to, returns an NSSet containing CTAddress's.
*/
- (NSSet *)replyTo;

/**
 Sets the message's reply to addresses
 @param addresses A NSSet containing CTCoreAddress's
*/
- (void)setReplyTo:(NSSet *)addresses;

/**
 Returns the message rendered as the appropriate MIME and IMF content.
 
 Use this only if you want the raw encoding of the message.
*/
- (NSString *)render;

/**
 Returns the message in the format Mail.app uses, Emlx. 
 
 This format stores the message headers, body, and flags.
*/
- (NSData *)messageAsEmlx;

/**
 Fetches from the server the rfc822 content of the message, which are the headers and the message body.
 @return Return nil on error. Call method lastError to get error if one occurred
*/
- (NSString *)rfc822;

/**
 Fetches from the server the rfc822 content of the message headers.
 @return Return nil on error. Call method lastError to get error if one occurred
 */
- (NSString *)rfc822Header;

/**
 return rfc822 content of the message headers that is store locally.
 */
- (NSString *)localRFC822Header;


/* Intended for advanced use only */
- (struct mailmessage *)messageStruct;
- (mailimap *)imapSession;
- (void)setBodyStructure:(struct mailmime *)mime;
- (void)setFields:(struct mailimf_fields *)fields;
@end
