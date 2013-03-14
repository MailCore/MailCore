//
//  CTCoreMessage+Extended.m
//  MailCore
//
//  Created by Davide Gullo on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <libetpan/mailimap_types.h>
#import "CTCoreMessage+Extended.h"
#import "MailCoreTypes.h"
#import "MailCoreUtilities.h"
#import "CTMIME.h"
#import "CTMIMEFactory.h"
#import "CTMIME_HtmlPart.h"

@implementation CTCoreMessage (Extended)

- (BOOL)fetchMyMessage {
    if (myMessage == NULL) {
        return NO;
    }
	
    int err;
    struct mailmime *dummyMime;
    //Retrieve message mime and message field
    err = mailmessage_get_bodystructure(myMessage, &dummyMime);
    if (err != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromIMAPCode(err);
        return NO;
    }
    
    CTMIME *oldMIME = myParsedMIME;
    myParsedMIME = [[CTMIMEFactory createMIMEWithMIMEStruct:[self messageStruct]->msg_mime
												 forMessage:[self messageStruct]] retain];
    [oldMIME release];
	
    return YES;
}

- (char *)my_rfc822 {
	
	/*
    char *result = NULL;
    int r = mailimap_fetch_rfc822([self imapSession], [self sequenceNumber], &result);
    if (r != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromIMAPCode(r);
        return nil;
    }
    mailimap_msg_att_rfc822_free(result);
	 */
	
    return myMessage->msg_user_data;
}

@end
