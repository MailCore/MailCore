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
 CTCoreAccount is the base class with which you establish a connection to the
 IMAP server. After establishing a connection with CTCoreAccount you can access
 all of the folders (I use the term folder instead of mailbox) on the server.
*/

@class CTCoreFolder;

@interface CTCoreAccount : NSObject {
    struct mailstorage *myStorage;
    BOOL connected;
    NSError *lastError;
    NSString *pathDelimiter;
    
    int idlePipe[2];
}
/**
 If an error occurred (nil or return of NO) call this method to get the error
*/
@property(nonatomic, retain) NSError *lastError;

@property(nonatomic, retain) NSString *pathDelimiter;

/**
 Retrieves the list of all the available folders from the server.
 @return Returns a NSSet which contains NSStrings of the folders pathnames, nil on error
*/
- (NSSet *)allFolders;

/**
 Retrieves a list of only the subscribed folders from the server.
 @return Returns a NSSet which contains NSStrings of the folders pathnames, nil on error
*/
- (NSSet *)subscribedFolders;

/**
 If you have the path of a folder on the server use this method to retrieve just the one folder.
 @param path A NSString specifying the path of the folder to retrieve from the server.
 @return Returns a CTCoreFolder.
*/
- (CTCoreFolder *)folderWithPath:(NSString *)path;

/**
 This method initiates the connection to the server.
 @param server The address of the server.
 @param port The port to connect to.
 @param connnectionType What kind of connection to use, it can be one of these three values:
 CTConnectionTypePlain, CTConnectionTypeStartTLS, CTConnectionTypeTryStartTLS, CTConnectionTypeTLS. See MailCoreTypes.h for more information
 @param authType The authentication type, only CTImapAuthTypePlain is currently supported
 @param login The username to connect with.
 @param password The password to use to connect.
 @return Return YES on success, NO on error. Call method lastError to get error if one occurred
*/
- (BOOL)connectToServer:(NSString *)server port:(int)port connectionType:(int)conType authType:(int)authType
                        login:(NSString *)login password:(NSString *)password;

/**
 This method returns the current connection status.
 @return Returns YES or NO as the status of the connection.
*/
- (BOOL)isConnected;

/**
 Terminates the connection. If you terminate this connection it will also affect the
 connectivity of CTCoreFolders and CTMessages that rely on this account.
*/
- (void)disconnect;


/**
 Sends the idle command to the server.
*/
- (CTIdleResult)idle;
- (void)cancelIdle;

- (NSSet *)capabilities;

@property BOOL idling;


/* Intended for advanced use only */
- (mailimap *)session;
- (struct mailstorage *)storageStruct;
@end
