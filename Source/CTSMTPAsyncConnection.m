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
#import "CTSMTPConnectionDelegate.h"
#import "MailCoreTypes.h"


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
- (void)cleanupAfterThread;

@end


@implementation CTSMTPAsyncConnection

@synthesize message = mMessage;
@synthesize serverSettings = mServerSettings;

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
               

- (void)sendMessageInBackgroundAndNotify:(CTCoreMessage*)aMessage
{
	//TODO: convert to exceptions
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
    [mMailThread cancel];
}

- (BOOL)isBusy
{
	return ( mMailThread != nil && [mMailThread isExecuting] );
}

- (BOOL)isCancelled
{
    return ( mMailThread != nil && [mMailThread isCancelled] );
}

- (void)threadWillExitHandler:(NSNotification*)aNote
{
	if ( [aNote object] != mMailThread )
    {
    	return;
    }
    if( mDelegate )
    {
        //TODO: check mStatus and send it along.
    	[mDelegate smtpDidFinishSendingMessage];
	}
    [self cleanupAfterThread];
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

	@try {
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

		/* recipients */
		NSMutableSet *rcpts = [NSMutableSet set];
		[rcpts unionSet:[theMessage to]];
		[rcpts unionSet:[theMessage bcc]];
		[rcpts unionSet:[theMessage cc]];
		[mSMTPObj setRecipients:rcpts];
	 
		/* data */
		[mSMTPObj setData:[theMessage render]];
	}
    @catch (NSException* aException) {
        //TODO: handle exceptions, set mStatus, or let them out?
        NSLog( @"Exception caught while sending mail:%@", [aException description] );
    }
    [thePool drain];
}

- (void)handleSmtpProgress:(NSNumber*)aProgress
{
    //check if cancelled before sending an update
    if( [mMailThread isCancelled] && [NSThread currentThread] == mMailThread )
    {
        [NSThread exit];
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


- (void)cleanupAfterThread
{
    [mSMTPObj release];
    mSMTPObj = nil;

    if( mSMTP )
    {
        mailstream_cancel( mSMTP->stream );
        mailsmtp_free(mSMTP); //this can take 300 seconds to come back!
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
