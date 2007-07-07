#import <Cocoa/Cocoa.h>
#import "libetpan.h"

/*!
	@class CTCoreAccount
	CTCoreAccount is the base class with which you establish a connection to the 
	IMAP server. After establishing a connection with CTCoreAccount you can access 
	all of the folders (I use the term folder instead of mailbox) on the server.
	All methods throw an exception on failure.
*/

@class CTCoreFolder;

@interface CTCoreAccount : NSObject {	
	struct mailstorage	*myStorage;
	BOOL				connected;
}

/*!
	@abstract	Retrieves the list of all the available folders from the server.
	@result		Returns a NSSet which contains NSStrings of the folders pathnames.
*/
- (NSSet *)allFolders;

/*!
	@abstract	Retrieves a list of only the subscribed folders from the server.
	@result		Returns a NSSet which contains NSStrings of the folders pathnames.
*/
- (NSSet *)subscribedFolders;

/*!
	@abstract	If you have the path of a folder on the server use this method to retrieve just the one folder.
	@param		path A NSString specifying the path of the folder to retrieve from the server.
	@result		Returns a CTCoreFolder.
*/
- (CTCoreFolder *)folderWithPath:(NSString *)path;


/*!
	@abstract	This method initiates the connection to the server.
	@param		server The address of the server.
	@param		port The port to connect to.
	@param		connnectionType What kind of connection to use, it can be one of these three values:
				CONNECTION_TYPE_PLAIN, CONNECTION_TYPE_STARTTLS, CONNECTION_TYPE_TRY_STARTTLS
	@param		authType The authentication type, only IMAP_AUTH_TYPE_PLAIN is currently supported
	@param		login The username to connect with.
	@param		password The password to use to connect.
*/
- (void)connectToServer:(NSString *)server port:(int)port connectionType:(int)conType authType:(int)authType 
						login:(NSString *)login password:(NSString *)password;
						
/*!
	@abstract	This method returns the current connection status.
	@result		Returns YES or NO as the status of the connection.
*/
- (BOOL)isConnected;

/*!
	@abstract	Terminates the connection. If you terminate this connection it will also affect the
				connectivity of CTCoreFolders and CTMessages that rely on this account.
*/
- (void)disconnect;

/* Intended for advanced use only */
- (mailimap *)session;
- (struct mailstorage *)storageStruct;
@end
