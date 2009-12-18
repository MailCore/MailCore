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
	@class	CTCoreFolder
	CTCoreFolder is the class used to get and set attributes for a server side folder. It is also the
	class used to get a list of messages from the server. You need to make sure and establish a connection
	first by calling connect. All methods throw an exceptions on failure.
*/

@class CTCoreMessage, CTCoreAccount;

@interface CTCoreFolder : NSObject {
	struct mailfolder *myFolder;
	CTCoreAccount *myAccount;
	NSString *myPath;
	BOOL connected;
}

/*!
	@abstract	This method is used to initialize a folder. This method or the 
				method in CTCoreAccount folderWithPath can be used to setup a folder.
	@param		inAccount This parameter must be passed in so the folder can initiate it's connection.
*/
- (id)initWithPath:(NSString *)path inAccount:(CTCoreAccount *)account;

/*!
	@abstract	This initiates the connection after the folder has been initalized.
*/
- (void)connect;

/*!
	@abstract	This method terminates the connection, make sure you don't have any message
				connections open from this folder before disconnecting.
*/
- (void)disconnect;

/*
	Implementation is in alpha.
*/
//TODO Document Me!
- (NSSet *)messageObjectsFromIndex:(unsigned int)start toIndex:(unsigned int)end;

/*!
	@abstract	This will return the message from this folder with the UID that was passed in. If the message
				can't be found, nil is returned
	@param		uid The uid as an NSString for the message to retrieve.
	@result		A CTMessage object is returned which can be used to get further information and perform operations
				on the message.
*/
- (CTCoreMessage *)messageWithUID:(NSString *)uid;


//TODO Document me!
//TODO Attributes is ignore, fix me!
- (NSSet *)messageListWithFetchAttributes:(NSArray *)attributes;

/*!
	@abstract	This validates the passed in UID. The server can at times change the set of UID's for a folder. So
				you should verify that the server is still using the same set when connecting.
	@param		uid The UID to verify.
	@return		YES if the UID is valid.
*/
- (BOOL)isUIDValid:(NSString *)uid;

/*!
	@abstract	Pulls the sequence number for the messag with the specified uid.
				It does not perform UID validation, and the sequence ID is only
				valid per session.
	@param		The uid for the message
	@return		> 1 if successful, 0 on err
*/
- (NSUInteger)sequenceNumberForUID:(NSString *)uid;


//FIXME What is this?
- (void)check;


/*!
	@abstract	The folder name.
*/
- (NSString *)name;

/*!
	@abstract	The entire path of folder.
*/
- (NSString *)path;

/*!
	@abstract	This will change the path of the folder. Use this method to rename the folder on the server
				or to move the folder on the server.
	@param		path The new path for the folder as an NSString.
*/
- (void)setPath:(NSString *)path;

/*!
	@abstract	If the folder doesn't exist on the server this method will create it. Make sure the pathname
				has been set first.
*/
- (void)create;

/*!
	@abstract	This method will remove the folder and any messages contained within from the server.
				Be careful when using this method because there is no way to undo.
*/
- (void)delete;

/*!
	@abstract	The folder will be listed as subscribed on the server.
*/
- (void)subscribe;

/*!
	@abstract	The folder will be listed as unsubscribed.
*/
- (void)unsubscribe;

/*!
	@abstract	Returns the message flags. You must AND/OR using the defines constants.
				Here is a list of message flags: 
				CTFlagNew, CTFlagSeen, CTFlagFlagged, CTFlagDeleted,
				CTFlagAnswered, CTFlagForwarded.
*/
- (unsigned int)flagsForMessage:(CTCoreMessage *)msg;

/*!
	@abstract	Sets the message's flags on the server, take a look at the 
				documentation for flagsForMessage:
*/
- (void)setFlags:(unsigned int)flags forMessage:(CTCoreMessage *)msg;

/*!
	@astract	Deletes all messages contained in the folder that are marked for
				deletion. Deleting messages in IMAP is a little strange, first 
				you need to set the message flag CTFlagDeleted to CTFlagSet, and
				then when you call expunge on the folder the message is contained 
				in, it will be deleted.
*/
- (void)expunge;

//TODO document me
//Should this be by message instead of by UID?
- (void)copyMessageWithUID:(NSString *)uid toFolderWithPath:(NSString *)path;

/*!
	@abstract	Returns the number of unread messages.
	@result		A NSUInteger containing the number of unread messages.
*/
- (NSUInteger)unreadMessageCount;

/*!
	@abstract	Returns the number of messages in the folder.
	@result		A NSUInteger containing the number of messages.
*/
- (NSUInteger)totalMessageCount;

/*!
	@abstract	Returns the uid validity value for the folder
	@result		An integer containing the uid validity
*/
- (NSUInteger)uidValidity;

/* Intended for advanced use only */
- (struct mailfolder *)folderStruct;
- (mailsession *)folderSession;
- (mailimap *)imapSession;
@end
