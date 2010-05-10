//
//  CTSMTPConnectionDelegate.h
//  MailCore
//
//  Created by Juan Leon on 5/9/10.
//  Copyright 2010 NotOptimal.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol CTSMTPConnectionDelegate

//This is called with values between 0-100 (inclusive)
-(void)smtpProgress:(unsigned int)aProgress;

//TODO: this should include a status code
-(void)smtpDidFinishSendingMessage;


@end