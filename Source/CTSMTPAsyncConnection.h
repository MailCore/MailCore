//
//  CTSMTPAsyncConnection.h
//  MailCore
//
//  Created by Juan Leon on 5/6/10.
//  Copyright 2010 NotOptimal.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <libetpan/libetpan.h>


@class CTCoreMessage;
@class CTCoreAddress;
@class CTSMTP;
@protocol CTSMTPConnectionDelegate;

@interface CTSMTPAsyncConnection : NSObject 
{
    CTSMTP* mSMTPObj;
    mailsmtp* mSMTP;
    CTCoreMessage* mMessage;
    NSDictionary* mServerSettings;
    NSThread* mMailThread;
    id <CTSMTPConnectionDelegate> mDelegate;
    unsigned int mLastProgress;
}

@property (readonly, retain) NSDictionary* serverSettings;
@property (retain) CTCoreMessage* message;

- (id)initWithServer:(NSString *)aServer 
            username:(NSString *)aUsername
            password:(NSString *)aPassword 
                port:(unsigned int)aPort 
              useTLS:(BOOL)aTls 
             useAuth:(BOOL)aAuth
            delegate:(id<CTSMTPConnectionDelegate>)aDelegate;


- (void)sendMessageInBackgroundAndNotify:(CTCoreMessage*)aMessage;
- (void)cancel;
- (BOOL)isBusy;

@end