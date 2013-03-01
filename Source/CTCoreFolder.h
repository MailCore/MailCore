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
#import "MailCoreTypes.h"

/**
 CTCoreFolder is the class used to get and set attributes for a server side folder. It is also the
 class used to get a list of messages from the server. You need to make sure and establish a connection
 first by calling connect.
*/

@class CTCoreMessage, CTCoreAccount;

@interface CTCoreFolder : NSObject {
    struct mailfolder *myFolder;
    CTCoreAccount *myAccount;
    NSString *myPath;
    BOOL connected;
    NSError *lastError;
    
    BOOL idling;
    int idlePipe[2];
}
/**
 If an error occurred (nil or return of NO) call this method to get the error
*/
@property (nonatomic, retain) NSError *lastError;

@property (nonatomic, retain) CTCoreAccount *parentAccount;

/**
 This method is used to initialize a folder. This method or the
 method in CTCoreAccount folderWithPath can be used to setup a folder.
 @param inAccount This parameter must be passed in so the folder can initiate it's connection.
*/
- (id)initWithPath:(NSString *)path inAccount:(CTCoreAccount *)account;

/**
 This initiates the connection after the folder has been initalized.
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
*/
- (BOOL)connect;

/**
 This method terminates the connection
 
 Make sure you don't have any message connections open from this folder before disconnecting.
*/
- (void)disconnect;

/**
 This will return the message from this folder with the UID that was passed in.

 A CTMessage object is returned which can be used to get further information and perform operationson the message.
 @return A CTCoreMessage or if not found, nil
*/
- (CTCoreMessage *)messageWithUID:(NSUInteger)uid;

/**
 Use this method to download message lists from the server.
 
 This method take fetch attributes which configure what is fetched. Fetch attributes can be combined
 so you fetch all the message data at once, or select which pieces you want for your app. You can
 also fetch just the default attributes which will be as fast as possible. Pass in
 CTFetchAttrDefaultsOnly to attrs fetch the minimum possible, this includes the UID and
 flags. The defaults are always fetched, even when you don't pass in this flag.  Use
 CTFetchAttrBodyStructure to also fetch the body structure of the message. This prevents a future
 round trip done by [CTCoreMessage fetchBodyStructure], if it sees you already have the body
 structure it won't re-fetch it.  Use CTFetchAttrEnvelope if you'd like to fetch the subject, to,
 from, cc, bcc, sender, date, size, etc. You can also fetch both the envelope and body structure by passing
 in CTFetchAttrEnvelope | CTFetchAttrBodyStructure

 
 @param start The message sequence number to start from, starts with 1 and NOT 0 (IMAP starts with 1 that way, sorry)
 @param end The ending message sequence number, or if you'd like to fetch to the end of the message list pass in 0
 @param attrs This controls what is fetched.
 @return Returns a NSArray of CTCoreMessage's. Returns nil on error
*/
- (NSArray *)messagesFromSequenceNumber:(NSUInteger)startNum to:(NSUInteger)endNum withFetchAttributes:(CTFetchAttributes)attrs;

/**
 Use this method to download message lists from the server. 
 
 This method uses UID ranges to determine which messages to download, while messagesFromSequenceNumber:to:withFetchAttributes: uses sequence numbers.

 @param start The message sequence number to start from, starts with 1 and NOT 0 (IMAP starts with 1 that way, sorry)
 @param end The ending message sequence number, or if you'd like to fetch to the end of the message list pass in 0
 @param attrs This controls what is fetched.
 @return Returns a NSArray of CTCoreMessage's. Returns nil on error
 @see messagesFromSequenceNumber:to:withFetchAttributes:
*/
- (NSArray *)messagesFromUID:(NSUInteger)startUID to:(NSUInteger)endUID withFetchAttributes:(CTFetchAttributes)attrs;

/**
 Pulls the sequence number for the message with the specified uid.
 It does not perform UID validation, and the sequence ID is only
 valid per session.
 @param The uid for the message
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
*/
- (BOOL)sequenceNumberForUID:(NSUInteger)uid sequenceNumber:(NSUInteger *)sequenceNumber;


/**
 Perform an IMAP check command
 
 From IMAP RFC: "The CHECK command requests a checkpoint of the currently selected mailbox.
 A checkpoint refers to any implementation-dependent housekeeping associated
 with the mailbox (e.g., resolving the server's in-memory state of the mailbox
 with the state on its disk) that is not normally executed as part of each command."
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
 */
- (BOOL)check;

/**
 The entire path of the folder.
*/
- (NSString *)path;

/**
 This will change the path of the folder.
 
 Use this method to rename the folder on the server or to move the folder on the server.
 @param path The new path for the folder as an NSString.
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
*/
- (BOOL)setPath:(NSString *)path;

/**
 Sends the idle command to the server.
 */
- (CTIdleResult)idleWithTimeout:(NSUInteger)timeout;
- (void)cancelIdle;
@property (atomic) BOOL idling;


/**
 If the folder doesn't exist on the server this method will create it. Make sure the pathname
 has been set first.
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
*/
- (BOOL)create;

/**
 This method will remove the folder and any messages contained within from the server.
 Be careful when using this method because there is no way to undo.
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
*/
- (BOOL)delete;

/**
 The folder will be listed as subscribed on the server.
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
*/
- (BOOL)subscribe;

/**
 The folder will be listed as unsubscribed.
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
*/
- (BOOL)unsubscribe;

/**
 Exposes the IMAP APPEND command, see the IMAP RFC 4549.
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
*/
- (BOOL) appendMessage: (CTCoreMessage *) msg;

/**
 Retrieves the message flags. You must AND/OR using the defines constants.
 Here is a list of message flags:
 CTFlagNew, CTFlagSeen, CTFlagFlagged, CTFlagDeleted,
 CTFlagAnswered, CTFlagForwarded.
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
*/
- (BOOL)flagsForMessage:(CTCoreMessage *)msg flags:(NSUInteger *)flags;

/**
 Sets the message's flags on the server, take a look at the
 documentation for flagsForMessage:
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
*/
- (BOOL)setFlags:(NSUInteger)flags forMessage:(CTCoreMessage *)msg;

/**
 Deletes all messages contained in the folder that are marked for
 deletion. Deleting messages in IMAP is a little strange, first
 you need to set the message flag CTFlagDeleted to CTFlagSet, and
 then when you call expunge on the folder the message is contained
 in, it will be deleted.
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
*/
- (BOOL)expunge;

/**
 Copies a message to a folder
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
*/
- (BOOL)copyMessageWithUID:(NSUInteger)uid toPath:(NSString *)path;

/**
 Moves a message to a folder
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
*/
- (BOOL)moveMessageWithUID:(NSUInteger)uid toPath:(NSString *)path;

/**
 Returns the number of unread messages. This causes a round trip to the server, as it fetches
 the count for each call.
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
*/
- (BOOL)unreadMessageCount:(NSUInteger *)unseenCount;

/**
 Returns the number of messages in the folder. The count was retrieved when the folder connection was
 established, so to refresh the count you must disconnect and reconnect.
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
*/
- (BOOL)totalMessageCount:(NSUInteger *)totalCount;

/**
 Returns the uid validity value for the folder, which can be used to determine if the
 local cached UID's are still valid, or if the server has changed UID's
*/
- (NSUInteger)uidValidity;

/**
 Returns the uid next value for the folder. The next message added to the mailbox
 will be assigned a UID greater than or equal to uidNext
*/
- (NSUInteger)uidNext;

/* Intended for advanced use only */
- (struct mailfolder *)folderStruct;
- (mailsession *)folderSession;
- (mailimap *)imapSession;
@end
