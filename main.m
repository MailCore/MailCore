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
#import "CTCoreAccount.h"
#import "CTCoreFolder.h"
#import "CTCoreMessage.h"
#import "CTSMTPConnection.h"
#import "CTCoreAddress.h"
#import "MailCoreTypes.h"

#import "CTMIME_TextPart.h"
#import "CTMIME_SinglePart.h"
#import "CTMIME_MultiPart.h"
#import "CTMIME_MessagePart.h"
#import "CTMIME.h"

#import "CTMIMEFactory.h"

const NSString *filePrefix = @"/Users/local/Projects/MailCore/";

int main( int argc, char *argv[ ] )
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

//	CTCoreMessage *msg = [[CTCoreMessage alloc] initWithFileAtPath:[NSString stringWithFormat:@"%@%@",filePrefix,@"TestData/mime-tests/imagetest"]];
//	CTMIME *mime = [CTMIMEFactory createMIMEWithMIMEStruct:[msg messageStruct]->msg_mime forMessage:[msg messageStruct]];


//	CTCoreAccount *account = [[CTCoreAccount alloc] init];
//	CTCoreFolder *folder;
//////	CTCoreFolder *inbox, *newFolder, *archive;
//////	CTCoreMessage *msgOne;
//////	
////
////	MailCoreEnableLogging();
//	[account connectToServer:@"mail.theronge.com" port:143 connectionType:CONNECTION_TYPE_STARTTLS 
//				authType:IMAP_AUTH_TYPE_PLAIN login:@"mronge" password:@""];
//	
//	folder = [account folderWithPath:@"INBOX.Trash"];
//	for (CTCoreMessage *msg in [folder messageObjectsFromIndex:0 toIndex:10]) {
//		NSLog(@"%@ / %@", msg.subject, msg.uid);
//	}
//	
//	CTCoreMessage *msg = [folder messageWithUID:@"1163997146-103"];
//	unsigned int flags = [folder flagsForMessage:msg];
//	flags = flags | CTFlagDeleted;
//	[folder setFlags:flags forMessage:msg];
//	[folder expunge];
//	

    //[folder copyMessageWithUID:@"1163978737-3691" toFolderWithPath:@"INBOX.Trash"];
    //NSLog(@"%d", [folder totalMessageCount]);
/*	for (CTCoreMessage *msg in [folder messageObjectsFromIndex:10 toIndex:18]) {
        NSLog(@"%d", [msg sequenceNumber]);
        NSLog([msg uid]);
    }*/
    //	14
    //1163978737-3518
    //CTCoreMessage *msg = [folder messageWithUID:@"1163978737-3518"];
    //NSLog([msg subject]);
//	NSLog(@"%d", [folder sequenceNumberForUID:@"1163978737-3518"]);
//	[account release];
//	CTCoreMessage *msg;
//	NSEnumerator *enumer = [set objectEnumerator];
//	while ((msg == [enumer nextObject])) {
//		
//	}
//	//NSLog(@"%@", [inbox messageObjectsFromIndex:500 toIndex:600]);
//	
//	msgOne = [inbox messageWithUID:@"1146070022-553"];
//	NSLog(@"%@ %@", [msgOne flags], [msgOne subject]);
//	NSMutableDictionary *flags = [[msgOne flags] mutableCopy];
//	[flags setObject:CTFlagSet forKey:CTFlagSeen];
//	[msgOne setFlags:flags];
    //[inbox disconnect];
    //	[inbox expunge];

    /*
    NSSet *messageList = [inbox messageListFromIndex:nil];
    NSLog(@"Message List....");
    NSLog(@"%@",messageList);
    NSEnumerator *enumerator = [messageList objectEnumerator];
    id obj;
    CTCoreMessage *tempMsg;
    while(obj = [enumerator nextObject])
    {
        tempMsg = [inbox messageWithUID:obj];
        NSLog(@"%@",[tempMsg subject]);
    }

    NSSet *archiveMessageList;
    archive = [account folderWithPath:@"INBOX.TheArchive"];
    archiveMessageList = [archive messageListFromIndex:nil];
    NSEnumerator *objEnum = [archiveMessageList objectEnumerator];
    id aMessage;

    NSLog(@"INBOX.TheArchive");
    NSLog(@"%@",archiveMessageList);
    while(aMessage = [objEnum nextObject])
    {
        tempMsg = [archive messageWithUID:aMessage];
        NSLog(@"%@",[tempMsg subject]);
        NSLog(@"%@",[tempMsg from]);
        NSLog(@"%@",[tempMsg to]);
    }

    msgOne =[inbox messageWithUID:@"1142229815-9"];
    [msgOne setBody:@"Muhahahaha. Libetpan!"];
    [msgOne setSubject:@"Hahaha"];
    [msgOne setTo:[NSSet setWithObject:[CTCoreAddress addressWithName:@"Bob" email:@"mronge2@uiuc.edu"]]];
    [msgOne setFrom:[NSSet setWithObject:[CTCoreAddress addressWithName:@"Matt" email:@"mronge@theronge.com"]]];
    */

    //CTCoreAddress *addr = [CTCoreAddress address];
    //[addr setEmail:@"Test"];
    //[addr setEmail:@"Test2"];

    /* GMAIL Test */

//	MailCoreEnableLogging();

    CTCoreMessage *msgOne = [[CTCoreMessage alloc] init];
    [msgOne setTo:[NSSet setWithObject:[CTCoreAddress addressWithName:@"Bob" email:@"mronge@theronge.com"]]];
    [msgOne setFrom:[NSSet setWithObject:[CTCoreAddress addressWithName:@"test" email:@"test@test.com"]]];
    //[msgOne setBody:@"Test"];
    CTMIME_TextPart *text = [CTMIME_TextPart mimeTextPartWithString:@"Hell this is a mime test"];
    CTMIME_SinglePart *part = [CTMIME_SinglePart mimeSinglePartWithData:[NSData dataWithContentsOfFile:@"/tmp/DSC_6201.jpg"]];
    part.contentType = @"image/jpeg";
    CTMIME_MultiPart *multi = [CTMIME_MultiPart mimeMultiPart];
    [multi addMIMEPart:text];
    [multi addMIMEPart:part];
    CTMIME_MessagePart *messagePart = [CTMIME_MessagePart mimeMessagePartWithContent:multi];
    [msgOne setSubject:@"MIME Test"];
    msgOne.mime = messagePart;
    [CTSMTPConnection sendMessage:msgOne server:@"mail.theronge.com" username:@"mronge" password:@"" port:25 useTLS:YES useAuth:YES];
    [msgOne release];

    //[CTSMTPConnection sendMessage:msgOne server:@"mail.dls.net" username:@"" password:@"" port:25 useTLS:NO shouldAuth:NO];
    //[archive disconnect];
    //[account disconnect];
    //[account release];

    [pool release];

    //while(1) {}
    return 0;
}
