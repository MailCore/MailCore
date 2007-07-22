#import <Cocoa/Cocoa.h>
#import "libetpan.h"

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

/*!
	@abstract	This returns an NSSet of NSStrings which contain the UID's (unique identifiers) of the messages
				which reside in this folder. If you pass in a UID make sure you verify that UID is still valid with
				isUIDValid first.
	@param		uid If you pass in nil, then it will return the all of the UID's in the folder. If you pass in
				a NSString containing a UID the method will only fetch a list of UID's which start after that base
				UID. This can be used to for example, only download the newest messages if you pass in the last UID
				returned from a previous fetch.
	@result		A NSSet which contains NSStrings with the message UIDs
*/
- (NSSet *)messageListFromUID:(NSString *)uid;

//TODO Document me!
//TODO Attributes is ignore, fix me!
- (NSSet *)messageListWithFetchAttributes:(NSArray *)attributes;

/*
	Implementation is in alpha.
*/
//TODO Document Me!
- (NSSet *)messageObjectsFromIndex:(unsigned int)start toIndex:(unsigned int)end;

/*!
	@abstract	This returns an NSSet of CTCoreMessage's. If you need to get access the message attributes on
				all of the messages it's faster to use this method than messageListFromIndex:. However, this method
				has higher overhead if you need to get a list quickly.
	@param		uid If you pass in nil, then it will return the all of the UID's in the folder. If you pass in
				a NSString containing a UID the method will only fetch a list of UID's which start after that base
				UID. This can be used to for example, only download the newest messages if you pass in the last UID
				returned from a previous fetch.
	@result		NSSet which contains CTCoreMessage's
*/
- (NSSet *)messageObjectsFromUID:(NSString *)uid;

/*!
	@abstract	This will return the message from this folder with the UID that was passed in. If the message
				can't be found, nil is returned
	@param		uid The uid as an NSString for the message to retrieve.
	@result		A CTMessage object is returned which can be used to get further information and perform operations
				on the message.
*/
- (CTCoreMessage *)messageWithUID:(NSString *)uid;

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
	@abstract	Returns an NSDictionary of message flags, every flag is either marked as CTFlagSet or CTFlagNotSet. Here is a list of message flags: CTFlagNew, CTFlagSeen, CTFlagFlagged, CTFlagDeleted, CTFlagAnswered, CTFlagForwarded. Those are the keys you should use on the dictionary that is returned.
*/
- (NSDictionary *)flagsForMessage:(CTCoreMessage *)msg;

/*!
	@abstract	Sets the message's flags on the server, take a look at the documentation for the flags: for more information.
*/
- (void)setFlags:(NSDictionary *)flags forMessage:(CTCoreMessage *)msg;

/*!
	@astract	Deletes all messages contained in the folder that are marked for deletion. Deleting messages in IMAP is a little strange, first you need to set the message flag CTFlagDeleted to CTFlagSet, and then when you call expunge on the folder the message is contained in, it will be deleted.
*/
- (void)expunge;

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
