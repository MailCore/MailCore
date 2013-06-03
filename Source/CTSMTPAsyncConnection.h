/*
 * MailCore
 *
 * Copyright (C) 2010 - Matt Ronge
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

@protocol CTSMTPConnectionDelegate

//This is called with values between 0-100 (inclusive)
-(void)smtpProgress:(unsigned int)aProgress;

-(void)smtpDidFinishSendingMessage:(CTSMTPAsyncStatus)aStatus;
@end

@class CTCoreMessage;
@class CTCoreAddress;
@class CTSMTP;


@interface CTSMTPAsyncConnection : NSObject
{
    CTSMTP* mSMTPObj;
    mailsmtp* mSMTP;
    CTCoreMessage* mMessage;
    NSDictionary* mServerSettings;
    NSThread* mMailThread;
    id <CTSMTPConnectionDelegate> mDelegate;
    unsigned int mLastProgress;
    CTSMTPAsyncStatus mStatus;
}

@property (readonly) NSDictionary* serverSettings;
@property (retain) CTCoreMessage* message;
@property (readonly) CTSMTPAsyncStatus status;

- (id)initWithServer:(NSString *)aServer
            username:(NSString *)aUsername
            password:(NSString *)aPassword
                port:(unsigned int)aPort
      connectionType:(CTSMTPConnectionType)connectionType
             useAuth:(BOOL)aAuth
            delegate:(id<CTSMTPConnectionDelegate>)aDelegate;


- (void)sendMessageInBackgroundAndNotify:(CTCoreMessage*)aMessage;
- (void)cancel;
- (BOOL)isBusy;

@end