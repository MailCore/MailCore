//
//  CTSMTPAsyncConnection.m
//  MailCore
//
//  Created by Juan Leon on 5/6/10.
//  Copyright 2010 NotOptimal.net. All rights reserved.
//

#import <libetpan/libetpan.h>

#import "CTCoreAddress.h"
#import "CTCoreMessage.h"
#import "CTESMTP.h"
#import "CTSMTP.h"
#import "CTSMTPAsyncConnection.h"


//setup to allow c callback fxn:
CTSMTPAsyncConnection* ptrToSelf;

void
smtpProgress( size_t aCurrent, size_t aTotal )
{
    if( ptrToSelf != nil )
    {
        float theProgress = (float)aCurrent / (float)aTotal * 100;
        [ptrToSelf performSelector:@selector(handleSmtpProgress:) 
                        withObject:[NSNumber numberWithFloat:theProgress]];
    }
}

@interface CTSMTPAsyncConnection (PrivateMethods)

- (void)sendMailThread;
- (void)handleSmtpProgress:(NSNumber*)aProgress;
- (void)threadWillExitHandler:(NSNotification*)aNote;
- (void)cleanupAfterThread;

@end


@implementation CTSMTPAsyncConnection

@synthesize message = mMessage;
@synthesize serverSettings = mServerSettings;
@synthesize status = mStatus;

- (id)initWithServer:(NSString *)aServer 
            username:(NSString *)aUsername
            password:(NSString *)aPassword 
                port:(unsigned int)aPort 
              useTLS:(BOOL)aTls 
             useAuth:(BOOL)aAuth
            delegate:(id<CTSMTPConnectionDelegate>)aDelegate
{

    self = [super init];
    if(self)
    {
        mStatus = CTSMTPAsyncSuccess;
        ptrToSelf = self;
        mSMTPObj = nil;
        mSMTP = NULL;
        mMailThread = nil;
        mDelegate = aDelegate;
        mServerSettings = 
            [[NSDictionary dictionaryWithObjectsAndKeys:aServer, @"server",
                                                        aUsername, @"username",
                                                        aPassword, @"password",
                                                        [NSNumber numberWithInt:aPort], @"port",
                                                        [NSNumber numberWithBool:aTls], @"tls",
                                                        [NSNumber numberWithBool:aAuth], @"auth", nil] retain];

        //save clients from themselves (they could be leaking us - no dealloc)
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(threadWillExitHandler:) 
                                                     name:NSThreadWillExitNotification
                                                   object:nil];
    }
    return self;
}               

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cleanupAfterThread];
    [super dealloc];
}

- (void)finalize
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cleanupAfterThread];
    [super finalize];
}


- (void)sendMessageInBackgroundAndNotify:(CTCoreMessage*)aMessage
{
    //TODO: convert to exceptions?
    if( aMessage == nil )
    {
        NSLog(@"CTCoreMessage param cannot be nil");
        return;
    }

    if ( mMailThread != nil && [mMailThread isExecuting] )
    {
        NSLog(@"Can only send one message at a time, we're busy, sheesh.");
        return;
    }

    NSAssert( mMailThread == nil, @"Invalid smtp thread state" );

    self.message = aMessage;

    //start thread:
    mMailThread = [NSThread alloc];
    [mMailThread initWithTarget:self selector:@selector(sendMailThread) object:nil];
    [mMailThread start];
}

- (void)cancel
{
    if( ![mMailThread isExecuting] || [mMailThread isCancelled] )
    {
        return;
    }
    //mark thread as cancelled
    [mMailThread cancel];
    //cancel libetpan smtp stream
    mailstream_cancel(mSMTP->stream);
    mailstream_close(mSMTP->stream);
    mSMTP->stream = NULL;
    mailsmtp_free(mSMTP);
    mSMTP = NULL;
}

- (BOOL)isBusy
{
    return ( mMailThread != nil && [mMailThread isExecuting] );
}

@end

@implementation CTSMTPAsyncConnection (PrivateMethods)

- (void)sendMailThread
{
    NSAutoreleasePool* thePool = [[NSAutoreleasePool alloc] init];
    void (*progFxn)(size_t, size_t) = &smtpProgress;
    mSMTP = NULL;
    mSMTP = mailsmtp_new(30, progFxn);
    assert(mSMTP != NULL);
    mSMTPObj = [[CTESMTP alloc] initWithResource:mSMTP];

    NSDictionary* theSettings = self.serverSettings;

    @try
    {
        [mSMTPObj connectToServer:[theSettings objectForKey:@"server"]
                             port:[[theSettings objectForKey:@"port"] unsignedIntValue]];
        if ([mSMTPObj helo] == false) {
            /* The server didn't support ESMTP, so switching to STMP */
            [mSMTPObj release];
            mSMTPObj = [[CTSMTP alloc] initWithResource:mSMTP];
            [mSMTPObj helo];
        }
        if ([(NSNumber*)[theSettings objectForKey:@"tls"] boolValue] )
            [mSMTPObj startTLS];
        if ([(NSNumber*)[theSettings objectForKey:@"auth"] boolValue])
            [mSMTPObj authenticateWithUsername:[theSettings objectForKey:@"username"]
                                      password:[theSettings objectForKey:@"password"] 
                                        server:[theSettings objectForKey:@"server"]];

        CTCoreMessage* theMessage = self.message;
        [mSMTPObj setFrom:[[[theMessage from] anyObject] email]];

        NSMutableSet *rcpts = [NSMutableSet set];
        [rcpts unionSet:[theMessage to]];
        [rcpts unionSet:[theMessage bcc]];
        [rcpts unionSet:[theMessage cc]];
        [mSMTPObj setRecipients:rcpts];

        //send
        int theReturn = [mSMTPObj setData:[theMessage render] raiseExceptions:NO];
        if( theReturn == MAILSMTP_NO_ERROR )
        {
            mStatus = CTSMTPAsyncSuccess;
        } 
        else if( theReturn == MAILSMTP_ERROR_STREAM && [mMailThread isCancelled] )
        {
            //libetpan was cancelled from another thread
            mStatus = CTSMTPAsyncCanceled;
        }
        else
        {
            mStatus = CTSMTPAsyncError;
        }
    }
    @catch (NSException* aException) 
    {
        mStatus = CTSMTPAsyncError;
    }
    [thePool drain];
}

- (void)handleSmtpProgress:(NSNumber*)aProgress
{
    //check if cancelled before sending an update
    if( [mMailThread isCancelled] && [NSThread currentThread] == mMailThread )
    {
        return;
    }

    unsigned int theProgress = [aProgress unsignedIntValue];
    if( theProgress > mLastProgress )
    {
        mLastProgress = theProgress;
        //call delegate
        if( mDelegate )
        {
            [mDelegate smtpProgress:mLastProgress];
        }
    }
}

- (void)threadWillExitHandler:(NSNotification*)aNote
{
    if( [aNote object] != mMailThread )
    {
        return;
    }
    if( mDelegate )
    {
        [mDelegate smtpDidFinishSendingMessage:mStatus];
    }
    [self cleanupAfterThread];
}

- (void)cleanupAfterThread
{
    [mSMTPObj release];
    mSMTPObj = nil;

    if( mSMTP )
    {
        if( mSMTP->stream )
        {
            mailstream_cancel(mSMTP->stream);
            mailstream_close(mSMTP->stream);
            mSMTP->stream = NULL;
        }
        mailsmtp_free(mSMTP);
        mSMTP = NULL;
    }

    [mServerSettings release];
    mServerSettings = nil;

    [mMessage release];
    mMessage = nil;

    [mMailThread release];
    mMailThread = nil;
}

@end
